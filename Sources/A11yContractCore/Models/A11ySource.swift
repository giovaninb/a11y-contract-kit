import Foundation

public struct A11ySource: Codable, Sendable, Hashable {
    public let filePath: String?
    public let line: Int?

    public init(filePath: String? = nil, line: Int? = nil) {
        self.filePath = filePath
        self.line = line
    }
}
