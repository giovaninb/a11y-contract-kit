import Foundation

public struct A11ySpec: Codable, Sendable, Hashable {
    public let id: String
    public let label: String?
    public let hint: String?
    public let value: String?
    public let role: A11yRole
    public let state: A11yState?
    public let wcag: [WCAGCriterion]
    public let owner: A11yOwner?
    public let source: A11ySource?
    public let actionType: A11yActionType?

    public init(
        id: String,
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        role: A11yRole,
        state: A11yState? = nil,
        wcag: [WCAGCriterion] = [],
        owner: A11yOwner? = nil,
        source: A11ySource? = nil,
        actionType: A11yActionType? = nil
    ) {
        self.id = id
        self.label = label
        self.hint = hint
        self.value = value
        self.role = role
        self.state = state
        self.wcag = wcag
        self.owner = owner
        self.source = source
        self.actionType = actionType
    }
}
