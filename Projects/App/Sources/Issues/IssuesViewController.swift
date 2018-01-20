import UIKit
import IssuesKit
import SafariServices

class IssuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IssuesViewing, LoginDelegate {
    
    // MARK: - Attributes
    
    private let tableView: UITableView = UITableView()
    private var viewModel: IssuesViewModeling!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        format()
        setup()
    }
    
    // MARK: - Private
    
    private func format() {
        self.title = "Issues"
        self.view.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(IssueCell.classForCoder(), forCellReuseIdentifier: "default")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.topAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    private func setup() {
        viewModel = IssuesViewModel(view: self)
        viewModel.viewDidLoad()
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.issues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IssueCell! = tableView.dequeueReusableCell(withIdentifier: "default") as! IssueCell
        let issue = viewModel.issues[indexPath.row]
        cell.present(issue: issue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .destructive,
                                             title: "Close") { [weak self] (_, _, done) in
                                                self?.viewModel.closeIssue(at: UInt(indexPath.row), completion: { done($0 != nil) })
        }
        let renameAction = UIContextualAction(style: .normal,
                                              title: "Rename") { [weak self] (_, _, done) in
                                                self?.renameIssue(indexPath: indexPath, done: done)
        }
        let configuration = UISwipeActionsConfiguration(actions: [closeAction, renameAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let issue = viewModel.issues[indexPath.row]
        let viewController = SFSafariViewController(url: issue.htmlUrl)
        present(viewController, animated: true, completion: nil)
    }

    // MARK: - IssuesViewing
    
    func issuesDidChange() {
        tableView.reloadData()
    }
    
    func authenticatedDidChange() {
        setupLoginButton()
    }
    
    // MARK: - Private
    
    private func setupLoginButton() {
        if self.viewModel.authenticated {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(login))
        }
    }
    
    // MARK: - LoginDelegate
    
    func loginDidComplete(error: Error?) {
        viewModel.reload()
    }
    
    // MARK: - Internal
    
    @objc func login() {
        let loginViewController = LoginViewController(delegate: self)
        present(NavigationController(rootViewController: loginViewController), animated: true, completion: nil)
    }
    
    @objc func logout() {
        viewModel.logout()
    }
    
    @objc func reload() {
        viewModel.reload()
        tableView.refreshControl?.endRefreshing()
    }
    
    func renameIssue(indexPath: IndexPath, done: @escaping (Bool) -> ()) {
        let issue = viewModel.issues[indexPath.row]
        let alertController = UIAlertController(title: "Rename", message: "Introduce the new issue name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = issue.title
        }
        alertController.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] (_) in
            guard let text = alertController.textFields?[0].text else { return done(true) }
            self?.viewModel.renameIssue(at: UInt(indexPath.row), title: text, completion: { done($0 != nil) })
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in done(true) }))
        present(alertController, animated: true, completion: nil)
    }
}

