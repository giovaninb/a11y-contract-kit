import CoreGraphics
import Foundation

public struct WCAGTargetSizeMinimumRule: A11yRule {
    public let id = "ios-a11y-touch-target-wcag"
    public let minimumSize: CGFloat

    public var wcagCriteria: [WCAGCriterion] {
        [.targetSizeMinimum]
    }

    public init(minimumSize: CGFloat = 24) {
        self.minimumSize = minimumSize
    }

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard context.isInteractive, let frame = context.frame else { return [] }
        guard frame.width < minimumSize || frame.height < minimumSize else { return [] }

        let componentName = context.effectiveComponentId ?? "unknown_component"
        return [
            A11yIssue(
                ruleId: id,
                severity: .major,
                message: "Touch target is \(Int(frame.width))x\(Int(frame.height))pt. WCAG 2.5.8 requires at least \(Int(minimumSize))x\(Int(minimumSize))pt.",
                componentId: componentName,
                filePath: context.effectiveFilePath,
                line: context.effectiveLine,
                wcag: [.targetSizeMinimum],
                suggestedFix: "Increase the interactive area to at least \(Int(minimumSize))x\(Int(minimumSize)) points.",
                suggestedOwner: .design
            ),
        ]
    }
}
