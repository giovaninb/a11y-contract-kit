#if canImport(UIKit)
import UIKit
import XCTest
import A11yContractCore
import A11yContractUIKit
import A11yContractReporter

final class UIKitA11yScannerTests: XCTestCase {
    func testButtonWithoutLabelProducesCriticalIssue() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.accessibilityLabel = nil

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        container.addSubview(button)

        let issues = UIKitA11yScanner().scan(rootView: container)
        XCTAssertTrue(issues.contains { $0.ruleId == "ios-a11y-missing-label" && $0.severity == .critical })
    }

    func testApplyA11ySetsAccessibilityProperties() {
        let button = UIButton(type: .system)
        let spec = A11ySpec(
            id: "delete_button",
            label: "Excluir item",
            hint: "Remove este item da lista",
            role: .button
        )

        button.applyA11y(spec)

        XCTAssertEqual(button.accessibilityIdentifier, "delete_button")
        XCTAssertEqual(button.accessibilityLabel, "Excluir item")
        XCTAssertEqual(button.accessibilityHint, "Remove este item da lista")
        XCTAssertTrue(button.accessibilityTraits.contains(.button))
    }
}
#else
import XCTest

final class UIKitA11yScannerTests: XCTestCase {
    func testUIKitRequiresIOSPlatform() throws {
        throw XCTSkip("UIKit accessibility tests require iOS platform.")
    }
}
#endif
