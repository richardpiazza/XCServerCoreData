//===----------------------------------------------------------------------===//
//
// Enumerations.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/XCServerCoreData
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation

/// ### DocumentType
/// The various *types* of documents returned by the Xcode Server API.
public enum DocumentType: String {
    case Version = "version"
    case Bot = "bot"
    case Integration = "integration"
    case Device = "device"
    case Commit = "commit"
}

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
    case BeforeIntegration = 0
    case AfterIntegration
}

