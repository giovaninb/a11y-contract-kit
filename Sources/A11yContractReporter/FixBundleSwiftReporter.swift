import Foundation
import A11yContractCore

public struct FixBundleSwiftReporter {
    public static let outputFileName = "a11y-fixes.swift"

    public init() {}

    public func generate(input: A11yFixBundleInput) -> String {
        let snippets = A11yFixSnippetGenerator().generateSnippets(
            report: input.report,
            selection: input.selection
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var lines: [String] = [
            "// Accessibility Fix Bundle",
            "// Project: \(input.report.projectName)",
            "// Generated at: \(dateFormatter.string(from: Date()))",
            "// Fix style: \(input.selection.style.displayName)",
            "//",
            "// Paste the snippets below into your source files.",
            "// This file is for reference only — do not compile as-is.",
            "",
        ]

        if snippets.isEmpty {
            lines.append("// No fixes selected.")
            return lines.joined(separator: "\n")
        }

        for (index, snippet) in snippets.enumerated() {
            lines.append("// MARK: - Fix \(index + 1): \(snippet.title)")
            if let location = snippet.location {
                lines.append("// Location: \(location)")
            }
            if !snippet.ruleIds.isEmpty {
                lines.append("// Rules: \(snippet.ruleIds.joined(separator: ", "))")
            }
            lines.append("")
            lines.append(snippet.code)
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
