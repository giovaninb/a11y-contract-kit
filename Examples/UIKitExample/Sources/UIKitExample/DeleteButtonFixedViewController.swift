#if canImport(UIKit)
import A11yContractCore
import A11yContractUIKit
import UIKit

/// Referência de correção com contrato `applyA11y` aplicado.
public final class DeleteButtonFixedViewController: UIViewController {
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

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.accessibilityIdentifier = "delete_button"
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        deleteButton.applyA11y(
            A11ySpec(
                id: "delete_button",
                label: "Delete item",
                hint: "Removes this item from the list",
                role: .button,
                wcag: [.nameRoleValue, .targetSize],
                actionType: .destructive
            )
        )
    }
}
#endif
