import { Client } from '@notionhq/client';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const notion = new Client({ auth: process.env.NOTION_API_KEY });
    const databaseId = process.env.NOTION_DATABASE_ID!;

    // Retrieve database to get schema
    const database = await notion.databases.retrieve({ database_id: databaseId });

    // Extract select options from properties
    const properties = database.properties;

    // Get Project options
    let projectOptions: string[] = [];
    if (properties['Project'] && properties['Project'].type === 'select' && 'select' in properties['Project']) {
      projectOptions = properties['Project'].select.options.map((opt: any) => opt.name);
    }

    // Get Area options
    let areaOptions: string[] = [];
    if (properties['Area'] && properties['Area'].type === 'select' && 'select' in properties['Area']) {
      areaOptions = properties['Area'].select.options.map((opt: any) => opt.name);
    }

    // Get Priority options
    let priorityOptions: string[] = [];
    if (properties['Priority'] && properties['Priority'].type === 'select' && 'select' in properties['Priority']) {
      priorityOptions = properties['Priority'].select.options.map((opt: any) => opt.name);
    }

    // Get Status options and map to our names
    let statusOptions: string[] = [];
    if (properties['Status'] && properties['Status'].type === 'status' && 'status' in properties['Status']) {
      const notionStatuses = properties['Status'].status.options.map((opt: any) => opt.name);
      // Map Notion's status names to our names
      const statusMap: { [key: string]: string } = {
        'Done': 'Completed',
        'Not started': 'Not Started',
        'In progress': 'In Progress',
      };
      statusOptions = notionStatuses.map((status: string) => statusMap[status] || status);
    }

    return NextResponse.json({
      projects: projectOptions,
      areas: areaOptions,
      priorities: priorityOptions,
      statuses: statusOptions,
    });
  } catch (error) {
    console.error('Error fetching schema:', error);
    return NextResponse.json({ error: 'Failed to fetch schema' }, { status: 500 });
  }
}
