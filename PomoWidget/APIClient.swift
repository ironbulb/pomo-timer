import Foundation

class APIClient {
    // TODO: Replace with your actual Vercel deployment URL
    private let baseURL = "https://your-app.vercel.app"

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
