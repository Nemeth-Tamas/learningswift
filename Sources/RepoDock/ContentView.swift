import Foundation
import SwiftUI

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
