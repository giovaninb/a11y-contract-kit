import SwiftUI

struct DemoModeHeader: View {
    let intro: String
    let hint: String
    @Binding var mode: DemoMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(intro)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(hint)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Picker("", selection: $mode) {
                Text(DemoL10n.modeProblems).tag(DemoMode.problems)
                Text(DemoL10n.modeFixed).tag(DemoMode.fixed)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
}

enum DemoMode: String, CaseIterable, Identifiable {
    case problems
    case fixed

    var id: String { rawValue }
}
