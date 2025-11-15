import Foundation
import Combine

struct NotionTask: Identifiable, Codable {
    let id: String
    let title: String
    let priority: String?
    let status: String
    let timerStart: String?
    let timerEnd: String?
    let project: String?
}

struct TasksAPIResponse: Codable {
    let tasks: [NotionTask]
}

class TasksViewModel: ObservableObject {
    @Published var tasks: [NotionTask] = []
    @Published var isLoading = true
    @Published var error: String?
    @Published var selectedPriority: String?

    private var refreshTimer: Timer?
    private let apiClient = TasksAPIClient()

    init(initialPriority: String? = nil) {
        self.selectedPriority = initialPriority
    }

    func fetchTasks() {
        Task {
            do {
                let response = try await apiClient.fetchTasks(priority: selectedPriority)

                await MainActor.run {
                    self.tasks = response.tasks
                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func filterByPriority(_ priority: String?) {
        selectedPriority = priority
        isLoading = true
        fetchTasks()
    }

    func toggleTaskCompletion(taskId: String) {
        // Optimistically update UI
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            let currentStatus = tasks[index].status
            let newStatus = currentStatus == "Completed" ? "Not Started" : "Completed"

            // Update local state immediately
            tasks[index] = NotionTask(
                id: tasks[index].id,
                title: tasks[index].title,
                priority: tasks[index].priority,
                status: newStatus,
                timerStart: tasks[index].timerStart,
                timerEnd: tasks[index].timerEnd,
                project: tasks[index].project
            )

            // Send update to server
            Task {
                do {
                    try await apiClient.updateTaskStatus(taskId: taskId, newStatus: newStatus)
                } catch {
                    // Revert on error
                    await MainActor.run {
                        self.tasks[index] = NotionTask(
                            id: self.tasks[index].id,
                            title: self.tasks[index].title,
                            priority: self.tasks[index].priority,
                            status: currentStatus,
                            timerStart: self.tasks[index].timerStart,
                            timerEnd: self.tasks[index].timerEnd,
                            project: self.tasks[index].project
                        )
                        self.error = "Failed to update task"
                    }
                }
            }
        }
    }

    func startAutoRefresh() {
        // Refresh every 2 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { [weak self] _ in
            self?.fetchTasks()
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}

class TasksAPIClient {
    private let baseURL = "https://pomo-timer-eta.vercel.app"

    func fetchTasks(priority: String? = nil, status: String? = nil) async throws -> TasksAPIResponse {
        var urlString = "\(baseURL)/api/tasks"

        // Add query parameters
        var queryItems: [String] = []
        if let priority = priority {
            queryItems.append("priority=\(priority)")
        }
        if let status = status {
            queryItems.append("status=\(status)")
        }

        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }

        guard let url = URL(string: urlString) else {
            throw TasksAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TasksAPIError.serverError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(TasksAPIResponse.self, from: data)
    }

    func updateTaskStatus(taskId: String, newStatus: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/event") else {
            throw TasksAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["pageId": taskId, "newStatus": newStatus]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TasksAPIError.serverError
        }
    }
}

enum TasksAPIError: LocalizedError {
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
