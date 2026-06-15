#if canImport(UIKit)
import UIKit
import A11yContractCore

enum UIKitColorExtractor {
    static func components(from color: UIColor?) -> ColorComponents? {
        guard let color else { return nil }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return ColorComponents(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            alpha: Double(alpha)
        )
    }
}

enum UIKitTraitExtractor {
    static func roles(from traits: UIAccessibilityTraits) -> Set<A11yRole> {
        var roles = Set<A11yRole>()
        if traits.contains(.button) { roles.insert(.button) }
        if traits.contains(.link) { roles.insert(.link) }
        if traits.contains(.image) { roles.insert(.image) }
        if traits.contains(.staticText) { roles.insert(.text) }
        if traits.contains(.header) { roles.insert(.header) }
        if traits.contains(.searchField) { roles.insert(.input) }
        if traits.contains(.adjustable) { roles.insert(.adjustable) }
        if traits.contains(.tabBar) { roles.insert(.tab) }
        return roles
    }

    static func isInteractive(view: UIView) -> Bool {
        if view is UIControl { return true }
        if view.isUserInteractionEnabled, !(view is UILabel) { return true }
        if !UIKitTraitExtractor.roles(from: view.accessibilityTraits).isEmpty {
            return true
        }
        if let gestures = view.gestureRecognizers, !gestures.isEmpty {
            return true
        }
        return false
    }
}

#endif
