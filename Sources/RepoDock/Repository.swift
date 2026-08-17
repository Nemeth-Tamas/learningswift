import Foundation

struct Repository: Decodable, Equatable, Sendable {
    struct Owner: Decodable, Equatable, Sendable {
        let login: String
    }

    let name: String
    let owner: Owner
    let description: String?
    let language: String?
    let stargazersCount: Int
    let openIssuesCount: Int
    let forksCount: Int
    let defaultBranch: String
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case name
        case owner
        case description
        case language
        case stargazersCount = "stargazers_count"
        case openIssuesCount = "open_issues_count"
        case forksCount = "forks_count"
        case defaultBranch = "default_branch"
        case updatedAt = "updated_at"
    }
}
