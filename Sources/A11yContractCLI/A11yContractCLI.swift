#if os(macOS)
import ArgumentParser
import Foundation
import A11yContractCore
import A11yContractReporter

@main
struct A11yContractCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "a11y-contract",
        abstract: "Accessibility contract scanner for iOS projects.",
        subcommands: [Scan.self, Baseline.self, ExportFixes.self],
        defaultSubcommand: Scan.self
    )
}

extension A11yContractCLI {
    struct Scan: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Run accessibility audit via XCTest.")

        @Option(name: .long, help: "Project directory.")
        var project: String = "."

        @Option(name: .long, help: "Target platform.")
        var platform: String = "ios"

        @Option(name: .long, help: "Comma-separated reporters: markdown,json,html,sonar,sarif,junit.")
        var reporters: String = "markdown,json"

        @Option(name: .long, help: "Output directory.")
        var output: String = ".a11y"

        @Option(name: .long, help: "Fail on issues at or above severity: critical, major, minor, info.")
        var failOn: String?

        @Flag(name: .long, help: "Fail only when new issues appear compared to baseline.")
        var failOnNewIssues: Bool = false

        @Option(name: .long, help: "Baseline JSON path.")
        var baseline: String?

        @Option(name: .long, help: "XCTest filter expression.")
        var filter: String = "A11y"

        @Option(name: .long, help: "iOS Simulator destination (used when --platform ios).")
        var destination: String = "platform=iOS Simulator,OS=18.6,name=iPhone 16"

        func run() throws {
            let projectURL = URL(fileURLWithPath: project, isDirectory: true).standardizedFileURL
            let outputURL = projectURL.appendingPathComponent(output, isDirectory: true)

            let partialOutput = outputURL.appendingPathComponent("partial", isDirectory: true)
            try A11yCLITestRunner.run(
                projectURL: projectURL,
                partialOutput: partialOutput,
                filter: filter,
                platform: platform,
                destination: destination
            )

            let projectName = A11yCLITestRunner.resolveProjectName(filter: filter, projectURL: projectURL)
            let report = try A11yTestReportAggregator.aggregate(
                from: partialOutput,
                projectName: projectName
            )

            let kinds = parseReporters(reporters)
            _ = try A11yReportWriter().write(report: report, kinds: kinds, to: outputURL)

            if report.issues.isEmpty {
                fputs(
                    "Warning: no accessibility issues exported. UIKit audits require --platform ios (default) and an available iOS Simulator.\n",
                    stderr
                )
            } else {
                print("Found \(report.issues.count) issue(s). Reports written to \(outputURL.path)")
            }

            if let baselinePath = baseline {
                let baselineURL = URL(fileURLWithPath: baselinePath, isDirectory: false)
                let baselineData = try Data(contentsOf: baselineURL)
                let decoder = JSONDecoder()
                let storedBaseline = try decoder.decode(A11yBaseline.self, from: baselineData)
                let diff = A11yBaselineService.diff(current: report, baseline: storedBaseline)

                let diffReport = A11yReport(
                    projectName: "\(report.projectName)-new-issues",
                    issues: diff.newIssues
                )
                _ = try A11yReportWriter().write(
                    report: diffReport,
                    kinds: [.markdown],
                    to: outputURL.appendingPathComponent("baseline-diff", isDirectory: true)
                )

                if failOnNewIssues, !diff.newIssues.isEmpty {
                    fputs("Found \(diff.newIssues.count) new accessibility issue(s).\n", stderr)
                    throw ExitCode.failure
                }
            }

            if let failOn {
                let severity = try parseSeverity(failOn)
                let failing = report.issues.filter { $0.severity >= severity }
                if !failing.isEmpty {
                    fputs("Found \(failing.count) issue(s) at or above \(severity.rawValue).\n", stderr)
                    throw ExitCode.failure
                }
            }
        }

