import Foundation
import A11yContractCore

public struct A11yFixSnippetGenerator {
    public init() {}

    public func generateSnippets(report: A11yReport, selection: A11yFixSelection) -> [A11yFixSnippet] {
        let selectedIds = Set(selection.issueIds)
        let issues = report.issues.filter { selectedIds.contains($0.id) }
        guard !issues.isEmpty else { return [] }

        if selection.groupByComponent {
            let grouped = Dictionary(grouping: issues) { issue in
                issue.componentId ?? issue.id
            }
            return grouped.keys.sorted().compactMap { key in
                guard let group = grouped[key] else { return nil }
                return makeGroupedSnippet(issues: group, style: selection.style)
            }
        }

        return issues.sorted(by: issueSort).map { issue in
            makeSingleSnippet(issue: issue, style: selection.style)
        }
    }

    private func issueSort(_ lhs: A11yIssue, _ rhs: A11yIssue) -> Bool {
        if lhs.severity != rhs.severity { return lhs.severity > rhs.severity }
        return (lhs.componentId ?? "") < (rhs.componentId ?? "")
    }

    private func makeGroupedSnippet(issues: [A11yIssue], style: A11yFixStyle) -> A11yFixSnippet {
        let sorted = issues.sorted(by: issueSort)
        let primary = sorted[0]
        let componentId = primary.componentId ?? primary.id
        let variableName = swiftVariableName(for: componentId)
        let ruleIds = sorted.map(\.ruleId)
        let location = primaryLocation(from: sorted)
        let code = consolidatedCode(
            variableName: variableName,
            componentId: componentId,
            issues: sorted,
            style: style
        )

        return A11yFixSnippet(
            title: componentId,
            location: location,
            ruleIds: ruleIds,
            code: code
        )
    }

    private func makeSingleSnippet(issue: A11yIssue, style: A11yFixStyle) -> A11yFixSnippet {
        let componentId = issue.componentId ?? issue.id
        let variableName = swiftVariableName(for: componentId)
        let location = locationText(filePath: issue.filePath, line: issue.line)
        let code = snippetForIssue(issue, variableName: variableName, componentId: componentId, style: style)

        return A11yFixSnippet(
            title: issue.message,
            location: location,
            ruleIds: [issue.ruleId],
            code: code
        )
    }

    private func primaryLocation(from issues: [A11yIssue]) -> String? {
        for issue in issues {
            if let location = locationText(filePath: issue.filePath, line: issue.line) {
                return location
            }
        }
        return nil
    }

    private func locationText(filePath: String?, line: Int?) -> String? {
        guard let filePath else { return nil }
        guard let line else { return filePath }
        return "\(filePath):\(line)"
    }

    private func consolidatedCode(
        variableName: String,
        componentId: String,
        issues: [A11yIssue],
        style: A11yFixStyle
    ) -> String {
        let ruleIds = Set(issues.map(\.ruleId))
        let minimumTouchTarget = issues.compactMap { parseTouchTargetMinimum(from: $0) }.max() ?? 44

        switch style {
        case .uikit:
            return consolidatedUIKit(
                variableName: variableName,
                componentId: componentId,
                ruleIds: ruleIds,
                minimumTouchTarget: minimumTouchTarget,
                issues: issues
            )
        case .framework:
            return consolidatedFramework(
                variableName: variableName,
                componentId: componentId,
                ruleIds: ruleIds,
                minimumTouchTarget: minimumTouchTarget,
                issues: issues
            )
        case .swiftUI:
            return consolidatedSwiftUI(
                variableName: variableName,
                componentId: componentId,
                ruleIds: ruleIds,
                minimumTouchTarget: minimumTouchTarget,
                issues: issues
            )
        }
    }

    private func snippetForIssue(
        _ issue: A11yIssue,
        variableName: String,
        componentId: String,
        style: A11yFixStyle
    ) -> String {
        consolidatedCode(
            variableName: variableName,
            componentId: componentId,
            issues: [issue],
            style: style
        )
    }

