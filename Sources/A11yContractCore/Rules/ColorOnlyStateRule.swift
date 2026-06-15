import Foundation

public struct ColorOnlyStateRule: A11yRule {
    public let id = "ios-a11y-color-only-state"

    public var wcagCriteria: [WCAGCriterion] {
        [.useOfColor]
    }

    public init() {}

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard let spec = context.spec else { return [] }
        guard spec.wcag.contains(.useOfColor) else { return [] }
        guard !context.declaresColorOnlyState else { return [] }

        return [
            A11yIssue(
                ruleId: id,
                severity: .major,
                message: "Component state may rely on color only. Provide a non-color indicator or accessible value.",
                componentId: spec.id,
                filePath: context.effectiveFilePath,
                line: context.effectiveLine,
                wcag: [.useOfColor],
                suggestedFix: """
                A11ySpec(
                    id: "\(spec.id)",
                    label: "\(spec.label ?? "State label")",
                    value: "Current state",
                    role: .\(spec.role.displayName)
                )
                """,
                suggestedOwner: .design
            ),
        ]
    }
}
