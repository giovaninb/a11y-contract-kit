import CoreGraphics
import Foundation

public struct MinimumTouchTargetRule: A11yRule {
    public enum Mode: Sendable {
        case appleHIG
        case wcagAAA
    }

    public let minimumSize: CGFloat
    public let mode: Mode

    public var id: String {
        switch mode {
        case .appleHIG:
            return "ios-a11y-touch-target-hig"
        case .wcagAAA:
            return "ios-a11y-touch-target"
        }
    }

    public var wcagCriteria: [WCAGCriterion] {
        switch mode {
        case .appleHIG:
            return []
        case .wcagAAA:
            return [.targetSize]
        }
    }

    public init(minimumSize: CGFloat = 44, mode: Mode = .appleHIG) {
        self.minimumSize = minimumSize
        self.mode = mode
    }

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        guard context.isInteractive, let frame = context.frame else { return [] }
        guard frame.width < minimumSize || frame.height < minimumSize else { return [] }

        let componentName = context.effectiveComponentId ?? "unknown_component"
        let severity: A11ySeverity = mode == .appleHIG ? .info : .major
        let message: String
        let suggestedFix: String
        let wcag: [WCAGCriterion]

        switch mode {
        case .appleHIG:
            message = "Touch target is \(Int(frame.width))x\(Int(frame.height))pt. Apple HIG recommends at least \(Int(minimumSize))x\(Int(minimumSize))pt."
            suggestedFix = "Increase the interactive area to at least \(Int(minimumSize))x\(Int(minimumSize)) points per Apple Human Interface Guidelines."
            wcag = []
        case .wcagAAA:
            message = "Touch target is \(Int(frame.width))x\(Int(frame.height))pt. Minimum required size is \(Int(minimumSize))x\(Int(minimumSize))pt."
            suggestedFix = "Increase the interactive area to at least \(Int(minimumSize))x\(Int(minimumSize)) points."
            wcag = [.targetSize]
        }

        return [
            A11yIssue(
                ruleId: id,
                severity: severity,
                message: message,
                componentId: componentName,
                filePath: context.effectiveFilePath,
                line: context.effectiveLine,
                wcag: wcag,
                suggestedFix: suggestedFix,
                suggestedOwner: .design
            ),
        ]
    }
}
