import SwiftUI
import UIKit

struct DemoRootView: View {
    var body: some View {
        TabView {
            UIKitDemoTabView()
                .tabItem {
                    Label(DemoL10n.tabUIKit, systemImage: "rectangle.stack")
                }

            CustomDemoTabView()
                .tabItem {
                    Label(DemoL10n.tabCustom, systemImage: "list.number")
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
