import Foundation

enum TimerFilter: String, Codable {
    case any = "Any"
    case today = "Today"
    case thisWeek = "This Week"
    case noTimer = "No Timer"
    case hasTimer = "Has Timer"
}

struct FilterPane: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var priority: String?
    var status: String?
    var project: String?
    var area: String?
    var checked: Bool?
    var timerFilter: TimerFilter?

    init(id: String = UUID().uuidString, name: String, priority: String? = nil, status: String? = nil, project: String? = nil, area: String? = nil, checked: Bool? = nil, timerFilter: TimerFilter? = nil) {
        self.id = id
        self.name = name
        self.priority = priority
        self.status = status
        self.project = project
        self.area = area
        self.checked = checked
        self.timerFilter = timerFilter
    }

    var filterDescription: String {
        var parts: [String] = []
        if let checked = checked {
            parts.append(checked ? "Checked" : "Unchecked")
        }
        if let area = area {
            parts.append(area)
        }
        if let project = project {
            parts.append(project)
        }
        if let status = status {
            parts.append(status)
        }
        if let priority = priority {
            parts.append("P\(priority)")
        }
        if let timer = timerFilter, timer != .any {
            parts.append(timer.rawValue)
        }
        return parts.isEmpty ? "All Tasks" : parts.joined(separator: " • ")
    }
}
