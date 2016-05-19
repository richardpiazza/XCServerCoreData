//===----------------------------------------------------------------------===//
//
// Integration.swift
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
import CoreData
import CodeQuickKit

enum IntegrationStep: String {
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
    
    var description: String {
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

enum IntegrationResult: String {
    case Unknown
    case BuildErrors = "build-errors"
    case BuildFailed = "build-failed"
    case TestFailures = "test-failures"
    case Warnings = "warnings"
    case InternalBuildError = "internal-build-error"
    case Succeeded = "succeeded"
    
    var description: String {
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

class Integration: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.bot = bot
        self.buildResultSummary = BuildResultSummary(managedObjectContext: managedObjectContext, integration: self)
        self.assets = IntegrationAssets(managedObjectContext: managedObjectContext)
        self.issues = IntegrationIssues(managedObjectContext: managedObjectContext)
    }
    
    func update(withIntegration integration: IntegrationJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
    }
}

class IntegrationJSON: SerializableObject {
    var _id: String = ""
    var _rev: String?
    var doc_type: String?
    var tinyID: String?
    var number: Int = 0
    var shouldClean: Bool = false
    var currentStep: String?
    var result: String?
    var buildResultSummary: BuildResultSummaryJSON?
    var queuedDate: String?
    var startedTime: String?
    var endedTime: String?
    var endedTimeDate: [Int] = [Int]()
    var duration: Float = 0
    var success_streak: Int = 0
    var tags: [String] = [String]()
    var buildServiceFingerprint: String?
    var testedDevices: [DeviceJSON] = [DeviceJSON]()
    var testHierarchy: [String : AnyObject]?
    var perfMetricNames: [String] = [String]()
    var perfMetricKeyPaths: [String] = [String]()
    var assets: IntegrationAssetsJSON?
    var revisionBlueprint: RevisionBlueprintJSON?
    var hasCoverageData: Bool?
    var hasRequestedIssues: Bool = false
    var hasRequestedCommits: Bool = false
    
    override func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        if propertyName == "testedDevices" {
            return DeviceJSON.self
        }
        
        return super.objectClassOfCollectionType(forPropertyname: propertyName)
    }
}
