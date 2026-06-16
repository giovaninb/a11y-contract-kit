#if canImport(UIKit)
import UIKit
import A11yContractCore

public final class UIKitA11yScanner {
    private let engine: A11yRuleEngine
    private let auditSourceFile: String?

    public init(
        target: A11yConformanceTarget = .wcag22AA,
        minimumTouchTarget: CGFloat = 44,
        auditSourceFile: String? = nil,
        engine: A11yRuleEngine? = nil
    ) {
        self.auditSourceFile = auditSourceFile
        if let engine {
            self.engine = engine
        } else {
            let rules = Self.rules(for: target, minimumTouchTarget: minimumTouchTarget)
            self.engine = A11yRuleEngine(rules: rules, conformanceTarget: target)
        }
    }

    public func scan(rootView: UIView) -> [A11yIssue] {
        let contexts = collectContexts(from: rootView, in: rootView)
        return engine.evaluate(contexts: contexts)
    }

    private static func rules(
        for target: A11yConformanceTarget,
        minimumTouchTarget: CGFloat
    ) -> [any A11yRule] {
        A11yRuleCatalog.rules(for: target).map { rule in
            switch rule.id {
            case MinimumTouchTargetRule(minimumSize: minimumTouchTarget, mode: .appleHIG).id,
                 MinimumTouchTargetRule(minimumSize: minimumTouchTarget, mode: .wcagAAA).id:
                let mode: MinimumTouchTargetRule.Mode =
                    rule.id == "ios-a11y-touch-target" ? .wcagAAA : .appleHIG
                return MinimumTouchTargetRule(minimumSize: minimumTouchTarget, mode: mode)
            default:
                return rule
            }
        }
    }

    private func collectContexts(from view: UIView, in rootView: UIView) -> [A11yRuleContext] {
        guard !view.isHidden, view.alpha > 0.01 else { return [] }

        var contexts: [A11yRuleContext] = []
        if shouldEvaluate(view) {
            contexts.append(makeContext(for: view, in: rootView))
        }
        for subview in view.subviews {
            contexts.append(contentsOf: collectContexts(from: subview, in: rootView))
        }
        return contexts
    }

    /// Skips plain container views that are not exposed to assistive tech.
    private func shouldEvaluate(_ view: UIView) -> Bool {
        if view is UIControl { return true }
        if view.isAccessibilityElement { return true }
        if view.accessibilityIdentifier != nil { return true }
        if !UIKitTraitExtractor.roles(from: view.accessibilityTraits).isEmpty { return true }
        if let gestures = view.gestureRecognizers, !gestures.isEmpty { return true }
        return false
    }

    private func makeContext(for view: UIView, in rootView: UIView) -> A11yRuleContext {
        let frame = view.convert(view.bounds, to: rootView.window ?? rootView)
        let label = view.accessibilityLabel ?? (view as? UILabel)?.text

        var foreground: ColorComponents?
        var background: ColorComponents?
        var adjustsFont: Bool?
        var isLargeText = false

        if let labelView = view as? UILabel {
            foreground = UIKitColorExtractor.components(from: labelView.textColor)
            background = UIKitColorExtractor.components(from: labelView.backgroundColor)
            adjustsFont = labelView.adjustsFontForContentSizeCategory
            if let font = labelView.font {
                isLargeText = font.pointSize >= 18 || font.fontDescriptor.symbolicTraits.contains(.traitBold)
            }
        } else if let textField = view as? UITextField {
            foreground = UIKitColorExtractor.components(from: textField.textColor)
            background = UIKitColorExtractor.components(from: textField.backgroundColor)
            adjustsFont = textField.adjustsFontForContentSizeCategory
        } else if let textView = view as? UITextView {
            foreground = UIKitColorExtractor.components(from: textView.textColor)
            background = UIKitColorExtractor.components(from: textView.backgroundColor)
            adjustsFont = textView.adjustsFontForContentSizeCategory
        }

        let traits = UIKitTraitExtractor.roles(from: view.accessibilityTraits)
        let isInteractive = UIKitTraitExtractor.isInteractive(view: view)
        let componentId = view.accessibilityIdentifier
        let registrySpec = componentId.flatMap { A11yContractRegistry.shared.spec(forComponentId: $0) }
        let resolvedSource = componentId.flatMap {
            A11ySourceLocator.resolve(componentId: $0, fallbackFile: auditSourceFile)
        }

        return A11yRuleContext(
            componentId: componentId,
            accessibleLabel: label,
            traits: traits,
            isInteractive: isInteractive,
            frame: isInteractive ? frame : nil,
            foregroundColor: foreground,
            backgroundColor: background,
            adjustsFontForContentSizeCategory: adjustsFont,
            isLargeText: isLargeText,
            spec: registrySpec,
            filePath: resolvedSource?.filePath,
            line: resolvedSource?.line,
            declaresColorOnlyState: false
        )
    }
}

#endif
