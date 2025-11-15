# TasksWidget - Easiest Setup Ever! 🚀

## The Problem
The command-line build has code signing issues. Using Xcode GUI is actually easier!

## Simple 3-Step Setup

### Step 1: Open Xcode Project
```bash
open /Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget/TasksWidget/TasksWidget.xcodeproj
```

### Step 2: Click Run Button ▶️
Just press the **Play button** (▶️) in the top-left of Xcode, or press **⌘R**

That's it! ✨

---

## What Xcode Will Do Automatically

When you click Run:
1. ✅ Uses the updated `TasksViewModel.swift` (already updated!)
2. ✅ Includes `TasksContentViewEnhanced.swift` (already added!)
3. ✅ Includes `TasksWidget.entitlements` (already added!)
4. ✅ Builds and launches the widget

---

## First Time Setup (One-Time Only)

If this is your first time running, you might need to:

1. **Select a Development Team:**
   - Click on "TasksWidget" project (top of left sidebar)
   - Go to "Signing & Capabilities" tab
   - Under "Team", select your Apple ID
   - Or select "None" if you just want to run locally

2. **That's it!** Click ▶️

---

## What You'll See

The widget will launch with:

### 🎯 Combined Filters (Default)
- **Status row**: In Progress / Not Started buttons
- **Project row**: ICI / Work / Personal buttons
- **Clear button**: Reset all filters

### ➕ Task Creation
- Click the **+** button (top-right)
- Enter task title
- Select priority (P1, P2, P3) - optional
- Select project (ICI, Work, Personal) - optional
- Click **Create**

### ✅ Task Completion
- Click checkbox (○) to mark complete
- Click again (✓) to mark incomplete
- Updates Notion instantly!

---

## Switching Filter Modes

Want different filters? Edit [TasksWidgetApp.swift:53](TasksWidgetApp.swift#L53):

**Current (Combined filters):**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .combined))
```

**Change to Priority filters (P1/P2/P3):**
```swift
let contentView = NSHostingView(rootView: TasksContentView())
```

**Change to Status filters only:**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .status))
```

**Change to Project filters only:**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(filterMode: .project))
```

**Fixed filter (e.g., only "In Progress + ICI"):**
```swift
let contentView = NSHostingView(rootView: TasksContentViewEnhanced(
    filterMode: .combined,
    status: "In Progress",
    project: "ICI"
))
```

After changing, just press **⌘R** again to rebuild!

---

## Troubleshooting

### "Build Failed" or Errors?

1. **Clean Build Folder:**
   - Menu: Product → Clean Build Folder (or **⌘+Shift+K**)

2. **Check Files Are Added:**
   - Left sidebar should show:
     - ✅ TasksWidgetApp.swift
     - ✅ TasksContentView.swift
     - ✅ TasksContentViewEnhanced.swift
     - ✅ TasksViewModel.swift
     - ✅ VisualEffectView.swift
     - ✅ TasksWidget.entitlements

3. **Rebuild:**
   - Press **⌘R** to run

### "Network Error" in Widget?

1. **Add App Sandbox** (one-time setup):
   - Click project name (top of left sidebar)
   - Go to "Signing & Capabilities" tab
   - Click **+ Capability**
   - Add **App Sandbox**
   - Enable:
     - ✅ Outgoing Connections (Client)
     - ✅ Incoming Connections (Server)

2. **Rebuild:**
   - Press **⌘R**

### Widget Shows Old Version?

- Make sure you're editing the correct file:
  - `/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget/TasksWidget/TasksWidget/TasksViewModel.swift`
  - NOT `/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget/TasksViewModel.swift`

---

## Auto-Launch on Startup (Optional)

Want the widget to start when your Mac boots?

1. Build the app first (⌘R)
2. Find the app:
   ```bash
   open ~/Library/Developer/Xcode/DerivedData
   ```
3. Navigate to: `TasksWidget-.../Build/Products/Release/TasksWidget.app`
4. Copy `TasksWidget.app` to `/Applications`
5. System Settings → General → Login Items
6. Add TasksWidget.app
7. Check "Open at Login"

---

## That's It! 🎉

Just open Xcode and press ▶️ - it's that simple!

No terminal commands needed, no build scripts, just click and run.
