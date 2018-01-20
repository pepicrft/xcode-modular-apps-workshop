import Foundation
import Client
import GitHubKit
import Result
import RxSwift

protocol IssuesSyncServicing {
    func sync(completion: @escaping () -> ())
    var issues: Variable<[IssueEntity]> { get }
}

public struct LabelEntity {
    public let color: String
    public let name: String
    init(label: Label) {
        self.color = label.color
        self.name = label.name
    }
}

public struct UserEntity {
    public let login: String
    public let avatarUrl: String?
    init(user: User) {
        self.login = user.login
        self.avatarUrl = user.avatarUrl
    }
}

public struct IssueEntity {
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

class IssuesSyncService: IssuesSyncServicing {
    
    // MARK: - Private
    
    let client: Client
    let issues: Variable<[IssueEntity]> = Variable([])
    
    // MARK: - Init
    
    init(client: Client = Services.githubInstance) {
        self.client = client
    }
    
    // MARK: - Internal
    
    func sync(completion: @escaping () -> ()) {
        client.execute(resource: Issue.assigned()) { (result) in
            self.response(result: result, issues: [], completion: completion)
        }.resume()
    }
    
    // MARK: - Private
    
    func sync(next: Link, issues: [IssueEntity], completion: @escaping () -> ()) {
        client.execute(resource: resource(link: next, type: Issue.self)) { (result) in
            self.response(result: result, issues: issues, completion: completion)
        }.resume()
    }
    
    func response(result: Result<ClientResponse<([Issue], Link?)>, ClientError>, issues: [IssueEntity], completion: @escaping () -> ()) {
        guard let value = result.value else {
            syncCompleted(issues: issues, completion: completion)
            return
        }
        var mutableIssues = issues
        mutableIssues.append(contentsOf: value.value.0.map(IssueEntity.init))
        if let link = value.value.1 {
            self.sync(next: link, issues: mutableIssues, completion: completion)
        } else {
            self.syncCompleted(issues: mutableIssues, completion: completion)
        }
    }
    
    func syncCompleted(issues: [IssueEntity], completion: @escaping () -> ()) {
        self.issues.value = issues
        completion()
    }
    
}
