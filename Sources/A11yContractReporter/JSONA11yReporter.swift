import Foundation
import A11yContractCore

public struct JSONA11yReporter: A11yReporter {
    public let outputFileName = "a11y-report.json"

    private let encoder: JSONEncoder

    public init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
    }

    public func generate(report: A11yReport) throws -> String {
        let data = try encoder.encode(report)
        guard let string = String(data: data, encoding: .utf8) else {
            throw A11yReporterError.encodingFailed
        }
        return string
    }
}
