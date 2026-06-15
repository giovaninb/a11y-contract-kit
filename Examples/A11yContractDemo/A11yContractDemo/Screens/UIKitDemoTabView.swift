import SwiftUI
import UIKit

struct UIKitDemoTabView: View {
    @State private var mode: DemoMode = .problems

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DemoModeHeader(
                    intro: DemoL10n.uikitIntro,
                    hint: DemoL10n.uikitHint,
                    mode: $mode
                )

                ViewControllerHost(identity: mode.rawValue) {
                    mode == .problems
                        ? UIKitProblemsViewController()
                        : UIKitFixedViewController()
                }
            }
            .navigationTitle(mode == .problems ? DemoL10n.uikitScreenProblems : DemoL10n.uikitScreenFixed)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
