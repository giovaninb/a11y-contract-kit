import CoreGraphics
import Foundation

public struct A11yRuleContext: Sendable {
    public let componentId: String?
    public let accessibleLabel: String?
    public let traits: Set<A11yRole>
    public let isInteractive: Bool
    public let frame: CGRect?
    public let foregroundColor: ColorComponents?
    public let backgroundColor: ColorComponents?
    public let adjustsFontForContentSizeCategory: Bool?
    public let isLargeText: Bool
    public let spec: A11ySpec?
    public let filePath: String?
    public let line: Int?
    public let declaresColorOnlyState: Bool

    public init(
        componentId: String? = nil,
        accessibleLabel: String? = nil,
        traits: Set<A11yRole> = [],
        isInteractive: Bool = false,
        frame: CGRect? = nil,
        foregroundColor: ColorComponents? = nil,
        backgroundColor: ColorComponents? = nil,
        adjustsFontForContentSizeCategory: Bool? = nil,
        isLargeText: Bool = false,
        spec: A11ySpec? = nil,
        filePath: String? = nil,
        line: Int? = nil,
        declaresColorOnlyState: Bool = false
    ) {
        self.componentId = componentId
        self.accessibleLabel = accessibleLabel
        self.traits = traits
        self.isInteractive = isInteractive
        self.frame = frame
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        self.isLargeText = isLargeText
        self.spec = spec
        self.filePath = filePath
        self.line = line
        self.declaresColorOnlyState = declaresColorOnlyState
    }

    public var effectiveRole: A11yRole? {
        if let spec { return spec.role }
        return traits.first
    }

    public var effectiveComponentId: String? {
        componentId ?? spec?.id
    }

    public var effectiveFilePath: String? {
        filePath ?? spec?.source?.filePath
    }

    public var effectiveLine: Int? {
        line ?? spec?.source?.line
    }

    /// Component metadata required to report a fixable issue.
    public var anchoredComponent: (id: String, filePath: String, line: Int?)? {
        guard let id = effectiveComponentId, !id.isEmpty else { return nil }
        guard let filePath = effectiveFilePath, !filePath.isEmpty else { return nil }
        return (id, filePath, effectiveLine)
    }
}

public protocol A11yRule: Sendable {
    var id: String { get }
    var wcagCriteria: [WCAGCriterion] { get }
    func evaluate(context: A11yRuleContext) -> [A11yIssue]
}

public extension A11yRule {
    var wcagCriteria: [WCAGCriterion] { [] }

    func isApplicable(to target: A11yConformanceTarget) -> Bool {
        guard !wcagCriteria.isEmpty else { return true }
        return wcagCriteria.allSatisfy { $0.isApplicable(to: target) }
    }
}
