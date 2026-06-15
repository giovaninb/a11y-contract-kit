import Foundation
import A11yContractCore

public struct FixSelectionTemplateExporter {
    public static let outputFileName = "a11y-fix-selection.json"

    private let encoder: JSONEncoder

    public init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func generate(report: A11yReport) throws -> String {
        let manifest = A11yFixSelectionManifest.from(report: report)
        let data = try encoder.encode(manifest)
        guard let string = String(data: data, encoding: .utf8) else {
            throw A11yReporterError.encodingFailed
        }
        return string
    }
}
