import Foundation

public enum A11yRuleCatalog {
    public static var defaultRules: [any A11yRule] {
        rules(for: .wcag22AA)
    }

    public static func rules(for target: A11yConformanceTarget) -> [any A11yRule] {
        var candidates: [any A11yRule] = [
            MissingAccessibilityLabelRule(),
            MissingRoleTraitRule(),
            LowContrastRule(level: target.level),
            FixedFontSizeRule(),
            ColorOnlyStateRule(),
            MissingHintDestructiveActionRule(),
        ]

        if target.version >= .v22, target.level >= .aa {
            candidates.append(WCAGTargetSizeMinimumRule())
        }

        if target.level == .aaa {
            candidates.append(MinimumTouchTargetRule(mode: .wcagAAA))
        } else {
            candidates.append(MinimumTouchTargetRule(mode: .appleHIG))
        }

        return candidates.filter { $0.isApplicable(to: target) }
    }
}

public struct A11yRuleEngine: Sendable {
    public let rules: [any A11yRule]
    public let conformanceTarget: A11yConformanceTarget

    public init(target: A11yConformanceTarget = .wcag22AA) {
        self.conformanceTarget = target
        self.rules = A11yRuleCatalog.rules(for: target)
    }

    public init(rules: [any A11yRule], conformanceTarget: A11yConformanceTarget = .wcag22AA) {
        self.rules = rules
        self.conformanceTarget = conformanceTarget
    }

    public func evaluate(context: A11yRuleContext) -> [A11yIssue] {
        rules.flatMap { $0.evaluate(context: context) }
    }

    public func evaluate(contexts: [A11yRuleContext]) -> [A11yIssue] {
        let issues = contexts.flatMap { evaluate(context: $0) }
        return deduplicate(issues.filter(isReportable))
    }

    private func isReportable(_ issue: A11yIssue) -> Bool {
        guard let filePath = issue.filePath, !filePath.isEmpty else { return false }
        guard let componentId = issue.componentId, !componentId.isEmpty else { return false }
        return componentId != "unknown_component"
    }

    private func deduplicate(_ issues: [A11yIssue]) -> [A11yIssue] {
        var seen = Set<String>()
        var result: [A11yIssue] = []
        for issue in issues {
            let key = "\(issue.ruleId)|\(issue.componentId ?? "")|\(issue.message)"
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(issue)
        }
        return result
    }
}
