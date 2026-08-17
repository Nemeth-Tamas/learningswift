import Foundation

struct GitCommit: Decodable, Equatable, Sendable {
    struct Details: Decodable, Equatable, Sendable {
        struct Author: Decodable, Equatable, Sendable {
            let name: String
            let date: Date
        }

        let author: Author
        let message: String
    }

    let sha: String
    let details: Details

    enum CodingKeys: String, CodingKey {
        case sha
        case details = "commit"
    }

    var shortSHA: String {
        String(sha.prefix(7))
    }

    var summary: String {
        details.message
            .split(separator: "\n", maxSplits: 1)
            .first
            .map(String.init) ?? details.message
    }
}
