#if canImport(UIKit)
import UIKit
import A11yContractCore

public struct A11yContract {
    private let view: UIView
    private var specBuilder: A11ySpecBuilder

    public init(view: UIView) {
        self.view = view
        self.specBuilder = A11ySpecBuilder(id: view.accessibilityIdentifier ?? UUID().uuidString, role: .button)
    }

    public func id(_ value: String) -> A11yContract {
        var copy = self
        copy.specBuilder.id = value
        return copy
    }

    public func label(_ value: String?) -> A11yContract {
        var copy = self
        copy.specBuilder.label = value
        return copy
    }

    public func hint(_ value: String?) -> A11yContract {
        var copy = self
        copy.specBuilder.hint = value
        return copy
    }

    public func value(_ value: String?) -> A11yContract {
        var copy = self
        copy.specBuilder.value = value
        return copy
    }

    public func role(_ value: A11yRole) -> A11yContract {
        var copy = self
        copy.specBuilder.role = value
        return copy
    }

    public func state(_ value: A11yState?) -> A11yContract {
        var copy = self
        copy.specBuilder.state = value
        return copy
    }

    public func wcag(_ criteria: WCAGCriterion...) -> A11yContract {
        var copy = self
        copy.specBuilder.wcag = criteria
        return copy
    }

    public func owner(_ value: A11yOwner?) -> A11yContract {
        var copy = self
        copy.specBuilder.owner = value
        return copy
    }

    public func actionType(_ value: A11yActionType?) -> A11yContract {
        var copy = self
        copy.specBuilder.actionType = value
        return copy
    }

    public func minimumTouchTarget(_ size: CGFloat = 44) -> A11yContract {
        var copy = self
        copy.specBuilder.minimumTouchTarget = size
        return copy
    }

    public func apply() {
        view.applyA11y(specBuilder.build())
    }

    public func validate(
        projectName: String = "A11yContract",
        target: A11yConformanceTarget? = nil
    ) -> A11yReport {
        let spec = specBuilder.build()
        view.applyA11y(spec)

        let resolvedTarget = A11yConformanceTargetResolver.resolve(explicit: target)
        var rules = A11yRuleCatalog.rules(for: resolvedTarget)
        if let minimum = specBuilder.minimumTouchTarget {
            rules = rules.map { rule in
                switch rule.id {
                case "ios-a11y-touch-target-hig":
                    return MinimumTouchTargetRule(minimumSize: minimum, mode: .appleHIG)
                case "ios-a11y-touch-target":
                    return MinimumTouchTargetRule(minimumSize: minimum, mode: .wcagAAA)
                default:
                    return rule
                }
            }
        }

        let engine = A11yRuleEngine(rules: rules, conformanceTarget: resolvedTarget)
        let context = A11yRuleContext(
            componentId: spec.id,
            accessibleLabel: spec.label ?? view.accessibilityLabel,
            traits: [spec.role],
            isInteractive: spec.role.isInteractive,
            frame: spec.role.isInteractive ? view.bounds : nil,
            spec: spec,
            filePath: spec.source?.filePath,
            line: spec.source?.line,
            declaresColorOnlyState: spec.value != nil
        )

        let issues = engine.evaluate(context: context)
        return A11yReport(
            projectName: projectName,
            issues: issues,
            conformanceTarget: resolvedTarget
        )
    }
}

private struct A11ySpecBuilder {
    var id: String
    var label: String?
    var hint: String?
    var value: String?
    var role: A11yRole
    var state: A11yState?
    var wcag: [WCAGCriterion] = []
    var owner: A11yOwner?
    var source: A11ySource?
    var actionType: A11yActionType?
    var minimumTouchTarget: CGFloat?

    func build() -> A11ySpec {
        A11ySpec(
            id: id,
            label: label,
            hint: hint,
            value: value,
            role: role,
            state: state,
            wcag: wcag,
            owner: owner,
            source: source,
            actionType: actionType
        )
    }
}

#endif
