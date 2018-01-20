import Foundation
import Result

public enum GitHubLoginError: Error {
    case alreadyActive
    case other(Error)
    case unknown
}

public protocol GitHubLoginHandlerDelegate: AnyObject {
    func open(url: URL)
    func completed(_ result: Result<String, GitHubLoginError>)
}

public protocol GitHubLoginHandling: AnyObject {
    func start() throws
    func shouldOpen(url: URL) -> Bool
}

public class GitHubLoginHandler: GitHubLoginHandling {
    
    // MARK: - Attributes
    
    private let clientId: String
    private let clientSecret: String
    private let redirectUri: String
    private let scopes: [String]
    private let allowSignup: Bool
    private let state: String = "issues-state"
    private weak var delegate: GitHubLoginHandlerDelegate?
    private var active: Bool = false
    
    // MARK: - Init
    
    public init(clientId: String,
                clientSecret: String,
                redirectUri: String,
                scopes: [String],
                allowSignup: Bool = true,
                delegate: GitHubLoginHandlerDelegate) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.scopes = scopes
        self.allowSignup = allowSignup
        self.delegate = delegate
    }
    
    // MARK: - Public
    
    public func start() throws {
        if self.active { throw GitHubLoginError.alreadyActive }
        self.active = true
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "client_id", value: clientId))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
        queryItems.append(URLQueryItem(name: "scope", value: scopes.joined(separator: " ")))
        queryItems.append(URLQueryItem(name: "state", value: state))
        queryItems.append(URLQueryItem(name: "allow_signup", value: allowSignup ? "true": "false"))
        components.queryItems = queryItems
        delegate?.open(url: components.url!)
    }
    
    public func shouldOpen(url: URL) -> Bool {
        if url.baseURL?.absoluteString.contains(redirectUri) == false { return true }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        func queryItem(name: String) -> String? {
            return components.queryItems?.first(where: {$0.name == name}).flatMap({$0.value})
        }
        if queryItem(name: "state") != state { return true }
        guard let code = queryItem(name: "code") else { return true }
        getToken(code: code)
        return false
    }
    
    // MARK: - Fileprivate
    
    fileprivate func getToken(code: String) {
        let session = URLSession.shared
        var components = URLComponents(string: "https://github.com/login/oauth/access_token")!
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "client_id", value: clientId))
        queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
        queryItems.append(URLQueryItem(name: "code", value: code))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
        queryItems.append(URLQueryItem(name: "state", value: state))
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.allHTTPHeaderFields = [:]
        request.allHTTPHeaderFields?["Accept"] = "application/json"
        request.httpMethod = "POST"
        session.dataTask(with: request) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                defer {
                    self?.active = false
                }
                if let error = error {
                    self?.delegate?.completed(.failure(.other(error)))
                } else if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
                        let token = json["access_token"]!
                        self?.delegate?.completed(.success(token))
                    } catch {
                        self?.delegate?.completed(.failure(.other(error)))
                    }
                } else {
                    self?.delegate?.completed(.failure(.unknown))
                }
            }
        }.resume()
    }
    
}
