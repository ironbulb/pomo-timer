import { Client } from '@notionhq/client';
import { NextRequest, NextResponse } from 'next/server';

export async function GET() {
  try {
    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const databaseId = process.env.NOTION_DATABASE_ID!;
    const now = new Date();

    // Get all pages from database
    const response = await notion.databases.query({
      database_id: databaseId,
    });

    // Find first event with Timer set (ignore timezone, just get the duration)
    for (const page of response.results) {
      if (!('properties' in page)) continue;

      const dateProperty = page.properties['Timer'];
      if (!dateProperty || dateProperty.type !== 'date' || !dateProperty.date) continue;

      const { start, end } = dateProperty.date;
      if (!start || !end) continue;

      const startDate = new Date(start);
      const endDate = new Date(end);
      const isCurrent = now >= startDate && now < endDate;

      // Find the first event that is currently active
      if (isCurrent) {
        const titleProperty = page.properties['Task '];
        let title = 'Untitled';

        if (titleProperty && titleProperty.type === 'title' && Array.isArray(titleProperty.title) && titleProperty.title.length > 0) {
          title = titleProperty.title[0].plain_text;
        }

        // Calculate remaining duration from now
        const remainingDuration = Math.floor((endDate.getTime() - now.getTime()) / 1000);

        return NextResponse.json({
          id: page.id,
          title,
          // Return remaining duration, or 1 if it's less than 1
          duration: Math.max(1, remainingDuration)
        });
      }
    }

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
      return NextResponse.json({ error: 'Invalid status' }, { status: 400 });
    }

    // Try to update Status property (it's a status type property)
    await notion.pages.update({
      page_id: pageId,
      properties: {
        'Status': {
          status: {
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
