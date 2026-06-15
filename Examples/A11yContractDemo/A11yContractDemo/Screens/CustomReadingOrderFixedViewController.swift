import A11yContractCore
import A11yContractUIKit
import UIKit

/// Contratos explícitos + ordem de leitura definida com accessibilityElements.
final class CustomReadingOrderFixedViewController: UIViewController {
    let summaryContainer = UIView()
    let headerLabel = UILabel()
    let itemLabel = UILabel()
    let priceLabel = UILabel()
    let deliveryLabel = UILabel()
    let continueButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureComponents()
        applyContracts()
        layoutScreen()
        configureReadingOrder()
    }

    private func configureComponents() {
        headerLabel.text = DemoL10n.customHeaderText
        headerLabel.font = .preferredFont(forTextStyle: .headline)
        headerLabel.accessibilityIdentifier = "order_summary_header"

        itemLabel.text = DemoL10n.customItemText
        itemLabel.font = .preferredFont(forTextStyle: .body)
        itemLabel.accessibilityIdentifier = "order_item_name"

        priceLabel.text = DemoL10n.customPriceText
        priceLabel.font = .preferredFont(forTextStyle: .body)
        priceLabel.textColor = .secondaryLabel
        priceLabel.accessibilityIdentifier = "order_item_price"

        deliveryLabel.text = DemoL10n.customDeliveryText
        deliveryLabel.font = .preferredFont(forTextStyle: .subheadline)
        deliveryLabel.textColor = .secondaryLabel
        deliveryLabel.accessibilityIdentifier = "order_delivery_eta"

        continueButton.setTitle(DemoL10n.customContinueLabel, for: .normal)
        continueButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        continueButton.backgroundColor = .systemBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 10
        continueButton.accessibilityIdentifier = "continue_button"

        summaryContainer.backgroundColor = .secondarySystemBackground
        summaryContainer.layer.cornerRadius = 12

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func applyContracts() {
        headerLabel.applyA11y(
            A11ySpec(
                id: "order_summary_header",
                label: DemoL10n.customHeaderText,
                role: .header,
                wcag: [.infoAndRelationships]
            )
        )

        itemLabel.applyA11y(
            A11ySpec(
                id: "order_item_name",
                label: DemoL10n.customItemText,
                role: .text
            )
        )

        priceLabel.applyA11y(
            A11ySpec(
                id: "order_item_price",
                label: DemoL10n.customPriceText,
                role: .text
            )
        )

        deliveryLabel.applyA11y(
            A11ySpec(
                id: "order_delivery_eta",
                label: DemoL10n.customDeliveryText,
                role: .text
            )
        )

        continueButton.applyA11y(
            A11ySpec(
                id: "continue_button",
                label: DemoL10n.customContinueLabel,
                hint: DemoL10n.customContinueHint,
                role: .button,
                wcag: [.nameRoleValue, .targetSize]
            )
        )
    }

    private func layoutScreen() {
        let (_, stack) = DemoUIKitCardViews.makeScrollContainer(in: view)
        stack.addArrangedSubview(DemoUIKitCardViews.makeIntroLabel(text: DemoL10n.customFixedDetail))

        stack.addArrangedSubview(makePreviewCard())

        stack.addArrangedSubview(
            DemoUIKitCardViews.makeInfoCard(
                title: DemoL10n.customFixedOrderTitle,
                body: DemoL10n.customFixedOrderBody
            )
        )

        stack.addArrangedSubview(makeReadingOrderCard())
    }

    private func makePreviewCard() -> UIView {
        let card = DemoUIKitCardViews.makeCardContainer(borderColor: UIColor.systemGreen.withAlphaComponent(0.35))
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        let summaryStack = UIStackView(arrangedSubviews: [headerLabel, itemLabel, priceLabel, deliveryLabel])
        summaryStack.axis = .vertical
        summaryStack.spacing = 6
        summaryStack.isLayoutMarginsRelativeArrangement = true
        summaryStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        summaryContainer.addSubview(summaryStack)
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: summaryContainer.topAnchor),
            summaryStack.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor),
            summaryStack.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor),
            summaryStack.bottomAnchor.constraint(equalTo: summaryContainer.bottomAnchor),
        ])

        content.addArrangedSubview(summaryContainer)
        content.addArrangedSubview(continueButton)

        return card
    }

    private func makeReadingOrderCard() -> UIView {
        let steps = [
            DemoL10n.customOrderStep(index: 1, text: DemoL10n.customHeaderText),
            DemoL10n.customOrderStep(index: 2, text: DemoL10n.customItemText),
            DemoL10n.customOrderStep(index: 3, text: DemoL10n.customPriceText),
            DemoL10n.customOrderStep(index: 4, text: DemoL10n.customDeliveryText),
            DemoL10n.customOrderStep(index: 5, text: DemoL10n.customContinueLabel),
        ]

        return DemoUIKitCardViews.makeInfoCard(
            title: DemoL10n.customFixedStepsTitle,
            body: steps.joined(separator: "\n")
        )
    }

    private func configureReadingOrder() {
        view.isAccessibilityElement = false
        view.accessibilityElements = [
            headerLabel,
            itemLabel,
            priceLabel,
            deliveryLabel,
            continueButton,
        ]
    }
}
