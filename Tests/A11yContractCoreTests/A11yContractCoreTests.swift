import XCTest
import CoreGraphics
@testable import A11yContractCore

final class A11yContrastTests: XCTestCase {
    func testBlackOnWhiteMeetsMinimumContrast() {
        let foreground = ColorComponents(red: 0, green: 0, blue: 0)
        let background = ColorComponents(red: 1, green: 1, blue: 1)
        let ratio = A11yContrast.ratio(foreground: foreground, background: background)
        XCTAssertGreaterThan(ratio, 20)
        XCTAssertTrue(A11yContrast.meetsMinimum(foreground: foreground, background: background))
    }

    func testLowContrastFailsMinimum() {
        let foreground = ColorComponents(red: 0.75, green: 0.75, blue: 0.75)
        let background = ColorComponents(red: 1, green: 1, blue: 1)
        XCTAssertFalse(A11yContrast.meetsMinimum(foreground: foreground, background: background))
    }

    func testEnhancedContrastRequiresHigherRatio() {
        let foreground = ColorComponents(red: 0.45, green: 0.45, blue: 0.45)
        let background = ColorComponents(red: 1, green: 1, blue: 1)
        XCTAssertTrue(A11yContrast.meets(foreground: foreground, background: background, level: .aa))
        XCTAssertFalse(A11yContrast.meetsEnhanced(foreground: foreground, background: background))
    }
}

final class A11yConformanceTargetTests: XCTestCase {
    func testParseConformanceTarget() {
        XCTAssertEqual(
            A11yConformanceTarget.parse("2.2-AA"),
            A11yConformanceTarget(version: .v22, level: .aa)
        )
        XCTAssertEqual(
            A11yConformanceTarget.parse("2.1-A"),
            A11yConformanceTarget(version: .v21, level: .a)
        )
        XCTAssertNil(A11yConformanceTarget.parse("invalid"))
    }

    func testDefaultTargetIsWCAG22AA() {
        XCTAssertEqual(A11yConformanceTarget.wcag22AA.displayName, "WCAG 2.2 AA")
    }
}

final class WCAGCriterionTests: XCTestCase {
    func testCriterionLevels() {
        XCTAssertEqual(WCAGCriterion.contrastMinimum.level, .aa)
        XCTAssertEqual(WCAGCriterion.contrastEnhanced.level, .aaa)
        XCTAssertEqual(WCAGCriterion.targetSizeMinimum.level, .aa)
        XCTAssertEqual(WCAGCriterion.targetSize.level, .aaa)
    }

    func testCriterionVersionFiltering() {
        XCTAssertTrue(WCAGCriterion.targetSizeMinimum.isApplicable(to: .wcag22AA))
        XCTAssertFalse(WCAGCriterion.targetSizeMinimum.isApplicable(to: A11yConformanceTarget(version: .v21, level: .aa)))
    }

    func testFormattedIncludesLevel() {
        XCTAssertTrue(WCAGCriterion.contrastMinimum.formatted.contains("[AA]"))
    }
}

final class A11yRuleCatalogTests: XCTestCase {
    func testAAProfileIncludesWCAGTouchTargetAndExcludesAAATouchTarget() {
        let rules = A11yRuleCatalog.rules(for: .wcag22AA)
        let ruleIds = Set(rules.map(\.id))
        XCTAssertTrue(ruleIds.contains("ios-a11y-touch-target-wcag"))
        XCTAssertTrue(ruleIds.contains("ios-a11y-touch-target-hig"))
        XCTAssertFalse(ruleIds.contains("ios-a11y-touch-target"))
    }

    func testAAAProfileUsesWCAGTouchTargetRule() {
        let rules = A11yRuleCatalog.rules(for: A11yConformanceTarget(version: .v22, level: .aaa))
        let ruleIds = Set(rules.map(\.id))
        XCTAssertTrue(ruleIds.contains("ios-a11y-touch-target"))
        XCTAssertFalse(ruleIds.contains("ios-a11y-touch-target-hig"))
    }

