import SwiftUI
import ServiceManagement

@main
struct PomoHubApp: App {
    @NSApplicationDelegateAdaptor(PomoHubDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class PomoHubDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var windows: [String: NSWindow] = [:]

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomo Hub")
            button.action = #selector(toggleMenu)
            button.target = self
        }

        // Create menu
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Pomo Widgets", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "Timer Widget", action: #selector(toggleTimerWidget), keyEquivalent: "t")
        menu.addItem(withTitle: "P1 Tasks", action: #selector(toggleP1Widget), keyEquivalent: "1")
        menu.addItem(withTitle: "P2 Tasks", action: #selector(toggleP2Widget), keyEquivalent: "2")
        menu.addItem(withTitle: "All Tasks", action: #selector(toggleAllTasksWidget), keyEquivalent: "a")

        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "q")

        statusItem?.menu = menu

        // Auto-launch widgets on startup
        launchDefaultWidgets()
    }

    @objc func toggleMenu() {
        statusItem?.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    func launchDefaultWidgets() {
        // Launch timer widget
        createTimerWidget()

        // Launch P1 tasks widget
        createTasksWidget(priority: "1", title: "P1 Tasks", position: .topLeft)

        // Uncomment to launch more widgets by default:
        // createTasksWidget(priority: "2", title: "P2 Tasks", position: .middleLeft)
        // createTasksWidget(priority: nil, title: "All Tasks", position: .bottomLeft)
    }

    @objc func toggleTimerWidget() {
        if windows["timer"] != nil {
            closeWidget("timer")
        } else {
            createTimerWidget()
        }
    }

    @objc func toggleP1Widget() {
        if windows["p1"] != nil {
            closeWidget("p1")
        } else {
            createTasksWidget(priority: "1", title: "P1 Tasks", position: .topLeft)
        }
    }

    @objc func toggleP2Widget() {
        if windows["p2"] != nil {
            closeWidget("p2")
        } else {
            createTasksWidget(priority: "2", title: "P2 Tasks", position: .middleLeft)
        }
    }

    @objc func toggleAllTasksWidget() {
        if windows["all"] != nil {
            closeWidget("all")
        } else {
            createTasksWidget(priority: nil, title: "All Tasks", position: .bottomLeft)
        }
    }

    func createTimerWidget() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 180),
            styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.minSize = NSSize(width: 200, height: 120)
        panel.maxSize = NSSize(width: 600, height: 400)

        let contentView = NSHostingView(rootView: TimerContentView())
        panel.contentView = contentView

        // Position in top-right corner
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let x = screenRect.maxX - panel.frame.width - 20
            let y = screenRect.maxY - panel.frame.height - 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.makeKeyAndOrderFront(nil)
        windows["timer"] = panel
    }

    func createTasksWidget(priority: String?, title: String, position: WidgetPosition) {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.minSize = NSSize(width: 300, height: 200)
        panel.maxSize = NSSize(width: 800, height: 1000)

        let contentView = NSHostingView(rootView: TasksContentView(fixedPriority: priority))
        panel.contentView = contentView

        // Position based on preference
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let pos = position.calculate(for: panel.frame, in: screenRect)
            panel.setFrameOrigin(pos)
        }

        panel.makeKeyAndOrderFront(nil)

        let key = priority ?? "all"
        windows[key] = panel
    }

    func closeWidget(_ key: String) {
        windows[key]?.close()
        windows.removeValue(forKey: key)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

enum WidgetPosition {
    case topLeft
    case topRight
    case middleLeft
    case middleRight
    case bottomLeft
    case bottomRight

    func calculate(for windowFrame: NSRect, in screenFrame: NSRect) -> NSPoint {
        let padding: CGFloat = 20

        switch self {
        case .topLeft:
            return NSPoint(x: padding, y: screenFrame.maxY - windowFrame.height - padding)
        case .topRight:
            return NSPoint(x: screenFrame.maxX - windowFrame.width - padding, y: screenFrame.maxY - windowFrame.height - padding)
        case .middleLeft:
            return NSPoint(x: padding, y: screenFrame.midY - windowFrame.height / 2)
        case .middleRight:
            return NSPoint(x: screenFrame.maxX - windowFrame.width - padding, y: screenFrame.midY - windowFrame.height / 2)
        case .bottomLeft:
            return NSPoint(x: padding, y: padding)
        case .bottomRight:
            return NSPoint(x: screenFrame.maxX - windowFrame.width - padding, y: padding)
        }
    }
}
