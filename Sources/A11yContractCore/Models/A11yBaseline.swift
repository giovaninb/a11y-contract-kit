import Foundation
import CryptoKit

public struct A11yIssueFingerprint: Codable, Sendable, Hashable {
    public let ruleId: String
    public let filePath: String?
    public let line: Int?
    public let componentId: String?
    public let messageHash: String

    public init(
        ruleId: String,
        filePath: String? = nil,
        line: Int? = nil,
        componentId: String? = nil,
        messageHash: String
    ) {
        self.ruleId = ruleId
        self.filePath = filePath
        self.line = line
        self.componentId = componentId
        self.messageHash = messageHash
    }

    public init(issue: A11yIssue) {
        self.init(
            ruleId: issue.ruleId,
            filePath: issue.filePath,
            line: issue.line,
            componentId: issue.componentId,
            messageHash: A11yIssueFingerprint.hashMessage(issue.message)
        )
    }

    public static func hashMessage(_ message: String) -> String {
        let digest = SHA256.hash(data: Data(message.utf8))
        return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
    }
}

public struct A11yBaseline: Codable, Sendable {
    public static let currentVersion = "1.0"

    public let version: String
    public let issues: [A11yIssueFingerprint]

    public init(version: String = A11yBaseline.currentVersion, issues: [A11yIssueFingerprint]) {
        self.version = version
        self.issues = issues
    }
}

public struct BaselineDiff: Sendable {
    public let newIssues: [A11yIssue]
    public let existingIssues: [A11yIssue]
    public let resolvedIssues: [A11yIssueFingerprint]
}

public enum A11yBaselineService {
    public static func create(from report: A11yReport) -> A11yBaseline {
        A11yBaseline(issues: report.issues.map(A11yIssueFingerprint.init))
    }

    public static func diff(current: A11yReport, baseline: A11yBaseline) -> BaselineDiff {
        let baselineSet = Set(baseline.issues)
        let currentFingerprints = current.issues.map { (A11yIssueFingerprint(issue: $0), $0) }
        let currentSet = Set(currentFingerprints.map(\.0))

        let newIssues = currentFingerprints
            .filter { !baselineSet.contains($0.0) }
            .map(\.1)

        let existingIssues = currentFingerprints
            .filter { baselineSet.contains($0.0) }
            .map(\.1)

        let resolvedIssues = baseline.issues.filter { !currentSet.contains($0) }

        return BaselineDiff(
            newIssues: newIssues,
            existingIssues: existingIssues,
            resolvedIssues: resolvedIssues
        )
    }
}
