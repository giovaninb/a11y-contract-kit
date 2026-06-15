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
        title = "Problemas"
        layoutComponents()
    }

    private func layoutComponents() {
        deleteButton.frame = CGRect(x: 24, y: 120, width: 28, height: 28)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.accessibilityLabel = nil
        view.addSubview(deleteButton)

        favoriteButton.frame = CGRect(x: 80, y: 120, width: 28, height: 28)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemPink
        favoriteButton.accessibilityLabel = nil
        view.addSubview(favoriteButton)

        lowContrastLabel.frame = CGRect(x: 24, y: 200, width: view.bounds.width - 48, height: 44)
        lowContrastLabel.autoresizingMask = [.flexibleWidth]
        lowContrastLabel.text = "Texto com contraste insuficiente"
        lowContrastLabel.textColor = UIColor(white: 0.78, alpha: 1)
        lowContrastLabel.backgroundColor = .white
        lowContrastLabel.font = .systemFont(ofSize: 16)
        view.addSubview(lowContrastLabel)

        fixedFontLabel.frame = CGRect(x: 24, y: 260, width: view.bounds.width - 48, height: 44)
        fixedFontLabel.autoresizingMask = [.flexibleWidth]
        fixedFontLabel.text = "Fonte fixa sem Dynamic Type"
        fixedFontLabel.font = .systemFont(ofSize: 14)
        fixedFontLabel.adjustsFontForContentSizeCategory = false
        view.addSubview(fixedFontLabel)

        let caption = UILabel(frame: CGRect(x: 24, y: 320, width: view.bounds.width - 48, height: 80))
        caption.autoresizingMask = [.flexibleWidth]
        caption.numberOfLines = 0
        caption.font = .preferredFont(forTextStyle: .footnote)
        caption.textColor = .secondaryLabel
        caption.text = """
        Esta tela contém problemas propositais:
        • botões sem label acessível
        • touch targets abaixo de 44pt
        • contraste baixo e fonte fixa
        """
        view.addSubview(caption)
    }
}
