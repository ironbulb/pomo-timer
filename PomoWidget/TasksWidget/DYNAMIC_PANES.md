# Dynamic Widget Panes - Create Windows On-The-Fly! 🚀

Now you can **create new filtered widget windows from within any widget**!

## How It Works

### 1. Start with One Widget
When you launch the app, you get **one widget** with filter buttons.

### 2. Apply Filters
Click filter buttons to change what you see:
- Click "In Progress"
- Click "PhD Admin"
- Now you're viewing "In Progress + PhD Admin" tasks

### 3. Open in New Window!
See a **new button** next to the + button (looks like two overlapping rectangles)

Click it → **New widget window opens** showing only "In Progress + PhD Admin" tasks!

### 4. Repeat!
- Go back to first widget
- Click "P3"
- Click open in new window button
- Now you have a dedicated P3 widget!

## 🎯 Example Workflow

```
Step 1: Launch app
┌────────────────────┐
│ All Tasks     [+]  │
│ Status: [In Progress] [Not Started]
│ Project: [ICI] [Work]
└────────────────────┘

Step 2: Click "In Progress" + "PhD Admin"
┌────────────────────────┐
│ All Tasks    [📋][+]  │  ← New button appears!
│ Status: [In Progress] ✓
│ Project: [PhD Admin] ✓
│ Tasks: 5
└────────────────────────┘

Step 3: Click the [📋] button
┌────────────────────┐  ┌─────────────────────────┐
│ All Tasks     [+]  │  │ In Progress + PhD Admin │
│                    │  │ [+]                     │
│ Status: ...        │  │ Status: In Progress ✓   │
│ Project: ...       │  │ Project: PhD Admin ✓    │
└────────────────────┘  └─────────────────────────┘
        Original               New dedicated pane!

Step 4: Create more panes!
┌─────────────┐  ┌──────────────┐  ┌─────────┐
│ All Tasks   │  │ In Progress  │  │   P3    │
│             │  │ + PhD Admin  │  │         │
└─────────────┘  └──────────────┘  └─────────┘
```

## 🎨 Creating Dedicated Panes

### For Priority (P3 tasks)
1. In main widget, click filter buttons until only "P3" is selected
2. Click the "open in new window" button (📋)
3. New window opens: "P3 Tasks"

### For Project + Status Combo
1. Click "In Progress"
2. Click "ICI"
3. Click "open in new window" button
4. New window: "In Progress + ICI"

### For Single Project
1. Clear all filters
2. Click "PhD Admin"
3. Click "open in new window" button
4. New window: "PhD Admin"

## 📍 Window Positioning

New windows auto-cascade (each one slightly offset from the last).

You can then:
- **Drag** them anywhere you want
- **Resize** by dragging corners/edges
- **Close** any window with X

## 💡 Pro Tips

### Start with One Dynamic Widget
```swift
// In TasksWidgetApp.swift
WidgetManager.shared.createWidget(
    title: "All Tasks",
    filterMode: .combined,
    position: .topLeft
)
```

This gives you ONE widget where you can:
- Click filters to change what you see
- Click "open in new window" to create dedicated panes
- Build your layout dynamically!

### Mix Static and Dynamic
```swift
// Start with some fixed widgets
WidgetManager.shared.createWidget(title: "PhD Admin", project: "PhD Admin", position: .topLeft)

// Plus one dynamic widget for exploring
WidgetManager.shared.createWidget(title: "Explore", filterMode: .combined, position: .topRight)
```

## 🔧 The New Button

The **"Open in New Window"** button (📋):
- Only appears when you have active filters
- Creates a new widget with those exact filters
- The new widget also has this button!
- Infinite nesting possible!

## 🎯 Real-World Example

**Morning routine:**

1. Launch app → One "All Tasks" widget
2. Click "In Progress" → See what you're working on
3. Click "PhD Admin" → See active PhD tasks
4. Click 📋 → Dedicated "In Progress + PhD Admin" pane opens
5. Back to main widget, click "P1"
6. Click 📋 → Dedicated "P1" priority pane opens
7. Close main widget, keep the two focused panes!

**Result:** Two clean widgets showing exactly what you need!

## 🚀 Quick Start

1. Make sure `WidgetManager.swift` is added to your Xcode project
2. Press **⌘R** to rebuild
3. One widget launches with filter buttons
4. Click filters → Click 📋 button → New pane appears!

---

**This is the power of dynamic panes!** Create your workspace layout on-the-fly based on what you're working on. 🎉
