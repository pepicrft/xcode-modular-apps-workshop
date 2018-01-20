import Foundation
import Client

// MARK: - Label

public struct Label: Codable {
    public let color: String
    public let name: String
}

// MARK: - User

public struct User: Codable {
    public let login: String
    public let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case avatarUrl = "avatar_url"
    }
}

// MARK: - Issue

public struct Issue: Codable {
    
    public let title: String
    public let createdAt: Date
    public let number: Int
    public let labels: [Label]
    public let user: User
    public let repository: String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case createdAt = "created_at"
        case number = "number"
        case labels = "labels"
        case user = "user"
        case repository = "repository"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.number = try container.decode(Int.self, forKey: .number)
        self.labels = try container.decode([Label].self, forKey: .labels)
        self.user = try container.decode(User.self, forKey: .user)
        let repository: [String: Any] = try container.decode([String: Any].self, forKey: .repository)
        self.repository = repository["full_name"] as! String
    }
    
}

// MARK: - Issue + Resources

extension Issue {
    
    public static func assigned() -> Resource<[Issue]> {
        return Resource.jsonResource(makeRequest: { (components) -> URLRequest in
            var mutableComponents = components
            mutableComponents.path = "/issues"
            mutableComponents.queryItems = []
            mutableComponents.queryItems?.append(URLQueryItem(name: "filter", value: "assigned"))
            mutableComponents.queryItems?.append(URLQueryItem(name: "state", value: "open"))
            return URLRequest(url: mutableComponents.url!)
        })
    }
    
    public static func close(number: Int, repository: String) -> Resource<Void> {
        return Resource(makeRequest: { (components) -> URLRequest in
            var mutableComponents = components
            mutableComponents.path = "/issues/\(repository)/issues/\(number)"
            mutableComponents.queryItems = []
            mutableComponents.queryItems?.append(URLQueryItem(name: "state", value: "closed"))
            var request = URLRequest(url: mutableComponents.url!)
            request.httpMethod = "PATCH"
            return request
        }, parse: { _ in return () })
    }
    
    public func close() -> Resource<Void> {
        return Issue.close(number: self.number, repository: self.repository)
    }

    public static func rename(number: Int, repository: String, title: String) -> Resource<Void> {
        return Resource(makeRequest: { (components) -> URLRequest in
            var mutableComponents = components
            mutableComponents.path = "/issues/\(repository)/issues/\(number)"
            mutableComponents.queryItems = []
            mutableComponents.queryItems?.append(URLQueryItem(name: "title", value: title))
            var request = URLRequest(url: mutableComponents.url!)
            request.httpMethod = "PATCH"
            return request
        }, parse: { _ in return () })
    }
    
    public func rename(title: String) -> Resource<Void> {
        return Issue.rename(number: self.number, repository: self.repository, title: title)
    }
    
}