    private func consolidatedUIKit(
        variableName: String,
        componentId: String,
        ruleIds: Set<String>,
        minimumTouchTarget: Int,
        issues: [A11yIssue]
    ) -> String {
        var lines: [String] = []

        if ruleIds.contains("ios-a11y-missing-label") || ruleIds.contains("ios-a11y-missing-role") {
            lines.append("\(variableName).accessibilityIdentifier = \"\(componentId)\"")
        }
        if ruleIds.contains("ios-a11y-missing-label") {
            lines.append("\(variableName).accessibilityLabel = \"Descriptive label\"")
        }
        if ruleIds.contains("ios-a11y-missing-role") {
            lines.append("\(variableName).accessibilityTraits = [.button]")
        }
        if ruleIds.contains(where: { $0.hasPrefix("ios-a11y-touch-target") }) {
            lines.append("NSLayoutConstraint.activate([")
            lines.append("    \(variableName).widthAnchor.constraint(greaterThanOrEqualToConstant: \(minimumTouchTarget)),")
            lines.append("    \(variableName).heightAnchor.constraint(greaterThanOrEqualToConstant: \(minimumTouchTarget)),")
            lines.append("])")
        }
        if ruleIds.contains("ios-a11y-fixed-font") {
            lines.append("\(variableName).adjustsFontForContentSizeCategory = true")
            lines.append("\(variableName).font = .preferredFont(forTextStyle: .body)")
        }
        if ruleIds.contains("ios-a11y-low-contrast") {
            lines.append("\(variableName).textColor = .label")
            lines.append("\(variableName).backgroundColor = .secondarySystemBackground")
        }

        appendInstructionalFallbacks(to: &lines, issues: issues, style: .uikit)

        return lines.joined(separator: "\n")
    }

    private func consolidatedFramework(
        variableName: String,
        componentId: String,
        ruleIds: Set<String>,
        minimumTouchTarget: Int,
        issues: [A11yIssue]
    ) -> String {
        let contractRules: Set<String> = [
            "ios-a11y-missing-label",
            "ios-a11y-missing-role",
            "ios-a11y-missing-hint-destructive",
            "ios-a11y-color-only-state",
        ]

        if !ruleIds.intersection(contractRules).isEmpty {
            var wcag: [String] = []
            if ruleIds.contains("ios-a11y-missing-label") || ruleIds.contains("ios-a11y-missing-role") {
                wcag.append(".nameRoleValue")
            }
            if ruleIds.contains(where: { $0.hasPrefix("ios-a11y-touch-target") }) {
                wcag.append(".targetSize")
            }

            let wcagLine = wcag.isEmpty ? "" : "\n    wcag: [\(wcag.joined(separator: ", "))],"
            let hintLine = ruleIds.contains("ios-a11y-missing-hint-destructive")
                ? "\n    hint: \"Describe the action\","
                : ""

            var lines = [
                "\(variableName).applyA11y(A11ySpec(",
                "    id: \"\(componentId)\",",
                "    label: \"Descriptive label\",\(hintLine)",
                "    role: .button,\(wcagLine)",
                "))",
            ]

            if ruleIds.contains(where: { $0.hasPrefix("ios-a11y-touch-target") }) {
                lines.append("")
                lines.append("A11yContract(view: \(variableName))")
                lines.append("    .minimumTouchTarget(\(minimumTouchTarget))")
                lines.append("    .apply()")
            }

            appendInstructionalFallbacks(to: &lines, issues: issues, style: .framework)
            return lines.joined(separator: "\n")
        }

        var lines: [String] = []
        appendInstructionalFallbacks(to: &lines, issues: issues, style: .framework)
        if lines.isEmpty {
            return fallbackSuggestedFix(from: issues)
        }
        return lines.joined(separator: "\n")
    }

