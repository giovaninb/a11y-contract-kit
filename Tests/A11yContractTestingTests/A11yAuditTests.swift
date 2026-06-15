#if canImport(UIKit)
import UIKit
import XCTest
import A11yContractCore
import A11yContractReporter
import A11yContractTesting

final class AccessibilityProblemsViewController: UIViewController {
    let deleteButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        deleteButton.frame = CGRect(x: 20, y: 100, width: 44, height: 44)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.accessibilityLabel = nil
        view.addSubview(deleteButton)
    }
}

final class A11yAuditTests: XCTestCase {
    override func tearDown() {
        A11yContractRegistry.shared.clear()
        super.tearDown()
    }

    func testAccessibilityProblemsDetectsMissingLabel() throws {
        let report = A11yAudit.run(on: AccessibilityProblemsViewController(), projectName: "A11yContractDemo")

        XCTAssertTrue(report.issues.contains {
            $0.ruleId == "ios-a11y-missing-label" && $0.severity == .critical
        })

        try A11yTestReportExporter.exportIfNeeded(report, testName: name)

        let markdown = try MarkdownA11yReporter().generate(report: report)
        XCTAssertTrue(markdown.contains("Accessibility Report"))

        let sonar = try SonarGenericIssuesReporter().generate(report: report)
        XCTAssertTrue(sonar.contains("A11yContractKit"))
    }

    func testButtonWithoutLabelProducesCriticalIssue() {
        let report = A11yAudit.run(on: AccessibilityProblemsViewController())
        let critical = report.issues.filter { $0.severity == .critical }
        XCTAssertFalse(critical.isEmpty)
    }
}
#else
import XCTest

final class A11yAuditTests: XCTestCase {
    func testA11yAuditRequiresIOSPlatform() throws {
        throw XCTSkip("A11yAudit integration tests require iOS platform.")
    }
}
#endif
