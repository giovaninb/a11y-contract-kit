#if canImport(UIKit)
import XCTest
import A11yContractCore
import A11yContractReporter
import A11yContractTesting
import UIKitExample

final class DeleteButtonA11yTests: XCTestCase {
    override func tearDown() {
        A11yContractRegistry.shared.clear()
        super.tearDown()
    }

    func testDeleteButtonA11yIssues() throws {
        let report = A11yAudit.run(
            on: DeleteButtonProblemsViewController(),
            projectName: "UIKitExample"
        )

        XCTAssertTrue(report.issues.contains {
            $0.ruleId == "ios-a11y-missing-label" && $0.componentId == "delete_button"
        })

        XCTAssertTrue(report.issues.contains { $0.suggestedFix != nil })

        let partialOutput = Self.examplePartialOutput
        try A11yTestReportExporter.export(report, to: partialOutput, testName: name)
        try A11yTestReportExporter.exportIfNeeded(report, testName: name)
    }

    private static var examplePartialOutput: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(".a11y/partial", isDirectory: true)
    }

    func testDeleteButtonFixedHasNoCriticalIssues() {
        let report = A11yAudit.run(
            on: DeleteButtonFixedViewController(),
            projectName: "UIKitExample"
        )

        XCTAssertNoCriticalA11yIssues(report)
    }
}
#else
import XCTest

final class DeleteButtonA11yTests: XCTestCase {
    func testDeleteButtonA11yRequiresIOSPlatform() throws {
        throw XCTSkip("UIKitExample tests require iOS platform.")
    }
}
#endif
