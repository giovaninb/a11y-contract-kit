import Foundation
import A11yContractCore

public protocol A11yReporter {
    func generate(report: A11yReport) throws -> String
    var outputFileName: String { get }
}

public enum A11yReporterError: Error, LocalizedError {
    case encodingFailed

    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode accessibility report."
        }
    }
}
