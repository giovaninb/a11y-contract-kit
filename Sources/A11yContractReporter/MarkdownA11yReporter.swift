import Foundation
import A11yContractCore

public struct MarkdownA11yReporter: A11yReporter {
    public let outputFileName = "a11y-report.md"

    public init() {}

    public func generate(report: A11yReport) throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var lines: [String] = [
            "# Accessibility Report",
            "",
            "Project: \(report.projectName)",
            "Generated at: \(dateFormatter.string(from: report.generatedAt))",
        ]

        if let target = report.conformanceTarget {
            lines.append("Conformance target: \(target.displayName)")
        }

        lines.append(contentsOf: [
            "",
            "## Summary",
            "",
            "| Severity | Count |",
            "|---|---:|",
            "| Critical | \(report.summary.critical) |",
            "| Major | \(report.summary.major) |",
            "| Minor | \(report.summary.minor) |",
            "| Info | \(report.summary.info) |",
            "",
            "## Issues",
            "",
        ])

        let sortedIssues = report.issues.sorted {
            if $0.severity != $1.severity { return $0.severity > $1.severity }
            return ($0.componentId ?? "") < ($1.componentId ?? "")
        }

        for issue in sortedIssues {
            lines.append("### \(issue.severity.displayName) — \(issue.message)")
            lines.append("")
            if let componentId = issue.componentId {
                lines.append("- Component: \(componentId)")
            }
            if let filePath = issue.filePath {
                let location = issue.line.map { "\(filePath):\($0)" } ?? filePath
                lines.append("- File: \(location)")
            }
            if !issue.wcag.isEmpty {
                lines.append("- WCAG: \(issue.wcag.map(\.formatted).joined(separator: ", "))")
            }
            if let owner = issue.suggestedOwner {
                lines.append("- Suggested owner: \(owner.displayName)")
            }
            if let fix = issue.suggestedFix {
                lines.append("- Suggested fix:")
                lines.append("")
                lines.append("```swift")
                lines.append(fix)
                lines.append("```")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
