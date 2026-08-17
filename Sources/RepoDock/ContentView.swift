import Foundation
import SwiftUI

struct ContentView: View {
    @State private var repositoryPath = "Nemeth-Tamas/bareproxy"
    @State private var repository: Repository?
    @State private var latestCommit: GitCommit?
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
                } else if let repository, let latestCommit {
                    RepositoryDetailView(
                        repository: repository,
                        latestCommit: latestCommit
                    )
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
            latestCommit = nil
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
            async let repositoryRequest = GitHubClient.fetchRepository(
                owner: owner,
                name: name
            )

            async let commitRequest = GitHubClient.fetchLatestCommit(
                owner: owner,
                name: name
            )

            let (loadedRepository, loadedCommit) = try await (
                repositoryRequest,
                commitRequest
            )

            repository = loadedRepository
            latestCommit = loadedCommit
        } catch {
            repository = nil
            latestCommit = nil
            errorMessage = error.localizedDescription
        }
    }
}