        private func parseReporters(_ value: String) -> [A11yReporterKind] {
            value.split(separator: ",").compactMap { part in
                A11yReporterKind(rawValue: part.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
            }
        }

        private func parseSeverity(_ value: String) throws -> A11ySeverity {
            guard let severity = A11ySeverity(rawValue: value.lowercased()) else {
                throw ValidationError("Invalid severity: \(value)")
            }
            return severity
        }
    }

    struct ExportFixes: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "export-fixes",
            abstract: "Export selected accessibility fixes from an audit report.",
            subcommands: [InitSelection.self, ApplySelection.self, PatchSelection.self, ViewReport.self],
            defaultSubcommand: ApplySelection.self
        )

        struct ViewReport: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "view",
                abstract: "Generate an interactive HTML fix picker from an audit report."
            )

            @Option(name: .long, help: "Path to a11y-report.json.")
            var report: String

            @Option(name: .long, help: "Output directory.")
            var output: String = ".a11y"

            @Option(name: .long, help: "UI language: en, pt, es.")
            var lang: String = "pt"

            @Option(name: .long, help: "Project root used to resolve source file paths.")
            var project: String = "."

            func run() throws {
                let reportURL = URL(fileURLWithPath: report, isDirectory: false).standardizedFileURL
                let outputURL = URL(fileURLWithPath: output, isDirectory: true).standardizedFileURL
                let auditReport = try A11yFixExporter.loadReport(from: reportURL)
                let language = InteractiveHTMLLanguage(rawValue: lang.lowercased()) ?? .pt
                let selectionOutput = outputURL.appendingPathComponent("a11y-fix-selection.json")
                let content = InteractiveA11yHTMLReporter().renderHTML(
                    report: auditReport,
                    language: language,
                    reportPath: relativePath(for: reportURL),
                    projectRoot: project,
                    selectionOutputPath: relativePath(for: selectionOutput)
                )
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
                let url = outputURL.appendingPathComponent(InteractiveA11yHTMLReporter.outputFileName)
                try content.write(to: url, atomically: true, encoding: .utf8)
                print("Wrote interactive report to \(url.path)")
                print("Open in a browser: open \"\(url.path)\"")
            }
        }

        struct InitSelection: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "init",
                abstract: "Generate a fix selection template from an audit report."
            )

            @Option(name: .long, help: "Path to a11y-report.json.")
            var report: String

            @Option(name: .long, help: "Output path for a11y-fix-selection.json.")
            var output: String = ".a11y/a11y-fix-selection.json"

            func run() throws {
                let reportURL = URL(fileURLWithPath: report, isDirectory: false).standardizedFileURL
                let outputURL = URL(fileURLWithPath: output, isDirectory: false).standardizedFileURL
                let auditReport = try A11yFixExporter.loadReport(from: reportURL)
                let written = try A11yFixExporter().writeSelectionTemplate(report: auditReport, toFile: outputURL)
                print("Wrote fix selection template to \(written.path)")
            }
        }

        struct ApplySelection: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "apply",
                abstract: "Export fix snippets for selected issues."
            )

            @Option(name: .long, help: "Path to a11y-report.json.")
            var report: String

            @Option(name: .long, help: "Path to a11y-fix-selection.json.")
            var selection: String?

            @Option(name: .long, help: "Comma-separated issue IDs (alternative to --selection).")
            var issues: String?

            @Option(name: .long, help: "Fix style: uikit, framework, swiftui.")
            var style: String = A11yFixStyle.framework.rawValue

            @Option(name: .long, help: "Output format: markdown, swift, html.")
            var format: String = A11yFixExportFormat.markdown.rawValue

            @Option(name: .long, help: "Output directory.")
            var output: String = ".a11y"

            @Flag(name: .long, help: "Export one snippet per issue instead of grouping by component.")
            var noGroupByComponent: Bool = false

            func run() throws {
                let reportURL = URL(fileURLWithPath: report, isDirectory: false).standardizedFileURL
                let outputURL = URL(fileURLWithPath: output, isDirectory: true).standardizedFileURL
                let auditReport = try A11yFixExporter.loadReport(from: reportURL)

                let fixSelection: A11yFixSelection
                if let selectionPath = selection {
                    let manifest = try A11yFixExporter.loadSelectionManifest(
                        from: URL(fileURLWithPath: selectionPath, isDirectory: false).standardizedFileURL
                    )
                    fixSelection = manifest.toSelection()
                } else if let issuesList = issues {
                    guard let parsedStyle = A11yFixStyle(rawValue: style.lowercased()) else {
                        throw ValidationError("Invalid style: \(style)")
                    }
                    let issueIds = issuesList
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    guard !issueIds.isEmpty else {
                        throw ValidationError("Provide at least one issue ID via --issues.")
                    }
                    fixSelection = A11yFixSelection(
                        style: parsedStyle,
                        issueIds: issueIds,
                        groupByComponent: !noGroupByComponent
                    )
                } else {
                    throw ValidationError("Provide --selection or --issues.")
                }

                guard let exportFormat = A11yFixExportFormat(rawValue: format.lowercased()) else {
                    throw ValidationError("Invalid format: \(format)")
                }

                let input = A11yFixBundleInput(report: auditReport, selection: fixSelection)
                let written = try A11yFixExporter().writeFixBundle(
                    input: input,
                    format: exportFormat,
                    to: outputURL
                )

                for url in written {
                    print("Wrote fix bundle to \(url.path)")
                }
            }
        }

        struct PatchSelection: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "patch",
                abstract: "Apply selected fixes directly to source files."
            )

            @Option(name: .long, help: "Path to a11y-report.json.")
            var report: String

            @Option(name: .long, help: "Path to a11y-fix-selection.json.")
            var selection: String?

            @Option(name: .long, help: "Comma-separated issue IDs (alternative to --selection).")
            var issues: String?

            @Option(name: .long, help: "Project root used to resolve file paths from the report.")
            var project: String = "."

            @Option(name: .long, help: "Fix style: uikit, framework, swiftui.")
            var style: String = A11yFixStyle.framework.rawValue

            @Flag(name: .long, help: "Patch every issue in the report that has a source file.")
            var all: Bool = false

            @Flag(name: .long, help: "Preview changes without writing files.")
            var dryRun: Bool = false

            @Flag(name: .long, help: "Open patched files in the default editor after applying.")
            var open: Bool = false

            @Flag(name: .long, help: "Export one patch per issue instead of grouping by component.")
            var noGroupByComponent: Bool = false

            func run() throws {
                let reportURL = URL(fileURLWithPath: report, isDirectory: false).standardizedFileURL
                let projectURL = URL(fileURLWithPath: project, isDirectory: true).standardizedFileURL
                let auditReport = try A11yFixExporter.loadReport(from: reportURL)
                let fixSelection = try resolveSelection(report: auditReport, reportURL: reportURL)

                let outcomes = try A11yFixExporter().applyPatches(
                    report: auditReport,
                    selection: fixSelection,
                    projectRoot: projectURL,
                    dryRun: dryRun
                )

                if outcomes.isEmpty {
                    print("No patches applied.")
                    return
                }

                let changedFiles = outcomes.filter(\.changed).count
                let issueCount = fixSelection.issueIds.count
                print("\nSummary: \(issueCount) issue(s), \(changedFiles) file(s) \(dryRun ? "would change" : "updated").")

                for outcome in outcomes {
                    print("\n\(outcome.filePath)")
                    for message in outcome.messages {
                        print("  - \(message)")
                    }
                    if outcome.changed {
                        print("  => \(dryRun ? "Would update" : "Updated") \(outcome.filePath)")
                    } else {
                        print("  => No changes")
                    }
                }

                if open, !dryRun {
                    let changedOutcomes = outcomes.filter(\.changed)
                    if changedOutcomes.count > 5 {
                        fputs(
                            "Warning: --open skipped for \(changedOutcomes.count) files. Open from your IDE or run without --open.\n",
                            stderr
                        )
                    } else {
                        for outcome in changedOutcomes {
                            let fileURL = projectURL.appendingPathComponent(outcome.filePath)
                            try openInEditor(fileURL)
                        }
                    }
                }
            }

            private func resolveSelection(report: A11yReport, reportURL: URL) throws -> A11yFixSelection {
                let parsedStyle = A11yFixStyle(rawValue: style.lowercased()) ?? .framework
                let groupByComponent = !noGroupByComponent

                if let selectionPath = selection {
                    let manifest = try A11yFixExporter.loadSelectionManifest(
                        from: URL(fileURLWithPath: selectionPath, isDirectory: false).standardizedFileURL
                    )
                    return manifest.toSelection()
                }

                if let savedSelection = try A11yFixExporter.loadSelectionManifestIfPresent(nearReport: reportURL) {
                    return savedSelection
                }

                if all {
                    guard let selection = A11yFixExporter.selectionForAllPatchable(
                        report: report,
                        style: parsedStyle,
                        groupByComponent: groupByComponent
                    ) else {
                        throw ValidationError("No patchable issues with source files in the report.")
                    }
                    return selection
                }

                if let issuesList = issues {
                    guard A11yFixStyle(rawValue: style.lowercased()) != nil else {
                        throw ValidationError("Invalid style: \(style)")
                    }
                    let issueIds = issuesList
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    guard !issueIds.isEmpty else {
                        throw ValidationError("Provide at least one issue ID via --issues.")
                    }
                    return A11yFixSelection(
                        style: parsedStyle,
                        issueIds: issueIds,
                        groupByComponent: groupByComponent
                    )
                }

                if let fallback = A11yFixExporter.selectionForAllPatchable(
                    report: report,
                    style: parsedStyle,
                    groupByComponent: groupByComponent
                ) {
                    return fallback
                }

                throw ValidationError("No patchable issues with source files in the report.")
            }

            private func openInEditor(_ url: URL) throws {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                process.arguments = [url.path]
                try process.run()
                process.waitUntilExit()
            }
        }
    }

    struct Baseline: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "baseline",
            subcommands: [Create.self],
            defaultSubcommand: Create.self
        )

        struct Create: ParsableCommand {
            static let configuration = CommandConfiguration(commandName: "create")

            @Option(name: .long, help: "Project directory.")
            var project: String = "."

            @Option(name: .long, help: "Output baseline JSON path.")
            var output: String = ".a11y/baseline.json"

            @Option(name: .long, help: "XCTest filter expression.")
            var filter: String = "A11y"

            @Option(name: .long, help: "Target platform.")
            var platform: String = "ios"

            @Option(name: .long, help: "iOS Simulator destination (used when --platform ios).")
            var destination: String = "platform=iOS Simulator,name=iPhone 16"

            func run() throws {
                let projectURL = URL(fileURLWithPath: project, isDirectory: true).standardizedFileURL
                let partialOutput = projectURL.appendingPathComponent(".a11y/partial", isDirectory: true)

                try A11yCLITestRunner.run(
                    projectURL: projectURL,
                    partialOutput: partialOutput,
                    filter: filter,
                    platform: platform,
                    destination: destination
                )

                let report = try A11yTestReportAggregator.aggregate(
                    from: partialOutput,
                    projectName: projectURL.lastPathComponent
                )

                let baseline = A11yBaselineService.create(from: report)
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(baseline)

                let outputURL = URL(fileURLWithPath: output, isDirectory: false)
                try FileManager.default.createDirectory(
                    at: outputURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try data.write(to: outputURL)
            }
        }
    }
}

