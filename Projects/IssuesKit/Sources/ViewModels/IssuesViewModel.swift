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

public final class IssuesViewModel: IssuesViewModeling {
    
    // MARK: - Attributes
    
    private weak var view: IssuesViewing?
    private let secureStore: SecureStoring
    private let disposeBag: DisposeBag = DisposeBag()
    private let service: IssuesSyncServicing
    private let client: Client
    
    // MARK: - Init
    
    public init(view: IssuesViewing) {
        self.view = view
        self.secureStore = Services.secureStore
        self.service = IssuesSyncService()
        self.client = Services.githubInstance
    }
    
    init(view: IssuesViewing,
         secureStore: SecureStoring,
         service: IssuesSyncServicing,
         client: Client) {
        self.view = view
        self.secureStore = secureStore
        self.service = service
        self.client = client
    }
    
    // MARK: - HomeViewModeling
    
    public var issues: [IssueEntity] { return self.service.issues.value }
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
        service.issues.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.view?.issuesDidChange() })
            .disposed(by: disposeBag)
        reload()
    }
    
    public func logout() {
        secureStore.delete(key: .githubAccessToken)
    }
    
    public func reload() {
        service.sync { }
    }
}
