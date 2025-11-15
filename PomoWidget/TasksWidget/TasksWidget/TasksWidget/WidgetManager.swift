import SwiftUI
import AppKit

// Singleton to manage all widget windows
class WidgetManager: ObservableObject {
    static let shared = WidgetManager()

    @Published var windows: [NSWindow] = []

    private init() {}

    enum WidgetPosition {
        case topLeft, topRight, middleLeft, middleRight, bottomLeft, bottomRight, auto
    }

    func createWidget(
        title: String,
        project: String? = nil,
        status: String? = nil,
        priority: String? = nil,
        filterMode: TasksContentViewEnhanced.FilterMode = .combined,
        position: WidgetPosition = .auto
    ) {
        // Create the floating panel window
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
        panel.title = title

        // Set minimum and maximum sizes
        panel.minSize = NSSize(width: 300, height: 200)
        panel.maxSize = NSSize(width: 800, height: 1000)

        // Create content view with filters
        let contentView = NSHostingView(
            rootView: TasksContentViewEnhanced(
                filterMode: filterMode,
                priority: priority,
                status: status,
                project: project
            )
        )
        panel.contentView = contentView

        // Position window
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let padding: CGFloat = 20
            let x: CGFloat
            let y: CGFloat

            switch position {
            case .topLeft:
                x = padding
                y = screenRect.maxY - panel.frame.height - padding
            case .topRight:
                x = screenRect.maxX - panel.frame.width - padding
                y = screenRect.maxY - panel.frame.height - padding
            case .middleLeft:
                x = padding
                y = screenRect.midY - panel.frame.height / 2
            case .middleRight:
                x = screenRect.maxX - panel.frame.width - padding
                y = screenRect.midY - panel.frame.height / 2
            case .bottomLeft:
                x = padding
                y = screenRect.minY + padding
            case .bottomRight:
                x = screenRect.maxX - panel.frame.width - padding
                y = screenRect.minY + padding
            case .auto:
                // Auto position: cascade from existing windows
                let offset = CGFloat(windows.count * 30)
                x = padding + offset
                y = screenRect.maxY - panel.frame.height - padding - offset
            }

            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.makeKeyAndOrderFront(nil)
        windows.append(panel)
    }

    func closeAllWindows() {
        windows.forEach { $0.close() }
        windows.removeAll()
    }
}
