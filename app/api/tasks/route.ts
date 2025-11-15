import { Client } from '@notionhq/client';
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  try {
    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const databaseId = process.env.NOTION_DATABASE_ID!;

    // Get URL params for filtering
    const { searchParams } = new URL(request.url);
    const priorityFilter = searchParams.get('priority'); // e.g., "1", "2", "3"
    const statusFilter = searchParams.get('status'); // e.g., "Not Started", "In Progress"

    // Build filters
    const filters: any[] = [];

    if (priorityFilter) {
      filters.push({
        property: 'Priority',
        select: {
          equals: priorityFilter,
        },
      });
    }

    if (statusFilter) {
      filters.push({
        property: 'Status',
        status: {
          equals: statusFilter,
        },
      });
    }

    // Query database
    const response = await notion.databases.query({
      database_id: databaseId,
      filter: filters.length > 0 ? {
        and: filters,
      } : undefined,
      sorts: [
        {
          property: 'Priority',
          direction: 'ascending',
        },
        {
          property: 'Timer',
          direction: 'ascending',
        },
      ],
    });

    // Parse results
    const tasks = response.results.map((page: any) => {
      if (!('properties' in page)) return null;

      const props = page.properties;

      // Extract Task title
      let title = 'Untitled';
      if (props['Task '] && props['Task '].type === 'title' && props['Task '].title.length > 0) {
        title = props['Task '].title[0].plain_text;
      }

      // Extract Priority
      let priority = null;
      if (props['Priority'] && props['Priority'].type === 'select' && props['Priority'].select) {
        priority = props['Priority'].select.name;
      }

      // Extract Status
      let status = 'Not Started';
      if (props['Status'] && props['Status'].type === 'status' && props['Status'].status) {
        status = props['Status'].status.name;
      }

      // Extract Timer dates
      let timerStart = null;
      let timerEnd = null;
      if (props['Timer'] && props['Timer'].type === 'date' && props['Timer'].date) {
        timerStart = props['Timer'].date.start;
        timerEnd = props['Timer'].date.end;
      }

      // Extract Project (if exists)
      let project = null;
      if (props['Project'] && props['Project'].type === 'select' && props['Project'].select) {
        project = props['Project'].select.name;
      }

      return {
        id: page.id,
        title,
        priority,
        status,
        timerStart,
        timerEnd,
        project,
      };
    }).filter(task => task !== null);

    return NextResponse.json({ tasks });
  } catch (error) {
    console.error('Error fetching tasks:', error);
    return NextResponse.json({ error: 'Failed to fetch tasks' }, { status: 500 });
  }
}
