import Foundation

public enum A11yOwner: String, Codable, Sendable, CaseIterable {
    case design
    case development
    case qa
    case product
    case unknown

    public var displayName: String {
        switch self {
        case .design: return "Design"
        case .development: return "Development"
        case .qa: return "QA"
        case .product: return "Product"
        case .unknown: return "Unknown"
        }
    }
}
