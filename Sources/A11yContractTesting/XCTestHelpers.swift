import Foundation
import XCTest
import A11yContractCore
import A11yContractReporter

public func XCTAssertNoCriticalA11yIssues(
    _ report: A11yReport,
    file: StaticString = #file,
    line: UInt = #line
) {
    let critical = report.issues.filter { $0.severity == .critical }
    if !critical.isEmpty {
        let messages = critical.map { "- [\($0.ruleId)] \($0.message)" }.joined(separator: "\n")
        XCTFail("Found \(critical.count) critical accessibility issue(s):\n\(messages)", file: file, line: line)
    }
}

public func XCTAssertNoA11yIssues(
    _ report: A11yReport,
    minimumSeverity: A11ySeverity = .minor,
    file: StaticString = #file,
    line: UInt = #line
) {
    let failing = report.issues.filter { $0.severity >= minimumSeverity }
    if !failing.isEmpty {
        let messages = failing.map { "- [\($0.severity.rawValue)] \($0.ruleId): \($0.message)" }
            .joined(separator: "\n")
        XCTFail(
            "Found \(failing.count) accessibility issue(s) at or above \(minimumSeverity.rawValue):\n\(messages)",
            file: file,
            line: line
        )
    }
}
