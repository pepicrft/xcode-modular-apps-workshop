import Foundation
import Client

// MARK: - Label

public struct Label: Decodable {
    public let color: String
    public let name: String
}

// MARK: - User

public struct User: Decodable {
    public let login: String
    public let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case avatarUrl = "avatar_url"
    }
}

// MARK: - Issue

public struct Issue: Decodable {
    
    public let title: String
    public let createdAt: Date
    public let number: Int
    public let labels: [Label]
    public let user: User
    public let repository: String
    public let htmlUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case createdAt = "created_at"
        case number = "number"
        case labels = "labels"
        case user = "user"
        case repository = "repository"
        case htmlUrl = "html_url"
        case repositoryUrl = "repository_url"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = ISO8601DateFormatter().date(from: createdAtString)!
        self.number = try container.decode(Int.self, forKey: .number)
        self.labels = try container.decode([Label].self, forKey: .labels)
        self.user = try container.decode(User.self, forKey: .user)
        self.htmlUrl = try container.decode(URL.self, forKey: .htmlUrl)
        if let repositoryUrl: String = try container.decodeIfPresent(String.self, forKey: .repositoryUrl) {
            self.repository = repositoryUrl.split(separator: "/").suffix(2).joined(separator: "/")
        } else {
            self.repository = try container.decode(String.self, forKey: .repository)
        }
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
            mutableComponents.queryItems?.append(URLQueryItem(name: "sort", value: "updated"))
            mutableComponents.queryItems?.append(URLQueryItem(name: "direction", value: "desc"))
            return URLRequest(url: mutableComponents.url!)
        })
    }
    
    public static func close(number: Int, repository: String) -> Resource<Void> {
        return Resource(makeRequest: { (components) -> URLRequest in
            var mutableComponents = components
            mutableComponents.path = "/repos/\(repository)/issues/\(number)"
            let body = [
                "state": "closed"
            ]
            var request = URLRequest(url: mutableComponents.url!)
            request.httpMethod = "PATCH"
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
            return request
        }, parse: { _ in return () })
    }
    
    public func close() -> Resource<Void> {
        return Issue.close(number: self.number, repository: self.repository)
    }

    public static func rename(number: Int, repository: String, title: String) -> Resource<Void> {
        return Resource(makeRequest: { (components) -> URLRequest in
            var mutableComponents = components
            mutableComponents.path = "/repos/\(repository)/issues/\(number)"
            mutableComponents.queryItems = []
            let body = [
                "title": title
            ]
            mutableComponents.queryItems?.append(URLQueryItem(name: "title", value: title))
            var request = URLRequest(url: mutableComponents.url!)
            request.httpMethod = "PATCH"
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
            return request
        }, parse: { _ in return () })
    }
    
    public func rename(title: String) -> Resource<Void> {
        return Issue.rename(number: self.number, repository: self.repository, title: title)
    }
    
}
