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

struct SchemaResponse: Codable {
    let projects: [String]
    let areas: [String]
    let priorities: [String]
    let statuses: [String]
}

class TasksViewModel: ObservableObject {
    @Published var tasks: [NotionTask] = []
    @Published var isLoading = true
    @Published var error: String?
    @Published var selectedPriority: String?
    @Published var selectedStatus: String?
    @Published var selectedProject: String?
    @Published var availableProjects: [String] = []
    @Published var availableAreas: [String] = []
    @Published var availablePriorities: [String] = []
    @Published var availableStatuses: [String] = []

    private var refreshTimer: Timer?
    private let apiClient = TasksAPIClient()

    init(initialPriority: String? = nil, initialStatus: String? = nil, initialProject: String? = nil) {
        self.selectedPriority = initialPriority
        self.selectedStatus = initialStatus
        self.selectedProject = initialProject
    }

    func fetchSchema() {
        Task {
            do {
                let schema = try await apiClient.fetchSchema()
                await MainActor.run {
                    self.availableProjects = schema.projects
                    self.availableAreas = schema.areas
                    self.availablePriorities = schema.priorities
                    self.availableStatuses = schema.statuses
                }
            } catch {
                print("Failed to fetch schema: \(error)")
            }
        }
    }

    func fetchTasks() {
        Task {
            do {
                let response = try await apiClient.fetchTasks(
                    priority: selectedPriority,
                    status: selectedStatus,
                    project: selectedProject
                )

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

    func filterByStatus(_ status: String?) {
        selectedStatus = status
        isLoading = true
        fetchTasks()
    }

    func filterByProject(_ project: String?) {
        selectedProject = project
        isLoading = true
        fetchTasks()
    }

    func applyFilters(priority: String? = nil, status: String? = nil, project: String? = nil) {
        selectedPriority = priority
        selectedStatus = status
        selectedProject = project
        isLoading = true
        fetchTasks()
    }

    func createTask(title: String, priority: String? = nil, status: String? = nil, project: String? = nil, area: String? = nil, checked: Bool = false) {
        Task {
            do {
                try await apiClient.createTask(
                    title: title,
                    priority: priority,
                    status: status,
                    project: project,
                    area: area,
                    checked: checked
                )

                // Refresh tasks after creation
                await MainActor.run {
                    self.fetchTasks()
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to create task"
                }
            }
        }
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

    func fetchSchema() async throws -> SchemaResponse {
        guard let url = URL(string: "\(baseURL)/api/schema") else {
            throw TasksAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TasksAPIError.serverError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(SchemaResponse.self, from: data)
    }

    func fetchTasks(priority: String? = nil, status: String? = nil, project: String? = nil) async throws -> TasksAPIResponse {
        var urlString = "\(baseURL)/api/tasks"

        // Add query parameters
        var queryItems: [String] = []
        if let priority = priority {
            queryItems.append("priority=\(priority)")
        }
        if let status = status {
            queryItems.append("status=\(status)")
        }
        if let project = project {
            queryItems.append("project=\(project)")
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

    func createTask(title: String, priority: String? = nil, status: String? = nil, project: String? = nil, area: String? = nil, checked: Bool = false) async throws {
        guard let url = URL(string: "\(baseURL)/api/tasks") else {
            throw TasksAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["title": title, "checked": checked]
        if let priority = priority { body["priority"] = priority }
        if let status = status { body["status"] = status }
        if let project = project { body["project"] = project }
        if let area = area { body["area"] = area }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TasksAPIError.serverError
        }
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

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TasksAPIError.serverError
        }

        if !(200...299).contains(httpResponse.statusCode) {
            // Print error for debugging
            if let errorString = String(data: data, encoding: .utf8) {
                print("Status update failed: \(httpResponse.statusCode) - \(errorString)")
            }
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
