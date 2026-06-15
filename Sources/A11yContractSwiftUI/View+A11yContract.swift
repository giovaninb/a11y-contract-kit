#if canImport(SwiftUI)
import SwiftUI
import A11yContractCore

public extension View {
    func a11yContract(_ spec: A11ySpec) -> some View {
        modifier(A11yContractModifier(spec: spec))
    }
}

private struct A11yContractModifier: ViewModifier {
    let spec: A11ySpec

    func body(content: Content) -> some View {
        content
            .accessibilityIdentifier(spec.id)
            .accessibilityLabel(spec.label ?? "")
            .accessibilityHint(spec.hint ?? "")
            .accessibilityValue(spec.value ?? "")
            .accessibilityAddTraits(spec.role.toSwiftUITraits())
            .onAppear {
                A11yContractRegistry.shared.register(spec)
            }
    }
}

extension A11yRole {
    func toSwiftUITraits() -> AccessibilityTraits {
        switch self {
        case .button: return .isButton
        case .link: return .isLink
        case .image: return .isImage
        case .header: return .isHeader
        case .input: return .isSearchField
        case .tab: return .isSelected
        case .text, .adjustable, .custom: return []
        }
    }
}

public enum SwiftUIA11yAudit {
    public static func run(projectName: String = "SwiftUIA11yAudit") -> A11yReport {
        let engine = A11yRuleEngine()
        let issues = A11yContractRegistry.shared.allSpecs().flatMap { spec -> [A11yIssue] in
            let context = A11yRuleContext(
                componentId: spec.id,
                accessibleLabel: spec.label,
                traits: [spec.role],
                isInteractive: spec.role.isInteractive,
                spec: spec,
                filePath: spec.source?.filePath,
                line: spec.source?.line,
                declaresColorOnlyState: spec.value != nil
            )
            return engine.evaluate(context: context)
        }

        return A11yReport(projectName: projectName, issues: issues)
    }
}

#endif
