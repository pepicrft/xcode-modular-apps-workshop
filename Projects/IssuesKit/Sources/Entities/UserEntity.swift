import Foundation
import GitHubKit

public struct UserEntity: Codable {
    public let login: String
    public let avatarUrl: String?
    init(user: User) {
        self.login = user.login
        self.avatarUrl = user.avatarUrl
    }
}
