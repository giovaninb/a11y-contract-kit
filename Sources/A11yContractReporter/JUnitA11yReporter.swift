import Foundation
import A11yContractCore

public struct JUnitA11yReporter: A11yReporter {
    public let outputFileName = "a11y-junit.xml"
    public let failingSeverities: Set<A11ySeverity>

    public init(failingSeverities: Set<A11ySeverity> = [.critical, .major, .minor]) {
        self.failingSeverities = failingSeverities
    }

    public func generate(report: A11yReport) throws -> String {
        let failures = report.issues.filter { failingSeverities.contains($0.severity) }.count
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <testsuite name="A11yContractKit" tests="\(report.issues.count)" failures="\(failures)">

        """

        for issue in report.issues {
            let className = issue.filePath ?? report.projectName
            let testName = issue.componentId ?? issue.ruleId
            xml += "  <testcase classname=\"\(escapeXML(className))\" name=\"\(escapeXML(testName))\">\n"

            if failingSeverities.contains(issue.severity) {
                let wcag = issue.wcag.map(\.formatted).joined(separator: ", ")
                xml += "    <failure message=\"\(escapeXML(issue.message))\">"
                xml += escapeXML(wcag.isEmpty ? issue.message : wcag)
                xml += "</failure>\n"
            }

            xml += "  </testcase>\n"
        }

        xml += "</testsuite>\n"
        return xml
    }

    private func escapeXML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
