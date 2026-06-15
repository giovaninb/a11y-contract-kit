import UIKit

/// Ordem de leitura incorreta: botão Continuar é anunciado antes do resumo.
final class CustomReadingOrderProblemsViewController: UIViewController {
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
        layoutScreen()
        configureWrongReadingOrder()
    }

    private func configureComponents() {
        headerLabel.text = DemoL10n.customHeaderText
        headerLabel.font = .preferredFont(forTextStyle: .headline)

        itemLabel.text = DemoL10n.customItemText
        itemLabel.font = .preferredFont(forTextStyle: .body)

        priceLabel.text = DemoL10n.customPriceText
        priceLabel.font = .preferredFont(forTextStyle: .body)
        priceLabel.textColor = .secondaryLabel

        deliveryLabel.text = DemoL10n.customDeliveryText
        deliveryLabel.font = .preferredFont(forTextStyle: .subheadline)
        deliveryLabel.textColor = .secondaryLabel

        continueButton.setTitle(DemoL10n.customContinueLabel, for: .normal)
        continueButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        continueButton.backgroundColor = .systemBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 10
        continueButton.accessibilityLabel = nil

        summaryContainer.backgroundColor = .secondarySystemBackground
        summaryContainer.layer.cornerRadius = 12
    }

    private func layoutScreen() {
        let (_, stack) = DemoUIKitCardViews.makeScrollContainer(in: view)
        stack.addArrangedSubview(DemoUIKitCardViews.makeIntroLabel(text: DemoL10n.customProblemsDetail))

        let preview = makePreviewCard()
        stack.addArrangedSubview(preview)

        stack.addArrangedSubview(
            DemoUIKitCardViews.makeInfoCard(
                title: DemoL10n.customProblemsOrderTitle,
                body: DemoL10n.customProblemsOrderWrong
            )
        )

        stack.addArrangedSubview(
            DemoUIKitCardViews.makeInfoCard(
                title: DemoL10n.customProblemsIssueTitle,
                body: DemoL10n.customProblemsIssueBody
            )
        )
    }

    private func makePreviewCard() -> UIView {
        let card = DemoUIKitCardViews.makeCardContainer()
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

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        content.addArrangedSubview(summaryContainer)
        content.addArrangedSubview(continueButton)

        return card
    }

    private func configureWrongReadingOrder() {
        view.isAccessibilityElement = false
        view.accessibilityElements = [
            continueButton,
            headerLabel,
            itemLabel,
            priceLabel,
            deliveryLabel,
        ]
    }
}
