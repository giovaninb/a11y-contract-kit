import SwiftUI
import UIKit

struct DemoRootView: View {
    var body: some View {
        TabView {
            DemoScreenTab(
                title: DemoL10n.screenProblems,
                viewController: UIKitProblemsViewController()
            )
            .tabItem {
                Label(DemoL10n.tabProblems, systemImage: "exclamationmark.triangle")
            }

            DemoScreenTab(
                title: DemoL10n.screenFixed,
                viewController: UIKitFixedViewController()
            )
            .tabItem {
                Label(DemoL10n.tabFixed, systemImage: "checkmark.circle")
            }

            SwiftUIDemoView()
                .tabItem {
                    Label(DemoL10n.tabSwiftUI, systemImage: "swift")
                }

            AuditTabView()
                .tabItem {
                    Label(DemoL10n.tabAudit, systemImage: "doc.text.magnifyingglass")
                }
        }
    }
}

private struct DemoScreenTab: View {
    let title: String
    let viewController: UIViewController

    var body: some View {
        NavigationView {
            ViewControllerHost(viewController: viewController)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
