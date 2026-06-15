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
        subcommands: [Scan.self, Baseline.self],
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

        @Option(name: .long, help: "Comma-separated reporters: markdown,json,sonar,sarif,junit.")
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

        func run() throws {
            let projectURL = URL(fileURLWithPath: project, isDirectory: true).standardizedFileURL
            let outputURL = projectURL.appendingPathComponent(output, isDirectory: true)

            let partialOutput = outputURL.appendingPathComponent("partial", isDirectory: true)
            try runSwiftTests(projectURL: projectURL, partialOutput: partialOutput, filter: filter)

            let report = try A11yTestReportAggregator.aggregate(
                from: partialOutput,
                projectName: projectURL.lastPathComponent
            )

            let kinds = parseReporters(reporters)
            _ = try A11yReportWriter().write(report: report, kinds: kinds, to: outputURL)

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

        fileprivate func runSwiftTests(projectURL: URL, partialOutput: URL, filter: String) throws {
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

            func run() throws {
                let projectURL = URL(fileURLWithPath: project, isDirectory: true).standardizedFileURL
                let partialOutput = projectURL.appendingPathComponent(".a11y/partial", isDirectory: true)

                try Scan().runSwiftTests(projectURL: projectURL, partialOutput: partialOutput, filter: filter)

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

enum A11yTestReportAggregator {
    static func aggregate(from directory: URL, projectName: String) throws -> A11yReport {
        try A11yTestReportExporter.aggregateReports(from: directory, projectName: projectName)
    }
}
#endif
