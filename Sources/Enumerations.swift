import Foundation

/// ### IntegrationStep
/// Current state of the `Integration` as it moves through the lifecycle.
public enum IntegrationStep: String {
    case Unknown
    case Pending = "pending"
    case Checkout = "checkout"
    case BeforeTriggers = "before-triggers"
    case Building = "building"
    case Testing = "testing"
    case Archiving = "archiving"
    case Processing = "processing"
    case Uploading = "uploading"
    case Completed = "completed"
    
    public var description: String {
        switch self {
        case .Unknown: return "Unknown"
        case .Pending: return "Pending"
        case .Checkout: return "Checkout"
        case .BeforeTriggers: return "Before Triggers"
        case .Building: return "Building"
        case .Testing: return "Testing"
        case .Archiving: return "Archiving"
        case .Processing: return "Processing"
        case .Uploading: return "Uploading"
        case .Completed: return "Completed"
        }
    }
}

/// ### IntegrationResult
/// The outcome of the `Integration`.
public enum IntegrationResult: String {
    case Unknown
    case BuildErrors = "build-errors"
    case BuildFailed = "build-failed"
    case TestFailures = "test-failures"
    case Warnings = "warnings"
    case InternalBuildError = "internal-build-error"
    case Succeeded = "succeeded"
    
    public var description: String {
        switch self {
        case .Unknown: return "Unknown"
        case .BuildErrors: return "Build Errors"
        case .BuildFailed: return "Build Failed"
        case .TestFailures: return "Test Failures"
        case .Warnings: return "Warnings"
        case .InternalBuildError: return "Internal Errors"
        case .Succeeded: return "Succeeded"
        }
    }
}

/// ### IssueType
/// Identifies the type of an `Integration` issue.
public enum IssueType: String {
    case Unknown = "unknown"
    case BuildServiceError = "buildServiceError"
    case BuildServiceWarning = "buildServiceWarning"
    case TriggerError = "triggerError"
    case Error = "error"
    case Warning = "warning"
    case TestFailure = "testFailure"
    case AnalyzerWarning = "analyzerWarning"
    
    public var isWarning: Bool {
        switch self {
        case .Warning, .BuildServiceWarning: return true
        default: return false
        }
    }
    
    public var isError: Bool {
        switch self {
        case .TriggerError, .Error, .BuildServiceError, .TestFailure: return true
        default: return false
        }
    }
}

/// ### TriggerPhase
/// When a trigger may be executed during the `Integration` lifecycle.
public enum TriggerPhase: Int {
    case beforeIntegration = 0
    case afterIntegration
}

