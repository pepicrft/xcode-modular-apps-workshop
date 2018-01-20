import UIKit
import IssuesKit

class IssuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IssuesViewing {
    
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
        let action = UIContextualAction(style: .destructive,
                                        title: "Close") { [weak self] (_, _, done) in
                            self?.viewModel.closeIssue(at: UInt(indexPath.row), completion: { done($0 != nil) })
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
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
    
    // MARK: - Internal
    
    @objc func login() {
        present(NavigationController(rootViewController: LoginViewController(nibName: nil, bundle: nil)), animated: true, completion: nil)
    }
    
    @objc func logout() {
        viewModel.logout()
    }
    
}

