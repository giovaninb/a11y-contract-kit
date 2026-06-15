import Foundation
import A11yContractCore

public enum A11yReporterKind: String, CaseIterable {
    case markdown
    case json
    case sonar
    case sarif
    case junit

    public func makeReporter() -> any A11yReporter {
        switch self {
        case .markdown: return MarkdownA11yReporter()
        case .json: return JSONA11yReporter()
        case .sonar: return SonarGenericIssuesReporter()
        case .sarif: return SarifA11yReporter()
        case .junit: return JUnitA11yReporter()
        }
    }
}

public struct A11yReportWriter {
    public init() {}

    public func write(report: A11yReport, reporters: [any A11yReporter], to directory: URL) throws -> [URL] {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var written: [URL] = []

        for reporter in reporters {
            let content = try reporter.generate(report: report)
            let url = directory.appendingPathComponent(reporter.outputFileName)
            try content.write(to: url, atomically: true, encoding: .utf8)
            written.append(url)
        }

        return written
    }

    public func write(
        report: A11yReport,
        kinds: [A11yReporterKind],
        to directory: URL
    ) throws -> [URL] {
        try write(report: report, reporters: kinds.map { $0.makeReporter() }, to: directory)
    }
}
