import Foundation
import UIKit
import IssuesKit

public final class IssueCell: UITableViewCell {
    
    let titleLabel: UILabel = UILabel()
    let detailLabel: UILabel = UILabel()
    let labelsLabel: UILabel = UILabel()
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        [titleLabel, detailLabel, labelsLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            labelsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            labelsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            labelsLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 7),
            labelsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        detailLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
        detailLabel.textColor = .gray
        labelsLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
    }
    
    func present(issue: Issue) {
        titleLabel.text = issue.title
        let daysAgo = Date().interval(ofComponent: .day, fromDate: issue.createdAt)
        detailLabel.text = "#\(issue.number) - @\(issue.user.login) - \(daysAgo) days ago"
        labelsLabel.attributedText = issue.labels.reduce(into: NSMutableAttributedString(string: "")) { (attributedString, label) in
            let labelAttributed = NSAttributedString(string: "\(label.name) ", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(label.color)])
            attributedString.append(labelAttributed)
        }
    }
    
}

