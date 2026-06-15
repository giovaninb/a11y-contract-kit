import A11yContractCore
import Foundation

enum DemoL10n {
    static var tabUIKit: String { tr("tab.uikit") }
    static var tabCustom: String { tr("tab.custom") }
    static var tabSwiftUI: String { tr("tab.swiftui") }
    static var tabAudit: String { tr("tab.audit") }

    static var modeProblems: String { tr("demo.mode.problems") }
    static var modeFixed: String { tr("demo.mode.fixed") }

    static var uikitIntro: String { tr("uikit.intro") }
    static var uikitHint: String { tr("uikit.hint") }
    static var uikitScreenProblems: String { tr("uikit.screen.problems") }
    static var uikitScreenFixed: String { tr("uikit.screen.fixed") }

    static var customIntro: String { tr("custom.intro") }
    static var customHint: String { tr("custom.hint") }
    static var customScreenProblems: String { tr("custom.screen.problems") }
    static var customScreenFixed: String { tr("custom.screen.fixed") }
    static var customProblemsDetail: String { tr("custom.problems.detail") }
    static var customProblemsOrderTitle: String { tr("custom.problems.order.title") }
    static var customProblemsOrderWrong: String { tr("custom.problems.order.wrong") }
    static var customProblemsIssueTitle: String { tr("custom.problems.issue.title") }
    static var customProblemsIssueBody: String { tr("custom.problems.issue.body") }
    static var customFixedDetail: String { tr("custom.fixed.detail") }
    static var customFixedOrderTitle: String { tr("custom.fixed.order.title") }
    static var customFixedOrderBody: String { tr("custom.fixed.order.body") }
    static var customFixedStepsTitle: String { tr("custom.fixed.steps.title") }
    static var customHeaderText: String { tr("custom.header.text") }
    static var customItemText: String { tr("custom.item.text") }
    static var customPriceText: String { tr("custom.price.text") }
    static var customDeliveryText: String { tr("custom.delivery.text") }
    static var customContinueLabel: String { tr("custom.continue.label") }
    static var customContinueHint: String { tr("custom.continue.hint") }

    static var screenAudit: String { tr("screen.audit") }

    static var auditHeadline: String { tr("audit.headline") }
    static var auditDescription: String { tr("audit.description") }
    static var auditRun: String { tr("audit.run") }
    static var auditRunning: String { tr("audit.running") }
    static var auditEmpty: String { tr("audit.empty") }
    static var auditTapHint: String { tr("audit.tap_hint") }
    static var auditFindings: String { tr("audit.findings") }
    static var auditDetailTitle: String { tr("audit.detail.title") }
    static var auditDetailRule: String { tr("audit.detail.rule") }
    static var auditDetailComponent: String { tr("audit.detail.component") }
    static var auditDetailMessage: String { tr("audit.detail.message") }
    static var auditDetailWCAG: String { tr("audit.detail.wcag") }
    static var auditDetailSuggestedFix: String { tr("audit.detail.suggested_fix") }
    static var auditDetailOwner: String { tr("audit.detail.owner") }
    static var auditDetailLocation: String { tr("audit.detail.location") }
    static var auditDetailNotAvailable: String { tr("audit.detail.not_available") }

    static var problemsLowContrastText: String { tr("problems.low_contrast_text") }
    static var problemsFixedFontText: String { tr("problems.fixed_font_text") }
    static var problemsCaption: String { tr("problems.caption") }
    static var problemsIntro: String { tr("problems.intro") }
    static var problemsComponentId: String { tr("problems.component_id") }
    static var problemsExpectedRules: String { tr("problems.expected_rules") }

    static var fixedStatus: String { tr("fixed.status") }
    static var fixedCaption: String { tr("fixed.caption") }
    static var fixedIntro: String { tr("fixed.intro") }
    static var fixedContractApplied: String { tr("fixed.contract_applied") }

    static var swiftUIIntro: String { tr("swiftui.intro") }
    static var swiftUILinkHint: String { tr("swiftui.link_hint") }
    static var swiftUIScreenProblems: String { tr("swiftui.screen.problems") }
    static var swiftUIScreenFixed: String { tr("swiftui.screen.fixed") }
    static var swiftUICaption: String { tr("swiftui.caption") }

    static var deleteLabel: String { tr("a11y.delete_label") }
    static var deleteHint: String { tr("a11y.delete_hint") }
    static var favoriteLabel: String { tr("a11y.favorite_label") }
    static var favoriteHint: String { tr("a11y.favorite_hint") }
    static var statusLabel: String { tr("a11y.status_label") }
    static var statusValue: String { tr("a11y.status_value") }

    static func customOrderStep(index: Int, text: String) -> String {
        String(format: tr("custom.order.step"), index, text)
    }

    static func severity(_ severity: A11ySeverity) -> String {
        tr("severity.\(severity.rawValue)")
    }

    static func owner(_ owner: A11yOwner) -> String {
        tr("owner.\(owner.rawValue)")
    }

    static func key(_ key: String) -> String {
        tr(key)
    }

    private static func tr(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .main, value: key, comment: "")
    }
}
