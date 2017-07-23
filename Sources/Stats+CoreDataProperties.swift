//===----------------------------------------------------------------------===//
//
// Stats+CoreDataProperties.swift
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

public extension Stats {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }
    
    @NSManaged public var codeCoveragePercentageDelta: NSNumber?
    @NSManaged public var numberOfCommits: NSNumber?
    @NSManaged public var numberOfIntegrations: NSNumber?
    @NSManaged public var sinceDate: String?
    @NSManaged public var testAdditionRate: NSNumber?
    @NSManaged public var numberOfSuccessfulIntegrations: NSNumber?
    @NSManaged public var analysisWarnings: StatsBreakdown?
    @NSManaged public var averageIntegrationTime: StatsBreakdown?
    @NSManaged public var bestSuccessStreak: Integration?
    @NSManaged public var bot: Bot?
    @NSManaged public var errors: StatsBreakdown?
    @NSManaged public var improvedPerfTests: StatsBreakdown?
    @NSManaged public var lastCleanIntegration: Integration?
    @NSManaged public var regressedPerfTests: StatsBreakdown?
    @NSManaged public var testFailures: StatsBreakdown?
    @NSManaged public var tests: StatsBreakdown?
    @NSManaged public var warnings: StatsBreakdown?
    
}
