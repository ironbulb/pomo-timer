const { Client } = require('@notionhq/client');
require('dotenv').config({ path: '.env.local' });

async function testAPI() {
  console.log('Testing Notion API connection...\n');

  const apiKey = process.env.NOTION_API_KEY;
  const databaseId = process.env.NOTION_DATABASE_ID;

  console.log('API Key present:', !!apiKey);
  console.log('Database ID:', databaseId);
  console.log('');

  if (!apiKey || !databaseId) {
    console.error('ERROR: Missing environment variables!');
    return;
  }

  try {
    const notion = new Client({ auth: apiKey });

    console.log('Querying Notion database...');
    const response = await notion.databases.query({
      database_id: databaseId,
    });

    console.log(`Found ${response.results.length} total pages\n`);

    // Check each page
    for (let i = 0; i < response.results.length; i++) {
      const page = response.results[i];
      if (!('properties' in page)) continue;

      console.log(`--- Page ${i + 1} ---`);

      const timerProp = page.properties['Timer'];
      const taskProp = page.properties['Task '];

      console.log('Timer property:', timerProp?.type);
      console.log('Timer value:', timerProp?.type === 'date' ? timerProp.date : 'N/A');

      if (taskProp?.type === 'title' && Array.isArray(taskProp.title) && taskProp.title.length > 0) {
        console.log('Task name:', taskProp.title[0].plain_text);
      } else {
        console.log('Task name: (empty)');
      }

      if (timerProp?.type === 'date' && timerProp.date) {
        const { start, end } = timerProp.date;
        if (start && end) {
          const startDate = new Date(start);
          const endDate = new Date(end);
          const duration = Math.floor((endDate.getTime() - startDate.getTime()) / 1000);

          console.log('Start:', startDate.toISOString());
          console.log('End:', endDate.toISOString());
          console.log('Duration:', Math.floor(duration / 60), 'minutes');
          console.log('✅ This event would be returned by the API');
        } else {
          console.log('❌ Missing start or end time');
        }
      } else {
        console.log('❌ No Timer property or empty');
      }
      console.log('');
    }

    console.log('\n✅ API test complete!');
  } catch (error) {
    console.error('❌ ERROR:', error.message);
    if (error.code) {
      console.error('Error code:', error.code);
    }
  }
}

testAPI();
