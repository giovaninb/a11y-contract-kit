import Foundation
import A11yContractCore

public struct FixBundleMarkdownReporter {
    public static let outputFileName = "a11y-fixes.md"

    public init() {}

    public func generate(input: A11yFixBundleInput) -> String {
        let snippets = A11yFixSnippetGenerator().generateSnippets(
            report: input.report,
            selection: input.selection
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var lines: [String] = [
            "# Accessibility Fix Bundle",
            "",
            "Project: \(input.report.projectName)",
            "Generated at: \(dateFormatter.string(from: Date()))",
            "Fix style: \(input.selection.style.displayName)",
            "Grouped by component: \(input.selection.groupByComponent ? "yes" : "no")",
            "",
            "> Paste these snippets manually into your source files. This tool does not modify your project.",
            "",
        ]

        if snippets.isEmpty {
            lines.append("No fixes selected.")
            return lines.joined(separator: "\n")
        }

        lines.append("## Fixes")
        lines.append("")

        for (index, snippet) in snippets.enumerated() {
            lines.append("### \(index + 1). \(snippet.title)")
            lines.append("")
            if let location = snippet.location {
                lines.append("- Location: `\(location)`")
            }
            if !snippet.ruleIds.isEmpty {
                lines.append("- Rules: \(snippet.ruleIds.joined(separator: ", "))")
            }
            lines.append("")
            lines.append("```swift")
            lines.append(snippet.code)
            lines.append("```")
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
