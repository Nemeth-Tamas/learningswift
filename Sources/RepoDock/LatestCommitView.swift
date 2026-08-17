import SwiftUI

struct LatestCommitView: View {
    let commit: GitCommit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Latest commit", systemImage: "clock.arrow.circlepath")
                .font(.headline)

            Text(commit.summary)
                .font(.title3.weight(.medium))
                .lineLimit(2)

            HStack(spacing: 12) {
                Text(commit.shortSHA)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())

                Text(commit.details.author.name)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(
                    commit.details.author.date,
                    format: .dateTime
                        .year()
                        .month()
                        .day()
                        .hour()
                        .minute()
                )
                .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }
}
