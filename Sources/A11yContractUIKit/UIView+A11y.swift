#if canImport(UIKit)
import UIKit
import A11yContractCore

extension A11yRole {
    public func toUIKitTraits() -> UIAccessibilityTraits {
        switch self {
        case .button:
            return .button
        case .link:
            return .link
        case .image:
            return .image
        case .text:
            return .staticText
        case .header:
            return .header
        case .input:
            return .searchField
        case .adjustable:
            return .adjustable
        case .tab:
            return .tabBar
        case .custom:
            return .none
        }
    }
}

extension UIView {
    public func applyA11y(_ spec: A11ySpec) {
        accessibilityIdentifier = spec.id
        accessibilityLabel = spec.label
        accessibilityHint = spec.hint
        accessibilityValue = spec.value
        accessibilityTraits = spec.role.toUIKitTraits()

        if let state = spec.state {
            switch state {
            case .selected(let value):
                accessibilityTraits.formUnion(value ? .selected : [])
            case .enabled(let value):
                isUserInteractionEnabled = value
            case .expanded(let value):
                accessibilityTraits.formUnion(value ? .notEnabled : [])
            case .loading(let value):
                if value { accessibilityTraits.formUnion(.updatesFrequently) }
            case .checked(let value):
                accessibilityTraits.formUnion(value ? .selected : [])
            }
        }

        A11yContractRegistry.shared.register(spec)
    }
}

#endif