private func relativePath(for url: URL) -> String {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).standardizedFileURL.path
    let path = url.standardizedFileURL.path
    if path.hasPrefix(cwd + "/") {
        return String(path.dropFirst(cwd.count + 1))
    }
    return path
}

enum A11yTestReportAggregator {
    static func aggregate(from directory: URL, projectName: String) throws -> A11yReport {
        try A11yTestReportExporter.aggregateReports(from: directory, projectName: projectName)
    }
}

enum A11yCLITestRunner {
    static func run(
        projectURL: URL,
        partialOutput: URL,
        filter: String,
        platform: String = "ios",
        destination: String = "platform=iOS Simulator,name=iPhone 16"
    ) throws {
        if platform.lowercased() == "ios" {
            try runXcodebuildTests(
                projectURL: projectURL,
                partialOutput: partialOutput,
                filter: filter,
                destination: destination
            )
        } else {
            try runSwiftPMTests(
                projectURL: projectURL,
                partialOutput: partialOutput,
                filter: filter
            )
        }
    }

    static func resolveProjectName(filter: String, projectURL: URL) -> String {
        if filter == "UIKitExample" || filter == "UIKitExampleTests" {
            return "UIKitExample"
        }
        return projectURL.lastPathComponent
    }

    private static func runSwiftPMTests(projectURL: URL, partialOutput: URL, filter: String) throws {
        let process = Process()
        process.currentDirectoryURL = projectURL
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            "swift", "test",
            "--filter", filter,
        ]
        var environment = ProcessInfo.processInfo.environment
        environment[A11yTestReportExporter.outputEnvironmentKey] = partialOutput.path
        process.environment = environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                fputs(output, stderr)
            }
            throw ExitCode(process.terminationStatus)
        }
    }

    private static func runXcodebuildTests(
        projectURL: URL,
        partialOutput: URL,
        filter: String,
        destination: String
    ) throws {
        try FileManager.default.createDirectory(at: partialOutput, withIntermediateDirectories: true)

        let scheme = resolveXcodeScheme(projectURL: projectURL)
        var arguments = [
            "test",
            "-scheme", scheme,
            "-destination", destination,
            "-quiet",
        ]

        for testTarget in resolveTestTargets(for: filter) {
            arguments.append("-only-testing:\(testTarget)")
        }

        let process = Process()
        process.currentDirectoryURL = projectURL
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = arguments
        var environment = ProcessInfo.processInfo.environment
        environment[A11yTestReportExporter.outputEnvironmentKey] = partialOutput.path
        process.environment = environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            if !hasPartialReports(in: partialOutput) {
                if let output = String(data: data, encoding: .utf8) {
                    fputs(output, stderr)
                }
                throw ExitCode(process.terminationStatus)
            }
            fputs(
                "Warning: xcodebuild exited with status \(process.terminationStatus); continuing with exported partial reports.\n",
                stderr
            )
        }
    }

    private static func hasPartialReports(in directory: URL) -> Bool {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return false
        }
        for case let url as URL in enumerator where url.lastPathComponent == "a11y-report.json" {
            return true
        }
        return false
    }

    private static func resolveXcodeScheme(projectURL: URL) -> String {
        let packageURL = projectURL.appendingPathComponent("Package.swift")
        guard let contents = try? String(contentsOf: packageURL, encoding: .utf8),
              let nameRange = contents.range(of: "name: \""),
              let endQuote = contents[nameRange.upperBound...].firstIndex(of: "\"") else {
            return "A11yContractKit-Package"
        }
        let packageName = String(contents[nameRange.upperBound..<endQuote])
        return "\(packageName)-Package"
    }

    private static func resolveTestTargets(for filter: String) -> [String] {
        if filter == "A11y" {
            return ["A11yContractTestingTests", "UIKitExampleTests/DeleteButtonA11yTests/testDeleteButtonA11yIssues"]
        }
        if filter == "UIKitExample" {
            return ["UIKitExampleTests/DeleteButtonA11yTests/testDeleteButtonA11yIssues"]
        }
        if filter.hasSuffix("Tests") {
            return [filter]
        }
        return ["\(filter)Tests"]
    }
}
#endif
