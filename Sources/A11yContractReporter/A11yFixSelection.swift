import Foundation
import A11yContractCore

public enum A11yFixStyle: String, Codable, CaseIterable, Sendable {
    case uikit
    case framework
    case swiftUI = "swiftui"

    public var displayName: String {
        switch self {
        case .uikit: return "UIKit"
        case .framework: return "Framework"
        case .swiftUI: return "SwiftUI"
        }
    }
}

public enum A11yFixExportFormat: String, Codable, CaseIterable, Sendable {
    case markdown
    case swift
}

public struct A11yFixSelection: Codable, Sendable, Equatable {
    public var style: A11yFixStyle
    public var issueIds: [String]
    public var groupByComponent: Bool

    public init(
        style: A11yFixStyle = .framework,
        issueIds: [String] = [],
        groupByComponent: Bool = true
    ) {
        self.style = style
        self.issueIds = issueIds
        self.groupByComponent = groupByComponent
    }
}

public struct A11yFixSelectionIssue: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let ruleId: String
    public let componentId: String?
    public let severity: A11ySeverity
    public var selected: Bool

    public init(
        id: String,
        ruleId: String,
        componentId: String?,
        severity: A11ySeverity,
        selected: Bool = false
    ) {
        self.id = id
        self.ruleId = ruleId
        self.componentId = componentId
        self.severity = severity
        self.selected = selected
    }
}

public struct A11yFixSelectionManifest: Codable, Sendable, Equatable {
    public var style: A11yFixStyle
    public var groupByComponent: Bool
    public var issues: [A11yFixSelectionIssue]

    public init(
        style: A11yFixStyle = .framework,
        groupByComponent: Bool = true,
        issues: [A11yFixSelectionIssue] = []
    ) {
        self.style = style
        self.groupByComponent = groupByComponent
        self.issues = issues
    }

    public func toSelection() -> A11yFixSelection {
        A11yFixSelection(
            style: style,
            issueIds: issues.filter(\.selected).map(\.id),
            groupByComponent: groupByComponent
        )
    }

    public static func from(report: A11yReport) -> A11yFixSelectionManifest {
        let sortedIssues = report.issues.sorted {
            if $0.severity != $1.severity { return $0.severity > $1.severity }
            return ($0.componentId ?? "") < ($1.componentId ?? "")
        }

        return A11yFixSelectionManifest(
            issues: sortedIssues.map {
                A11yFixSelectionIssue(
                    id: $0.id,
                    ruleId: $0.ruleId,
                    componentId: $0.componentId,
                    severity: $0.severity,
                    selected: false
                )
            }
        )
    }
}

public struct A11yFixBundleInput: Sendable {
    public let report: A11yReport
    public let selection: A11yFixSelection

    public init(report: A11yReport, selection: A11yFixSelection) {
        self.report = report
        self.selection = selection
    }
}

public struct A11yFixSnippet: Sendable, Equatable {
    public let title: String
    public let location: String?
    public let ruleIds: [String]
    public let code: String

    public init(title: String, location: String?, ruleIds: [String], code: String) {
        self.title = title
        self.location = location
        self.ruleIds = ruleIds
        self.code = code
    }
}
