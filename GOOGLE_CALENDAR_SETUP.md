# Google Calendar Integration Setup

## Overview
This guide will help you integrate your Google Calendar events into the TasksWidget alongside your Notion tasks.

## Prerequisites
- Google Cloud Platform account
- Google Calendar with events

## Step-by-Step Setup

### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google Calendar API**:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Calendar API"
   - Click "Enable"

### 2. Create a Service Account

1. Navigate to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Fill in the service account details:
   - Name: `tasks-widget-calendar`
   - Description: "Service account for TasksWidget calendar integration"
4. Click "Create and Continue"
5. Skip the optional steps and click "Done"

### 3. Generate Service Account Key

1. Click on the service account you just created
2. Go to the "Keys" tab
3. Click "Add Key" > "Create new key"
4. Choose "JSON" format
5. Click "Create" - a JSON file will download

### 4. Share Calendar with Service Account

1. Open [Google Calendar](https://calendar.google.com/)
2. Find the calendar you want to integrate (or use your primary calendar)
3. Click the three dots next to the calendar name > "Settings and sharing"
4. Scroll to "Share with specific people"
5. Click "Add people"
6. Add the service account email (found in the JSON file as `client_email`)
   - Example: `tasks-widget-calendar@your-project.iam.gserviceaccount.com`
7. Set permission to "See all event details"
8. Click "Send"

### 5. Configure Environment Variables

1. Open the downloaded JSON key file
2. Copy the `.env.local.example` to `.env.local`:
   ```bash
   cp .env.local.example .env.local
   ```
3. Update `.env.local` with values from the JSON file:
   ```env
   GOOGLE_CLIENT_EMAIL=value_from_client_email_field
   GOOGLE_PRIVATE_KEY="value_from_private_key_field"
   GOOGLE_CALENDAR_ID=your-calendar-id@gmail.com
   ```

**Important**: The `GOOGLE_PRIVATE_KEY` must include the quotes and `\n` characters as-is from the JSON file.

### 6. Find Your Calendar ID

1. Go to [Google Calendar Settings](https://calendar.google.com/calendar/u/0/r/settings)
2. Click on the calendar you shared with the service account
3. Scroll down to "Integrate calendar"
4. Copy the "Calendar ID"
   - For your primary calendar, you can use `"primary"` as the ID
   - Otherwise, it will look like: `abc123@group.calendar.google.com`

### 7. Deploy to Vercel

```bash
git add .
git commit -m "Add Google Calendar integration"
git push
```

Vercel will automatically deploy. Then add the environment variables in Vercel:

1. Go to your project on Vercel
2. Navigate to "Settings" > "Environment Variables"
3. Add the three Google Calendar variables:
   - `GOOGLE_CLIENT_EMAIL`
   - `GOOGLE_PRIVATE_KEY`
   - `GOOGLE_CALENDAR_ID`

### 8. Test the Integration

1. Build and run the TasksWidget in Xcode
2. Create a new filter pane with Timer set to "Today"
3. You should see your Google Calendar events appear above your tasks!

## How It Works

- **Calendar events are fetched** when you create a pane with a Timer filter (Today, This Week, etc.)
- **Events appear at the top** of the task list with a blue calendar icon
- **Events show**: Title, time range, and location (if available)
- **Events update** automatically with your tasks

## Example Filter Panes

### Daily Pane
- Name: "Daily"
- Timer: **Today**
- Shows: Today's calendar events + today's tasks

### This Week
- Name: "This Week"
- Timer: **This Week**
- Shows: This week's calendar events + this week's tasks

### PhD Work Today
- Name: "PhD Today"
- Timer: **Today**
- Area: PhD
- Status: In Progress
- Shows: Today's calendar events + uncompleted PhD tasks

## Troubleshooting

### No events showing
1. Check that the service account email has access to the calendar
2. Verify environment variables are set correctly in `.env.local` and Vercel
3. Check the browser console or Vercel logs for errors

### "Failed to fetch calendar events"
1. Ensure Google Calendar API is enabled
2. Verify the private key is correctly formatted with `\n` characters
3. Check that the calendar ID is correct

### Events not updating
- Calendar events refresh when you switch panes or reload the widget
- Auto-refresh updates tasks, but you may need to manually refresh for calendar events

## Security Notes

- Never commit `.env.local` to git (it's in .gitignore)
- Keep your service account JSON file secure
- The service account only has read-only access to your calendar
