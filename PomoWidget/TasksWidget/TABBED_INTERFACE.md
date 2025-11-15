# Tabbed Filter Pane Interface

## Overview
The widget now uses a tab-based interface where you can create custom filter panes and switch between them.

## Features

### 1. Filter Panes
- Each pane is a saved combination of filters
- Panes appear as tabs at the top of the widget
- Click a tab to switch to that pane's filters
- Hover over a tab to see a delete button (❌)

### 2. Creating Filter Panes
Click the grid icon (📋) to create a new filter pane:
- **Name**: Give your pane a descriptive name
- **Checked**: Filter by checked/unchecked/any
- **Area**: Filter by specific area (PhD, Life, MD, etc.)
- **Priority**: Filter by priority (1, 2, 3, or any)
- **Status**: Filter by status (Not Started, In Progress, Completed, or any)
- **Project**: Filter by project (ICI, Admin, Learn, etc., or any)

### 3. Example Filter Panes

**Unchecked ICI In Progress Priority 1**
- Name: "ICI P1"
- Checked: Unchecked
- Area: Any
- Priority: 1
- Status: In Progress
- Project: ICI

**PhD Admin Not Started**
- Name: "PhD Admin Todo"
- Checked: Any
- Area: PhD
- Priority: Any
- Status: Not Started
- Project: Admin

**All Priority 1 Tasks**
- Name: "Priority 1"
- Checked: Any
- Area: Any
- Priority: 1
- Status: Any
- Project: Any

## Persistence
All filter panes are saved to UserDefaults and persist between app launches.

## UI Layout

```
┌─────────────────────────────────────┐
│ Tasks                      📋  ➕   │  ← Header with add pane/task buttons
├─────────────────────────────────────┤
│ [All Tasks] [ICI P1] [PhD Todo]     │  ← Pane tabs (scrollable)
├─────────────────────────────────────┤
│                                     │
│  📋 Task 1                          │
│  📋 Task 2                          │  ← Tasks list
│  📋 Task 3                          │
│                                     │
└─────────────────────────────────────┘
```

## Key Files

- **FilterPane.swift**: Model for a filter pane
- **PaneManager.swift**: Manages panes and persistence
- **TasksContentViewTabs.swift**: Main tabbed view
- **AddPaneView.swift**: Dialog for creating new panes (embedded in TasksContentViewTabs.swift)

## Migration from Old View

The old view with separate Status/Project filter buttons has been replaced with the tabbed interface. You can recreate your common filters as saved panes for quick access.
