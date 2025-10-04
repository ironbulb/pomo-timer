import { Client } from '@notionhq/client';
import { NextRequest, NextResponse } from 'next/server';

export async function GET() {
  try {
    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const databaseId = process.env.NOTION_DATABASE_ID!;
    const now = new Date();

    // Get all pages without filter - we'll filter in the loop
    const response = await notion.databases.query({
      database_id: databaseId,
    });

    console.log('=== NOTION RESPONSE ===');
    console.log('Number of results:', response.results.length);
    console.log('First page properties:', JSON.stringify(
      response.results[0] && 'properties' in response.results[0]
        ? response.results[0].properties
        : 'No properties',
      null,
      2
    ));
    console.log('======================');

    // Post-query filtering to find first event that is currently active
    for (const page of response.results) {
      if (!('properties' in page)) continue;

      const dateProperty = page.properties['Timer'];
      if (dateProperty.type !== 'date' || !dateProperty.date) continue;

      const startTime = dateProperty.date.start;
      const endTime = dateProperty.date.end;

      if (!startTime || !endTime) continue;

      const startDate = new Date(startTime);
      const endDate = new Date(endTime);

      // Check if current time is within the event's time range
      if (startDate <= now && endDate > now) {
        // This event is currently active
        const titleProperty = page.properties['Task '];
        let title = 'Untitled';

        if (titleProperty.type === 'title' && Array.isArray(titleProperty.title) && titleProperty.title.length > 0) {
          title = titleProperty.title[0].plain_text;
        }

        const durationInSeconds = Math.floor((endDate.getTime() - startDate.getTime()) / 1000);

        return NextResponse.json({ id: page.id, title, duration: durationInSeconds });
      }
    }

    // No active event found
    return NextResponse.json({ id: null });
  } catch (error) {
    console.error('Error fetching event:', error);
    return NextResponse.json({ error: 'Failed to fetch event' }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const body = await request.json();
    const { pageId, newStatus } = body;

    if (!pageId || typeof pageId !== 'string') {
      return NextResponse.json({ error: 'Invalid pageId' }, { status: 400 });
    }

    if (newStatus !== 'In Progress' && newStatus !== 'Completed') {
      return NextResponse.json({ error: 'Invalid status. Must be "In Progress" or "Completed"' }, { status: 400 });
    }

    await notion.pages.update({
      page_id: pageId,
      properties: {
        'Timer': {
          select: {
            name: newStatus,
          },
        },
      },
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error updating event:', error);
    return NextResponse.json({ error: 'Failed to update event' }, { status: 500 });
  }
}
