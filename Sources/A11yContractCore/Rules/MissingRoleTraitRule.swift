import Foundation

public struct MissingRoleTraitRule: A11yRule {
    public let id = "ios-a11y-missing-role"

    public var wcagCriteria: [WCAGCriterion] {
        [.nameRoleValue]
    }

    public init() {}

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard context.isInteractive else { return [] }

        let interactiveRoles: Set<A11yRole> = [.button, .link, .input, .adjustable, .tab]
        let hasRole = !context.traits.intersection(interactiveRoles).isEmpty
            || context.spec?.role.isInteractive == true

        guard !hasRole else { return [] }

        let componentName = context.effectiveComponentId ?? "unknown_component"
        return [
            A11yIssue(
                ruleId: id,
                severity: .major,
                message: "Interactive component without appropriate accessibility role/trait.",
                componentId: componentName,
                filePath: context.effectiveFilePath,
                line: context.effectiveLine,
                wcag: [.nameRoleValue],
                suggestedFix: """
                view.applyA11y(A11ySpec(
                    id: "\(componentName)",
                    label: "Descriptive label",
                    role: .button
                ))
                """,
                suggestedOwner: .development
            ),
        ]
    }
}
