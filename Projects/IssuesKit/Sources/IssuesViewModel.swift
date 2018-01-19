import Foundation

public protocol IssuesViewModeling: AnyObject {
    var issues: [Issue] { get }
    var authenticated: Bool { get }
    func viewDidLoad()
    func paginageIfNeeded()
    func closeIssue(at index: UInt, completion: (Error?) -> ())
    func renameIssue(at index: UInt)
}

public protocol IssuesViewing: AnyObject {
    func issuesDidChange()
    func authenticatedDidChange()
}

public struct Label {
    public let color: String
    public let name: String
}

public struct User {
    public let login: String
    public let avatarUrl: String
}

public struct Issue {
    public let title: String
    public let createdAt: Date
    public let number: Int
    public let labels: [Label]
    public let user: User
}

public final class IssuesViewModel: IssuesViewModeling {
    
    // MARK: - Attributes
    
    private weak var view: IssuesViewing?
    
    // MARK: - Init
    
    public init(view: IssuesViewing) {
        self.view = view
    }
    
    // MARK: - HomeViewModeling
    
    public let issues: [Issue] = [] // TODO
    public let authenticated: Bool = false
    
    public func closeIssue(at index: UInt, completion: (Error?) -> ()) {
        // TODO
    }
    
    public func renameIssue(at index: UInt) {
        // TODO
    }
    
    public func viewDidLoad() {
        self.view?.authenticatedDidChange()
        // TODO
    }
    
    public func paginageIfNeeded() {
        // TODO
    }
    
}
