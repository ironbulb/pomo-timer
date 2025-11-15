import Foundation

struct GoogleCalendarEvent: Identifiable, Codable {
    let id: String
    let title: String
    let start: String
    let end: String?
    let description: String?
    let location: String?
    let isAllDay: Bool

    var startDate: Date? {
        return ISO8601DateFormatter().date(from: start)
    }

    var endDate: Date? {
        guard let end = end else { return nil }
        return ISO8601DateFormatter().date(from: end)
    }

    var formattedTime: String {
        guard let startDate = startDate else { return "" }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        if isAllDay {
            return "All Day"
        } else if let endDate = endDate {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        } else {
            return formatter.string(from: startDate)
        }
    }
}

struct GoogleCalendarResponse: Codable {
    let events: [GoogleCalendarEvent]
}

class GoogleCalendarService {
    private let baseURL = "https://pomo-timer-eta.vercel.app"

    func fetchEvents(timeMin: Date? = nil, timeMax: Date? = nil) async throws -> [GoogleCalendarEvent] {
        var urlString = "\(baseURL)/api/gcal"
        var queryItems: [String] = []

        let formatter = ISO8601DateFormatter()

        if let timeMin = timeMin {
            queryItems.append("timeMin=\(formatter.string(from: timeMin))")
        }

        if let timeMax = timeMax {
            queryItems.append("timeMax=\(formatter.string(from: timeMax))")
        }

        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let calendarResponse = try decoder.decode(GoogleCalendarResponse.self, from: data)
        return calendarResponse.events
    }

    func fetchTodayEvents() async throws -> [GoogleCalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        return try await fetchEvents(timeMin: startOfDay, timeMax: endOfDay)
    }

    func fetchThisWeekEvents() async throws -> [GoogleCalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)

        return try await fetchEvents(timeMin: startOfWeek, timeMax: endOfWeek)
    }
}
