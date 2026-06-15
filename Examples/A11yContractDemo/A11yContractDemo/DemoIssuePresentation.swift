import A11yContractCore
import Foundation

enum DemoIssuePresentation {
    static func localizedMessage(for issue: A11yIssue) -> String {
        switch issue.ruleId {
        case "ios-a11y-missing-label":
            return DemoL10n.tr("issue.missing_label")
        case "ios-a11y-missing-role":
            return DemoL10n.tr("issue.missing_role")
        case "ios-a11y-fixed-font":
            return DemoL10n.tr("issue.fixed_font")
        case "ios-a11y-low-contrast":
            if let match = parseContrast(from: issue.message) {
                return String(
                    format: DemoL10n.tr("issue.low_contrast"),
                    match.ratio,
                    match.required
                )
            }
        case "ios-a11y-touch-target-hig":
            if let match = parseTouchTarget(from: issue.message) {
                return String(
                    format: DemoL10n.tr("issue.touch_target_hig"),
                    match.width,
                    match.height,
                    match.minimum,
                    match.minimum
                )
            }
        case "ios-a11y-touch-target":
            if let match = parseTouchTarget(from: issue.message) {
                return String(
                    format: DemoL10n.tr("issue.touch_target_wcag"),
                    match.width,
                    match.height,
                    match.minimum,
                    match.minimum
                )
            }
        default:
            break
        }

        return issue.message
    }

    static func localizedSuggestedFix(for issue: A11yIssue) -> String? {
        guard issue.suggestedFix != nil else { return nil }

        switch issue.ruleId {
        case "ios-a11y-fixed-font":
            return DemoL10n.tr("fix.fixed_font")
        case "ios-a11y-low-contrast":
            return DemoL10n.tr("fix.low_contrast")
        case "ios-a11y-touch-target-hig", "ios-a11y-touch-target":
            if let minimum = parseTouchTarget(from: issue.message)?.minimum {
                return String(format: DemoL10n.tr("fix.touch_target"), minimum, minimum)
            }
            return issue.suggestedFix
        default:
            return issue.suggestedFix
        }
    }

    private static func parseTouchTarget(from message: String) -> (width: String, height: String, minimum: String)? {
        let pattern = #"Touch target is (\d+)x(\d+)pt\..*?(\d+)x(\d+)pt"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
              let widthRange = Range(match.range(at: 1), in: message),
              let heightRange = Range(match.range(at: 2), in: message),
              let minimumRange = Range(match.range(at: 3), in: message) else {
            return nil
        }

        return (
            width: String(message[widthRange]),
            height: String(message[heightRange]),
            minimum: String(message[minimumRange])
        )
    }

    private static func parseContrast(from message: String) -> (ratio: String, required: String)? {
        let pattern = #"Insufficient color contrast \(([\d.]+):1\)\. Minimum required: ([^\.]+)\."#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
              let ratioRange = Range(match.range(at: 1), in: message),
              let requiredRange = Range(match.range(at: 2), in: message) else {
            return nil
        }

        return (
            ratio: String(message[ratioRange]),
            required: String(message[requiredRange])
        )
    }
}

private extension DemoL10n {
    static func tr(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .main, value: key, comment: "")
    }
}
