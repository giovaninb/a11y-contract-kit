import Foundation

public enum WCAGCriterion: String, Codable, Sendable, CaseIterable {
    case nonTextContent = "1.1.1"
    case infoAndRelationships = "1.3.1"
    case useOfColor = "1.4.1"
    case contrastMinimum = "1.4.3"
    case resizeText = "1.4.4"
    case contrastEnhanced = "1.4.6"
    case keyboard = "2.1.1"
    case focusOrder = "2.4.3"
    case focusVisible = "2.4.7"
    case focusNotObscuredMinimum = "2.4.11"
    case focusNotObscuredEnhanced = "2.4.13"
    case targetSize = "2.5.5"
    case targetSizeMinimum = "2.5.8"
    case redundantEntry = "3.3.8"
    case nameRoleValue = "4.1.2"

    public var displayName: String {
        switch self {
        case .nonTextContent: return "Non-text Content"
        case .infoAndRelationships: return "Info and Relationships"
        case .useOfColor: return "Use of Color"
        case .contrastMinimum: return "Contrast (Minimum)"
        case .resizeText: return "Resize Text"
        case .contrastEnhanced: return "Contrast (Enhanced)"
        case .keyboard: return "Keyboard"
        case .focusOrder: return "Focus Order"
        case .focusVisible: return "Focus Visible"
        case .focusNotObscuredMinimum: return "Focus Not Obscured (Minimum)"
        case .focusNotObscuredEnhanced: return "Focus Not Obscured (Enhanced)"
        case .targetSize: return "Target Size (Enhanced)"
        case .targetSizeMinimum: return "Target Size (Minimum)"
        case .redundantEntry: return "Redundant Entry"
        case .nameRoleValue: return "Name, Role, Value"
        }
    }

    public var level: WCAGLevel {
        switch self {
        case .nonTextContent, .infoAndRelationships, .useOfColor, .keyboard, .focusOrder, .nameRoleValue:
            return .a
        case .contrastMinimum, .resizeText, .focusVisible, .focusNotObscuredMinimum,
             .targetSizeMinimum, .redundantEntry:
            return .aa
        case .contrastEnhanced, .focusNotObscuredEnhanced, .targetSize:
            return .aaa
        }
    }

    public var minimumVersion: WCAGVersion {
        switch self {
        case .focusNotObscuredMinimum, .focusNotObscuredEnhanced, .targetSizeMinimum, .redundantEntry:
            return .v22
        default:
            return .v21
        }
    }

    public var formatted: String {
        "\(rawValue) \(displayName) [\(level.rawValue)]"
    }

    public func isApplicable(to target: A11yConformanceTarget) -> Bool {
        level <= target.level && minimumVersion <= target.version
    }
}
