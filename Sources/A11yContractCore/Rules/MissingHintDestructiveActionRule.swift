import Foundation

public struct MissingHintDestructiveActionRule: A11yRule {
    public let id = "ios-a11y-missing-hint-destructive"

    public var wcagCriteria: [WCAGCriterion] {
        [.nameRoleValue]
    }

    public init() {}

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard let spec = context.spec else { return [] }
        guard spec.role == .button || spec.role.isInteractive else { return [] }
        guard spec.actionType == .destructive else { return [] }

        let hint = context.spec?.hint?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard hint == nil || hint?.isEmpty == true else { return [] }

        return [
            A11yIssue(
                ruleId: id,
                severity: .minor,
                message: "Destructive action without accessibility hint explaining the impact.",
                componentId: spec.id,
                filePath: context.effectiveFilePath,
                line: context.effectiveLine,
                wcag: [.nameRoleValue],
                suggestedFix: """
                A11ySpec(
                    id: "\(spec.id)",
                    label: "\(spec.label ?? "Delete")",
                    hint: "Explain the impact of this destructive action.",
                    role: .button,
                    actionType: .destructive
                )
                """,
                suggestedOwner: .design
            ),
        ]
    }
}
