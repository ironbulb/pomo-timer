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

struct APIResponse: Codable {
    let id: String?
    let title: String
    let duration: Int?
}
