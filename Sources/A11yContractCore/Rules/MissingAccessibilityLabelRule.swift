import Foundation

public struct MissingAccessibilityLabelRule: A11yRule {
    public let id = "ios-a11y-missing-label"

    public var wcagCriteria: [WCAGCriterion] {
        [.nonTextContent, .nameRoleValue]
    }

    public init() {}

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        let role = context.effectiveRole
        let requiresLabel = role?.requiresLabel == true
            || context.isInteractive
            || context.traits.contains(.image)

        guard requiresLabel else { return [] }

        let label = context.accessibleLabel?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard label == nil || label?.isEmpty == true else { return [] }

        guard let anchor = context.anchoredComponent else { return [] }

        let componentName = anchor.id
        return [
            A11yIssue(
                ruleId: id,
                severity: .critical,
                message: "Interactive component without accessible label.",
                componentId: componentName,
                filePath: anchor.filePath,
                line: anchor.line,
                wcag: [.nameRoleValue, .nonTextContent],
                suggestedFix: """
                view.applyA11y(A11ySpec(
                    id: "\(componentName)",
                    label: "Descriptive label",
                    role: .button
                ))
                """,
                suggestedOwner: .design
            ),
        ]
    }
}
