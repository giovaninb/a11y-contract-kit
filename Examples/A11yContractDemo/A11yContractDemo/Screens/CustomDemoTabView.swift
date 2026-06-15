import SwiftUI
import UIKit

struct CustomDemoTabView: View {
    @State private var mode: DemoMode = .problems

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DemoModeHeader(
                    intro: DemoL10n.customIntro,
                    hint: DemoL10n.customHint,
                    mode: $mode
                )

                ViewControllerHost(
                    viewController: mode == .problems
                        ? CustomReadingOrderProblemsViewController()
                        : CustomReadingOrderFixedViewController()
                )
            }
            .navigationTitle(mode == .problems ? DemoL10n.customScreenProblems : DemoL10n.customScreenFixed)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
