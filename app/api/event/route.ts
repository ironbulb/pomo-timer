import { Client } from '@notionhq/client';
import { google } from 'googleapis';
import { NextRequest, NextResponse } from 'next/server';

export async function GET() {
  try {
    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const databaseId = process.env.NOTION_DATABASE_ID!;
    const now = new Date();

    let nearestTask: { title: string; start: Date; source: 'notion' | 'gcal' } | null = null;
    let currentEvent: { id: string; title: string; duration: number; source: 'notion' | 'gcal' } | null = null;


    // Get all pages from database
    const response = await notion.databases.query({
      database_id: databaseId,
      sorts: [
        {
          property: 'Timer',
          direction: 'ascending',
        },
      ],
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

      // While we're iterating, find the nearest future task
      if (startDate > now) {
        const titleProperty = page.properties['Task '];
        if (titleProperty && titleProperty.type === 'title' && Array.isArray(titleProperty.title) && titleProperty.title.length > 0) {
          const title = titleProperty.title[0].plain_text;
          if (!nearestTask || startDate < nearestTask.start) {
            nearestTask = {
              title: title,
              start: startDate,
            };
          }
        }
      }

      // Find the first event that is currently active
      if (isCurrent) {
        const titleProperty = page.properties['Task '];
        let title = 'Untitled';

        if (titleProperty && titleProperty.type === 'title' && Array.isArray(titleProperty.title) && titleProperty.title.length > 0) {
          title = titleProperty.title[0].plain_text;
        }

        // Calculate remaining duration from now
        const remainingDuration = Math.floor((endDate.getTime() - now.getTime()) / 1000);

        if (!currentEvent || startDate < new Date(currentEvent.id)) {
          currentEvent = {
            id: page.id,
            title,
            duration: Math.max(1, remainingDuration),
            source: 'notion'
          };
        }
      }
    }

    // Fetch Google Calendar events if configured
    if (process.env.GOOGLE_CLIENT_EMAIL && process.env.GOOGLE_PRIVATE_KEY) {
      try {
        const auth = new google.auth.GoogleAuth({
          credentials: {
            client_email: process.env.GOOGLE_CLIENT_EMAIL,
            private_key: process.env.GOOGLE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
          },
          scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
        });

        const calendar = google.calendar({ version: 'v3', auth });

        const gcalResponse = await calendar.events.list({
          calendarId: process.env.GOOGLE_CALENDAR_ID || 'primary',
          timeMin: new Date(now.getTime() - 60 * 60 * 1000).toISOString(), // 1 hour ago
          timeMax: new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString(), // 24 hours from now
          maxResults: 50,
          singleEvents: true,
          orderBy: 'startTime',
        });

        const gcalEvents = gcalResponse.data.items || [];

        for (const event of gcalEvents) {
          if (!event.start?.dateTime || !event.end?.dateTime) continue;

          const startDate = new Date(event.start.dateTime);
          const endDate = new Date(event.end.dateTime);
          const isCurrent = now >= startDate && now < endDate;

          // Track nearest future event
          if (startDate > now) {
            if (!nearestTask || startDate < nearestTask.start) {
              nearestTask = {
                title: event.summary || 'Untitled Event',
                start: startDate,
                source: 'gcal'
              };
            }
          }

          // Track current event
          if (isCurrent) {
            const remainingDuration = Math.floor((endDate.getTime() - now.getTime()) / 1000);

            // Prefer the earlier event if there are overlaps
            if (!currentEvent || startDate.getTime() < Number(currentEvent.id)) {
              currentEvent = {
                id: event.id || startDate.toISOString(),
                title: `📅 ${event.summary || 'Untitled Event'}`,
                duration: Math.max(1, remainingDuration),
                source: 'gcal'
              };
            }
          }
        }
      } catch (gcalError) {
        console.error('Error fetching Google Calendar events:', gcalError);
        // Continue without calendar events if there's an error
      }
    }

    // Return current event if found
    if (currentEvent) {
      return NextResponse.json({
        id: currentEvent.id,
        title: currentEvent.title,
        duration: currentEvent.duration
      });
    }

    // Return nearest future task if found
    if (nearestTask) {
      const prefix = nearestTask.source === 'gcal' ? '📅 ' : '';
      return NextResponse.json({ id: null, title: `The next task is: ${prefix}${nearestTask.title}` });
    }

    return NextResponse.json({ id: null, title: 'No active events scheduled.' });
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

    // Map our status names to Notion's default status names
    const statusMapping: { [key: string]: string } = {
      'Completed': 'Done',
      'Not Started': 'Not started',
      'In Progress': 'In progress',
    };

    const notionStatus = statusMapping[newStatus] || newStatus;

    // Normalize page ID (remove dashes if present, Notion accepts both formats)
    const normalizedPageId = pageId.replace(/-/g, '');

    console.log('Updating page:', normalizedPageId, 'from status:', newStatus, 'to Notion status:', notionStatus);

    // Update the Status property
    await notion.pages.update({
      page_id: normalizedPageId,
      properties: {
        'Status': {
          status: {
            name: notionStatus,
          },
        },
      },
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error updating event:', error);
    console.error('Error details:', error.message, error.body);
    return NextResponse.json({
      error: 'Failed to update event',
      details: error.message
    }, { status: 500 });
  }
}
