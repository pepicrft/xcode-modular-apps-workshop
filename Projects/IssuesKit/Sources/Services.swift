import Foundation
import Client
import GitHubKit

fileprivate var _githubClient: Client!

class Services {
    
    static var githubInstance: Client! {
        if _githubClient == nil {
            _githubClient = Client.github { () -> String? in
                let token = "" // TODO
                return token
            }
        }
        return _githubClient
    }
    
}
