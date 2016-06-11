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

class Integration: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.bot = bot
        self.buildResultSummary = BuildResultSummary(managedObjectContext: managedObjectContext, integration: self)
        self.assets = IntegrationAssets(managedObjectContext: managedObjectContext)
        self.issues = IntegrationIssues(managedObjectContext: managedObjectContext)
    }
    
    override func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "bot", "inverseBestSuccessStreak", "inverseLastCleanIntegration":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withIntegration integration: IntegrationJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        self.identifier = integration._id
        self.number = integration.number
        self.shouldClean = integration.shouldClean
        self.currentStep = integration.currentStep
        self.result = integration.result
        self.queuedDate = integration.queuedDate
        self.startedTime = integration.startedTime
        self.endedTime = integration.endedTime
        self.duration = integration.duration
        self.success_streak = integration.success_streak
        self.testHierachy = integration.testHierarchy
        self.hasCoverageData = integration.hasCoverageData
        
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
            let device = moc.device(withIdentifier: testedDevice.ID)
            device.update(withDevice: testedDevice)
            
            if self.testedDevices == nil {
                self.testedDevices = NSSet()
            }
            
            if let devices = self.testedDevices {
                if !devices.containsObject(device) {
                    self.testedDevices = devices.setByAddingObject(device)
                }
            }
        }
        
        // Revision Blueprint
        if let blueprint = integration.revisionBlueprint {
            for id in blueprint.repositoryIds {
                var repository = moc.repository(withIdentifier: id)
                if repository == nil {
                    repository = Repository(managedObjectContext: moc, identifier: id)
                }
                
                repository?.update(withRevisionBlueprint: blueprint, integration: self)
            }
        }
    }
    
    var integrationNumber: Int {
        guard let value = self.number else {
            return 0
        }
        
        return value.integerValue
    }
    
    var integrationStep: IntegrationStep {
        guard let rawValue = self.currentStep else {
            return .Unknown
        }
        
        guard let enumeration = IntegrationStep(rawValue: rawValue) else {
            return .Unknown
        }
        
        return enumeration
    }
    
    var integrationResult: IntegrationResult {
        guard let rawValue = self.result else {
            return .Unknown
        }
        
        guard let enumeration = IntegrationResult(rawValue: rawValue) else {
            return .Unknown
        }
        
        return enumeration
    }
}
