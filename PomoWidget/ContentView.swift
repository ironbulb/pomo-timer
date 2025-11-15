import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Frosted glass background
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)

            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if viewModel.isActiveTimer, let title = viewModel.eventTitle {
                    // Active timer view
                    VStack(spacing: 12) {
                        // Task name
                        Text(title)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        // Timer display
                        Text(viewModel.formattedTime)
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        // Status indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                            Text("In Progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 20)
                } else if let title = viewModel.eventTitle {
                    // Message display (next task or no events)
                    VStack(spacing: 12) {
                        if title.contains("next task") {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.green)
                        }

                        Text(title)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                } else {
                    // No events
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                        Text("All done!")
                            .font(.headline)
                        Text("No active events")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 320, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            viewModel.startTimer()
        }
    }
}

// Visual Effect View for frosted glass
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
