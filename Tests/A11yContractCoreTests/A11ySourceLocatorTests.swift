import XCTest
import A11yContractCore

final class A11ySourceLocatorTests: XCTestCase {
    override func tearDown() {
        A11yContractRegistry.shared.clear()
        super.tearDown()
    }

    func testResolveUsesRegistrySource() {
        A11yContractRegistry.shared.registerSource(
            A11ySource(
                filePath: "Sources/Demo/Button.swift",
                line: 12
            ),
            forComponentId: "delete_button"
        )

        let source = A11ySourceLocator.resolve(componentId: "delete_button")
        XCTAssertEqual(source?.filePath, "Sources/Demo/Button.swift")
        XCTAssertEqual(source?.line, 12)
    }

    func testResolveFindsLineInFallbackFile() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let relativePath = "Sources/Demo/DeleteButton.swift"
        let fileURL = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try """
        final class Demo {
            let deleteButton = UIButton()
            func setup() {
                deleteButton.accessibilityIdentifier = "delete_button"
            }
        }
        """.write(to: fileURL, atomically: true, encoding: .utf8)

        let source = A11ySourceLocator.resolve(
            componentId: "delete_button",
            fallbackFile: relativePath,
            projectRoots: [root.path]
        )

        XCTAssertEqual(source?.filePath, relativePath)
        XCTAssertEqual(source?.line, 4)
    }
}
