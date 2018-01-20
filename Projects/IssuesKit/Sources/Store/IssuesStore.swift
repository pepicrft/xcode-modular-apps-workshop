import Foundation
import RxSwift

protocol IssuesStoring: AnyObject {
    var observable: Observable<[IssueEntity]> { get }
    func save(_ issues: [IssueEntity]) throws
    func get() -> [IssueEntity]
    func delete()
}

class IssuesStore: IssuesStoring {
    
    // MARK: - Attributes
    
    let subject: PublishSubject<[IssueEntity]> = PublishSubject()
    var observable: Observable<[IssueEntity]> { return subject.asObservable() }
    let containerURL: URL
    
    // MARK: - Init
    
    init(containerURL: URL) {
        self.containerURL = containerURL
    }
    
    init() {
        self.containerURL = Constants.containerURL
    }
    
    // MARK: - Internal
    
    func save(_ issues: [IssueEntity]) throws {
        setupFolder()
        try JSONEncoder().encode(issues).write(to: issuesURL(), options: [])
        subject.onNext(issues)
    }
    
    func get() -> [IssueEntity] {
        guard let data = try? Data(contentsOf: issuesURL()) else { return [] }
        return (try? JSONDecoder().decode([IssueEntity].self, from: data)) ?? []
    }
    
    func delete() {
        try? FileManager.default.removeItem(at: issuesURL())
        subject.onNext([])
    }
    
    // MARK: - Private
    
    private func setupFolder() {
        try? FileManager.default.createDirectory(at: issuesURL().deletingLastPathComponent(),
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
    }
    
    private func issuesURL() -> URL {
        return containerURL.appendingPathComponent("issues.json")
    }
    
}
