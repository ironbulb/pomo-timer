# Pomo Hub - Widget Manager

A single menu bar app that manages all your Pomo widgets with auto-launch on macOS startup.

## Features

✨ **Menu Bar App** - Clean interface with menu bar icon
🚀 **Auto-launches on startup** - All widgets appear when you boot your Mac
📍 **Multiple widgets** - Timer + Task lists with different filters
✅ **Clickable checkboxes** - Complete tasks directly from widgets
🎯 **Pre-configured filters** - P1, P2, P3, or All tasks
⚙️ **Easy control** - Show/hide widgets from menu bar

## What Gets Launched

By default, when you start your Mac:

1. **Timer Widget** (top-right corner)
   - Shows current Pomodoro timer
   - Auto-updates every second
   - 320x180 pixels (resizable)

2. **P1 Tasks Widget** (top-left corner)
   - Shows only Priority 1 tasks
   - Red priority indicator
   - 400x500 pixels (resizable)

You can add more widgets by editing the code!

## Setup Instructions

### 1. Deploy the API

First, deploy the tasks API endpoint:

```bash
cd /Users/roitaitou/Alain/pomo
git add app/api/tasks/route.ts
git commit -m "Add tasks API endpoint"
git push
```

### 2. Create Xcode Project

1. Open Xcode
2. File > New > Project
3. Choose: **macOS > App**
4. Project details:
   - Product Name: `PomoHub`
   - Organization Identifier: `com.yourname.pomohub`
   - Interface: **SwiftUI**
   - Language: **Swift**
5. Save to: `/Users/roitaitou/Alain/pomo/PomoWidget/PomoHub`

### 3. Add Files to Project

Add these files to your Xcode project:

**Required:**
- `PomoHubApp.swift` - Main app with menu bar
- `TimerContentView.swift` - Alias for timer widget
- Copy `ContentView.swift` from PomoWidget
- Copy `TasksContentView.swift` from TasksWidget
- Copy `TasksViewModel.swift` from TasksWidget

### 4. Configure Project

In Xcode:

1. **Signing & Capabilities:**
   - Add **App Sandbox**
   - Enable **Outgoing Connections (Client)**
   - Enable **Incoming Connections (Server)**

2. **Build Settings:**
   - Set minimum macOS version to 13.0+

3. **Info.plist:**
   - Set "Application is agent (UIElement)" to **YES**
   - This hides the app from Dock

### 5. Enable Auto-Launch on Startup

After building the app once:

1. Open **System Settings**
2. Go to **General > Login Items**
3. Click the **+** button
4. Select **PomoHub.app** from your build folder
5. Check **"Open at Login"**

Or programmatically (already included in the code via `ServiceManagement`).

## Usage

### Menu Bar Controls

Click the timer icon (⏲) in your menu bar to see:

- **Timer Widget** - Toggle timer widget (⌘T)
- **P1 Tasks** - Toggle P1 filter widget (⌘1)
- **P2 Tasks** - Toggle P2 filter widget (⌘2)
- **All Tasks** - Toggle all tasks widget (⌘A)
- **Quit** - Quit all widgets (⌘Q)

### Completing Tasks

Click the checkbox (○) next to any task to mark it complete:
- Empty circle (○) → Filled green checkmark (✓)
- Updates instantly in Notion
- Strikes through completed tasks

### Widget Positions

Default positions (all customizable):
- **Timer**: Top-right corner
- **P1 Tasks**: Top-left corner
- **P2 Tasks**: Middle-left (if enabled)
- **All Tasks**: Bottom-left (if enabled)

## Customization

### Add More Default Widgets

Edit `PomoHubApp.swift`, in `launchDefaultWidgets()`:

```swift
func launchDefaultWidgets() {
    createTimerWidget()
    createTasksWidget(priority: "1", title: "P1 Tasks", position: .topLeft)

    // Uncomment to add more:
    createTasksWidget(priority: "2", title: "P2 Tasks", position: .middleLeft)
    createTasksWidget(priority: nil, title: "All Tasks", position: .bottomLeft)
}
```

### Change Widget Positions

Available positions:
- `.topLeft`
- `.topRight`
- `.middleLeft`
- `.middleRight`
- `.bottomLeft`
- `.bottomRight`

### Change Menu Bar Icon

Edit `PomoHubApp.swift`:
```swift
button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomo Hub")
// Change "timer" to any SF Symbol name
```

### Add Status Filters

Create widgets filtered by status:

```swift
createTasksWidget(priority: nil, title: "In Progress", position: .middleRight, status: "In Progress")
```

You'll need to update the API client to support status filtering.

## Architecture

```
PomoHub (Menu Bar App)
    ├── Timer Widget (ContentView)
    │   └── Calls /api/event
    │
    └── Tasks Widgets (TasksContentView)
        ├── P1 Widget (priority="1")
        ├── P2 Widget (priority="2")
        └── All Widget (priority=nil)
        └── All call /api/tasks with filters
```

## Keyboard Shortcuts

- **⌘T** - Toggle Timer Widget
- **⌘1** - Toggle P1 Tasks
- **⌘2** - Toggle P2 Tasks
- **⌘A** - Toggle All Tasks
- **⌘Q** - Quit PomoHub

## Troubleshooting

**Widgets don't appear on startup:**
- Check System Settings > Login Items
- Make sure PomoHub is in the list

**Can't complete tasks:**
- Verify App Sandbox has network permissions
- Check that the PATCH endpoint works

**Menu bar icon missing:**
- Restart PomoHub
- Check Console.app for errors

## Notes

- All widgets are separate windows
- Each widget is independently draggable and resizable
- Window positions are NOT saved between sessions
- To save positions, you'd need to store them in UserDefaults

## Future Enhancements

Ideas for future versions:
- [ ] Save widget positions
- [ ] Custom filter combinations
- [ ] Drag-and-drop task reordering
- [ ] Task creation from widget
- [ ] Notification when Pomodoro ends
- [ ] Spotify integration for music control
