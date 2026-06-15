import Foundation

public struct A11yIssue: Codable, Sendable, Hashable, Identifiable {
    public let id: String
    public let ruleId: String
    public let severity: A11ySeverity
    public let message: String
    public let componentId: String?
    public let filePath: String?
    public let line: Int?
    public let wcag: [WCAGCriterion]
    public let suggestedFix: String?
    public let suggestedOwner: A11yOwner?

    public init(
        id: String = UUID().uuidString,
        ruleId: String,
        severity: A11ySeverity,
        message: String,
        componentId: String? = nil,
        filePath: String? = nil,
        line: Int? = nil,
        wcag: [WCAGCriterion] = [],
        suggestedFix: String? = nil,
        suggestedOwner: A11yOwner? = nil
    ) {
        self.id = id
        self.ruleId = ruleId
        self.severity = severity
        self.message = message
        self.componentId = componentId
        self.filePath = filePath
        self.line = line
        self.wcag = wcag
        self.suggestedFix = suggestedFix
        self.suggestedOwner = suggestedOwner
    }
}
