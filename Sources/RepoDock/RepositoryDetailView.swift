import SwiftUI

struct RepositoryDetailView: View {
    let repository: Repository

    var body: some View {
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
    }
}
