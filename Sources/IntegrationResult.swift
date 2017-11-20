import Foundation

/// ### IntegrationResult
/// The outcome of the `Integration`.
public enum IntegrationResult: String {
    case unknown
    case buildErrors = "build-errors"
    case buildFailed = "build-failed"
    case testFailures = "test-failures"
    case warnings = "warnings"
    case internalError = "internal-error"
    case internalBuildError = "internal-build-error"
    case succeeded = "succeeded"
    
    public var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .buildErrors: return "Build Errors"
        case .buildFailed: return "Build Failed"
        case .testFailures: return "Test Failures"
        case .warnings: return "Warnings"
        case .internalError: return "Internal Error"
        case .internalBuildError: return "Internal Build Errors"
        case .succeeded: return "Succeeded"
        }
    }
}
