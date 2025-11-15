# TasksWidget - Simple Setup (2 Steps!)

## Step 1: Add Files to Xcode

Open your Xcode project and **drag these 2 files** from Finder into Xcode:

1. `TasksWidget.entitlements`
2. `TasksContentViewEnhanced.swift`

**How to drag:**
- Open Finder → Navigate to `/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget/`
- Open Xcode with your TasksWidget project
- Drag both files from Finder into the Xcode file list (left sidebar)
- When the dialog appears:
  - ✅ Check "Copy items if needed"
  - ✅ Check "Add to targets: TasksWidget"
  - Click **Add**

## Step 2: Build and Run

Click the **Play button** (▶️) in Xcode or press **⌘R**

That's it! 🎉

---

## Alternative: Use Terminal (Even Easier!)

If you prefer, just run this command:

```bash
cd /Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget
./setup.sh
```

The script will:
1. Build everything automatically
2. Ask if you want to launch the widget
3. Done!

---

## What You'll See

When the widget launches:

### ✨ New Features

1. **+ Button** (top-right) - Click to create new tasks
2. **Two filter rows**:
   - Status: In Progress / Not Started
   - Project: ICI / Work / Personal
3. **Clear button** - Reset all filters
4. **Checkboxes** - Click to toggle task completion (works both ways!)

### 🎯 Example Usage

**Show only "In Progress" tasks from "ICI":**
1. Click "In Progress" button
2. Click "ICI" button
3. Widget now shows only matching tasks

**Create a new task:**
1. Click **+** button
2. Enter title: "Review code"
3. Select P1 and Work
4. Click Create
5. Task appears in Notion instantly!

---

## Troubleshooting

**Build fails?**
- Try: Product → Clean Build Folder (⌘+Shift+K)
- Then: Product → Build (⌘+B)

**Network error still showing?**
1. In Xcode, go to: Signing & Capabilities tab
2. Click **+ Capability**
3. Add **App Sandbox**
4. Enable checkboxes:
   - ✅ Outgoing Connections (Client)
   - ✅ Incoming Connections (Server)
5. Rebuild (⌘+B)

**Files not appearing in Xcode?**
- Make sure you dragged them into the project navigator (left sidebar)
- Not just into an empty space

---

## Customization

### Change Filter Mode

Edit [TasksWidgetApp.swift:53](TasksWidgetApp.swift#L53) and uncomment the mode you want:

```swift
// Combined filters (Status + Project) - DEFAULT
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .combined))

// OR use Priority filters (P1, P2, P3)
// let contentView = NSHostingView(rootView: TasksContentView())

// OR use Status filters only
// let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .status))

// OR use Project filters only
// let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .project))
```

### Add Your Projects

Edit [TasksContentViewEnhanced.swift:159](TasksContentViewEnhanced.swift#L159):

```swift
ForEach(["ICI", "Work", "Personal", "YourProject"], id: \.self) { project in
```

Also update line 381 for the task creation dialog.

---

That's it! You now have a fully enhanced TasksWidget with custom filters and task creation! 🚀
