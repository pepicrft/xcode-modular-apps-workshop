import Foundation
import GitHubKit

public struct IssueEntity: Codable {
    public let title: String
    public let createdAt: Date
    public let number: Int
    public let labels: [LabelEntity]
    public let user: UserEntity
    public let repository: String
    public let htmlUrl: URL
    init(issue: Issue) {
        self.title = issue.title
        self.createdAt = issue.createdAt
        self.number = issue.number
        self.repository = issue.repository
        self.labels = issue.labels.map(LabelEntity.init)
        self.user = UserEntity(user: issue.user)
        self.htmlUrl = issue.htmlUrl
    }
}
