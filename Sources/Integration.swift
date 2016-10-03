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
import XCServerAPI

public typealias TestResult = (name: String, passed: Bool)

/// ## Integration
/// An Xcode Server Bot integration (run).
/// "An integration is a single run of a bot. Integrations consist of building, analyzing, testing, and archiving the apps (or other software products) defined in your Xcode projects."
public class Integration: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.identifier = identifier
        self.bot = bot
        self.buildResultSummary = BuildResultSummary(managedObjectContext: managedObjectContext, integration: self)
        self.assets = IntegrationAssets(managedObjectContext: managedObjectContext)
        self.issues = IntegrationIssues(managedObjectContext: managedObjectContext)
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "bot", "inverseBestSuccessStreak", "inverseLastCleanIntegration":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    internal func update(withIntegration integration: IntegrationJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: type(of: self))
            return
        }
        
        self.number = integration.number as NSNumber?
        self.shouldClean = integration.shouldClean as NSNumber?
        self.currentStep = integration.currentStep
        self.result = integration.result
        self.queuedDate = integration.queuedDate
        self.startedTime = integration.startedTime
        self.endedTime = integration.endedTime
        self.duration = integration.duration as NSNumber?
        self.success_streak = integration.success_streak as NSNumber?
        if let value = integration.testHierarchy {
            self.testHierachy = value as NSObject?
        }
        self.hasCoverageData = integration.hasCoverageData as NSNumber?
        
        // Build Results Summary
        if let summary = integration.buildResultSummary {
            self.buildResultSummary?.update(withBuildResultSummary: summary)
        }
        
        // Assets
        if let assets = integration.assets {
            self.assets?.update(withIntegrationAssets: assets)
        }
        
        // Tested Devices
        for testedDevice in integration.testedDevices {
            if let device = moc.device(withIdentifier: testedDevice.ID) {
                self.testedDevices?.insert(device)
                continue
            }
            
            if let device = Device(managedObjectContext: moc, identifier: testedDevice.ID) {
                device.update(withDevice: testedDevice)
                self.testedDevices?.insert(device)
            }
        }
        
        // Revision Blueprint
        if let blueprint = integration.revisionBlueprint {
            for id in blueprint.repositoryIds {
                if let repository = moc.repository(withIdentifier: id) {
                    repository.update(withRevisionBlueprint: blueprint, integration: self)
                    continue
                }
                
                if let repository = Repository(managedObjectContext: moc, identifier: id) {
                    repository.update(withRevisionBlueprint: blueprint, integration: self)
                }
            }
        }
    }
    
    public var integrationNumber: Int {
        guard let value = self.number else {
            return 0
        }
        
        return value.intValue
    }
    
    public var integrationStep: IntegrationStep {
        guard let rawValue = self.currentStep else {
            return .Unknown
        }
        
        guard let enumeration = IntegrationStep(rawValue: rawValue) else {
            return .Unknown
        }
        
        return enumeration
    }
    
    public var integrationResult: IntegrationResult {
        guard let rawValue = self.result else {
            return .Unknown
        }
        
        guard let enumeration = IntegrationResult(rawValue: rawValue) else {
            return .Unknown
        }
        
        return enumeration
    }
    
    public var queuedTimestamp: Date? {
        guard let timestamp = self.queuedDate else {
            return nil
        }
        
        return DateFormatter.xcodeServerDateFormatter.date(from: timestamp)
    }
    
    public var startedTimestamp: Date? {
        guard let timestamp = self.startedTime else {
            return nil
        }
        
        return DateFormatter.xcodeServerDateFormatter.date(from: timestamp)
    }
    
    public var endedTimestamp: Date? {
        guard let timestamp = self.endedTime else {
            return nil
        }
        
        return DateFormatter.xcodeServerDateFormatter.date(from: timestamp)
    }
    
    public var testResults: [TestResult] {
        guard let testHierachy = self.testHierachy as? [String : AnyObject] else {
            return []
        }
        
        guard testHierachy.keys.count > 0 else {
            return []
        }
        
        var results = [TestResult]()
        
        for target in testHierachy.keys {
            guard let suite = testHierachy[target] as? [String : AnyObject] else {
                continue
            }
            
            let suiteClasses = suite.keys.filter({ (key: String) -> Bool in
                return !key.hasPrefix("_")
            })
            
            for suiteClass in suiteClasses {
                guard let classMethods = suite[suiteClass] as? [String : AnyObject] else {
                    continue
                }
                
                let methodNames = classMethods.keys.filter({ (key: String) -> Bool in
                    return !key.hasPrefix("_")
                })
                
                for method in methodNames {
                    guard let devices = classMethods[method] as? [String : Bool] else {
                        continue
                    }
                    
                    var passed = true
                    for device in devices {
                        if device.1 == false {
                            passed = false
                        }
                    }
                    
                    results.append(TestResult(name: method.xcServerTestMethodName, passed: passed))
                }
            }
        }
        
        return results
    }
}
