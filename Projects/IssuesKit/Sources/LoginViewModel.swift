import Foundation

#if os(iOS)
public protocol LoginViewModeling: AnyObject {
    func login()
    func shouldLoad(url: URL) -> Bool
}

public protocol LoginViewing: AnyObject {
    func open(url: URL)
    func logged(error: Error?)
}

public final class LoginViewModel: LoginViewModeling {
    
    // MARK: - Attributes
    
    private weak var view: LoginViewing?
    
    
    public init(view: LoginViewing?) {
        self.view = view
    }
    
    public func login() {
        view?.open(url: URL(string: "https://google.com")!)
        // TODO
    }
    
    public func shouldLoad(url: URL) -> Bool {
        // TODO
        return false
    }
    
}
#endif
