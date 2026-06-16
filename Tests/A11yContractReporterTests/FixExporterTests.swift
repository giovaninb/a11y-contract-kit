import XCTest
import A11yContractCore
import A11yContractReporter

final class FixExporterTests: XCTestCase {
    private let deleteLabelIssue = A11yIssue(
        id: "issue-label",
        ruleId: "ios-a11y-missing-label",
        severity: .critical,
        message: "Interactive component without accessible label.",
        componentId: "delete_button",
        filePath: "Sources/Demo/DeleteButton.swift",
        line: 10,
        wcag: [.nameRoleValue],
        suggestedFix: """
        view.applyA11y(A11ySpec(
            id: "delete_button",
            label: "Descriptive label",
            role: .button
        ))
        """
    )

    private let deleteRoleIssue = A11yIssue(
        id: "issue-role",
        ruleId: "ios-a11y-missing-role",
        severity: .major,
        message: "Interactive component without appropriate accessibility role/trait.",
        componentId: "delete_button",
        filePath: "Sources/Demo/DeleteButton.swift",
        line: 10,
        wcag: [.nameRoleValue]
    )

    private let deleteTargetIssue = A11yIssue(
        id: "issue-target",
        ruleId: "ios-a11y-touch-target-hig",
        severity: .info,
        message: "Touch target is 28x28pt. Apple HIG recommends at least 44x44pt.",
        componentId: "delete_button",
        wcag: [],
        suggestedFix: "Increase the interactive area to at least 44x44 points per Apple Human Interface Guidelines."
    )

    private let favoriteLabelIssue = A11yIssue(
        id: "issue-favorite",
        ruleId: "ios-a11y-missing-label",
        severity: .critical,
        message: "Interactive component without accessible label.",
        componentId: "favorite_button",
        wcag: [.nameRoleValue]
    )

    private var sampleReport: A11yReport {
        A11yReport(
            projectName: "A11yContractDemo",
            generatedAt: Date(timeIntervalSince1970: 1_750_000_000),
            issues: [deleteLabelIssue, deleteRoleIssue, deleteTargetIssue, favoriteLabelIssue]
        )
    }

    func testGeneratorProducesDistinctStylesForMissingLabel() {
        let selection = A11yFixSelection(
            style: .uikit,
            issueIds: [deleteLabelIssue.id],
            groupByComponent: false
        )
        let uikit = A11yFixSnippetGenerator().generateSnippets(report: sampleReport, selection: selection)
        XCTAssertEqual(uikit.count, 1)
        XCTAssertTrue(uikit[0].code.contains("deleteButton.accessibilityLabel"))

        let frameworkSelection = A11yFixSelection(style: .framework, issueIds: [deleteLabelIssue.id], groupByComponent: false)
        let framework = A11yFixSnippetGenerator().generateSnippets(report: sampleReport, selection: frameworkSelection)
        XCTAssertTrue(framework[0].code.contains("applyA11y"))

        let swiftUISelection = A11yFixSelection(style: .swiftUI, issueIds: [deleteLabelIssue.id], groupByComponent: false)
        let swiftUI = A11yFixSnippetGenerator().generateSnippets(report: sampleReport, selection: swiftUISelection)
        XCTAssertTrue(swiftUI[0].code.contains(".accessibilityLabel"))
        XCTAssertFalse(swiftUI[0].code.contains(".a11yContract"))
    }

    func testPartialSelectionExportsOnlySelectedIssues() {
        let selection = A11yFixSelection(
            style: .framework,
            issueIds: [deleteLabelIssue.id],
            groupByComponent: false
        )
        let snippets = A11yFixSnippetGenerator().generateSnippets(report: sampleReport, selection: selection)
        XCTAssertEqual(snippets.count, 1)
        XCTAssertEqual(snippets[0].ruleIds, ["ios-a11y-missing-label"])
    }

    func testGroupByComponentDeduplicatesDeleteButtonIssues() {
        let selection = A11yFixSelection(
            style: .uikit,
            issueIds: [deleteLabelIssue.id, deleteRoleIssue.id, deleteTargetIssue.id],
            groupByComponent: true
        )
        let snippets = A11yFixSnippetGenerator().generateSnippets(report: sampleReport, selection: selection)
        XCTAssertEqual(snippets.count, 1)
        XCTAssertEqual(Set(snippets[0].ruleIds).count, 3)
        XCTAssertTrue(snippets[0].code.contains("accessibilityLabel"))
        XCTAssertTrue(snippets[0].code.contains("accessibilityTraits"))
        XCTAssertTrue(snippets[0].code.contains("widthAnchor"))
    }

    func testNoGroupByComponentExportsOneSnippetPerIssue() {
        let selection = A11yFixSelection(
            style: .uikit,
            issueIds: [deleteLabelIssue.id, deleteRoleIssue.id, deleteTargetIssue.id],
            groupByComponent: false
        )
        let snippets = A11yFixSnippetGenerator().generateSnippets(report: sampleReport, selection: selection)
        XCTAssertEqual(snippets.count, 3)
    }

