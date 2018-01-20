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
    private let sessionController: SessionControlling
    private let store: IssuesStoring
    private let client: Client
    private let service: IssuesSyncServicing
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Init
    
    public init(view: IssuesViewing) {
        self.view = view
        self.sessionController = Services.sessionController
        self.store = Services.issuesStore
        self.client = Services.githubInstance
        self.service = IssuesSyncService(client: self.client,
                                         store: self.store)
    }
    
    init(view: IssuesViewing,
         sessionController: SessionControlling,
         service: IssuesSyncServicing,
         client: Client,
         store: IssuesStoring) {
        self.view = view
        self.sessionController = sessionController
        self.service = service
        self.client = client
        self.store = store
    }
    
    // MARK: - HomeViewModeling
    
    public var issues: [IssueEntity] = [] {
        didSet {
            self.view?.issuesDidChange()
        }
    }
    public var authenticated: Bool { return sessionController.authenticated.value }
    
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
        sessionController.authenticated.asObservable()
            .subscribe(onNext: { [weak self] _ in  self?.view?.authenticatedDidChange() })
            .disposed(by: disposeBag)
        store.observable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] issues in self?.issues = issues })
            .disposed(by: disposeBag)
        reload()
    }
    
    public func logout() {
        sessionController.logout()
    }
    
    public func reload() {
        service.sync { }
    }
}
