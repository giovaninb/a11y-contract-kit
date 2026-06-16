import Foundation
import A11yContractCore

public struct A11yFixPatchOutcome: Sendable, Equatable {
    public let filePath: String
    public let changed: Bool
    public let messages: [String]

    public init(filePath: String, changed: Bool, messages: [String]) {
        self.filePath = filePath
        self.changed = changed
        self.messages = messages
    }
}

public struct A11yFixPatcher {
    private let projectRoot: URL
    private let dryRun: Bool

    public init(projectRoot: URL, dryRun: Bool = false) {
        self.projectRoot = projectRoot.standardizedFileURL
        self.dryRun = dryRun
    }

    public func apply(report: A11yReport, selection: A11yFixSelection) throws -> [A11yFixPatchOutcome] {
        let selectedIds = Set(selection.issueIds)
        let issues = report.issues.filter { selectedIds.contains($0.id) }
        guard !issues.isEmpty else { return [] }

        let fileGroups = groupedIssues(issues, groupByComponent: selection.groupByComponent)
        var outcomes: [A11yFixPatchOutcome] = []

        for (filePath, componentGroups) in fileGroups {
            let fileURL = resolveFileURL(relativePath: filePath)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                outcomes.append(
                    A11yFixPatchOutcome(
                        filePath: filePath,
                        changed: false,
                        messages: ["File not found: \(fileURL.path)"]
                    )
                )
                continue
            }

            var lines = try String(contentsOf: fileURL, encoding: .utf8).components(separatedBy: "\n")
            let originalContent = lines.joined(separator: "\n")
            var messages: [String] = []

            for group in componentGroups {
                let variableName = swiftVariableName(for: group.componentId)
                let ruleIds = Set(group.issues.map(\.ruleId))
                let anchorLine = group.issues.compactMap(\.line).min() ?? 1
                var context = PatchContext(
                    lines: lines,
                    variableName: variableName,
                    componentId: group.componentId,
                    anchorLine: anchorLine,
                    style: selection.style,
                    ruleIds: ruleIds
                )

                messages.append(contentsOf: applyRules(to: &context))
                lines = context.lines
            }

            if selection.style == .framework {
                ensureImport(module: "A11yContractUIKit", in: &lines, messages: &messages)
                ensureImport(module: "A11yContractCore", in: &lines, messages: &messages)
            }

            let newContent = lines.joined(separator: "\n")
            let changed = originalContent != newContent
            if changed, !dryRun {
                try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
            }

            outcomes.append(
                A11yFixPatchOutcome(
                    filePath: filePath,
                    changed: changed,
                    messages: dryRun && changed
                        ? messages + ["Dry run: file not written."]
                        : messages
                )
            )
        }

