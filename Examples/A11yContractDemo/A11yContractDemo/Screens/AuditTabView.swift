import A11yContractCore
import A11yContractReporter
import A11yContractUIKit
import SwiftUI

struct AuditTabView: View {
    @State private var report: A11yReport?
    @State private var markdown: String = ""
    @State private var isRunning = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Auditoria em tempo real")
                    .font(.headline)

                Text("Executa o scanner UIKit na tela com problemas e exibe o relatório.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(isRunning ? "Auditando…" : "Rodar auditoria") {
                    runAudit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunning)

                if let report {
                    SummaryView(summary: report.summary)

                    List(report.issues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.severity.displayName)
                                .font(.caption.bold())
                                .foregroundStyle(color(for: issue.severity))
                            Text(issue.message)
                                .font(.subheadline)
                            Text(issue.ruleId)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Spacer()
                    Text("Nenhuma auditoria executada ainda.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Auditoria")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func runAudit() {
        isRunning = true
        A11yContractRegistry.shared.clear()

        let viewController = UIKitProblemsViewController()
        viewController.loadViewIfNeeded()

        let issues = UIKitA11yScanner().scan(rootView: viewController.view)
        let result = A11yReport(projectName: "A11yContractDemo", issues: issues)
        report = result

        if let markdown = try? MarkdownA11yReporter().generate(report: result) {
            self.markdown = markdown
        }

        isRunning = false
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
            SummaryBadge(title: "Critical", count: summary.critical, color: .red)
            SummaryBadge(title: "Major", count: summary.major, color: .orange)
            SummaryBadge(title: "Minor", count: summary.minor, color: .yellow)
            SummaryBadge(title: "Info", count: summary.info, color: .blue)
        }
    }
}

private struct SummaryBadge: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title3.bold())
            Text(title)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
