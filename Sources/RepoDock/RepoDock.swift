import Foundation
import SwiftUI

@main
struct RepoDockApp: App {
    var body: some Scene {
        WindowGroup("RepoDock") {
            ContentView()
        }
        .defaultSize(width: 720, height: 480)
    }
}

struct Repository: Decodable, Equatable, Sendable {
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let openIssuesCount: Int
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case language
        case stargazersCount = "stargazers_count"
        case openIssuesCount = "open_issues_count"
        case updatedAt = "updated_at"
    }
}

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

struct ContentView: View {
    @State private var repositoryPath = "Nemeth-Tamas/bareproxy"
    @State private var repository: Repository?
    @State private var errorMessage: String?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                TextField("owner/repository", text: $repositoryPath)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            await loadRepository()
                        }
                    }

                Button("Load") {
                    Task {
                        await loadRepository()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isLoading)
            }

            Group {
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()

                        Text("Fetching \(repositoryPath) from GitHub…")
                            .foregroundStyle(.secondary)
                    }
                } else if let repository {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 36))

                            VStack(alignment: .leading) {
                                Text(repository.name)
                                    .font(.largeTitle.bold())

                                Text(repository.description ?? "No description")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()

                        LabeledContent("Language", value: repository.language ?? "Unknown")
                        LabeledContent("Stars", value: "\(repository.stargazersCount)")
                        LabeledContent("Open issues", value: "\(repository.openIssuesCount)")
                        LabeledContent("Updated") {
                            Text(
                                repository.updatedAt,
                                format: .dateTime
                                    .year()
                                    .month()
                                    .day()
                                    .hour()
                                    .minute()
                            )
                        }
                    }
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 36))

                        Text("Could not load repository")
                            .font(.headline)

                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 560, minHeight: 360)
        .padding(32)
        .task {
            await loadRepository()
        }
    }

    @MainActor
    private func loadRepository() async {
        let parts =
            repositoryPath
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "/", omittingEmptySubsequences: false)

        guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else {
            repository = nil
            errorMessage = "Enter a repository as owner/name."
            isLoading = false
            return
        }

        let owner = String(parts[0])
        let name = String(parts[1])

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            repository = try await GitHubClient.fetchRepository(
                owner: owner,
                name: name
            )
        } catch {
            repository = nil
            errorMessage = error.localizedDescription
        }
    }
}
