import Foundation
import RxSwift

protocol SessionControlling: AnyObject {
    var authenticated: Variable<Bool> { get }
    func authenticated(token: String)
    func logout()
}

class SessionController: SessionControlling {
    
    // MARK: - Attributes
    
    private let issuesStore: IssuesStoring
    private let secureStore: SecureStoring
    private let disposeBag = DisposeBag()
    let authenticated: Variable<Bool>
    
    // MARK: - Init
    
    init(issuesStore: IssuesStoring,
         secureStore: SecureStoring) {
        self.issuesStore = issuesStore
        self.secureStore = secureStore
        self.authenticated = Variable<Bool>(secureStore.get(key: .githubAccessToken) != nil)
        self.secureStore
            .observe(key: .githubAccessToken).map({$0 != nil})
            .subscribe(onNext: { [weak self] authenticated in self?.authenticated.value = authenticated })
            .disposed(by: disposeBag)
    }
    
    func logout() {
        issuesStore.delete()
        secureStore.delete(key: .githubAccessToken)
    }
    
    func authenticated(token: String) {
        secureStore.set(token, key: .githubAccessToken)
    }
}