    private func consolidatedSwiftUI(
        variableName: String,
        componentId: String,
        ruleIds: Set<String>,
        minimumTouchTarget: Int,
        issues: [A11yIssue]
    ) -> String {
        var modifierLines: [String] = []

        if ruleIds.contains("ios-a11y-missing-label") || ruleIds.contains("ios-a11y-missing-role") {
            modifierLines.append(".accessibilityIdentifier(\"\(componentId)\")")
        }
        if ruleIds.contains("ios-a11y-missing-label") {
            modifierLines.append(".accessibilityLabel(\"Descriptive label\")")
        }
        if ruleIds.contains("ios-a11y-missing-role") {
            modifierLines.append(".accessibilityAddTraits(.isButton)")
        }
        if ruleIds.contains(where: { $0.hasPrefix("ios-a11y-touch-target") }) {
            modifierLines.append(".frame(minWidth: \(minimumTouchTarget), minHeight: \(minimumTouchTarget))")
        }
        if ruleIds.contains("ios-a11y-fixed-font") {
            modifierLines.append(".font(.body)")
        }
        if ruleIds.contains("ios-a11y-low-contrast") {
            modifierLines.append(".foregroundStyle(.primary)")
            modifierLines.append(".background(Color(.secondarySystemBackground))")
        }

        if modifierLines.isEmpty {
            var lines: [String] = ["\(variableName) // your SwiftUI view"]
            appendInstructionalFallbacks(to: &lines, issues: issues, style: .swiftUI)
            if lines.count == 1 {
                return fallbackSuggestedFix(from: issues)
            }
            return lines.joined(separator: "\n")
        }

        var lines = [
            "\(variableName) // your SwiftUI view",
        ]
        lines.append(contentsOf: modifierLines)
        appendInstructionalFallbacks(to: &lines, issues: issues, style: .swiftUI)
        return lines.joined(separator: "\n")
    }

    private func appendInstructionalFallbacks(
        to lines: inout [String],
        issues: [A11yIssue],
        style: A11yFixStyle
    ) {
        let handledRules: Set<String> = [
            "ios-a11y-missing-label",
            "ios-a11y-missing-role",
            "ios-a11y-touch-target-hig",
            "ios-a11y-touch-target",
            "ios-a11y-fixed-font",
            "ios-a11y-low-contrast",
            "ios-a11y-missing-hint-destructive",
            "ios-a11y-color-only-state",
        ]

        for issue in issues where !handledRules.contains(issue.ruleId) {
            if let fix = issue.suggestedFix, !fix.isEmpty {
                if !lines.isEmpty { lines.append("") }
                lines.append("// \(issue.ruleId): \(issue.message)")
                lines.append(fix)
            }
        }

        if style == .framework {
            for issue in issues where issue.ruleId == "ios-a11y-fixed-font" || issue.ruleId == "ios-a11y-low-contrast" {
                if let fix = issue.suggestedFix {
                    if !lines.isEmpty { lines.append("") }
                    lines.append("// \(issue.ruleId)")
                    lines.append(fix)
                }
            }
        }
    }

    private func fallbackSuggestedFix(from issues: [A11yIssue]) -> String {
        issues.compactMap(\.suggestedFix).joined(separator: "\n\n")
    }

    private func parseTouchTargetMinimum(from issue: A11yIssue) -> Int? {
        guard issue.ruleId.hasPrefix("ios-a11y-touch-target") else { return nil }
        let pattern = #"(\d+)x(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: issue.message, range: NSRange(issue.message.startIndex..., in: issue.message)),
              let range = Range(match.range(at: 1), in: issue.message) else {
            return 44
        }
        return Int(issue.message[range])
    }

    private func swiftVariableName(for componentId: String) -> String {
        let parts = componentId.split(separator: "_")
        guard let first = parts.first else { return "view" }
        let head = String(first)
        let tail = parts.dropFirst().map { part in
            part.prefix(1).uppercased() + part.dropFirst()
        }.joined()
        let name = head + tail
        if name.first?.isNumber == true {
            return "view" + name.prefix(1).uppercased() + name.dropFirst()
        }
        return name.isEmpty ? "view" : name
    }
}
