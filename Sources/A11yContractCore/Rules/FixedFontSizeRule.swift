import Foundation

public struct FixedFontSizeRule: A11yRule {
    public let id = "ios-a11y-fixed-font"

    public var wcagCriteria: [WCAGCriterion] {
        [.resizeText]
    }

    public init() {}

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard let adjusts = context.adjustsFontForContentSizeCategory, !adjusts else {
            return []
        }

        let componentName = context.effectiveComponentId ?? "unknown_component"
        return [
            A11yIssue(
                ruleId: id,
                severity: .major,
                message: "Text component does not support Dynamic Type.",
                componentId: componentName,
                filePath: context.effectiveFilePath,
                line: context.effectiveLine,
                wcag: [.resizeText],
                suggestedFix: "Set adjustsFontForContentSizeCategory = true or use text styles that scale with content size.",
                suggestedOwner: .development
            ),
        ]
    }
}
