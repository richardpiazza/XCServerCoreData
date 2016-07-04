//===----------------------------------------------------------------------===//
//
// IntegrationIssues.swift
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

public class IntegrationIssues: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, integration: Integration) {
        self.init(managedObjectContext: managedObjectContext)
        self.integration = integration
        
        Logger.info("Created `IntegrationIssues` entity for `Integration` with identifier '\(integration.identifier)'", callingClass: self.dynamicType)
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "integration":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withIntegrationIssues issues: IntegrationIssuesResponse) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        // Build Service Errors
        if let set = self.buildServiceErrors {
            for issue in set {
                issue.inverseBuildServiceErrors = nil
                moc.deleteObject(issue)
            }
        }
        
        for error in issues.buildServiceErrors {
            if let issue = Issue(managedObjectContext: moc) {
                issue.update(withIssue: error)
                issue.inverseBuildServiceErrors = self
            }
        }
        
        // Build Service Warnings
        if let set = self.buildServiceWarnings {
            for issue in set {
                issue.inverseBuildServiceWarnings = nil
                moc.deleteObject(issue)
            }
        }
        
        for warning in issues.buildServiceWarnings {
            if let issue = Issue(managedObjectContext: moc) {
                issue.update(withIssue: warning)
                issue.inverseBuildServiceWarnings = self
            }
        }
        
        // Errors
        if let errors = issues.errors {
            if let set = self.unresolvedErrors {
                for issue in set {
                    issue.inverseUnresolvedErrors = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedErrors {
                for issue in set {
                    issue.inverseResolvedErrors = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshErrors {
                for issue in set {
                    issue.inverseFreshErrors = nil
                    moc.deleteObject(issue)
                }
            }
            
            for unresolvedIssue in errors.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedErrors = self
                }
            }
            
            for resolvedIssue in errors.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedErrors = self
                }
            }
            
            for freshIssue in errors.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshErrors = self
                }
            }
        }
        
        // Warnings
        if let warnings = issues.warnings {
            if let set = self.unresolvedWarnings {
                for issue in set {
                    issue.inverseUnresolvedWarnings = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedWarnings {
                for issue in set {
                    issue.inverseResolvedWarnings = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshWarnings {
                for issue in set {
                    issue.inverseFreshWarnings = nil
                    moc.deleteObject(issue)
                }
            }
            
            for unresolvedIssue in warnings.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedWarnings = self
                }
            }
            
            for resolvedIssue in warnings.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedWarnings = self
                }
            }
            
            for freshIssue in warnings.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshWarnings = self
                }
            }
        }
        
        // Analyzer Warnings
        if let analyzerWarnings = issues.analyzerWarnings {
            if let set = self.unresolvedAnalyzerWarnings {
                for issue in set {
                    issue.inverseUnresolvedAnalyzerWarnings = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedAnalyzerWarnings {
                for issue in set {
                    issue.inverseResolvedAnalyzerWarnings = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshAnalyzerWarnings {
                for issue in set {
                    issue.inverseFreshAnalyserWarnings = nil
                    moc.deleteObject(issue)
                }
            }
            
            for unresolvedIssue in analyzerWarnings.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedAnalyzerWarnings = self
                }
            }
            
            for resolvedIssue in analyzerWarnings.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedAnalyzerWarnings = self
                }
            }
            
            for freshIssue in analyzerWarnings.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshAnalyserWarnings = self
                }
            }
        }
        
        // Test Failures
        if let testFailures = issues.testFailures {
            if let set = self.unresolvedTestFailures {
                for issue in set {
                    issue.inverseUnresolvedTestFailures = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedTestFailures {
                for issue in set {
                    issue.inverseResolvedTestFailures = nil
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshTestFailures {
                for issue in set {
                    issue.inverseFreshTestFailures = nil
                    moc.deleteObject(issue)
                }
            }
            
            for unresolvedIssue in testFailures.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedTestFailures = self
                }
            }
            
            for resolvedIssue in testFailures.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedAnalyzerWarnings = self
                }
            }
            
            for freshIssue in testFailures.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshTestFailures = self
                }
            }
        }
    }
}
