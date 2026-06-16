import Foundation
import A11yContractCore

public struct A11yFixExporter {
    public init() {}

    @discardableResult
    public func writeSelectionTemplate(report: A11yReport, to directory: URL) throws -> URL {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let content = try FixSelectionTemplateExporter().generate(report: report)
        let url = directory.appendingPathComponent(FixSelectionTemplateExporter.outputFileName)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    @discardableResult
    public func writeSelectionTemplate(report: A11yReport, toFile url: URL) throws -> URL {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let content = try FixSelectionTemplateExporter().generate(report: report)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    @discardableResult
    public func writeFixBundle(
        input: A11yFixBundleInput,
        format: A11yFixExportFormat = .markdown,
        to directory: URL
    ) throws -> [URL] {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        switch format {
        case .markdown:
            let content = FixBundleMarkdownReporter().generate(input: input)
            let url = directory.appendingPathComponent(FixBundleMarkdownReporter.outputFileName)
            try content.write(to: url, atomically: true, encoding: .utf8)
            return [url]
        case .swift:
            let content = FixBundleSwiftReporter().generate(input: input)
            let url = directory.appendingPathComponent(FixBundleSwiftReporter.outputFileName)
            try content.write(to: url, atomically: true, encoding: .utf8)
            return [url]
        case .html:
            let content = InteractiveA11yHTMLReporter().renderHTML(report: input.report)
            let url = directory.appendingPathComponent(InteractiveA11yHTMLReporter.outputFileName)
            try content.write(to: url, atomically: true, encoding: .utf8)
            return [url]
        }
    }

    public static func loadReport(from url: URL) throws -> A11yReport {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(A11yReport.self, from: data)
    }

    public static func loadSelectionManifest(from url: URL) throws -> A11yFixSelectionManifest {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(A11yFixSelectionManifest.self, from: data)
    }

    @discardableResult
    public func applyPatches(
        report: A11yReport,
        selection: A11yFixSelection,
        projectRoot: URL,
        dryRun: Bool = false
    ) throws -> [A11yFixPatchOutcome] {
        try A11yFixPatcher(projectRoot: projectRoot, dryRun: dryRun).apply(
            report: report,
            selection: selection
        )
    }
}
