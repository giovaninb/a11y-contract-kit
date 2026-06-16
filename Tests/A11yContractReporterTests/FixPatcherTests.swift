import XCTest
import A11yContractCore
import A11yContractReporter

final class FixPatcherTests: XCTestCase {
    private let sampleSource = """
    import UIKit

    final class SampleViewController: UIViewController {
        let deleteButton = UIButton(type: .system)

        override func viewDidLoad() {
            super.viewDidLoad()
            deleteButton.accessibilityLabel = nil
            deleteButton.accessibilityIdentifier = "delete_button"
            view.addSubview(deleteButton)

            NSLayoutConstraint.activate([
                deleteButton.widthAnchor.constraint(equalToConstant: 28),
                deleteButton.heightAnchor.constraint(equalToConstant: 28),
            ])
        }
    }
    """

    private func makeIssue(
        id: String,
        ruleId: String,
        filePath: String,
        line: Int,
        componentId: String = "delete_button"
    ) -> A11yIssue {
        A11yIssue(
            id: id,
            ruleId: ruleId,
            severity: .critical,
            message: "Issue",
            componentId: componentId,
            filePath: filePath,
            line: line,
            wcag: []
        )
    }

    private func writeSampleSource(at url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try sampleSource.write(to: url, atomically: true, encoding: .utf8)
    }

    func testUIKitPatchUpdatesLabelTraitsAndTouchTarget() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let relativePath = "Sources/SampleViewController.swift"
        let fileURL = root.appendingPathComponent(relativePath)
        try writeSampleSource(at: fileURL)

        let report = A11yReport(
            projectName: "Demo",
            issues: [
                makeIssue(id: "1", ruleId: "ios-a11y-missing-label", filePath: relativePath, line: 8),
                makeIssue(id: "2", ruleId: "ios-a11y-missing-role", filePath: relativePath, line: 9),
                makeIssue(id: "3", ruleId: "ios-a11y-touch-target-hig", filePath: relativePath, line: 14),
            ]
        )

        let selection = A11yFixSelection(
            style: .uikit,
            issueIds: ["1", "2", "3"],
            groupByComponent: true
        )

        let outcomes = try A11yFixPatcher(projectRoot: root).apply(report: report, selection: selection)
        XCTAssertEqual(outcomes.count, 1)
        XCTAssertTrue(outcomes[0].changed)

        let updated = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertTrue(updated.contains("deleteButton.accessibilityLabel = \"Descriptive label\""))
        XCTAssertTrue(updated.contains("deleteButton.accessibilityTraits = [.button]"))
        XCTAssertTrue(updated.contains("equalToConstant: 44"))
        XCTAssertFalse(updated.contains("equalToConstant: 28"))
    }

    func testFrameworkPatchInsertsApplyA11yAndImports() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let relativePath = "Sources/SampleViewController.swift"
        let fileURL = root.appendingPathComponent(relativePath)
        try writeSampleSource(at: fileURL)

        let report = A11yReport(
            projectName: "Demo",
            issues: [
                makeIssue(id: "1", ruleId: "ios-a11y-missing-label", filePath: relativePath, line: 8),
                makeIssue(id: "2", ruleId: "ios-a11y-missing-role", filePath: relativePath, line: 9),
                makeIssue(id: "3", ruleId: "ios-a11y-touch-target-hig", filePath: relativePath, line: 14),
            ]
        )

        let selection = A11yFixSelection(
            style: .framework,
            issueIds: ["1", "2", "3"],
            groupByComponent: true
        )

        let outcomes = try A11yFixPatcher(projectRoot: root).apply(report: report, selection: selection)
        XCTAssertTrue(outcomes[0].changed)

        let updated = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertTrue(updated.contains("import A11yContractUIKit"))
        XCTAssertTrue(updated.contains("import A11yContractCore"))
        XCTAssertTrue(updated.contains("deleteButton.applyA11y("))
        XCTAssertFalse(updated.contains("accessibilityLabel = nil"))
        XCTAssertTrue(updated.contains("equalToConstant: 44"))
    }

    func testDryRunDoesNotWriteFile() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let relativePath = "Sources/SampleViewController.swift"
        let fileURL = root.appendingPathComponent(relativePath)
        try writeSampleSource(at: fileURL)
        let original = try String(contentsOf: fileURL, encoding: .utf8)

        let report = A11yReport(
            projectName: "Demo",
            issues: [makeIssue(id: "1", ruleId: "ios-a11y-missing-label", filePath: relativePath, line: 8)]
        )
        let selection = A11yFixSelection(style: .uikit, issueIds: ["1"])

        _ = try A11yFixPatcher(projectRoot: root, dryRun: true).apply(report: report, selection: selection)
        let after = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertEqual(original, after)
    }
}
