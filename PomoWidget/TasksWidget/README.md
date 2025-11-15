# Tasks Widget - Notion Task List Display

A companion widget to the Pomodoro Timer that displays your Notion tasks with filtering capabilities.

## Features

- **Transparent frosted glass design** - Matches the timer widget
- **Priority filtering** - Filter by P1, P2, P3, or view all
- **Live updates** - Auto-refreshes every 2 minutes
- **Resizable window** - Adjust size to fit your needs
- **Floating window** - Always accessible, stays on top
- **Smart layout** - Shows priority, status, project, and time info

## Setup Instructions

### 1. Deploy the API Endpoint

The `/api/tasks` endpoint has been created in your Next.js project. Deploy to Vercel:

```bash
cd /Users/roitaitou/Alain/pomo
git add app/api/tasks/route.ts
git commit -m "Add tasks API endpoint"
git push
```

Vercel will automatically deploy the new endpoint.

### 2. Create Xcode Project for Tasks Widget

1. Open Xcode
2. Create a new macOS App project named "TasksWidget"
3. Save it in `/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget`

### 3. Add Files to Project

Copy these files to your Xcode project:
- `TasksWidgetApp.swift` - App entry point
- `TasksContentView.swift` - UI with task list and filters
- `TasksViewModel.swift` - Data model and API client
- `Info.plist` - Configuration

### 4. Configure Project

In Xcode:
1. Add **App Sandbox** capability
2. Enable **Outgoing Connections (Client)** under Network
3. Build and run (⌘+R)

## Usage

### Filter Tasks

Click the filter buttons at the top:
- **All** - Show all tasks
- **P1** - High priority only (red)
- **P2** - Medium priority (orange)
- **P3** - Low priority (yellow)

### Task Information

Each task shows:
- **Priority dot** - Color-coded priority indicator
- **Task title** - Name of the task
- **Status badge** - Current status (Not Started, In Progress, Completed)
- **Project badge** - Project name (if assigned)
- **Time** - Scheduled time (if timer is set)

### Window Position

- Default: **Top-left corner**
- Timer widget: **Top-right corner**
- Both widgets work together perfectly!

## Customization

### Change Refresh Interval

Edit `TasksViewModel.swift`:
```swift
refreshTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true)
// Change 120.0 to desired seconds
```

### Adjust Transparency

Edit `TasksContentView.swift`:
```swift
.opacity(0.85)
// Lower = more transparent (0.0 - 1.0)
```

### Window Size

Default: 400x500 pixels
Min: 300x200
Max: 800x1000

Change in `TasksWidgetApp.swift`

## Notion Database Requirements

Your Notion database should have these properties:
- **Task ** (title) - Task name
- **Priority** (select) - Values: "1", "2", "3"
- **Status** (status) - Values: "Not Started", "In Progress", "Completed"
- **Timer** (date) - Optional start/end time
- **Project** (select) - Optional project categorization

## Notes

- Widget appears in top-left corner by default
- Auto-refreshes every 2 minutes
- Minimal CPU/battery usage
- Works alongside the timer widget
- No modifications to existing code required
