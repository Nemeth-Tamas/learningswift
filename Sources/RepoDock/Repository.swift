import Foundation

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
