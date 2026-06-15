import A11yContractCore
import A11yContractReporter
import A11yContractUIKit
import SwiftUI

struct AuditTabView: View {
    @State private var report: A11yReport?
    @State private var isRunning = false

    var body: some View {
        NavigationView {
            Group {
                if let report {
                    List {
                        introSection
                        summarySection(report.summary)
                        findingsSection(report.issues)
                    }
                } else {
                    List {
                        introSection
                        Section {
                            Text(DemoL10n.auditEmpty)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(DemoL10n.screenAudit)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var introSection: some View {
        Section {
            Text(DemoL10n.auditHeadline)
                .font(.headline)

            Text(DemoL10n.auditDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button(isRunning ? DemoL10n.auditRunning : DemoL10n.auditRun) {
                runAudit()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)
        }
    }

    private func summarySection(_ summary: A11ySummary) -> some View {
        Section {
            SummaryView(summary: summary)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private func findingsSection(_ issues: [A11yIssue]) -> some View {
        Section {
            Text(DemoL10n.auditTapHint)
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text(DemoL10n.auditFindings)
        }

        Section {
            ForEach(issues) { issue in
                NavigationLink {
                    AuditIssueDetailView(issue: issue)
                } label: {
                    AuditIssueRow(issue: issue)
                }
            }
        }
    }

    private func runAudit() {
        isRunning = true
        A11yContractRegistry.shared.clear()

        let viewController = UIKitProblemsViewController()
        viewController.loadViewIfNeeded()

        let issues = UIKitA11yScanner().scan(rootView: viewController.view)
        report = A11yReport(projectName: "A11yContractDemo", issues: issues)
        isRunning = false
    }
}

private struct AuditIssueRow: View {
    let issue: A11yIssue

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DemoL10n.severity(issue.severity))
                .font(.caption.bold())
                .foregroundStyle(color(for: issue.severity))

            Text(DemoIssuePresentation.localizedMessage(for: issue))
                .font(.subheadline)

            Text(issue.ruleId)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func color(for severity: A11ySeverity) -> Color {
        switch severity {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        case .info: return .blue
        }
    }
}

private struct SummaryView: View {
    let summary: A11ySummary

    var body: some View {
        HStack(spacing: 12) {
            SummaryBadge(severity: .critical, count: summary.critical)
            SummaryBadge(severity: .major, count: summary.major)
            SummaryBadge(severity: .minor, count: summary.minor)
            SummaryBadge(severity: .info, count: summary.info)
        }
    }
}

private struct SummaryBadge: View {
    let severity: A11ySeverity
    let count: Int

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title3.bold())
            Text(DemoL10n.severity(severity))
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var color: Color {
        switch severity {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        case .info: return .blue
        }
    }
}
