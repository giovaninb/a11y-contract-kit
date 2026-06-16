import Foundation

public enum A11ySourceLocator {
    public static func resolve(
        componentId: String,
        fallbackFile: String? = nil,
        projectRoots: [String]? = nil
    ) -> A11ySource? {
        if let registered = A11yContractRegistry.shared.source(forComponentId: componentId) {
            return enrichLineIfNeeded(
                registered,
                componentId: componentId,
                projectRoots: projectRoots
            )
        }

        guard let fallbackFile, !fallbackFile.isEmpty else { return nil }
        guard let fileURL = resolveExistingPath(fallbackFile, projectRoots: projectRoots) else {
            return A11ySource(filePath: fallbackFile, line: nil)
        }

        let line = findLine(for: componentId, in: fileURL)
        return A11ySource(filePath: fallbackFile, line: line)
    }

    public static func resolveExistingPath(
        _ relativeOrAbsolutePath: String,
        projectRoots: [String]? = nil
    ) -> URL? {
        let path = relativeOrAbsolutePath
        if path.hasPrefix("/"), FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }

        for root in projectRoots ?? defaultProjectRoots() {
            let candidate = URL(fileURLWithPath: root, isDirectory: true)
                .appendingPathComponent(path)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
        }

        return nil
    }

    private static func enrichLineIfNeeded(
        _ source: A11ySource,
        componentId: String,
        projectRoots: [String]?
    ) -> A11ySource {
        if source.line != nil {
            return source
        }
        guard let filePath = source.filePath,
              let fileURL = resolveExistingPath(filePath, projectRoots: projectRoots),
              let line = findLine(for: componentId, in: fileURL) else {
            return source
        }
        return A11ySource(filePath: filePath, line: line)
    }

    private static func findLine(for componentId: String, in fileURL: URL) -> Int? {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return nil
        }

        let needles = [
            "accessibilityIdentifier = \"\(componentId)\"",
            "accessibilityIdentifier=\"\(componentId)\"",
            "id: \"\(componentId)\"",
            "forComponentId: \"\(componentId)\"",
        ]

        for (index, line) in content.components(separatedBy: "\n").enumerated() {
            if needles.contains(where: { line.contains($0) }) {
                return index + 1
            }
        }

        return nil
    }

    private static func defaultProjectRoots() -> [String] {
        var roots = [FileManager.default.currentDirectoryPath]
        if let envRoot = ProcessInfo.processInfo.environment["A11Y_PROJECT_ROOT"], !envRoot.isEmpty {
            roots.insert(envRoot, at: 0)
        }
        if let testRoot = ProcessInfo.processInfo.environment["SRCROOT"], !testRoot.isEmpty {
            roots.insert(testRoot, at: 0)
        }
        return roots
    }
}
