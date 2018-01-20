import Foundation
import Client

public extension Client {
    
    /// Initializes and returns a GitHub client.
    ///
    /// - Parameter accessToken: function that returns the access token.
    /// - Returns: GitHub client.
    public static func github(accessToken: @escaping () -> String?) -> Client {
        let urlComponents = URLComponents(string: "https://api.github.com")!
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        let session = URLSession.init(configuration: config)
        return Client(baseURLComponents: urlComponents,
                      session: session) { request in
                        var mutableRequest = request
                        if mutableRequest.allHTTPHeaderFields == nil  { mutableRequest.allHTTPHeaderFields = [:] }
                        mutableRequest.allHTTPHeaderFields?["Content-Type"] = "application/json"
                        mutableRequest.allHTTPHeaderFields?["Cache-Control"] = "max-age=0, private, must-revalidate"
                        if let token = accessToken() {
                            mutableRequest.allHTTPHeaderFields?["Authorization"] = "token \(token)"
                        }
                        return mutableRequest
        }
    }
    
}
