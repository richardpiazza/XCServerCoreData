//===----------------------------------------------------------------------===//
//
// MigrateIntegrationStringToDate.swift
//
// Copyright (c) 2017 Richard Piazza
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
//import CodeQuickKit

public class IntegrationStringToDateMigrationPolicy: NSEntityMigrationPolicy {
    public override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard sInstance.entity.name == Integration.entityName else {
            try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
            return
        }
        
        guard let identifier = sInstance.value(forKey: "identifier") as? String else {
//            Log.warn("IngtegrationMigration error: Source Identifier nil.")
            return
        }
        
        guard let destinationIntegration = Integration(managedObjectContext: manager.destinationContext, identifier: identifier) else {
//            Log.warn("IngtegrationMigration error: Destination Integration nil.")
            return
        }
        
        destinationIntegration.currentStep = sInstance.value(forKey: "currentStep") as? String
        destinationIntegration.duration = sInstance.value(forKey: "duration") as? NSNumber
        if let endedDate = sInstance.value(forKey: "endedTime") as? String, endedDate != "" {
            destinationIntegration.endedTime = XCServerCoreData.dateFormatter.date(from: endedDate)
        }
        destinationIntegration.number = sInstance.value(forKey: "number") as? NSNumber
        if let queuedDate = sInstance.value(forKey: "queuedDate") as? String, queuedDate != "" {
            destinationIntegration.queuedDate = XCServerCoreData.dateFormatter.date(from: queuedDate)
        }
        destinationIntegration.result = sInstance.value(forKey: "result") as? String
        destinationIntegration.shouldClean = sInstance.value(forKey: "shouldClean") as? NSNumber
        if let startedDate = sInstance.value(forKey: "startedTime") as? String, startedDate != "" {
            destinationIntegration.startedTime = XCServerCoreData.dateFormatter.date(from: startedDate)
        }
        destinationIntegration.successStreak = sInstance.value(forKey: "success_streak") as? NSNumber
        
        // Not mapping additional references. Should be auto filled on background sync operations.
        
        destinationIntegration.hasRetrievedAssets = false
        destinationIntegration.hasRetrievedCommits = false
        destinationIntegration.hasRetrievedIssues = false
        destinationIntegration.lastUpdate = nil
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationIntegration, for: mapping)
    }
}
