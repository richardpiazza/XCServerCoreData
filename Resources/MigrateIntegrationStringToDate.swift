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

public class IntegrationStringToDateMigrationPolicy: NSEntityMigrationPolicy {
    public override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard sInstance.entity.name == "Integration" else {
            try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
            return
        }
        
        guard let identifier = sInstance.value(forKey: "identifier") as? String else {
            NSLog("IngtegrationMigration error: Source Identifier nil.")
            return
        }
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Integration", in: manager.destinationContext) else {
            NSLog("IntegrationMigration error: Entity Description nil.")
            return
        }
        
        let destinationIntegration = NSManagedObject(entity: entityDescription, insertInto: manager.destinationContext)
        destinationIntegration.setValue(identifier, forKey: "identifier")
        
        if let buildResultSummaryDescription = NSEntityDescription.entity(forEntityName: "BuildResultSummary", in: manager.destinationContext) {
            destinationIntegration.setValue(NSManagedObject(entity: buildResultSummaryDescription, insertInto: manager.destinationContext), forKey: "buildResultSummary")
        }
        if let assetsDescription = NSEntityDescription.entity(forEntityName: "IntegrationAssets", in: manager.destinationContext) {
            destinationIntegration.setValue(NSManagedObject(entity: assetsDescription, insertInto: manager.destinationContext), forKey: "assets")
        }
        if let issuesDescription = NSEntityDescription.entity(forEntityName: "IntegrationIssues", in: manager.destinationContext) {
            destinationIntegration.setValue(NSManagedObject(entity: issuesDescription, insertInto: manager.destinationContext), forKey: "issues")
        }
        
        destinationIntegration.setValue(sInstance.value(forKey: "currentStep"), forKey: "currentStep")
        destinationIntegration.setValue(sInstance.value(forKey: "duration"), forKey: "duration")
        if let endedDate = sInstance.value(forKey: "endedTime") as? String, endedDate != "" {
            destinationIntegration.setValue(XCServerCoreData.dateFormatter.date(from: endedDate), forKey: "endedTime")
        }
        destinationIntegration.setValue(sInstance.value(forKey: "number"), forKey: "number")
        if let queuedDate = sInstance.value(forKey: "queuedDate") as? String, queuedDate != "" {
            destinationIntegration.setValue(XCServerCoreData.dateFormatter.date(from: queuedDate), forKey: "queuedDate")
        }
        destinationIntegration.setValue(sInstance.value(forKey: "result"), forKey: "result")
        destinationIntegration.setValue(sInstance.value(forKey: "shouldClean"), forKey: "shouldClean")
        if let startedDate = sInstance.value(forKey: "startedTime") as? String, startedDate != "" {
            destinationIntegration.setValue(XCServerCoreData.dateFormatter.date(from: startedDate), forKey: "startedTime")
        }
        destinationIntegration.setValue(sInstance.value(forKey: "success_streak"), forKey: "successStreak")
        
        // Not mapping additional references. Should be auto filled on background sync operations.
        
        destinationIntegration.setValue(false, forKey: "hasRetrievedAssets")
        destinationIntegration.setValue(false, forKey: "hasRetrievedCommits")
        destinationIntegration.setValue(false, forKey: "hasRetrievedIssues")
        destinationIntegration.setValue(nil, forKey: "lastUpdate")
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationIntegration, for: mapping)
    }
}