        return outcomes
    }

    // MARK: - Grouping

    private struct ComponentPatchGroup {
        let componentId: String
        let issues: [A11yIssue]
    }

    private func groupedIssues(
        _ issues: [A11yIssue],
        groupByComponent: Bool
    ) -> [(String, [ComponentPatchGroup])] {
        let withPath = issues.filter { $0.filePath != nil }
        let byFile = Dictionary(grouping: withPath) { $0.filePath! }

        return byFile.keys.sorted().map { filePath in
            let fileIssues = byFile[filePath] ?? []
            if groupByComponent {
                let byComponent = Dictionary(grouping: fileIssues) { $0.componentId ?? $0.id }
                let groups = byComponent.keys.sorted().map { key in
                    ComponentPatchGroup(
                        componentId: key,
                        issues: byComponent[key] ?? []
                    )
                }
                return (filePath, groups)
            }

            let groups = fileIssues.map {
                ComponentPatchGroup(componentId: $0.componentId ?? $0.id, issues: [$0])
            }
            return (filePath, groups)
        }
    }

    // MARK: - Patch context

    private struct PatchContext {
        var lines: [String]
        let variableName: String
        let componentId: String
        let anchorLine: Int
        let style: A11yFixStyle
        let ruleIds: Set<String>
    }

    private func applyRules(to context: inout PatchContext) -> [String] {
        var messages: [String] = []
        let variableName = context.variableName

        if context.style == .framework {
            messages.append(contentsOf: patchFrameworkContract(context: &context))
        } else {
            if context.ruleIds.contains("ios-a11y-missing-label") {
                messages.append(contentsOf: patchMissingLabel(context: &context))
            }

            if context.ruleIds.contains("ios-a11y-missing-role") {
                messages.append(contentsOf: patchMissingRoleUIKit(context: &context))
            }
        }

        if context.ruleIds.contains(where: { $0.hasPrefix("ios-a11y-touch-target") }) {
            messages.append(contentsOf: patchTouchTargets(context: &context))
        }

        if messages.isEmpty {
            messages.append("Skipped \(variableName): no supported automatic edits for selected rules.")
        }

        return messages
    }

    private func patchMissingLabel(context: inout PatchContext) -> [String] {
        let variableName = context.variableName
        let nilPattern = "\(variableName).accessibilityLabel = nil"

        if let index = context.lines.firstIndex(where: { $0.contains(nilPattern) }) {
            let indent = leadingWhitespace(context.lines[index])
            context.lines[index] = "\(indent)\(variableName).accessibilityLabel = \"Descriptive label\""
            return ["Updated accessibilityLabel at line \(index + 1)."]
        }

        if context.lines.contains(where: {
            $0.contains("\(variableName).accessibilityLabel =") && !$0.contains("= nil")
        }) {
            return ["Already has accessibilityLabel for \(variableName)."]
        }

        if let index = findLine(matching: "\(variableName).accessibilityIdentifier", in: context.lines) {
            let indent = leadingWhitespace(context.lines[index])
            context.lines.insert("\(indent)\(variableName).accessibilityLabel = \"Descriptive label\"", at: index + 1)
            return ["Inserted accessibilityLabel after line \(index + 1)."]
        }

        return ["Skipped accessibilityLabel for \(variableName): anchor line not found."]
    }

    private func patchMissingRoleUIKit(context: inout PatchContext) -> [String] {
        let variableName = context.variableName

        if context.lines.contains(where: { $0.contains("\(variableName).accessibilityTraits") }) {
            return ["Already has accessibilityTraits for \(variableName)."]
        }

        if let index = findLine(matching: "\(variableName).accessibilityLabel", in: context.lines)
            ?? findLine(matching: "\(variableName).accessibilityIdentifier", in: context.lines) {
            let indent = leadingWhitespace(context.lines[index])
            context.lines.insert("\(indent)\(variableName).accessibilityTraits = [.button]", at: index + 1)
            return ["Inserted accessibilityTraits after line \(index + 1)."]
        }

        return ["Skipped accessibilityTraits for \(variableName): anchor line not found."]
    }

    private func patchFrameworkContract(context: inout PatchContext) -> [String] {
        let contractRules: Set<String> = [
            "ios-a11y-missing-label",
            "ios-a11y-missing-role",
            "ios-a11y-missing-hint-destructive",
            "ios-a11y-color-only-state",
        ]
        guard !context.ruleIds.intersection(contractRules).isEmpty else { return [] }

        let variableName = context.variableName
        if context.lines.contains(where: { $0.contains("\(variableName).applyA11y(") }) {
            return ["Already has applyA11y for \(variableName)."]
        }

        removeLine(matching: "\(variableName).accessibilityLabel = nil", in: &context.lines)

        let snippet = frameworkApplyBlock(
            variableName: variableName,
            componentId: context.componentId,
            ruleIds: context.ruleIds
        )

        if let index = findLineAfterConstraints(for: variableName, in: context.lines, near: context.anchorLine) {
            let indent = leadingWhitespace(context.lines[index])
            let block = snippet
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { line in
                    let trimmed = String(line)
                    return trimmed.isEmpty ? "" : indent + trimmed
                }

            var insertAt = index + 1
            if insertAt < context.lines.count,
               !context.lines[insertAt].trimmingCharacters(in: .whitespaces).isEmpty {
                context.lines.insert("", at: insertAt)
                insertAt += 1
            }
            context.lines.insert(contentsOf: block, at: insertAt)
            return ["Inserted applyA11y block after line \(index + 1)."]
        }

        return ["Skipped applyA11y for \(variableName): constraint block not found."]
    }

    private func patchTouchTargets(context: inout PatchContext) -> [String] {
        let variableName = context.variableName
        let minimum = 44
        var changedLines: [Int] = []

        for index in context.lines.indices {
            let line = context.lines[index]
            guard line.contains("\(variableName).") else { continue }
            guard line.contains("widthAnchor") || line.contains("heightAnchor") else { continue }
            guard line.contains("equalToConstant:") else { continue }

            let updated = replaceTouchTargetConstant(in: line, minimum: minimum)
            if updated != line {
                context.lines[index] = updated
                changedLines.append(index + 1)
            }
        }

        if changedLines.isEmpty {
            return ["Already meets touch target minimum for \(variableName)."]
        }
        return ["Updated touch target constraints at lines \(changedLines.map(String.init).joined(separator: ", ")). "]
    }

    // MARK: - Helpers

    private func resolveFileURL(relativePath: String) -> URL {
        projectRoot.appendingPathComponent(relativePath)
    }

    private func findLine(matching fragment: String, in lines: [String]) -> Int? {
        lines.firstIndex { $0.contains(fragment) }
    }

    private func removeLine(matching fragment: String, in lines: inout [String]) {
        if let index = lines.firstIndex(where: { $0.contains(fragment) }) {
            lines.remove(at: index)
        }
    }

    private func findLineAfterConstraints(for variableName: String, in lines: [String], near anchorLine: Int) -> Int? {
        let start = max(0, anchorLine - 1)
        var inBlock = false

        for index in start..<lines.count {
            let line = lines[index]
            if line.contains("NSLayoutConstraint.activate") {
                inBlock = true
            }
            if inBlock, line.contains("\(variableName)."), line.contains("Anchor") {
                continue
            }
            if inBlock, line.trimmingCharacters(in: .whitespaces) == "])" {
                return index
            }
        }

        return lines.indices.reversed().first { lines[$0].trimmingCharacters(in: .whitespaces) == "])" }
    }

    private func replaceTouchTargetConstant(in line: String, minimum: Int) -> String {
        guard let regex = try? NSRegularExpression(pattern: #"equalToConstant:\s*(\d+)"#) else {
            return line
        }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range),
              let sizeRange = Range(match.range(at: 1), in: line),
              let size = Int(line[sizeRange]),
              size < minimum else {
            return line
        }

        var updated = line
        updated.replaceSubrange(sizeRange, with: String(minimum))
        return updated
    }

    private func leadingWhitespace(_ line: String) -> String {
        String(line.prefix(while: { $0 == " " || $0 == "\t" }))
    }

    private func ensureImport(module: String, in lines: inout [String], messages: inout [String]) {
        guard !lines.contains(where: { $0.contains("import \(module)") }) else { return }

        if let index = lines.lastIndex(where: { $0.hasPrefix("import ") }) {
            lines.insert("import \(module)", at: index + 1)
            messages.append("Added import \(module).")
        }
    }

    private func frameworkApplyBlock(
        variableName: String,
        componentId: String,
        ruleIds: Set<String>
    ) -> String {
        var wcag: [String] = []
        if ruleIds.contains("ios-a11y-missing-label") || ruleIds.contains("ios-a11y-missing-role") {
            wcag.append(".nameRoleValue")
        }
        if ruleIds.contains(where: { $0.hasPrefix("ios-a11y-touch-target") }) {
            wcag.append(".targetSize")
        }

        let wcagLine = wcag.isEmpty ? "" : "\n    wcag: [\(wcag.joined(separator: ", "))],"
        return """
        \(variableName).applyA11y(
            A11ySpec(
                id: "\(componentId)",
                label: "Descriptive label",
                role: .button,\(wcagLine)
            )
        )
        """
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
