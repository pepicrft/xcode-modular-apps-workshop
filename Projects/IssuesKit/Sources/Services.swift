import Foundation
import Client
import GitHubKit

fileprivate var _githubClient: Client!

class Services {
    
    static var githubInstance: Client! {
        if _githubClient == nil {
            _githubClient = Client.github { () -> String? in
                return Services.secureStore.get(key: .githubAccessToken)
            }
        }
        return _githubClient
    }
    
    static let secureStore: SecureStoring = SecureStore()
    
}
