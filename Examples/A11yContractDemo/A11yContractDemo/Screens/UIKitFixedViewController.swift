import A11yContractCore
import A11yContractUIKit
import UIKit

/// Mesmos componentes com contratos de acessibilidade aplicados.
final class UIKitFixedViewController: UIViewController {
    let deleteButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Corrigido"
        layoutComponents()
        applyContracts()
    }

    private func layoutComponents() {
        deleteButton.frame = CGRect(x: 24, y: 120, width: 44, height: 44)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        view.addSubview(deleteButton)

        favoriteButton.frame = CGRect(x: 88, y: 120, width: 44, height: 44)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemPink
        view.addSubview(favoriteButton)

        statusLabel.frame = CGRect(x: 24, y: 200, width: view.bounds.width - 48, height: 44)
        statusLabel.autoresizingMask = [.flexibleWidth]
        statusLabel.text = "Status: Ativo"
        statusLabel.textColor = .label
        statusLabel.backgroundColor = .secondarySystemBackground
        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(statusLabel)

        let caption = UILabel(frame: CGRect(x: 24, y: 260, width: view.bounds.width - 48, height: 80))
        caption.autoresizingMask = [.flexibleWidth]
        caption.numberOfLines = 0
        caption.font = .preferredFont(forTextStyle: .footnote)
        caption.textColor = .secondaryLabel
        caption.text = """
        Contratos aplicados com applyA11y:
        labels, hints, roles e touch target adequado.
        """
        view.addSubview(caption)
    }

    private func applyContracts() {
        deleteButton.applyA11y(
            A11ySpec(
                id: "delete_button",
                label: "Excluir item",
                hint: "Remove este item permanentemente",
                role: .button,
                wcag: [.nameRoleValue, .targetSize],
                actionType: .destructive
            )
        )

        favoriteButton.applyA11y(
            A11ySpec(
                id: "favorite_button",
                label: "Favoritar",
                hint: "Adiciona este item aos favoritos",
                role: .button,
                wcag: [.nameRoleValue, .targetSize]
            )
        )

        statusLabel.applyA11y(
            A11ySpec(
                id: "status_label",
                label: "Status",
                value: "Ativo",
                role: .text,
                wcag: [.useOfColor]
            )
        )
    }
}
