# Pomo Widgets - Complete Setup Guide

A beautiful collection of macOS desktop widgets for your Notion-based Pomodoro system.

## 📦 What You Have

### 1. **Timer Widget** (Already Working!)
- Displays current Pomodoro timer
- Translucent frosted glass design
- Auto-updates every second
- Located: `PomoWidget/PomoWidget/`

### 2. **Tasks Widget** (Ready to Build)
- Shows filtered task lists from Notion
- Clickable checkboxes to complete tasks
- Priority filtering (P1, P2, P3, All)
- Located: `PomoWidget/TasksWidget/`

### 3. **Pomo Hub** - Menu Bar Manager (Recommended!)
- Single app that launches all widgets on startup
- Menu bar controls to show/hide widgets
- Auto-launch on Mac boot
- Located: `PomoWidget/PomoHub/`

## 🚀 Quick Start (Recommended Path)

### Step 1: Deploy the Tasks API

```bash
cd /Users/roitaitou/Alain/pomo

# Add the new API endpoint
git add app/api/tasks/route.ts

# Commit and push
git commit -m "Add tasks API endpoint for widgets"
git push
```

Vercel will auto-deploy. Your API will be available at:
`https://pomo-timer-eta.vercel.app/api/tasks`

### Step 2: Build PomoHub (All-in-One Solution)

This is the easiest approach - one app that manages everything!

1. **Open Xcode**

2. **Create New Project:**
   - File > New > Project
   - Choose: macOS > App
   - Product Name: **PomoHub**
   - Save to: `/Users/roitaitou/Alain/pomo/PomoWidget/PomoHub`

3. **Add Files:**
   - Delete the default `ContentView.swift`
   - Add `PomoHubApp.swift`
   - Add `TimerContentView.swift`
   - From `PomoWidget/PomoWidget/PomoWidget/`:
     - Copy `ContentView.swift` (rename to `PomoContentView.swift` in project)
   - From `PomoWidget/TasksWidget/`:
     - Copy `TasksContentView.swift`
     - Copy `TasksViewModel.swift`

4. **Configure:**
   - Signing & Capabilities > Add "App Sandbox"
   - Enable "Outgoing Connections" and "Incoming Connections"
   - Info.plist > Add "Application is agent (UIElement)" = YES

5. **Build and Run** (⌘R)

6. **Enable Auto-Launch:**
   - System Settings > General > Login Items
   - Add PomoHub.app
   - Check "Open at Login"

Done! 🎉

## 📱 What You'll See

When PomoHub launches:

### Timer Widget (Top-Right)
```
┌─────────────────────┐
│  Task Name          │
│                     │
│      25:00          │
│                     │
│  ● In Progress      │
└─────────────────────┘
```

### P1 Tasks Widget (Top-Left)
```
┌──────────────────────────────┐
│  P1 Tasks                    │
│  ────────────────────────    │
│                              │
│  ○ ● Task 1         P1  ⏰  │
│  ○ ● Task 2         P1      │
│  ✓ ● Task 3         P1      │
│                              │
└──────────────────────────────┘
```

### Menu Bar
```
   ⏲
   ├─ Pomo Widgets
   ├─ ──────────────
   ├─ Timer Widget    ⌘T
   ├─ P1 Tasks        ⌘1
   ├─ P2 Tasks        ⌘2
   ├─ All Tasks       ⌘A
   ├─ ──────────────
   └─ Quit            ⌘Q
```

## ⚙️ Features

### ✅ Task Completion
- Click checkbox (○) next to any task
- Instantly marks complete in Notion
- Updates status to "Completed"
- Strikes through completed tasks

### 🎯 Priority Filtering
- **P1**: High priority (red)
- **P2**: Medium priority (orange)
- **P3**: Low priority (yellow)
- **All**: Show everything

### 📏 Resizable Widgets
- Drag corners/edges to resize
- Min/max limits prevent too small/large
- Positions are draggable

### 🔄 Auto-Refresh
- Timer: Updates every second
- Tasks: Refreshes every 2 minutes
- Manual refresh on task completion

## 🎨 Customization

### Change Default Widgets

Edit `PomoHubApp.swift` > `launchDefaultWidgets()`:

