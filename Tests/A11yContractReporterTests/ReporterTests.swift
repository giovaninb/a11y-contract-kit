import XCTest
import A11yContractCore
import A11yContractReporter

final class ReporterTests: XCTestCase {
    private let sampleReport = A11yReport(
        projectName: "A11yContractDemo",
        generatedAt: Date(timeIntervalSince1970: 1_750_000_000),
        issues: [
            A11yIssue(
                ruleId: "ios-a11y-missing-label",
                severity: .critical,
                message: "Missing accessible label",
                componentId: "favorite_button",
                filePath: "Sources/Demo/FavoriteButton.swift",
                line: 42,
                wcag: [.nameRoleValue],
                suggestedFix: "Add accessibility label",
                suggestedOwner: .design
            ),
        ],
        conformanceTarget: .wcag22AA
    )

    func testMarkdownReporterContainsSummaryAndIssue() throws {
        let output = try MarkdownA11yReporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("# Accessibility Report"))
        XCTAssertTrue(output.contains("Conformance target: WCAG 2.2 AA"))
        XCTAssertTrue(output.contains("favorite_button"))
        XCTAssertTrue(output.contains("CRITICAL"))
    }

    func testJSONReporterEncodesConformanceTarget() throws {
        let output = try JSONA11yReporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("\"conformanceTarget\""))
        XCTAssertTrue(output.contains("\"level\" : \"AA\""))
    }

    func testJSONReporterEncodesReport() throws {
        let output = try JSONA11yReporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("\"projectName\" : \"A11yContractDemo\""))
        XCTAssertTrue(output.contains("ios-a11y-missing-label"))
    }

    func testSonarReporterUsesExternalIssuesSchema() throws {
        let output = try SonarGenericIssuesReporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("\"engineId\" : \"A11yContractKit\""))
        XCTAssertTrue(output.contains("\"ruleId\" : \"ios-a11y-missing-label\""))
    }

    func testSarifReporterProducesValidVersion() throws {
        let output = try SarifA11yReporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("\"version\" : \"2.1.0\""))
        XCTAssertTrue(output.contains("A11yContractKit"))
    }

    func testJUnitReporterMarksFailures() throws {
        let output = try JUnitA11yReporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("<testsuite"))
        XCTAssertTrue(output.contains("<failure"))
        XCTAssertTrue(output.contains("favorite_button_has_label").self == false)
        XCTAssertTrue(output.contains("favorite_button"))
    }

    func testReportWriterCreatesFiles() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let urls = try A11yReportWriter().write(
            report: sampleReport,
            kinds: [.markdown, .json, .sonar],
            to: directory
        )

        XCTAssertEqual(urls.count, 3)
        XCTAssertTrue(FileManager.default.fileExists(atPath: urls[0].path))
    }
}
