#if canImport(UIKit)
import A11yContractCore
import A11yContractUIKit
import UIKit

/// Botão de exclusão intencionalmente problemático para gerar achados de auditoria.
public final class DeleteButtonProblemsViewController: UIViewController, A11yAuditable {
    public static let sourceFile = "Examples/UIKitExample/Sources/UIKitExample/DeleteButtonProblemsViewController.swift"
    public static var a11ySourceFile: String { sourceFile }

    public let deleteButton = UIButton(type: .system)

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        view.isAccessibilityElement = false

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        // Intencional: sem label acessível — o scanner deve reportar ios-a11y-missing-label.
        deleteButton.accessibilityLabel = nil
        deleteButton.accessibilityIdentifier = "delete_button"
        A11yContractRegistry.shared.registerSource(
            A11ySource(filePath: Self.sourceFile, line: 31),
            forComponentId: "delete_button"
        )
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
        ])

        view.accessibilityElements = [deleteButton]
    }
}
#endif
