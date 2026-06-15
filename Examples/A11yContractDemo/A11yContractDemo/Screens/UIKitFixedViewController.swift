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
        title = DemoL10n.tabFixed
        configureComponents()
        applyContracts()
        layoutScreen()
    }

    private func configureComponents() {
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.accessibilityIdentifier = "delete_button"
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemPink
        favoriteButton.accessibilityIdentifier = "favorite_button"
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        statusLabel.text = DemoL10n.fixedStatus
        statusLabel.accessibilityIdentifier = "status_label"
        statusLabel.textColor = .label
        statusLabel.backgroundColor = .secondarySystemBackground
        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.numberOfLines = 0
    }

    private func layoutScreen() {
        let (_, stack) = DemoUIKitCardViews.makeScrollContainer(in: view)
        stack.addArrangedSubview(DemoUIKitCardViews.makeIntroLabel(text: DemoL10n.fixedIntro))

        let examples = DemoComponentCatalog.fixExamples

        stack.addArrangedSubview(DemoUIKitCardViews.makeFixCard(example: examples[0], demoView: deleteButton))
        stack.addArrangedSubview(DemoUIKitCardViews.makeFixCard(example: examples[1], demoView: favoriteButton))
        stack.addArrangedSubview(DemoUIKitCardViews.makeFixCard(example: examples[2], demoView: statusLabel))

        stack.addArrangedSubview(DemoUIKitCardViews.makeIntroLabel(text: DemoL10n.fixedCaption))
    }

    private func applyContracts() {
        deleteButton.applyA11y(
            A11ySpec(
                id: "delete_button",
                label: DemoL10n.deleteLabel,
                hint: DemoL10n.deleteHint,
                role: .button,
                wcag: [.nameRoleValue, .targetSize],
                actionType: .destructive
            )
        )

        favoriteButton.applyA11y(
            A11ySpec(
                id: "favorite_button",
                label: DemoL10n.favoriteLabel,
                hint: DemoL10n.favoriteHint,
                role: .button,
                wcag: [.nameRoleValue, .targetSize]
            )
        )

        statusLabel.applyA11y(
            A11ySpec(
                id: "status_label",
                label: DemoL10n.statusLabel,
                value: DemoL10n.statusValue,
                role: .text,
                wcag: [.useOfColor]
            )
        )
    }
}
