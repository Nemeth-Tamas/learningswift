import Foundation
import Testing

@testable import RepoDock

@Test func decodesRepositoryFromGitHubJSON() throws {
    let json = """
        {
            "name": "bareproxy",
            "description": "A reverse proxy",
            "language": "Rust",
            "stargazers_count": 7,
            "open_issues_count": 2,
            "updated_at": "2026-08-17T08:00:00Z"
        }
        """

    let data = try #require(json.data(using: .utf8))
    let repository = try JSONDecoder().decode(Repository.self, from: data)

    #expect(repository.name == "bareproxy")
    #expect(repository.description == "A reverse proxy")
    #expect(repository.language == "Rust")
    #expect(repository.stargazersCount == 7)
    #expect(repository.openIssuesCount == 2)
    #expect(repository.updatedAt == "2026-08-17T08:00:00Z")
}
