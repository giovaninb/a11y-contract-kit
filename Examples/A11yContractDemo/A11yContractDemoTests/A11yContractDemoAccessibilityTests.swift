import A11yContractCore
import A11yContractTesting
import XCTest

@testable import A11yContractDemo

final class A11yContractDemoAccessibilityTests: XCTestCase {
    override func tearDown() {
        A11yContractRegistry.shared.clear()
        super.tearDown()
    }

    func testProblemsScreenProducesCriticalIssues() {
        let report = A11yAudit.run(
            on: UIKitProblemsViewController(),
            projectName: "A11yContractDemo"
        )

        XCTAssertTrue(report.issues.contains {
            $0.ruleId == "ios-a11y-missing-label" && $0.severity == .critical
        })
    }

    func testFixedScreenHasNoCriticalIssues() {
        let report = A11yAudit.run(
            on: UIKitFixedViewController(),
            projectName: "A11yContractDemo"
        )

        XCTAssertNoCriticalA11yIssues(report)
    }
}
