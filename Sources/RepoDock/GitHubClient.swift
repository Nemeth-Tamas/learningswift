import Foundation

enum GitHubClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not create the GitHub API URL."
        case .invalidResponse:
            return "GitHub returned an invalid HTTP response."
        case .httpStatus(let statusCode):
            return "GitHub returned HTTP \(statusCode)."
        }
    }
}

struct GitHubClient {
    static func fetchRepository(owner: String, name: String) async throws -> Repository {
        guard let url = URL(string: "https://api.github.com/repos/\(owner)/\(name)") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("RepoDock", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw GitHubClientError.httpStatus(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Repository.self, from: data)
    }
}
