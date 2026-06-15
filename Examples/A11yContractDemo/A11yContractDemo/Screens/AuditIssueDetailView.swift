import A11yContractCore
import SwiftUI

struct AuditIssueDetailView: View {
    let issue: A11yIssue

    var body: some View {
        List {
            Section {
                DetailRow(
                    title: DemoL10n.auditDetailMessage,
                    value: DemoIssuePresentation.localizedMessage(for: issue)
                )

                HStack {
                    Text(DemoL10n.auditDetailRule)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(issue.ruleId)
                        .font(.footnote.monospaced())
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                DetailRow(
                    title: DemoL10n.auditDetailComponent,
                    value: issue.componentId ?? DemoL10n.auditDetailNotAvailable
                )

                HStack {
                    Text(DemoL10n.severity(issue.severity))
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(severityColor(for: issue.severity).opacity(0.15))
                        .foregroundStyle(severityColor(for: issue.severity))
                        .clipShape(Capsule())
                    Spacer()
                }
            }

            if !issue.wcag.isEmpty {
                Section(DemoL10n.auditDetailWCAG) {
                    ForEach(issue.wcag, id: \.rawValue) { criterion in
                        Text(criterion.formatted)
                            .font(.subheadline)
                    }
                }
            }

            if let suggestedFix = DemoIssuePresentation.localizedSuggestedFix(for: issue) {
                Section(DemoL10n.auditDetailSuggestedFix) {
                    Text(suggestedFix)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
            }

            if issue.suggestedOwner != nil || issue.filePath != nil {
                Section {
                    if let owner = issue.suggestedOwner {
                        DetailRow(title: DemoL10n.auditDetailOwner, value: DemoL10n.owner(owner))
                    }

                    if let filePath = issue.filePath {
                        DetailRow(title: DemoL10n.auditDetailLocation, value: locationText(filePath: filePath, line: issue.line))
                    }
                }
            }
        }
        .navigationTitle(DemoL10n.auditDetailTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func locationText(filePath: String, line: Int?) -> String {
        guard let line else { return filePath }
        return "\(filePath):\(line)"
    }

    private func severityColor(for severity: A11ySeverity) -> Color {
        switch severity {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        case .info: return .blue
        }
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}
