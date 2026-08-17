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

struct Repository: Decodable, Equatable {
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let openIssuesCount: Int
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case language
        case stargazersCount = "stargazers_count"
        case openIssuesCount = "open_issues_count"
        case updatedAt = "update_at"
    }
}

struct ContentView: View {
    private let repository = Repository(
        name: "bareproxy",
        description: "Repository model wired up. Real GitHub data comes next.",
        language: "Rust",
        stargazersCount: 0,
        openIssuesCount: 0,
        updatedAt: "Not fetched yet"
    )

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
            LabeledContent("Starts", value: "\(repository.stargazersCount)")
            LabeledContent("Open issues", value: "\(repository.openIssuesCount)")
            LabeledContent("Updated", value: repository.updatedAt)
        }
        .frame(minWidth: 560, minHeight: 360)
        .padding(32)
    }
}
