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
import XCServerAPI

public class Stats: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, bot: Bot) {
        self.init(managedObjectContext: managedObjectContext)
        self.bot = bot
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "bot":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    internal func update(withStats stats: StatsJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: type(of: self))
            return
        }
        
        self.numberOfIntegrations = stats.numberOfIntegrations
        self.numberOfCommits = stats.numberOfCommits
        self.testAdditionRate = stats.testAdditionRate
        self.codeCoveragePercentageDelta = stats.codeCoveragePercentageDelta
        self.sinceDate = stats.sinceDate
        
        if let statsLastCleanIntegrationIdentifier = stats.lastCleanIntegration?.intergraionID {
            self.lastCleanIntegration = moc.integration(withIdentifier: statsLastCleanIntegrationIdentifier)
        }
        
        if let statsBestSuccessStreakIdentifier = stats.bestSuccessStreak?.integrationID {
            self.bestSuccessStreak = moc.integration(withIdentifier: statsBestSuccessStreakIdentifier)
        }
        
        if let statsBreakdown = stats.averageIntegrationTime {
            if self.averageIntegrationTime == nil {
                self.averageIntegrationTime = StatsBreakdown(managedObjectContext: moc)
                self.averageIntegrationTime?.inverseAverageIntegrationTime = self
            }
            
            self.averageIntegrationTime?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.analysisWarnings {
            if self.analysisWarnings == nil {
                self.analysisWarnings = StatsBreakdown(managedObjectContext: moc)
                self.analysisWarnings?.inverseAnalysisWarnings = self
            }
            
            self.analysisWarnings?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.testFailures {
            if self.testFailures == nil {
                self.testFailures = StatsBreakdown(managedObjectContext: moc)
                self.testFailures?.inverseTestFailures = self
            }
            
            self.testFailures?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.errors {
            if self.errors == nil {
                self.errors = StatsBreakdown(managedObjectContext: moc)
                self.errors?.inverseErrors = self
            }
            
            self.errors?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.regressedPerfTests {
            if self.regressedPerfTests == nil {
                self.regressedPerfTests = StatsBreakdown(managedObjectContext: moc)
                self.regressedPerfTests?.inverseRegressedPerfTests = self
            }
            
            self.regressedPerfTests?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.warnings {
            if self.warnings == nil {
                self.warnings = StatsBreakdown(managedObjectContext: moc)
                self.warnings?.inverseWarnings = self
            }
            
            self.warnings?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.improvedPerfTests {
            if self.improvedPerfTests == nil {
                self.improvedPerfTests = StatsBreakdown(managedObjectContext: moc)
                self.improvedPerfTests?.inverseImprovedPerfTests = self
            }
            
            self.improvedPerfTests?.update(withStatsBreakdown: statsBreakdown)
        }
        
        if let statsBreakdown = stats.tests {
            if self.tests == nil {
                self.tests = StatsBreakdown(managedObjectContext: moc)
                self.tests?.inverseTests = self
            }
            
            self.tests?.update(withStatsBreakdown: statsBreakdown)
        }
    }
}
