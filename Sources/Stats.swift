//===----------------------------------------------------------------------===//
//
// Stats.swift
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

class Stats: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.bot = bot
    }
    
    func update(withStats stats: StatsJSON) {
        
    }
}

class StatsJSON: SerializableObject {
    var lastCleanIntegration: LastCleanIntegrationJSON?
    var bestSuccessStreak: BestSuccessStreakJSON?
    var numberOfIntegrations: NSNumber?
    var numberOfCommits: NSNumber?
    var averageIntegrationTIme: StatsBreakdownJSON?
    var testAdditionRate: NSNumber?
    var analysisWarnings: StatsBreakdownJSON?
    var testFailures: StatsBreakdownJSON?
    var errors: StatsBreakdownJSON?
    var regressedPerfTests: StatsBreakdownJSON?
    var warnings: StatsBreakdownJSON?
    var improvedPerfTests: StatsBreakdownJSON?
    var tests: StatsBreakdownJSON?
    var codeCoveragePercentageDelta: NSNumber?
    var sinceDate: NSString?
}

class LastCleanIntegrationJSON: SerializableObject {
    var intergraionID: String?
    var endedTime: String?
}

class BestSuccessStreakJSON: SerializableObject {
    var integrationID: String?
    var success_streak: NSNumber?
    var endedTime: String?
}
