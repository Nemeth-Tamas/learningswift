import Foundation

enum GitHubClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case noCommits

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not create the GitHub API URL."
        case .invalidResponse:
            return "GitHub returned an invalid HTTP response."
        case .httpStatus(let statusCode):
            return "GitHub returned HTTP \(statusCode)."
        case .noCommits:
            return "This repository has no commits."
        }
    }
}

struct GitHubClient {
    static func fetchRepository(owner: String, name: String) async throws -> Repository {
        let data = try await fetchData(
            from: "https://api.github.com/repos/\(owner)/\(name)"
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Repository.self, from: data)
    }

    static func fetchLatestCommit(owner: String, name: String) async throws -> GitCommit {
        let data = try await fetchData(
            from: "https://api.github.com/repos/\(owner)/\(name)/commits?per_page=1"
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let commits = try decoder.decode([GitCommit].self, from: data)

        guard let latestCommit = commits.first else {
            throw GitHubClientError.noCommits
        }

        return latestCommit
    }

    private static func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
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

        return data
    }
}
