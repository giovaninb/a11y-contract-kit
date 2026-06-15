#if canImport(UIKit)
import UIKit
import A11yContractCore
import A11yContractUIKit

public enum A11yAudit {
    public static func run(
        on viewController: UIViewController,
        projectName: String = "A11yAudit",
        target: A11yConformanceTarget? = nil
    ) -> A11yReport {
        let resolvedTarget = A11yConformanceTargetResolver.resolve(explicit: target)
        let view = viewController.view!
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        view.layoutIfNeeded()

        let scanner = UIKitA11yScanner(target: resolvedTarget)
        var issues = scanner.scan(rootView: view)

        let engine = A11yRuleEngine(target: resolvedTarget)
        for spec in A11yContractRegistry.shared.allSpecs() {
            let context = A11yRuleContext(
                componentId: spec.id,
                accessibleLabel: spec.label,
                traits: [spec.role],
                isInteractive: spec.role.isInteractive,
                spec: spec,
                filePath: spec.source?.filePath,
                line: spec.source?.line,
                declaresColorOnlyState: spec.value != nil
            )
            issues.append(contentsOf: engine.evaluate(context: context))
        }

        issues = deduplicate(issues)

        return A11yReport(
            projectName: projectName,
            issues: issues,
            conformanceTarget: resolvedTarget
        )
    }

    public static func validate(
        view: UIView,
        spec: A11ySpec,
        projectName: String = "A11yAudit",
        target: A11yConformanceTarget? = nil
    ) -> A11yReport {
        let resolvedTarget = A11yConformanceTargetResolver.resolve(explicit: target)
        view.applyA11y(spec)
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        view.layoutIfNeeded()

        let engine = A11yRuleEngine(target: resolvedTarget)
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

        return A11yReport(
            projectName: projectName,
            issues: engine.evaluate(context: context),
            conformanceTarget: resolvedTarget
        )
    }

    private static func deduplicate(_ issues: [A11yIssue]) -> [A11yIssue] {
        var seen = Set<String>()
        return issues.filter { issue in
            let key = "\(issue.ruleId)|\(issue.componentId ?? "")|\(issue.message)"
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }
    }
}
#endif
