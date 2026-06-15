import SwiftUI
import UIKit

struct ViewControllerHost: UIViewControllerRepresentable {
    let identity: String
    let builder: () -> UIViewController

    init(identity: String, builder: @escaping () -> UIViewController) {
        self.identity = identity
        self.builder = builder
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> HostingContainerViewController {
        let container = HostingContainerViewController()
        context.coordinator.setHostedViewController(in: container, identity: identity, builder: builder)
        return container
    }

    func updateUIViewController(_ container: HostingContainerViewController, context: Context) {
        context.coordinator.setHostedViewController(in: container, identity: identity, builder: builder)
    }

    final class Coordinator {
        private var currentIdentity: String?

        func setHostedViewController(
            in container: HostingContainerViewController,
            identity: String,
            builder: () -> UIViewController
        ) {
            guard currentIdentity != identity else { return }
            currentIdentity = identity
            container.setHosted(builder())
        }
    }
}

final class HostingContainerViewController: UIViewController {
    private var hosted: UIViewController?

    func setHosted(_ viewController: UIViewController) {
        if let hosted {
            hosted.willMove(toParent: nil)
            hosted.view.removeFromSuperview()
            hosted.removeFromParent()
        }

        hosted = viewController
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        viewController.didMove(toParent: self)
    }
}