    func testLevelAProfileExcludesAAContrastRule() {
        let rules = A11yRuleCatalog.rules(for: A11yConformanceTarget(version: .v22, level: .a))
        XCTAssertFalse(rules.contains { $0.id == "ios-a11y-low-contrast" })
        XCTAssertFalse(rules.contains { $0.id == "ios-a11y-fixed-font" })
    }

    func testWCAG21ProfileExcludes22OnlyCriteria() {
        let rules = A11yRuleCatalog.rules(for: A11yConformanceTarget(version: .v21, level: .aa))
        XCTAssertFalse(rules.contains { $0.id == "ios-a11y-touch-target-wcag" })
    }
}

final class LowContrastRuleTests: XCTestCase {
    func testAAARuleUsesEnhancedCriterion() {
        let rule = LowContrastRule(level: .aaa)
        XCTAssertEqual(rule.wcagCriteria, [.contrastEnhanced])

        let foreground = ColorComponents(red: 0.45, green: 0.45, blue: 0.45)
        let background = ColorComponents(red: 1, green: 1, blue: 1)
        let context = A11yRuleContext(
            componentId: "label",
            foregroundColor: foreground,
            backgroundColor: background
        )

        let issues = rule.evaluate(context: context)
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.wcag, [.contrastEnhanced])
    }
}

final class TouchTargetRuleTests: XCTestCase {
    func testAppleHIGRuleProducesInfoSeverity() {
        let rule = MinimumTouchTargetRule(mode: .appleHIG)
        let context = A11yRuleContext(
            componentId: "button",
            isInteractive: true,
            frame: CGRect(x: 0, y: 0, width: 30, height: 30)
        )

        let issues = rule.evaluate(context: context)
        XCTAssertEqual(issues.first?.severity, .info)
        XCTAssertEqual(issues.first?.ruleId, "ios-a11y-touch-target-hig")
        XCTAssertTrue(issues.first?.wcag.isEmpty == true)
    }

    func testWCAGMinimumRuleUses24ptThreshold() {
        let rule = WCAGTargetSizeMinimumRule()
        let context = A11yRuleContext(
            componentId: "button",
            isInteractive: true,
            frame: CGRect(x: 0, y: 0, width: 20, height: 20)
        )

        let issues = rule.evaluate(context: context)
        XCTAssertEqual(issues.first?.ruleId, "ios-a11y-touch-target-wcag")
        XCTAssertEqual(issues.first?.wcag, [.targetSizeMinimum])
    }
}

final class MissingAccessibilityLabelRuleTests: XCTestCase {
    func testInteractiveComponentWithoutLabelProducesCriticalIssue() {
        let rule = MissingAccessibilityLabelRule()
        let context = A11yRuleContext(
            componentId: "favorite_button",
            accessibleLabel: nil,
            traits: [.button],
            isInteractive: true
        )

        let issues = rule.evaluate(context: context)
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.ruleId, "ios-a11y-missing-label")
        XCTAssertEqual(issues.first?.severity, .critical)
    }
}

final class A11yBaselineServiceTests: XCTestCase {
    func testDiffDetectsNewAndResolvedIssues() {
        let oldIssue = A11yIssue(
            ruleId: "ios-a11y-missing-label",
            severity: .critical,
            message: "old",
            componentId: "old_button"
        )
        let baseline = A11yBaseline(issues: [A11yIssueFingerprint(issue: oldIssue)])

        let current = A11yReport(
            projectName: "Test",
            issues: [
                oldIssue,
                A11yIssue(
                    ruleId: "ios-a11y-missing-role",
                    severity: .major,
                    message: "new",
                    componentId: "new_button"
                ),
            ]
        )

        let diff = A11yBaselineService.diff(current: current, baseline: baseline)
        XCTAssertEqual(diff.existingIssues.count, 1)
        XCTAssertEqual(diff.newIssues.count, 1)
        XCTAssertEqual(diff.newIssues.first?.ruleId, "ios-a11y-missing-role")
        XCTAssertEqual(diff.resolvedIssues.count, 0)
    }
}
