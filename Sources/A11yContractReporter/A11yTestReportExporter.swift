import Foundation
import A11yContractCore

public enum A11yTestReportExporter {
    public static let outputEnvironmentKey = "A11Y_REPORT_OUTPUT"

    public static func exportIfNeeded(_ report: A11yReport, testName: String) throws {
        guard let outputPath = ProcessInfo.processInfo.environment[outputEnvironmentKey] else {
            return
        }

        try export(
            report,
            to: URL(fileURLWithPath: outputPath, isDirectory: true),
            testName: testName
        )
    }

    public static func export(
        _ report: A11yReport,
        to outputDirectory: URL,
        testName: String
    ) throws {
        let directory = outputDirectory
            .appendingPathComponent(sanitize(testName), isDirectory: true)

        let partialReport = A11yReport(
            projectName: report.projectName,
            generatedAt: report.generatedAt,
            issues: report.issues,
            conformanceTarget: report.conformanceTarget
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(partialReport)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent("a11y-report.json"))
    }

    public static func aggregateReports(from directory: URL, projectName: String) throws -> A11yReport {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: directory.path) else {
            return A11yReport(projectName: projectName, issues: [])
        }

        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return A11yReport(projectName: projectName, issues: [])
        }

        var allIssues: [A11yIssue] = []
        var conformanceTarget: A11yConformanceTarget?
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for case let url as URL in enumerator where url.lastPathComponent == "a11y-report.json" {
            let data = try Data(contentsOf: url)
            let report = try decoder.decode(A11yReport.self, from: data)
            allIssues.append(contentsOf: report.issues)
            if conformanceTarget == nil {
                conformanceTarget = report.conformanceTarget
            }
        }

        return A11yReport(
            projectName: projectName,
            issues: allIssues,
            conformanceTarget: conformanceTarget
        )
    }

    private static func sanitize(_ value: String) -> String {
        value
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }
}
