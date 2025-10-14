const { Client } = require('@notionhq/client');
require('dotenv').config({ path: '.env.local' });

async function searchTask() {
  const notion = new Client({ auth: process.env.NOTION_API_KEY });
  const response = await notion.databases.query({
    database_id: process.env.NOTION_DATABASE_ID,
  });

  console.log(`Searching for "pomotry" in ${response.results.length} tasks...\n`);

  for (let i = 0; i < response.results.length; i++) {
    const page = response.results[i];
    if (!('properties' in page)) continue;

    const taskProp = page.properties['Task '];
    if (taskProp?.type === 'title' && Array.isArray(taskProp.title) && taskProp.title.length > 0) {
      const taskName = taskProp.title[0].plain_text.toLowerCase();

      if (taskName.includes('pomotry') || taskName.includes('test')) {
        console.log(`\n✅ FOUND: "${taskProp.title[0].plain_text}"`);
        console.log('Page ID:', page.id);

        const timerProp = page.properties['Timer'];
        console.log('Timer value:', timerProp?.date || 'null');

        const statusProp = page.properties['Status'];
        console.log('Status:', statusProp?.status?.name || 'N/A');

        console.log('\nAll properties:');
        for (const [name, prop] of Object.entries(page.properties)) {
          if (prop.type === 'date') {
            console.log(`  ${name}:`, prop.date);
          } else if (prop.type === 'status') {
            console.log(`  ${name}:`, prop.status?.name);
          }
        }
      }
    }
  }
}

searchTask();
