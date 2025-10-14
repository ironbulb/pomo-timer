const { Client } = require('@notionhq/client');
require('dotenv').config({ path: '.env.local' });

async function showProperties() {
  const notion = new Client({ auth: process.env.NOTION_API_KEY });
  const response = await notion.databases.query({
    database_id: process.env.NOTION_DATABASE_ID,
  });

  console.log(`Showing first 5 pages with ALL properties:\n`);

  for (let i = 0; i < Math.min(5, response.results.length); i++) {
    const page = response.results[i];
    if (!('properties' in page)) continue;

    console.log(`\n======= PAGE ${i + 1} =======`);

    for (const [name, prop] of Object.entries(page.properties)) {
      console.log(`\nProperty: "${name}"`);
      console.log(`  Type: ${prop.type}`);

      if (prop.type === 'title' && Array.isArray(prop.title)) {
        const text = prop.title.length > 0 ? prop.title[0].plain_text : '(empty)';
        console.log(`  Value: ${text}`);
      } else if (prop.type === 'date') {
        console.log(`  Value:`, prop.date);
      } else if (prop.type === 'select') {
        console.log(`  Value:`, prop.select?.name || '(empty)');
      } else if (prop.type === 'status') {
        console.log(`  Value:`, prop.status?.name || '(empty)');
      } else {
        console.log(`  Value:`, JSON.stringify(prop[prop.type]).substring(0, 100));
      }
    }
  }
}

showProperties();
