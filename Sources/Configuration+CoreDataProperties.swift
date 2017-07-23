//===----------------------------------------------------------------------===//
//
// Configuration+CoreDataProperties.swift
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

public extension Configuration {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Configuration> {
        return NSFetchRequest<Configuration>(entityName: "Configuration")
    }
    
    @NSManaged public var builtFromClean: NSNumber?
    @NSManaged public var codeCoveragePreference: NSNumber?
    @NSManaged public var hourOfIntegration: NSNumber?
    @NSManaged public var minutesAfterHourToIntegrate: NSNumber?
    @NSManaged public var performsAnalyzeAction: NSNumber?
    @NSManaged public var performsArchiveAction: NSNumber?
    @NSManaged public var performsTestAction: NSNumber?
    @NSManaged public var periodicScheduleInterval: NSNumber?
    @NSManaged public var scheduleType: NSNumber?
    @NSManaged public var schemeName: String?
    @NSManaged public var testingDestinationType: NSNumber?
    @NSManaged public var weeklyScheduleDay: NSNumber?
    @NSManaged public var disableAppThinning: NSNumber?
    @NSManaged public var useParallelDeviceTesting: NSNumber?
    @NSManaged public var exportsProductFromArchive: NSNumber?
    @NSManaged public var runOnlyDisabledTests: NSNumber?
    @NSManaged public var testingDestinationTypeRawValue: NSNumber?
    @NSManaged public var performsUpgradeIntegration: NSNumber?
    @NSManaged public var addMissingDeviceToTeams: NSNumber?
    @NSManaged public var manageCertsAndProfiles: NSNumber?
    @NSManaged public var additionalBuildArgumentsData: Data?
    @NSManaged public var buildEnvironmentVariablesData: Data?
    @NSManaged public var bot: Bot?
    @NSManaged public var deviceSpecification: DeviceSpecification?
    @NSManaged public var repositories: Set<Repository>?
    @NSManaged public var triggers: Set<Trigger>?
    
}

// MARK: Generated accessors for repositories
extension Configuration {
    
    @objc(addRepositoriesObject:)
    @NSManaged public func addToRepositories(_ value: Repository)
    
    @objc(removeRepositoriesObject:)
    @NSManaged public func removeFromRepositories(_ value: Repository)
    
    @objc(addRepositories:)
    @NSManaged public func addToRepositories(_ values: Set<Repository>)
    
    @objc(removeRepositories:)
    @NSManaged public func removeFromRepositories(_ values: Set<Repository>)
    
}

// MARK: Generated accessors for triggers
extension Configuration {
    
    @objc(addTriggersObject:)
    @NSManaged public func addToTriggers(_ value: Trigger)
    
    @objc(removeTriggersObject:)
    @NSManaged public func removeFromTriggers(_ value: Trigger)
    
    @objc(addTriggers:)
    @NSManaged public func addToTriggers(_ values: Set<Trigger>)
    
    @objc(removeTriggers:)
    @NSManaged public func removeFromTriggers(_ values: Set<Trigger>)
    
}
