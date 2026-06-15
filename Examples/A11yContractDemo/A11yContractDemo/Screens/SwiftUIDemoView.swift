import A11yContractCore
import A11yContractSwiftUI
import SwiftUI

struct SwiftUIDemoView: View {
    @State private var mode: DemoMode = .problems

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DemoModeHeader(
                        intro: DemoL10n.swiftUIIntro,
                        hint: DemoL10n.swiftUILinkHint,
                        mode: $mode
                    )

                    if mode == .problems {
                        SwiftUIProblemsPanel()
                    } else {
                        SwiftUIFixedPanel()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(mode == .problems ? DemoL10n.swiftUIScreenProblems : DemoL10n.swiftUIScreenFixed)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SwiftUIProblemsPanel: View {
    var body: some View {
        VStack(spacing: 16) {
            DemoSwiftUIProblemCard(example: DemoComponentCatalog.problemExamples[0]) {
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.body)
                }
                .frame(width: 28, height: 28)
                .foregroundStyle(.red)
            }

            DemoSwiftUIProblemCard(example: DemoComponentCatalog.problemExamples[1]) {
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.body)
                }
                .frame(width: 28, height: 28)
                .foregroundStyle(.pink)
            }

            DemoSwiftUIProblemCard(example: DemoComponentCatalog.problemExamples[2]) {
                Text(DemoL10n.problemsLowContrastText)
                    .foregroundStyle(Color(white: 0.78))
                    .background(Color.white)
            }

            DemoSwiftUIProblemCard(example: DemoComponentCatalog.problemExamples[3]) {
                Text(DemoL10n.problemsFixedFontText)
                    .font(.system(size: 14))
            }
        }
    }
}

private struct SwiftUIFixedPanel: View {
    var body: some View {
        VStack(spacing: 16) {
            DemoSwiftUIFixCard(example: DemoComponentCatalog.fixExamples[0]) {
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.title3)
                }
                .frame(width: 44, height: 44)
                .foregroundStyle(.red)
                .a11yContract(
                    A11ySpec(
                        id: "delete_button",
                        label: DemoL10n.deleteLabel,
                        hint: DemoL10n.deleteHint,
                        role: .button,
                        wcag: [.nameRoleValue, .targetSize],
                        actionType: .destructive
                    )
                )
            }

            DemoSwiftUIFixCard(example: DemoComponentCatalog.fixExamples[1]) {
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.title3)
                }
                .frame(width: 44, height: 44)
                .foregroundStyle(.pink)
                .a11yContract(
                    A11ySpec(
                        id: "favorite_button",
                        label: DemoL10n.favoriteLabel,
                        hint: DemoL10n.favoriteHint,
                        role: .button,
                        wcag: [.nameRoleValue, .targetSize]
                    )
                )
            }

            DemoSwiftUIFixCard(example: DemoComponentCatalog.fixExamples[2]) {
                Text(DemoL10n.fixedStatus)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .a11yContract(
                        A11ySpec(
                            id: "status_label",
                            label: DemoL10n.statusLabel,
                            value: DemoL10n.statusValue,
                            role: .text,
                            wcag: [.useOfColor]
                        )
                    )
            }

            Text(DemoL10n.swiftUICaption)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DemoSwiftUIProblemCard<Content: View>: View {
    let example: DemoProblemExample
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(DemoL10n.key(example.titleKey))
                .font(.headline)

            HStack(spacing: 8) {
                Text(DemoL10n.problemsComponentId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(example.componentId)
                    .font(.caption.monospaced())
            }

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(DemoL10n.key(example.detailKey))
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(DemoL10n.problemsExpectedRules)
                .font(.caption.bold())

            ForEach(example.rules) { rule in
                DemoSwiftUIRuleRow(rule: rule)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

private struct DemoSwiftUIFixCard<Content: View>: View {
    let example: DemoFixExample
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(DemoL10n.key(example.titleKey))
                .font(.headline)

            HStack(spacing: 8) {
                Text(DemoL10n.problemsComponentId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(example.componentId)
                    .font(.caption.monospaced())
            }

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(DemoL10n.fixedContractApplied)
                .font(.caption.bold())

            Text("✓ \(DemoL10n.key(example.summaryKey))")
                .font(.footnote)
                .foregroundStyle(.green)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct DemoSwiftUIRuleRow: View {
    let rule: DemoExpectedRule

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(DemoL10n.severity(rule.severity))
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor.opacity(0.15))
                    .foregroundStyle(severityColor)
                    .clipShape(Capsule())

                Text(rule.ruleId)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            Text(DemoL10n.key(rule.descriptionKey))
                .font(.caption)
        }
    }

    private var severityColor: Color {
        switch rule.severity {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        case .info: return .blue
        }
    }
}
