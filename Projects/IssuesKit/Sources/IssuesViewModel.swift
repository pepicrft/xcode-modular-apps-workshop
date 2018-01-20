import Foundation
import RxSwift
import GitHubKit
import Client

public protocol IssuesViewModeling: AnyObject {
    var issues: [IssueEntity] { get }
    var authenticated: Bool { get }
    func viewDidLoad()
    func closeIssue(at index: UInt, completion: @escaping (Error?) -> ())
    func renameIssue(at index: UInt, title: String, completion: @escaping (Error?) -> ())
    func logout()
    func reload()
}

public protocol IssuesViewing: AnyObject {
    func issuesDidChange()
    func authenticatedDidChange()
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

public final class IssuesViewModel: IssuesViewModeling {
    
    // MARK: - Attributes
    
    private weak var view: IssuesViewing?
    private let secureStore: SecureStoring
    private let disposeBag: DisposeBag = DisposeBag()
    private let client: Client
    
    // MARK: - Init
    
    public init(view: IssuesViewing) {
        self.view = view
        self.secureStore = Services.secureStore
        self.client = Services.githubInstance
    }
    
    init(view: IssuesViewing,
         secureStore: SecureStoring,
         client: Client) {
        self.view = view
        self.secureStore = secureStore
        self.client = client
    }
    
    // MARK: - HomeViewModeling
    
    public var issues: [IssueEntity] = [] {
        didSet {
            self.view?.issuesDidChange()
        }
    }
    public var authenticated: Bool { return secureStore.get(key: .githubAccessToken) != nil }
    
    public func closeIssue(at index: UInt, completion: @escaping (Error?) -> ()) {
        let issue = issues[Int(index)]
        client.execute(resource: Issue.close(number: issue.number,
                                             repository: issue.repository)) { [weak self] (result) in
                                                DispatchQueue.main.async { completion(result.error) }
                                                self?.reload()
        }.resume()
    }
    
    public func renameIssue(at index: UInt, title: String, completion: @escaping (Error?) -> ()) {
        let issue = issues[Int(index)]
        client.execute(resource: Issue.rename(number: issue.number,
                                              repository: issue.repository,
                                              title: title)) { [weak self] (result) in
                                                DispatchQueue.main.async { completion(result.error) }
                                                self?.reload()
        }.resume()
    }
    
    public func viewDidLoad() {
        self.view?.authenticatedDidChange()
        secureStore.observe(key: .githubAccessToken)
            .subscribe(onNext: { [weak self] _ in  self?.view?.authenticatedDidChange() })
            .disposed(by: disposeBag)
        reload()
    }
    
    public func logout() {
        secureStore.delete(key: .githubAccessToken)
    }
    
    public func reload() {
        client.execute(resource: Issue.assigned()) { [weak self] (result) in
            guard let issues = result.value else { return }
            let entities = issues.value.map(IssueEntity.init)
            DispatchQueue.main.async { self?.issues = entities }
        }.resume()
    }
}
