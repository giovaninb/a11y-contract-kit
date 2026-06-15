import Foundation

public struct A11ySummary: Codable, Sendable, Hashable {
    public let totalIssues: Int
    public let critical: Int
    public let major: Int
    public let minor: Int
    public let info: Int

    public init(issues: [A11yIssue]) {
        totalIssues = issues.count
        critical = issues.filter { $0.severity == .critical }.count
        major = issues.filter { $0.severity == .major }.count
        minor = issues.filter { $0.severity == .minor }.count
        info = issues.filter { $0.severity == .info }.count
    }

    public init(
        totalIssues: Int,
        critical: Int,
        major: Int,
        minor: Int,
        info: Int
    ) {
        self.totalIssues = totalIssues
        self.critical = critical
        self.major = major
        self.minor = minor
        self.info = info
    }
}

public struct A11yReport: Codable, Sendable {
    public let projectName: String
    public let generatedAt: Date
    public let issues: [A11yIssue]
    public let summary: A11ySummary
    public let conformanceTarget: A11yConformanceTarget?

    public init(
        projectName: String,
        generatedAt: Date = Date(),
        issues: [A11yIssue],
        conformanceTarget: A11yConformanceTarget? = nil
    ) {
        self.projectName = projectName
        self.generatedAt = generatedAt
        self.issues = issues
        self.summary = A11ySummary(issues: issues)
        self.conformanceTarget = conformanceTarget
    }
}
