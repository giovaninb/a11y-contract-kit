import Foundation

public enum A11yState: Hashable, Codable, Sendable {
    case selected(Bool)
    case enabled(Bool)
    case expanded(Bool)
    case loading(Bool)
    case checked(Bool)
}
