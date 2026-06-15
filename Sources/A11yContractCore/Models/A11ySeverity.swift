import Foundation

public enum A11ySeverity: String, Codable, Sendable, CaseIterable, Comparable {
    case info
    case minor
    case major
    case critical

    public var rank: Int {
        switch self {
        case .info: return 0
        case .minor: return 1
        case .major: return 2
        case .critical: return 3
        }
    }

    public static func < (lhs: A11ySeverity, rhs: A11ySeverity) -> Bool {
        lhs.rank < rhs.rank
    }

    public var displayName: String {
        rawValue.uppercased()
    }
}
