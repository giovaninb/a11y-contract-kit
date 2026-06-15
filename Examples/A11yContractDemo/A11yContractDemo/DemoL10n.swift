import A11yContractCore
import Foundation

enum DemoL10n {
    static var tabProblems: String { tr("tab.problems") }
    static var tabFixed: String { tr("tab.fixed") }
    static var tabSwiftUI: String { tr("tab.swiftui") }
    static var tabAudit: String { tr("tab.audit") }

    static var screenProblems: String { tr("screen.problems") }
    static var screenFixed: String { tr("screen.fixed") }
    static var screenSwiftUI: String { tr("screen.swiftui") }
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
    static var swiftUIModeProblems: String { tr("swiftui.mode.problems") }
    static var swiftUIModeFixed: String { tr("swiftui.mode.fixed") }
    static var swiftUIScreenProblems: String { tr("swiftui.screen.problems") }
    static var swiftUIScreenFixed: String { tr("swiftui.screen.fixed") }

    static var swiftUIHeadline: String { tr("swiftui.headline") }
    static var swiftUIDelete: String { tr("swiftui.delete") }
    static var swiftUICaption: String { tr("swiftui.caption") }

    static var deleteLabel: String { tr("a11y.delete_label") }
    static var deleteHint: String { tr("a11y.delete_hint") }
    static var favoriteLabel: String { tr("a11y.favorite_label") }
    static var favoriteHint: String { tr("a11y.favorite_hint") }
    static var statusLabel: String { tr("a11y.status_label") }
    static var statusValue: String { tr("a11y.status_value") }

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
