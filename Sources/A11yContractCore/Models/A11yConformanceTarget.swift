import Foundation

public enum WCAGVersion: String, Codable, Sendable, CaseIterable, Comparable {
    case v21 = "2.1"
    case v22 = "2.2"

    public static func < (lhs: WCAGVersion, rhs: WCAGVersion) -> Bool {
        switch (lhs, rhs) {
        case (.v21, .v22): return true
        default: return false
        }
    }
}

public enum WCAGLevel: String, Codable, Sendable, CaseIterable, Comparable {
    case a = "A"
    case aa = "AA"
    case aaa = "AAA"

    public static func < (lhs: WCAGLevel, rhs: WCAGLevel) -> Bool {
        let order: [WCAGLevel] = [.a, .aa, .aaa]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

public struct A11yConformanceTarget: Codable, Sendable, Hashable {
    public let version: WCAGVersion
    public let level: WCAGLevel

    public init(version: WCAGVersion, level: WCAGLevel) {
        self.version = version
        self.level = level
    }

    public static let wcag22AA = A11yConformanceTarget(version: .v22, level: .aa)

    public var displayName: String {
        "WCAG \(version.rawValue) \(level.rawValue)"
    }

    public static func parse(_ value: String) -> A11yConformanceTarget? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "-", maxSplits: 1).map(String.init)
        guard parts.count == 2,
              let version = WCAGVersion(rawValue: parts[0]),
              let level = WCAGLevel(rawValue: parts[1]) else {
            return nil
        }
        return A11yConformanceTarget(version: version, level: level)
    }
}

public enum A11yConformanceTargetResolver {
    public static let environmentKey = "A11Y_CONFORMANCE_TARGET"

    public static func resolve(explicit: A11yConformanceTarget? = nil) -> A11yConformanceTarget {
        if let explicit {
            return explicit
        }
        if let env = ProcessInfo.processInfo.environment[environmentKey],
           let parsed = A11yConformanceTarget.parse(env) {
            return parsed
        }
        return .wcag22AA
    }
}
