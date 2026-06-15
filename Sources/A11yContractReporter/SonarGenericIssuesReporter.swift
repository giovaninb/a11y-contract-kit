import Foundation
import A11yContractCore

public struct SonarGenericIssuesReporter: A11yReporter {
    public let outputFileName = "sonar-issues.json"

    public init() {}

    public func generate(report: A11yReport) throws -> String {
        let issues = report.issues.map { issue -> [String: Any] in
            var location: [String: Any] = [
                "message": issue.message,
            ]
            if let filePath = issue.filePath {
                location["filePath"] = filePath
            }
            if let line = issue.line {
                location["textRange"] = [
                    "startLine": line,
                    "endLine": line,
                ]
            }

            return [
                "engineId": "A11yContractKit",
                "ruleId": issue.ruleId,
                "severity": mapSeverity(issue.severity),
                "type": "CODE_SMELL",
                "primaryLocation": location,
            ]
        }

        let payload: [String: Any] = ["issues": issues]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        guard let string = String(data: data, encoding: .utf8) else {
            throw A11yReporterError.encodingFailed
        }
        return string
    }

    private func mapSeverity(_ severity: A11ySeverity) -> String {
        switch severity {
        case .critical: return "CRITICAL"
        case .major: return "MAJOR"
        case .minor: return "MINOR"
        case .info: return "INFO"
        }
    }
}
