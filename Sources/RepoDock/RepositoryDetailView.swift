import SwiftUI

struct RepositoryDetailView: View {
    let repository: Repository
    let latestCommit: GitCommit

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(repository.owner.login)/\(repository.name)")
                        .font(.largeTitle.bold())

                    Text(repository.description ?? "No description")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    RepositoryStatView(
                        title: "Language",
                        value: repository.language ?? "Unknown",
                        systemImage: "chevron.left.forwardslash.chevron.right"
                    )

                    RepositoryStatView(
                        title: "Default branch",
                        value: repository.defaultBranch,
                        systemImage: "folder.fill"
                    )
                }

                GridRow {
                    RepositoryStatView(
                        title: "Stars",
                        value: "\(repository.stargazersCount)",
                        systemImage: "star.fill"
                    )

                    RepositoryStatView(
                        title: "Forks",
                        value: "\(repository.forksCount)",
                        systemImage: "arrow.triangle.branch"
                    )
                }

                GridRow {
                    RepositoryStatView(
                        title: "Open issues",
                        value: "\(repository.openIssuesCount)",
                        systemImage: "exclamationmark.circle.fill"
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Updated")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(
                            repository.updatedAt,
                            format: .dateTime
                                .year()
                                .month()
                                .day()
                                .hour()
                                .minute()
                        )
                        .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                }
            }

            Divider()

            LatestCommitView(commit: latestCommit)
        }
    }
}
