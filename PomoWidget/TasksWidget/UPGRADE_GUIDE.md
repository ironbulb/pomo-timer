# TasksWidget Upgrade Guide

## What's New

Your TasksWidget now supports:

✅ **Custom Filter Options** - No longer limited to P1/P2/P3!
✅ **Task Creation** - Add tasks directly from the widget
✅ **Complex Filters** - Combine Status + Project (e.g., "In Progress AND ICI")
✅ **App Sandbox** - Proper network permissions configured

## Setup Steps

### 1. Add Entitlements File to Xcode

1. Open your Xcode project
2. Right-click on the project navigator
3. Select **Add Files to "TasksWidget"**
4. Navigate to `/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget/`
5. Select **TasksWidget.entitlements**
6. Make sure "Add to targets" has TasksWidget checked
7. Click **Add**

### 2. Configure Project to Use Entitlements

1. Select your project in the navigator
2. Go to **Signing & Capabilities** tab
3. You should see "App Sandbox" is now enabled
4. Verify these are checked:
   - ✅ Outgoing Connections (Client)
   - ✅ Incoming Connections (Server)

### 3. Add New Enhanced View to Xcode

1. In Xcode, right-click on the project
2. Select **Add Files to "TasksWidget"**
3. Navigate to `/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget/`
4. Select **TasksContentViewEnhanced.swift**
5. Make sure "Add to targets" has TasksWidget checked
6. Click **Add**

### 4. Deploy API Updates

The API has been enhanced to support project filtering and task creation:

```bash
cd /Users/roitaitou/Alain/pomo
git add app/api/tasks/route.ts
git commit -m "Add project filtering and task creation to API"
git push
```

Vercel will auto-deploy. Wait ~1 minute for deployment.

### 5. Choose Your Filter Mode

Edit [TasksWidgetApp.swift:53](TasksWidgetApp.swift#L53) to choose your preferred filter mode:

**Option 1: Priority Filters (P1, P2, P3)**
```swift
let contentView = NSHostingView(rootView: TasksContentView())
```

**Option 2: Status Filters (Not Started, In Progress, Completed)**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .status))
```

**Option 3: Project Filters (ICI, Work, Personal)**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .project))
```

**Option 4: Combined Filters** ⭐ *Recommended*
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .combined))
```
This shows both Status AND Project filters, letting you do complex combinations like "In Progress + ICI"

**Option 5: Fixed Filter (Pre-configured)**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(
    filterMode: .combined,
    status: "In Progress",
    project: "ICI"
))
```
This creates a widget that ONLY shows "In Progress AND ICI" tasks

### 6. Build and Run

1. Press **⌘R** or click the Run button
2. The widget should now:
   - Successfully fetch tasks (no network error!)
   - Show your chosen filter options
   - Have a **+** button in the top-right corner

## Features

### ➕ Creating Tasks

1. Click the **+** button in the top-right corner
2. Enter task title
3. Optionally select:
   - Priority (P1, P2, P3)
   - Project (ICI, Work, Personal)
4. Click **Create**
5. Task appears in Notion and refreshes in widget

### 🎯 Filter Modes Explained

**Priority Mode** - Filter by urgency
- All, P1, P2, P3

**Status Mode** - Filter by completion state
- All, Not Started, In Progress, Completed

**Project Mode** - Filter by project
- All, ICI, Work, Personal

**Combined Mode** - Mix and match!
- Status: In Progress / Not Started
- Project: ICI / Work / Personal
- Clear button to reset all filters

### 🔧 Customizing Projects

To add your own projects, edit [TasksContentViewEnhanced.swift:159](TasksContentViewEnhanced.swift#L159):

```swift
ForEach(["ICI", "Work", "Personal", "YourProject"], id: \.self) { project in
```

Also update the add task sheet at line 381:

```swift
ForEach(["ICI", "Work", "Personal", "YourProject"], id: \.self) { project in
```

## Examples

### Example 1: Show only "In Progress" tasks from "ICI" project

Set filterMode to `.combined`, then in the widget:
1. Click "In Progress" button
2. Click "ICI" button
3. Widget now shows only tasks matching BOTH filters

### Example 2: Dedicated widget for urgent ICI tasks

Use Option 5 in TasksWidgetApp.swift:
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(
    filterMode: .combined,
    status: "In Progress",
    project: "ICI"
))
```

### Example 3: Quick task creation

1. Click **+** button
2. Type: "Review PRs"
3. Select: P1, Work
4. Click Create
5. Task instantly appears in Notion with:
   - Task: "Review PRs"
   - Priority: 1
   - Project: Work
   - Status: Not Started (default)

## Troubleshooting

### Network Error Still Appears

1. Verify entitlements file is added to project
2. Check Signing & Capabilities shows App Sandbox
3. Clean build folder: **⌘+Shift+K**
4. Rebuild: **⌘+B**

### API Not Working

1. Check Vercel deployment succeeded:
   ```bash
   curl https://pomo-timer-eta.vercel.app/api/tasks
   ```

2. Test task creation:
   ```bash
   curl -X POST https://pomo-timer-eta.vercel.app/api/tasks \
     -H "Content-Type: application/json" \
     -d '{"title": "Test Task", "priority": "1", "project": "ICI"}'
   ```

### Tasks Not Showing

1. Verify your Notion database has:
   - `Task ` (title property)
   - `Priority` (select: "1", "2", "3")
   - `Status` (status: "Not Started", "In Progress", "Completed")
   - `Project` (select: "ICI", "Work", "Personal", etc.)

2. Check filters match your database values exactly (case-sensitive!)

### Build Errors

Make sure all files are added to target:
- ✅ TasksWidgetApp.swift
- ✅ TasksContentView.swift (original)
- ✅ TasksContentViewEnhanced.swift (new)
- ✅ TasksViewModel.swift
- ✅ VisualEffectView.swift
- ✅ TasksWidget.entitlements

## Next Steps

1. ✅ Add entitlements file to Xcode
2. ✅ Add TasksContentViewEnhanced.swift to Xcode
3. ✅ Deploy API updates to Vercel
4. ✅ Choose your filter mode
5. ✅ Build and test!
6. 🎨 Customize projects to match your workflow
7. 🚀 Consider creating multiple widget instances with different filters

Enjoy your enhanced TasksWidget! 🎉