    func testInstructionalFixUsesSuggestedFixFallback() {
        let contrastIssue = A11yIssue(
            id: "issue-contrast",
            ruleId: "ios-a11y-low-contrast",
            severity: .critical,
            message: "Insufficient color contrast.",
            componentId: "status_label",
            suggestedFix: "Adjust foreground and background colors to meet WCAG contrast requirements."
        )
        let report = A11yReport(projectName: "Demo", issues: [contrastIssue])
        let selection = A11yFixSelection(style: .framework, issueIds: [contrastIssue.id])

        let snippets = A11yFixSnippetGenerator().generateSnippets(report: report, selection: selection)
        XCTAssertEqual(snippets.count, 1)
        XCTAssertTrue(snippets[0].code.contains("Adjust foreground and background colors"))
    }

    func testSelectionTemplateContainsAllIssuesUnselected() throws {
        let output = try FixSelectionTemplateExporter().generate(report: sampleReport)
        XCTAssertTrue(output.contains("\"selected\" : false"))
        XCTAssertTrue(output.contains("issue-label"))
        XCTAssertTrue(output.contains("issue-role"))
        XCTAssertTrue(output.contains("delete_button"))
        XCTAssertTrue(output.contains("\"style\" : \"framework\""))
    }

    func testSelectionManifestToSelectionUsesSelectedIssues() {
        let manifest = A11yFixSelectionManifest(
            style: .swiftUI,
            issues: [
                A11yFixSelectionIssue(
                    id: "issue-label",
                    ruleId: "ios-a11y-missing-label",
                    componentId: "delete_button",
                    severity: .critical,
                    selected: true
                ),
                A11yFixSelectionIssue(
                    id: "issue-role",
                    ruleId: "ios-a11y-missing-role",
                    componentId: "delete_button",
                    severity: .major,
                    selected: false
                ),
            ]
        )

        let selection = manifest.toSelection()
        XCTAssertEqual(selection.style, .swiftUI)
        XCTAssertEqual(selection.issueIds, ["issue-label"])
    }

    func testMarkdownFixBundleContainsSelectedFixes() {
        let selection = A11yFixSelection(
            style: .framework,
            issueIds: [deleteLabelIssue.id, favoriteLabelIssue.id],
            groupByComponent: true
        )
        let input = A11yFixBundleInput(report: sampleReport, selection: selection)
        let output = FixBundleMarkdownReporter().generate(input: input)

        XCTAssertTrue(output.contains("# Accessibility Fix Bundle"))
        XCTAssertTrue(output.contains("Fix style: Framework"))
        XCTAssertTrue(output.contains("does not modify your project"))
        XCTAssertTrue(output.contains("delete_button"))
        XCTAssertTrue(output.contains("favorite_button"))
        XCTAssertTrue(output.contains("applyA11y"))
    }

    func testSwiftFixBundleUsesSwiftComments() {
        let selection = A11yFixSelection(style: .uikit, issueIds: [deleteLabelIssue.id])
        let input = A11yFixBundleInput(report: sampleReport, selection: selection)
        let output = FixBundleSwiftReporter().generate(input: input)

        XCTAssertTrue(output.contains("// Accessibility Fix Bundle"))
        XCTAssertTrue(output.contains("deleteButton.accessibilityLabel"))
    }

    func testFixExporterWritesFiles() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let templateURL = try A11yFixExporter().writeSelectionTemplate(report: sampleReport, to: directory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: templateURL.path))

        let selection = A11yFixSelection(style: .framework, issueIds: [deleteLabelIssue.id])
        let input = A11yFixBundleInput(report: sampleReport, selection: selection)
        let bundleURLs = try A11yFixExporter().writeFixBundle(input: input, format: .markdown, to: directory)
        XCTAssertEqual(bundleURLs.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: bundleURLs[0].path))
    }

    func testLoadReportRoundTrip() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        _ = try A11yReportWriter().write(report: sampleReport, kinds: [.json], to: directory)
        let reportURL = directory.appendingPathComponent("a11y-report.json")
        let loaded = try A11yFixExporter.loadReport(from: reportURL)
        XCTAssertEqual(loaded.issues.count, sampleReport.issues.count)
        XCTAssertEqual(loaded.issues.first?.id, deleteLabelIssue.id)
    }

    func testInteractiveHTMLReporterEmbedsIssuesAndScripts() throws {
        let output = InteractiveA11yHTMLReporter().renderHTML(report: sampleReport, language: .pt)
        XCTAssertTrue(output.contains("<!DOCTYPE html>"))
        XCTAssertTrue(output.contains("Seletor de correções A11y"))
        XCTAssertTrue(output.contains("Corrigir"))
        XCTAssertTrue(output.contains("delete_button"))
        XCTAssertTrue(output.contains("DeleteButton.swift:10"))
        XCTAssertTrue(output.contains("file-group"))
        XCTAssertTrue(output.contains("applyA11y"))
        XCTAssertTrue(output.contains("\"pt\""))
        XCTAssertTrue(output.contains("\"es\""))
        XCTAssertTrue(output.contains("apply-fixes"))
    }

    func testHTMLReporterKindWritesFile() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let urls = try A11yReportWriter().write(report: sampleReport, kinds: [.html], to: directory)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].lastPathComponent == "a11y-report.html")
        let html = try String(contentsOf: urls[0], encoding: .utf8)
        XCTAssertTrue(html.contains("favorite_button"))
    }
}
