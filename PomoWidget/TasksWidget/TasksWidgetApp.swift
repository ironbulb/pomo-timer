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
        // Create the floating panel window - resizable!
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

        // Set minimum and maximum sizes
        panel.minSize = NSSize(width: 300, height: 200)
        panel.maxSize = NSSize(width: 800, height: 1000)

        // Create and set the content view
        let contentView = NSHostingView(rootView: TasksContentView())
        panel.contentView = contentView

        // Position window in top-left corner with padding
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let x: CGFloat = 20
            let y = screenRect.maxY - panel.frame.height - 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.makeKeyAndOrderFront(nil)
        self.window = panel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
