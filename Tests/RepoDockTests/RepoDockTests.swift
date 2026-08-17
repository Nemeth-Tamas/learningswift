import Foundation
import Testing

@testable import RepoDock

@Test func decodesRepositoryFromGitHubJSON() throws {
    let json = """
        {
            "name": "bareproxy",
            "owner": {
                "login": "Nemeth-Tamas"
            },
            "description": "A reverse proxy",
            "language": "Rust",
            "stargazers_count": 7,
            "open_issues_count": 2,
            "forks_count": 3,
            "default_branch": "main",
            "updated_at": "2026-08-17T08:00:00Z"
        }
        """

    let data = try #require(json.data(using: .utf8))

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let repository = try decoder.decode(Repository.self, from: data)

    #expect(repository.name == "bareproxy")
    #expect(repository.owner.login == "Nemeth-Tamas")
    #expect(repository.description == "A reverse proxy")
    #expect(repository.language == "Rust")
    #expect(repository.stargazersCount == 7)
    #expect(repository.openIssuesCount == 2)
    #expect(repository.forksCount == 3)
    #expect(repository.defaultBranch == "main")
    #expect(repository.updatedAt == Date(timeIntervalSince1970: 1_786_953_600))
}

@Test func decodesLatestCommitFromGitHubJSON() throws {
    let json = """
        [
            {
                "sha": "e4a357be449d2e15e4303eab048f2f550d40947d",
                "commit": {
                    "author": {
                        "name": "Németh Tamás",
                        "date": "2026-08-17T10:04:02Z"
                    },
                    "message": "feat: implement TLS HelloRetryRequest\\n\\nMore details"
                }
            }
        ]
        """

    let data = try #require(json.data(using: .utf8))

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let commits = try decoder.decode([GitCommit].self, from: data)
    let commit = try #require(commits.first)

    #expect(commit.sha == "e4a357be449d2e15e4303eab048f2f550d40947d")
    #expect(commit.shortSHA == "e4a357b")
    #expect(commit.summary == "feat: implement TLS HelloRetryRequest")
    #expect(commit.details.author.name == "Németh Tamás")
    #expect(commit.details.author.date == Date(timeIntervalSince1970: 1_786_961_042))
}