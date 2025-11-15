import SwiftUI

@main
struct TasksWidgetApp: App {
    @NSApplicationDelegateAdaptor(TasksAppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class TasksAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the main tabbed widget window
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )

        // Configure panel appearance
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.title = "Tasks"

        // Set minimum and maximum sizes
        panel.minSize = NSSize(width: 300, height: 200)
        panel.maxSize = NSSize(width: 800, height: 1000)

        // Create content view with tabs
        let contentView = NSHostingView(rootView: TasksContentViewTabs())
        panel.contentView = contentView

        // Position window
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let padding: CGFloat = 20
            let x = padding
            let y = screenRect.maxY - panel.frame.height - padding
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.makeKeyAndOrderFront(nil)
        window = panel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
