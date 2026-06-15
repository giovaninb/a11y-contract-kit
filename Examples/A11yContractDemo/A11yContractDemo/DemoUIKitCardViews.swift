import A11yContractCore
import UIKit

enum DemoUIKitCardViews {
    static func makeScrollContainer(in view: UIView) -> (scrollView: UIScrollView, stack: UIStackView) {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])

        return (scrollView, stack)
    }

    static func makeIntroLabel(text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.text = text
        return label
    }

    static func makeProblemCard(example: DemoProblemExample, demoView: UIView) -> UIView {
        let card = makeCardContainer()
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

        content.addArrangedSubview(makeTitleLabel(DemoL10n.key(example.titleKey)))
        content.addArrangedSubview(makeMetaRow(title: DemoL10n.problemsComponentId, value: example.componentId))
        content.addArrangedSubview(wrapDemoView(demoView))
        content.addArrangedSubview(makeBodyLabel(DemoL10n.key(example.detailKey)))
        content.addArrangedSubview(makeSectionLabel(DemoL10n.problemsExpectedRules))

        for rule in example.rules {
            content.addArrangedSubview(makeRuleRow(rule: rule))
        }

        return card
    }

    static func makeFixCard(example: DemoFixExample, demoView: UIView) -> UIView {
        let card = makeCardContainer(borderColor: UIColor.systemGreen.withAlphaComponent(0.35))
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

        content.addArrangedSubview(makeTitleLabel(DemoL10n.key(example.titleKey)))
        content.addArrangedSubview(makeMetaRow(title: DemoL10n.problemsComponentId, value: example.componentId))
        content.addArrangedSubview(wrapDemoView(demoView))
        content.addArrangedSubview(makeSectionLabel(DemoL10n.fixedContractApplied))
        content.addArrangedSubview(makeSuccessLabel(DemoL10n.key(example.summaryKey)))

        return card
    }

    static func makeInfoCard(title: String, body: String) -> UIView {
        let card = makeCardContainer()
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 8
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        content.addArrangedSubview(makeSectionLabel(title))
        content.addArrangedSubview(makeBodyLabel(body))
        return card
    }

    static func makeCardContainer(borderColor: UIColor = .separator) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = borderColor.cgColor
        return card
    }

    private static func wrapDemoView(_ demoView: UIView) -> UIView {
        let wrapper = UIView()
        wrapper.backgroundColor = .systemBackground
        wrapper.layer.cornerRadius = 8
        demoView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(demoView)

        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),
            demoView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 12),
            demoView.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor, constant: -12),
            demoView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),
        ])

        return wrapper
    }

    private static func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = text
        return label
    }

    private static func makeBodyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.text = text
        return label
    }

    private static func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1).bold()
        label.textColor = .label
        label.text = text
        return label
    }

    private static func makeMetaRow(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.text = value

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 8
        return row
    }

    private static func makeRuleRow(rule: DemoExpectedRule) -> UIView {
        let badge = UILabel()
        badge.font = .preferredFont(forTextStyle: .caption2).bold()
        badge.text = DemoL10n.severity(rule.severity)
        badge.textColor = severityColor(rule.severity)
        badge.backgroundColor = severityColor(rule.severity).withAlphaComponent(0.15)
        badge.layer.cornerRadius = 6
        badge.clipsToBounds = true
        badge.textAlignment = .center
        badge.setContentHuggingPriority(.required, for: .horizontal)

        let ruleLabel = UILabel()
        ruleLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        ruleLabel.textColor = .secondaryLabel
        ruleLabel.text = rule.ruleId
        ruleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = .preferredFont(forTextStyle: .caption1)
        detailLabel.textColor = .label
        detailLabel.text = DemoL10n.key(rule.descriptionKey)

        let topRow = UIStackView(arrangedSubviews: [badge, ruleLabel])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [topRow, detailLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private static func makeSuccessLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemGreen
        label.text = "✓ \(text)"
        return label
    }

    private static func severityColor(_ severity: A11ySeverity) -> UIColor {
        switch severity {
        case .critical: return .systemRed
        case .major: return .systemOrange
        case .minor: return .systemYellow
        case .info: return .systemBlue
        }
    }
}

private extension UIFont {
    func bold() -> UIFont {
        UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold) ?? fontDescriptor, size: pointSize)
    }
}
