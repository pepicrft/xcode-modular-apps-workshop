import Foundation
import GitHubKit

public struct LabelEntity: Codable {
    public let color: String
    public let name: String
    init(label: Label) {
        self.color = label.color
        self.name = label.name
    }
}
