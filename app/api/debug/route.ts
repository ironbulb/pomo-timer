import { Client } from '@notionhq/client';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const hasApiKey = !!process.env.NOTION_API_KEY;
    const hasDatabaseId = !!process.env.NOTION_DATABASE_ID;

    if (!hasApiKey || !hasDatabaseId) {
      return NextResponse.json({
        error: 'Missing environment variables',
        hasApiKey,
        hasDatabaseId,
      });
    }

    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const databaseId = process.env.NOTION_DATABASE_ID!;
    const now = new Date();

    const response = await notion.databases.query({
      database_id: databaseId,
    });

    const results = response.results.map((page) => {
      if (!('properties' in page)) return null;

      const timerProp = page.properties['Timer'];
      const taskProp = page.properties['Task '];

      return {
        id: page.id,
        timer: timerProp?.type === 'date' ? timerProp.date : null,
        task: taskProp?.type === 'title' ? taskProp.title : null,
      };
    }).filter(Boolean);

    return NextResponse.json({
      success: true,
      currentTime: now.toISOString(),
      totalResults: response.results.length,
      results,
    });
  } catch (error: any) {
    return NextResponse.json({
      error: error.message,
      code: error.code,
    }, { status: 500 });
  }
}
