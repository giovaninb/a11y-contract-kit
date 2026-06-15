import UIKit

/// Tela intencionalmente problemática para demonstrar issues de acessibilidade.
final class UIKitProblemsViewController: UIViewController {
    let deleteButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    let lowContrastLabel = UILabel()
    let fixedFontLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = DemoL10n.tabProblems
        configureComponents()
        layoutScreen()
    }

    private func configureComponents() {
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.accessibilityLabel = nil
        deleteButton.accessibilityIdentifier = "delete_button"
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
        ])

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemPink
        favoriteButton.accessibilityLabel = nil
        favoriteButton.accessibilityIdentifier = "favorite_button"
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),
        ])

        lowContrastLabel.text = DemoL10n.problemsLowContrastText
        lowContrastLabel.accessibilityIdentifier = "low_contrast_label"
        lowContrastLabel.textColor = UIColor(white: 0.78, alpha: 1)
        lowContrastLabel.backgroundColor = .white
        lowContrastLabel.font = .systemFont(ofSize: 16)
        lowContrastLabel.numberOfLines = 0

        fixedFontLabel.text = DemoL10n.problemsFixedFontText
        fixedFontLabel.accessibilityIdentifier = "fixed_font_label"
        fixedFontLabel.font = .systemFont(ofSize: 14)
        fixedFontLabel.adjustsFontForContentSizeCategory = false
        fixedFontLabel.numberOfLines = 0
    }

    private func layoutScreen() {
        let (_, stack) = DemoUIKitCardViews.makeScrollContainer(in: view)
        stack.addArrangedSubview(DemoUIKitCardViews.makeIntroLabel(text: DemoL10n.problemsIntro))

        let demoViews: [UIView] = [deleteButton, favoriteButton, lowContrastLabel, fixedFontLabel]
        for (example, demoView) in zip(DemoComponentCatalog.problemExamples, demoViews) {
            stack.addArrangedSubview(DemoUIKitCardViews.makeProblemCard(example: example, demoView: demoView))
        }

        stack.addArrangedSubview(DemoUIKitCardViews.makeIntroLabel(text: DemoL10n.problemsCaption))
    }
}
