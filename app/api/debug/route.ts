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

      let isActive = false;
      let reason = 'Unknown';

      if (!timerProp || timerProp.type !== 'date') {
        reason = 'No Timer property or wrong type';
      } else if (!timerProp.date) {
        reason = 'Timer property has no date value';
      } else if (!timerProp.date.start || !timerProp.date.end) {
        reason = 'Missing start or end time';
      } else {
        const start = new Date(timerProp.date.start);
        const end = new Date(timerProp.date.end);
        const beforeStart = now < start;
        const afterEnd = now >= end;

        if (beforeStart) {
          reason = `Event hasn't started yet (starts ${start.toISOString()})`;
        } else if (afterEnd) {
          reason = `Event already ended (ended ${end.toISOString()})`;
        } else {
          isActive = true;
          reason = 'Active!';
        }
      }

      return {
        id: page.id,
        timer: timerProp?.type === 'date' ? timerProp.date : null,
        task: taskProp?.type === 'title' && Array.isArray(taskProp.title) && taskProp.title.length > 0 ? taskProp.title[0].plain_text : 'No title',
        isActive,
        reason,
      };
    }).filter(Boolean);

    return NextResponse.json({
      success: true,
      serverTime: now.toISOString(),
      serverTimeLocal: now.toString(),
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
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
