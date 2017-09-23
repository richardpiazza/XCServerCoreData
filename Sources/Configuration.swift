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

public class Configuration: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.bot = bot
        self.deviceSpecification = DeviceSpecification(managedObjectContext: managedObjectContext, configuration: self)
    }
    
    internal func update(withConfiguration configuration: XCServerAPI.Configuration) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        self.schemeName = configuration.schemeName
        
        self.builtFromClean = configuration.builtFromClean?.rawValue as NSNumber?
        self.disableAppThinning = configuration.disableAppThinning as NSNumber?
        self.codeCoveragePreference = configuration.codeCoveragePreference?.rawValue as NSNumber?
        self.useParallelDeviceTesting = configuration.useParallelDeviceTesting as NSNumber?
        self.performsArchiveAction = configuration.performsArchiveAction as NSNumber?
        self.performsAnalyzeAction = configuration.performsAnalyzeAction as NSNumber?
        self.exportsProductFromArchive = configuration.exportsProductFromArchive as NSNumber?
        
        self.performsTestAction = configuration.performsTestAction as NSNumber?
        self.runOnlyDisabledTests = configuration.runOnlyDisabledTests as NSNumber?
        self.testingDestinationType = configuration.testingDestinationType as NSNumber?
        // TODO: testLocalizations?
        
        self.scheduleType = configuration.scheduleType?.rawValue as NSNumber?
        self.periodicScheduleInterval = configuration.periodicScheduleInterval.rawValue as NSNumber?
        self.weeklyScheduleDay = configuration.weeklyScheduleDay as NSNumber?
        self.hourOfIntegration = configuration.hourOfIntegration as NSNumber?
        self.minutesAfterHourToIntegrate = configuration.minutesAfterHourToIntegrate as NSNumber?
        self.performsUpgradeIntegration = configuration.performsUpgradeIntegration as NSNumber?
        
        if let provConfig = configuration.provisioningConfiguration {
            self.addMissingDeviceToTeams = provConfig.addMissingDevicesToTeams as NSNumber
            self.manageCertsAndProfiles = provConfig.manageCertsAndProfiles as NSNumber
        }
        
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            if let buildArgs = configuration.additionalBuildArguments {
                do {
                    self.additionalBuildArgumentsData = try XCServerCoreData.jsonEncoder.encode(buildArgs)
                } catch {
                    Log.error(error, message: "Failed to encode Configuration BuildArgurments")
                }
            }
            
            if let envVars = configuration.buildEnvironmentVariables {
                do {
                    self.buildEnvironmentVariablesData = try XCServerCoreData.jsonEncoder.encode(envVars)
                } catch {
                    Log.error(error, message: "Failed to encode Configuratoin EnvironmentVariables")
                }
            }
        }
        
        // Repositories
        if let configurationBlueprint = configuration.sourceControlBlueprint {
            if let repositories = self.repositories {
                for repository in repositories {
                    let _ = repository.configurations?.remove(self)
                }
            }
            
            if let remoteRepositories = configurationBlueprint.remoteRepositories {
                for remoteRepository in remoteRepositories {
                    guard let identifier = remoteRepository.identifier else {
                        continue
                    }
                    
                    var repo: Repository?
                    if let r = moc.repository(withIdentifier: identifier) {
                        repo = r
                    } else if let r = Repository(managedObjectContext: moc, identifier: identifier) {
                        repo = r
                    }
                    
                    guard let repository = repo else {
                        continue
                    }
                    
                    repository.update(withRevisionBlueprint: configurationBlueprint)
                    
                    if let repositories = self.repositories {
                        if !repositories.contains(repository) {
                            self.repositories?.insert(repository)
                        }
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
                moc.delete(trigger)
            }
        }
        
        if let configTriggers = configuration.triggers {
            for configurationTrigger in configTriggers {
                if let trigger = Trigger(managedObjectContext: moc, configuration: self) {
                    trigger.update(withTrigger: configurationTrigger)
                }
            }
        }
    }
}
