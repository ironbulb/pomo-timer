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
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Launch initial widget(s) on startup
        // This widget has filter buttons - you can click them to change filters
        // Then click the "open in new window" button to create a dedicated pane!

        WidgetManager.shared.createWidget(
            title: "All Tasks",
            filterMode: .combined,
            position: .topLeft
        )

        // Optional: Start with some pre-filtered widgets too
        // WidgetManager.shared.createWidget(title: "PhD Admin", project: "PhD Admin", position: .topRight)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
