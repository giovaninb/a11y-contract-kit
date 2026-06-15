import Foundation

public enum A11yRole: Hashable, Codable, Sendable {
    case button
    case link
    case image
    case text
    case header
    case input
    case adjustable
    case tab
    case custom(String)

    public var displayName: String {
        switch self {
        case .button: return "button"
        case .link: return "link"
        case .image: return "image"
        case .text: return "text"
        case .header: return "header"
        case .input: return "input"
        case .adjustable: return "adjustable"
        case .tab: return "tab"
        case .custom(let name): return name
        }
    }

    public var requiresLabel: Bool {
        switch self {
        case .button, .link, .input, .tab, .image:
            return true
        case .text, .header, .adjustable, .custom:
            return false
        }
    }

    public var isInteractive: Bool {
        switch self {
        case .button, .link, .input, .adjustable, .tab:
            return true
        case .image, .text, .header, .custom:
            return false
        }
    }
}
