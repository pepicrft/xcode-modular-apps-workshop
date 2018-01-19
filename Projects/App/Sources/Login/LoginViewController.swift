import Foundation
import UIKit
import WebKit
import IssuesKit

class LoginViewController: UIViewController, LoginViewing, UIWebViewDelegate {

    // MARK: - Attributes
    
    let webview: UIWebView = UIWebView()
    var viewModel: LoginViewModeling!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        format()
    }
    
    // MARK: - Private
    
    private func setup() {
        viewModel = LoginViewModel(view: self)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        viewModel.login()
    }
    
    private func format() {
        self.view.backgroundColor = .white
        self.title = "Login"
        webview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webview)
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: view.topAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        webview.delegate = self
    }
    
    // MARK: - Internal
    
    @objc func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LoginViewing
    
    func open(url: URL) {
        webview.loadRequest(URLRequest(url: url))
    }
    
    func logged(error: Error?) {
        if let _ = error {
            let alert = UIAlertController(title: "Error", message: "There was an unexpected login error", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] (_) in
                self?.viewModel.login()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (_) in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return false }
        return self.viewModel.shouldLoad(url: url)
    }
    
}
