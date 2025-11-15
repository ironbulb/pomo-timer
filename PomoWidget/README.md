# Pomo Widget - macOS Desktop Widget

A native macOS desktop widget that displays your Notion Pomodoro timer in a beautiful, Silico-inspired floating window.

## Features

- **Translucent frosted glass design** - Native NSVisualEffectView with blur
- **Floating window** - Always accessible, stays on top, non-intrusive
- **Dark/Light mode** - Automatically adapts to system theme
- **Real-time countdown** - Updates every second
- **API integration** - Fetches data from your Vercel deployment
- **Compact & minimal** - Information-dense 320x180 window

## Setup Instructions

### 1. Update API URL

Open `APIClient.swift` and replace the placeholder URL with your actual Vercel deployment:

```swift
private let baseURL = "https://your-actual-app.vercel.app"
```

### 2. Create Xcode Project

1. Open Xcode
2. Select **File > New > Project**
3. Choose **macOS > App**
4. Fill in the details:
   - Product Name: `PomoWidget`
   - Team: (Select your team or leave as None for local development)
   - Organization Identifier: `com.yourname.pomowidget`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Use Core Data"
   - Uncheck "Include Tests"
5. Save the project in the `PomoWidget` directory

### 3. Replace Default Files

Replace the default Xcode template files with the files in this directory:

- `PomoWidgetApp.swift` → Replace the default App file
- `ContentView.swift` → Replace the default ContentView
- Add `TimerViewModel.swift` to the project (File > Add Files to "PomoWidget")
- Add `APIClient.swift` to the project
- Replace `Info.plist` if needed
- Add `PomoWidget.entitlements` to the project

### 4. Configure Project Settings

In Xcode:

1. Select the project in the navigator
2. Select the "PomoWidget" target
3. Go to **Signing & Capabilities**
   - Enable "App Sandbox"
   - Under "Network", enable "Outgoing Connections (Client)"
4. Go to **Info** tab
   - Ensure "Application is agent (UIElement)" is set to YES
5. Build and run (Cmd+R)

## How It Works

1. **Fetches from API** - Makes HTTP requests to `/api/event` endpoint
2. **Parses response** - Decodes JSON with current event and next event data
3. **Updates UI** - Displays timer, task name, and status
4. **Auto-refreshes** - Polls API every 60 seconds
5. **Counts down** - Updates display every second based on `end_time`

## UI States

- **Loading** - Shows spinner while fetching initial data
- **Active Timer** - Displays countdown with task name and status indicator
- **Next Task** - Shows upcoming task when no current event
- **All Done** - Celebrates completion when no events scheduled
- **Error** - Shows error message if API fails

## Customization

### Window Position
Edit `AppDelegate.swift` to change the position:
```swift
let x = screenRect.maxX - windowRect.width - 20  // Right side
let y = screenRect.maxY - windowRect.height - 20 // Top
```

### Window Size
Edit `ContentView.swift`:
```swift
.frame(width: 320, height: 180)
```

### Colors & Styling
Modify the gradient, status colors, and fonts in `ContentView.swift`

### Refresh Interval
Edit `TimerViewModel.swift`:
```swift
apiTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true)
```

## Architecture

```
PomoWidgetApp.swift    → App entry point, window configuration
AppDelegate.swift      → NSPanel setup with floating behavior
ContentView.swift      → SwiftUI UI with frosted glass effect
TimerViewModel.swift   → State management, timers, data models
APIClient.swift        → HTTP client for Vercel API
```

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9+
- Active internet connection
- Running Vercel deployment of the Pomo app

## Notes

- Widget appears in top-right corner by default
- Window is draggable by clicking and dragging anywhere
- Stays on top of other windows (floating level)
- Doesn't appear in Dock (LSUIElement = YES)
- Minimal CPU/battery usage
- No modifications to your existing Next.js codebase required

## Troubleshooting

**Widget doesn't show data:**
- Check that `baseURL` in `APIClient.swift` is correct
- Verify your Vercel deployment is running
- Check Console.app for error messages

**Build errors:**
- Ensure deployment target is macOS 13.0+
- Check that all files are added to the target

**Window doesn't float:**
- Verify `panel.level = .floating` in AppDelegate
- Check entitlements are properly configured
