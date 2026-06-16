import Foundation

public struct LowContrastRule: A11yRule {
    public let id = "ios-a11y-low-contrast"
    public let level: WCAGLevel

    public init(level: WCAGLevel = .aa) {
        self.level = level
    }

    public var wcagCriteria: [WCAGCriterion] {
        switch level {
        case .aaa:
            return [.contrastEnhanced]
        case .aa, .a:
            return [.contrastMinimum]
        }
    }

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard let foreground = context.foregroundColor,
              let background = context.backgroundColor else {
            return []
        }

        let effectiveLevel: WCAGLevel = level == .aaa ? .aaa : .aa
        let textSize: A11yTextSizeCategory = context.isLargeText ? .large : .normal
        guard !A11yContrast.meets(
            foreground: foreground,
            background: background,
            level: effectiveLevel,
            textSize: textSize
        ) else {
            return []
        }

        guard let anchor = context.anchoredComponent else { return [] }

        let ratio = A11yContrast.ratio(foreground: foreground, background: background)
        let componentName = anchor.id
        let criterion: WCAGCriterion = effectiveLevel == .aaa ? .contrastEnhanced : .contrastMinimum
        let required: String
        if effectiveLevel == .aaa {
            required = textSize == .large ? "4.5:1" : "7:1"
        } else {
            required = textSize == .large ? "3:1" : "4.5:1"
        }

        return [
            A11yIssue(
                ruleId: id,
                severity: .critical,
                message: String(format: "Insufficient color contrast (%.2f:1). Minimum required: %@.", ratio, required),
                componentId: componentName,
                filePath: anchor.filePath,
                line: anchor.line,
                wcag: [criterion],
                suggestedFix: "Adjust foreground and background colors to meet WCAG contrast requirements.",
                suggestedOwner: .design
            ),
        ]
    }
}
