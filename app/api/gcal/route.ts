import { google } from 'googleapis';
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const timeMin = searchParams.get('timeMin'); // Start date (ISO format)
    const timeMax = searchParams.get('timeMax'); // End date (ISO format)

    // Initialize Google Calendar API
    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: process.env.GOOGLE_CLIENT_EMAIL,
        private_key: process.env.GOOGLE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      },
      scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
    });

    const calendar = google.calendar({ version: 'v3', auth });

    // Fetch events from calendar
    const response = await calendar.events.list({
      calendarId: process.env.GOOGLE_CALENDAR_ID || 'primary',
      timeMin: timeMin || new Date().toISOString(),
      timeMax: timeMax || undefined,
      maxResults: 100,
      singleEvents: true,
      orderBy: 'startTime',
    });

    const events = response.data.items?.map((event: any) => ({
      id: event.id,
      title: event.summary || 'Untitled Event',
      start: event.start?.dateTime || event.start?.date,
      end: event.end?.dateTime || event.end?.date,
      description: event.description,
      location: event.location,
      isAllDay: !event.start?.dateTime, // If no dateTime, it's an all-day event
    })) || [];

    return NextResponse.json({ events });
  } catch (error: any) {
    console.error('Error fetching Google Calendar events:', error);
    return NextResponse.json(
      { error: 'Failed to fetch calendar events', details: error.message },
      { status: 500 }
    );
  }
}
