import Foundation
import Client

public extension Client {
    
    /// Initializes and returns a GitHub client.
    ///
    /// - Parameter accessToken: function that returns the access token.
    /// - Returns: GitHub client.
    public static func github(accessToken: @escaping () -> String?) -> Client {
        let urlComponents = URLComponents(string: "https://api.github.com")!
        return Client(baseURLComponents: urlComponents,
                      session: URLSession.shared) { request in
                        var mutableRequest = request
                        if mutableRequest.allHTTPHeaderFields == nil  { mutableRequest.allHTTPHeaderFields = [:] }
                        mutableRequest.allHTTPHeaderFields?["Content-Type"] = "application/json"
                        if let token = accessToken() {
                            mutableRequest.allHTTPHeaderFields?["Authorization"] = "token \(token)"
                        }
                        return mutableRequest
        }
    }
    
}
