//===----------------------------------------------------------------------===//
//
// Configuration.swift
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

public class Configuration: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.bot = bot
        self.deviceSpecification = DeviceSpecification(managedObjectContext: managedObjectContext, configuration: self)
        
        Logger.info("Created `Configuration` entity for `Bot` with identifier '\(bot.identifier)'", callingClass: self.dynamicType)
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "bot", "repositories":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withConfiguration configuration: ConfigurationJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        self.schemeName = configuration.schemeName
        self.builtFromClean = configuration.builtFromClean
        self.performsTestAction = configuration.performsTestAction
        self.performsAnalyzeAction = configuration.performsAnalyzeAction
        self.performsArchiveAction = configuration.performsArchiveAction
        self.testingDestinationType = configuration.testingDestinationType
        self.scheduleType = configuration.scheduleType
        self.periodicScheduleInterval = configuration.periodicScheduleInterval
        self.weeklyScheduleDay = configuration.weeklyScheduleDay
        self.hourOfIntegration = configuration.hourOfIntegration
        self.minutesAfterHourToIntegrate = configuration.minutesAfterHourToIntegrate
        self.codeCoveragePreference = configuration.codeCoveragePreference
        
        // Repositories
        if let configurationBlueprint = configuration.sourceControlBlueprint {
            if let repositories = self.repositories {
                for repository in repositories {
                    repository.configurations?.remove(self)
                }
            }
            
            if let remoteRepositories = configurationBlueprint.DVTSourceControlWorkspaceBlueprintRemoteRepositoriesKey {
                for remoteRepository in remoteRepositories {
                    guard let identifier = remoteRepository.DVTSourceControlWorkspaceBlueprintRemoteRepositoryIdentifierKey else {
                        continue
                    }
                    
                    if let repository = moc.repository(withIdentifier: identifier) {
                        repository.update(withRevisionBlueprint: configurationBlueprint)
                        continue
                    }
                    
                    if let repository = Repository(managedObjectContext: moc, identifier: identifier) {
                        repository.update(withRevisionBlueprint: configurationBlueprint)
                        self.repositories?.insert(repository)
                    }
                }
            }
        }
        
        // Device Specification
        if let configurationDeviceSpecification = configuration.deviceSpecification {
            self.deviceSpecification?.update(withDeviceSpecification: configurationDeviceSpecification)
        }
        
        // Triggers        
        if let triggers = self.triggers {
            for trigger in triggers {
                trigger.configuration = nil
                moc.deleteObject(trigger)
            }
        }
        
        for configurationTrigger in configuration.triggers {
            if let trigger = Trigger(managedObjectContext: moc, configuration: self) {
                trigger.update(withTrigger: configurationTrigger)
            }
        }
    }
}
