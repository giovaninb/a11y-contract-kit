import Foundation
import A11yContractCore

public struct SarifA11yReporter: A11yReporter {
    public let outputFileName = "a11y.sarif"

    public init() {}

    public func generate(report: A11yReport) throws -> String {
        let rules = Dictionary(uniqueKeysWithValues: report.issues.map { issue in
            (issue.ruleId, [
                "id": issue.ruleId,
                "name": issue.ruleId,
                "shortDescription": ["text": issue.message],
            ] as [String: Any])
        })

        let results: [[String: Any]] = report.issues.map { issue in
            var location: [String: Any] = [
                "message": ["text": issue.message],
                "ruleId": issue.ruleId,
                "level": mapLevel(issue.severity),
            ]

            if let filePath = issue.filePath {
                var region: [String: Any] = [:]
                if let line = issue.line {
                    region["startLine"] = line
                    region["endLine"] = line
                }
                location["locations"] = [[
                    "physicalLocation": [
                        "artifactLocation": ["uri": filePath],
                        "region": region,
                    ],
                ]]
            }

            return location
        }

        let payload: [String: Any] = [
            "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
            "version": "2.1.0",
            "runs": [[
                "tool": [
                    "driver": [
                        "name": "A11yContractKit",
                        "informationUri": "https://github.com/a11y-contract-kit",
                        "rules": Array(rules.values),
                    ],
                ],
                "results": results,
            ]],
        ]

        let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        guard let string = String(data: data, encoding: .utf8) else {
            throw A11yReporterError.encodingFailed
        }
        return string
    }

    private func mapLevel(_ severity: A11ySeverity) -> String {
        switch severity {
        case .critical, .major: return "error"
        case .minor: return "warning"
        case .info: return "note"
        }
    }
}
