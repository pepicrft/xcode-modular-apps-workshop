import UIKit
import Messages
import IssuesUI
import IssuesKit

class MessagesViewController: MSMessagesAppViewController, IssuesViewing, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    
    let tableView = UITableView(frame: .zero)
    let notLoggedInLabel = UILabel()
    var viewModel: IssuesViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = IssuesViewModel(view: self)
        setup()
        viewModel.viewDidLoad()
        viewModel.reload()
    }
    
    // MARK - Fileprivate
    
    fileprivate func setup() {
        view.addSubview(notLoggedInLabel)
        notLoggedInLabel.text = "Login first using the app"
        notLoggedInLabel.translatesAutoresizingMaskIntoConstraints = false
        notLoggedInLabel.isHidden = true
        NSLayoutConstraint.activate([
                notLoggedInLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                notLoggedInLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        tableView.register(IssueCell.classForCoder(), forCellReuseIdentifier: "default")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupVisibility() {
        notLoggedInLabel.isHidden = viewModel.authenticated
        tableView.isHidden = !viewModel.authenticated
    }
    
    // MARK: - IssuesViewing
    
    func issuesDidChange() {
        tableView.reloadData()
    }
    
    func authenticatedDidChange() {
        setupVisibility()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.issues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IssueCell! = tableView.dequeueReusableCell(withIdentifier: "default") as! IssueCell
        let issue = viewModel.issues[indexPath.row]
        cell.present(issue: issue)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let issue = viewModel.issues[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        activeConversation?.insertText(issue.htmlUrl.absoluteString, completionHandler: nil)
        if presentationStyle == .expanded {
            requestPresentationStyle(.compact)
        }
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        viewModel.reload()
        setupVisibility()
    }

}
