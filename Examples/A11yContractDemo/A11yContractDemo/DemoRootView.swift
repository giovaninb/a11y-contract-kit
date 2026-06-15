import SwiftUI
import UIKit

struct DemoRootView: View {
    var body: some View {
        TabView {
            DemoScreenTab(
                title: "UIKit — Problemas",
                systemImage: "exclamationmark.triangle",
                viewController: UIKitProblemsViewController()
            )
            .tabItem {
                Label("Problemas", systemImage: "exclamationmark.triangle")
            }

            DemoScreenTab(
                title: "UIKit — Corrigido",
                systemImage: "checkmark.circle",
                viewController: UIKitFixedViewController()
            )
            .tabItem {
                Label("Corrigido", systemImage: "checkmark.circle")
            }

            SwiftUIDemoView()
                .tabItem {
                    Label("SwiftUI", systemImage: "swift")
                }

            AuditTabView()
                .tabItem {
                    Label("Auditoria", systemImage: "doc.text.magnifyingglass")
                }
        }
    }
}

private struct DemoScreenTab: View {
    let title: String
    let systemImage: String
    let viewController: UIViewController

    var body: some View {
        NavigationView {
            ViewControllerHost(viewController: viewController)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
