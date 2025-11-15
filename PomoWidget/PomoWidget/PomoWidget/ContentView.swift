import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Frosted glass background - more transparent
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.85)

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
        .frame(minWidth: 200, idealWidth: 320, maxWidth: .infinity,
               minHeight: 120, idealHeight: 180, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
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

// MARK: - Timer ViewModel

import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var eventTitle: String?
    @Published var duration: Int?
    @Published var eventId: String?
    @Published var isLoading = true
    @Published var error: String?
    @Published var formattedTime = "00:00"
    @Published var remainingSeconds: Int = 0

    private var timer: Timer?
    private var apiTimer: Timer?
    private let apiClient = APIClient()

    func startTimer() {
        // Initial fetch
        fetchEvent()

        // Update timer display every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }

        // Fetch from API every 60 seconds
        apiTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.fetchEvent()
        }
    }

    func fetchEvent() {
        Task {
            do {
                let response = try await apiClient.fetchEvent()

                await MainActor.run {
                    self.eventId = response.id
                    self.eventTitle = response.title
                    self.duration = response.duration

                    // Set remaining seconds when we get new data
                    if let duration = response.duration {
                        self.remainingSeconds = duration
                    }

                    self.isLoading = false
                    self.error = nil
                    self.updateTimer()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func updateTimer() {
        guard let _ = eventId, let _ = duration else {
            formattedTime = "00:00"
            return
        }

        if remainingSeconds <= 0 {
            formattedTime = "00:00"
            // Fetch new event when timer reaches zero
            fetchEvent()
        } else {
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            formattedTime = String(format: "%02d:%02d", minutes, seconds)

            // Decrement remaining seconds
            remainingSeconds -= 1
        }
    }

    var isActiveTimer: Bool {
        return eventId != nil && duration != nil
    }

    deinit {
        timer?.invalidate()
        apiTimer?.invalidate()
    }
}

// MARK: - API Client

struct APIResponse: Codable {
    let id: String?
    let title: String
    let duration: Int?
}

class APIClient {
    private let baseURL = "https://pomo-timer-eta.vercel.app"

    func fetchEvent() async throws -> APIResponse {
        guard let url = URL(string: "\(baseURL)/api/event") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(APIResponse.self, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error"
        }
    }
}