```swift
func launchDefaultWidgets() {
    // Timer (always recommended)
    createTimerWidget()

    // Choose your task widgets:
    createTasksWidget(priority: "1", title: "P1 Tasks", position: .topLeft)
    createTasksWidget(priority: "2", title: "P2 Tasks", position: .middleLeft)
    createTasksWidget(priority: nil, title: "All Tasks", position: .bottomLeft)
}
```

### Widget Positions

Available positions:
- `.topLeft` - Upper left corner
- `.topRight` - Upper right corner
- `.middleLeft` - Left side, centered vertically
- `.middleRight` - Right side, centered vertically
- `.bottomLeft` - Lower left corner
- `.bottomRight` - Lower right corner

### Change Transparency

Edit `TasksContentView.swift` and `ContentView.swift`:

```swift
VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
    .opacity(0.85)  // Lower = more transparent (0.0 - 1.0)
```

### Menu Bar Icon

Edit `PomoHubApp.swift`:

```swift
button.image = NSImage(systemSymbolName: "timer", ...)
// Try: "clock", "checklist", "list.bullet", "circle.grid.3x3"
```

## 🔧 Troubleshooting

### API Returns No Tasks
**Check Notion database has these properties:**
- `Task ` (title)
- `Priority` (select): Values should be "1", "2", "3"
- `Status` (status): Values should be "Not Started", "In Progress", "Completed"
- `Timer` (date): Optional
- `Project` (select): Optional

### Widgets Don't Show on Startup
1. Check System Settings > Login Items
2. Ensure PomoHub is in the list
3. Make sure "Open at Login" is checked

### Can't Complete Tasks (Checkbox Doesn't Work)
1. Check App Sandbox has network permissions
2. Verify the PATCH endpoint works:
   ```bash
   curl -X PATCH https://pomo-timer-eta.vercel.app/api/event \
     -H "Content-Type: application/json" \
     -d '{"pageId": "test-id", "newStatus": "Completed"}'
   ```

### Build Errors in Xcode
- Make sure all Swift files are added to target
- Check deployment target is macOS 13.0+
- Clean build folder (⌘+Shift+K)

## 📁 Project Structure

```
PomoWidget/
├── PomoWidget/              # Original timer widget (working)
│   └── PomoWidget/
│       └── PomoWidget/
│           ├── ContentView.swift
│           ├── PomoWidgetApp.swift
│           └── (timer logic)
│
├── TasksWidget/             # Tasks list widget
│   ├── TasksWidgetApp.swift
│   ├── TasksContentView.swift
│   ├── TasksViewModel.swift
│   └── README.md
│
└── PomoHub/                 # ⭐ Menu bar manager (RECOMMENDED)
    ├── PomoHubApp.swift
    ├── TimerContentView.swift
    └── README.md
```

## 🎯 Notion Database Setup

Your database should look like this:

| Task | Priority | Status | Timer | Project |
|------|----------|--------|-------|---------|
| Complete project | 1 | In Progress | Oct 27, 2:00 PM → 2:25 PM | Work |
| Review code | 2 | Not Started | - | Work |
| Team meeting | 1 | Completed | Oct 27, 3:00 PM → 3:30 PM | Work |

**Property types:**
- `Task `: Title
- `Priority`: Select (options: "1", "2", "3")
- `Status`: Status (options: "Not Started", "In Progress", "Completed")
- `Timer`: Date (with start & end time)
- `Project`: Select (any values)

## 🚀 Next Steps

1. ✅ Deploy API endpoint
2. ✅ Build PomoHub in Xcode
3. ✅ Configure auto-launch
4. 🎨 Customize positions and filters
5. 🎯 Enjoy your productive workflow!

## 💡 Tips

- **Multiple monitors**: Widgets work on any display
- **Keyboard shortcuts**: Use ⌘1, ⌘2 to quickly toggle widgets
- **Drag to reposition**: All widgets are draggable
- **Resize as needed**: Drag corners/edges
- **Hide when not needed**: Use menu bar to toggle off

## 📝 Future Ideas

Want more features? Consider:
- Save widget positions between sessions
- Add task creation from widget
- Spotify controls
- Notification when timer ends
- Custom color themes
- More filter combinations

---

**Questions?** Check the individual README files:
- [PomoHub README](PomoHub/README.md)
- [Tasks Widget README](TasksWidget/README.md)
- [Timer Widget README](README.md)
