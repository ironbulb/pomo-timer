# Custom Widget Layouts

You can now create **multiple widget windows**, each showing different filtered views of your tasks!

## 🎨 Current Setup (Default)

When you run the app, it launches **2 widgets**:

1. **"PhD Admin"** widget (top-left) - Shows only PhD Admin project tasks
2. **"ICI Tasks"** widget (top-right) - Shows only ICI project tasks

## 📝 Customize Your Widgets

Edit [TasksWidgetApp.swift:17-28](TasksWidgetApp.swift#L17-L28):

```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    // Launch multiple widgets for different projects
    // Customize which widgets to show by commenting/uncommenting

    createWidget(title: "PhD Admin", project: "PhD Admin", position: .topLeft)
    createWidget(title: "ICI Tasks", project: "ICI", position: .topRight)
    // createWidget(title: "Personal", project: "Personal", position: .bottomLeft)
    // createWidget(title: "In Progress", status: "In Progress", position: .middleLeft)

    // Or create a widget with combined filters
    // createWidget(title: "All Tasks", filterMode: .combined, position: .topLeft)
}
```

## 🚀 Examples

### Example 1: PhD Admin + ICI + Personal (3 widgets)

```swift
createWidget(title: "PhD Admin", project: "PhD Admin", position: .topLeft)
createWidget(title: "ICI", project: "ICI", position: .topRight)
createWidget(title: "Personal", project: "Personal", position: .bottomLeft)
```

### Example 2: Filter by Status (In Progress tasks)

```swift
createWidget(title: "In Progress", status: "In Progress", position: .topLeft)
createWidget(title: "Not Started", status: "Not Started", position: .topRight)
```

### Example 3: Filter by Priority

```swift
createWidget(title: "High Priority", priority: "1", position: .topLeft)
createWidget(title: "Medium Priority", priority: "2", position: .topRight)
```

### Example 4: Combined Filters (In Progress PhD Admin tasks)

```swift
createWidget(
    title: "PhD In Progress",
    project: "PhD Admin",
    status: "In Progress",
    position: .topLeft
)
```

### Example 5: One Widget with All Filters Available

```swift
createWidget(title: "All Tasks", filterMode: .combined, position: .topLeft)
```

This creates a single widget where you can click filter buttons to change what you see.

## 📍 Widget Positions

Available positions:

```
┌─────────────────────────────┐
│ .topLeft        .topRight   │
│                             │
│ .middleLeft  .middleRight   │
│                             │
│ .bottomLeft  .bottomRight   │
└─────────────────────────────┘
```

## 🎯 Parameters

When calling `createWidget()`, you can use:

| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| `title` | String | "PhD Admin" | Widget window title (required) |
| `project` | String? | "PhD Admin" | Filter by project |
| `status` | String? | "In Progress" | Filter by status |
| `priority` | String? | "1" | Filter by priority (1, 2, 3) |
| `filterMode` | FilterMode | `.combined` | What filter buttons to show |
| `position` | Position | `.topLeft` | Where to place the widget |

### Filter Modes

- `.combined` - Shows Status + Project filter buttons
- `.status` - Shows only Status filter buttons
- `.project` - Shows only Project filter buttons
- `.priority` - Shows only Priority filter buttons

## 💡 Tips

### Mix Fixed and Dynamic Filters

```swift
// Fixed widget: Always shows PhD Admin tasks
createWidget(title: "PhD Admin", project: "PhD Admin", position: .topLeft)

// Dynamic widget: User can change filters
createWidget(title: "All Tasks", filterMode: .combined, position: .topRight)
```

### One Widget Per Project

```swift
createWidget(title: "PhD Admin", project: "PhD Admin", position: .topLeft)
createWidget(title: "ICI", project: "ICI", position: .topRight)
createWidget(title: "Work", project: "Work", position: .middleLeft)
createWidget(title: "Personal", project: "Personal", position: .middleRight)
```

### Focus on What's Active

```swift
createWidget(title: "Today (In Progress)", status: "In Progress", position: .topLeft)
createWidget(title: "Backlog (Not Started)", status: "Not Started", position: .topRight)
```

## 🔧 Make Sure Projects Exist in Notion

Before creating widgets for projects, make sure your Notion database has these exact project names in the "Project" property:

- "PhD Admin"
- "ICI"
- "Personal"
- etc.

The filter is **case-sensitive**!

## 🎨 Resize & Rearrange

After launching:
- **Drag** any widget to reposition it
- **Resize** by dragging corners/edges
- **Close** any widget you don't want (click X)

Note: Positions are not saved between app launches (yet!)

## 🚀 Quick Start

1. Edit `TasksWidgetApp.swift` lines 21-27
2. Uncomment/add the widgets you want
3. Press **⌘R** in Xcode to rebuild
4. All your custom widgets launch automatically!

---

**Pro Tip:** Start with 2-3 widgets to avoid clutter, then add more as needed!
