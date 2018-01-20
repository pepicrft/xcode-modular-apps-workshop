import Foundation
import RxSwift

public protocol IssuesViewModeling: AnyObject {
    var issues: [IssueEntity] { get }
    var authenticated: Bool { get }
    func viewDidLoad()
    func paginageIfNeeded()
    func closeIssue(at index: UInt, completion: (Error?) -> ())
    func renameIssue(at index: UInt)
    func logout()
}

public protocol IssuesViewing: AnyObject {
    func issuesDidChange()
    func authenticatedDidChange()
}

public struct LabelEntity {
    public let color: String
    public let name: String
}

public struct UserEntity {
    public let login: String
    public let avatarUrl: String
}

public struct IssueEntity {
    public let title: String
    public let createdAt: Date
    public let number: Int
    public let labels: [LabelEntity]
    public let user: UserEntity
}

public final class IssuesViewModel: IssuesViewModeling {
    
    // MARK: - Attributes
    
    private weak var view: IssuesViewing?
    private let secureStore: SecureStoring
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Init
    
    public init(view: IssuesViewing) {
        self.view = view
        self.secureStore = Services.secureStore
    }
    
    init(view: IssuesViewing,
                secureStore: SecureStoring) {
        self.view = view
        self.secureStore = secureStore
    }
    
    // MARK: - HomeViewModeling
    
    public let issues: [IssueEntity] = [] // TODO
    public var authenticated: Bool { return secureStore.get(key: .githubAccessToken) != nil }
    
    public func closeIssue(at index: UInt, completion: (Error?) -> ()) {
        // TODO
    }
    
    public func renameIssue(at index: UInt) {
        // TODO
    }
    
    public func viewDidLoad() {
        self.view?.authenticatedDidChange()
        secureStore.observe(key: .githubAccessToken)
            .subscribe(onNext: { [weak self] _ in  self?.view?.authenticatedDidChange() })
            .disposed(by: disposeBag)
    }
    
    public func logout() {
        secureStore.delete(key: .githubAccessToken)
    }
    
    public func paginageIfNeeded() {
        // TODO
    }
    
}
