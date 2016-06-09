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

class IntegrationIssues: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, integration: Integration) {
        self.init(managedObjectContext: managedObjectContext)
        self.integration = integration
    }
    
    func update(withIntegrationIssues issues: IntegrationIssuesResponse) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        // Build Service Errors
        if let set = self.buildServiceErrors as? Set<Issue> {
            for issue in set {
                moc.deleteObject(issue)
            }
        }
        
        self.buildServiceErrors = NSSet()
        
        for error in issues.buildServiceErrors {
            if let issue = Issue(managedObjectContext: moc) {
                issue.update(withIssue: error)
                issue.inverseBuildServiceErrors = self
                self.buildServiceErrors = self.buildServiceErrors?.setByAddingObject(issue)
            }
        }
        
        // Build Service Warnings
        if let set = self.buildServiceWarnings as? Set<Issue> {
            for issue in set {
                moc.deleteObject(issue)
            }
        }
        
        self.buildServiceWarnings = NSSet()
        
        for warning in issues.buildServiceWarnings {
            if let issue = Issue(managedObjectContext: moc) {
                issue.update(withIssue: warning)
                issue.inverseBuildServiceWarnings = self
                self.buildServiceWarnings = self.buildServiceWarnings?.setByAddingObject(issue)
            }
        }
        
        // Errors
        if let errors = issues.errors {
            if let set = self.unresolvedErrors as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedErrors as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshErrors as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            self.unresolvedErrors = NSSet()
            self.resolvedErrors = NSSet()
            self.freshErrors = NSSet()
            
            for unresolvedIssue in errors.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedErrors = self
                    self.unresolvedErrors = self.unresolvedErrors?.setByAddingObject(issue)
                }
            }
            
            for resolvedIssue in errors.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedErrors = self
                    self.resolvedErrors = self.resolvedErrors?.setByAddingObject(issue)
                }
            }
            
            for freshIssue in errors.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshErrors = self
                    self.freshErrors = self.freshErrors?.setByAddingObject(issue)
                }
            }
        }
        
        // Warnings
        if let warnings = issues.warnings {
            if let set = self.unresolvedWarnings as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedWarnings as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshWarnings as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            self.unresolvedWarnings = NSSet()
            self.resolvedWarnings = NSSet()
            self.freshWarnings = NSSet()
            
            for unresolvedIssue in warnings.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedWarnings = self
                    self.unresolvedWarnings = self.unresolvedWarnings?.setByAddingObject(issue)
                }
            }
            
            for resolvedIssue in warnings.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedWarnings = self
                    self.resolvedWarnings = self.resolvedWarnings?.setByAddingObject(issue)
                }
            }
            
            for freshIssue in warnings.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshWarnings = self
                    self.freshWarnings = self.freshWarnings?.setByAddingObject(issue)
                }
            }
        }
        
        // Analyzer Warnings
        if let analyzerWarnings = issues.analyzerWarnings {
            if let set = self.unresolvedAnalyzerWarnings as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedAnalyzerWarnings as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshAnalyzerWarnings as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            self.unresolvedAnalyzerWarnings = NSSet()
            self.resolvedAnalyzerWarnings = NSSet()
            self.freshAnalyzerWarnings = NSSet()
            
            for unresolvedIssue in analyzerWarnings.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedAnalyzerWarnings = self
                    self.unresolvedAnalyzerWarnings = self.unresolvedAnalyzerWarnings?.setByAddingObject(issue)
                }
            }
            
            for resolvedIssue in analyzerWarnings.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedAnalyzerWarnings = self
                    self.resolvedAnalyzerWarnings = self.resolvedAnalyzerWarnings?.setByAddingObject(issue)
                }
            }
            
            for freshIssue in analyzerWarnings.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshAnalyserWarnings = self
                    self.freshAnalyzerWarnings = self.resolvedAnalyzerWarnings?.setByAddingObject(issue)
                }
            }
        }
        
        // Test Failures
        if let testFailures = issues.testFailures {
            if let set = self.unresolvedTestFailures as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.resolvedTestFailures as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            if let set = self.freshTestFailures as? Set<Issue> {
                for issue in set {
                    moc.deleteObject(issue)
                }
            }
            
            self.unresolvedTestFailures = NSSet()
            self.resolvedTestFailures = NSSet()
            self.freshTestFailures = NSSet()
            
            for unresolvedIssue in testFailures.unresolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: unresolvedIssue)
                    issue.inverseUnresolvedTestFailures = self
                    self.unresolvedTestFailures = self.unresolvedTestFailures?.setByAddingObject(issue)
                }
            }
            
            for resolvedIssue in testFailures.resolvedIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: resolvedIssue)
                    issue.inverseResolvedAnalyzerWarnings = self
                    self.resolvedTestFailures = self.resolvedTestFailures?.setByAddingObject(issue)
                }
            }
            
            for freshIssue in testFailures.freshIssues {
                if let issue = Issue(managedObjectContext: moc) {
                    issue.update(withIssue: freshIssue)
                    issue.inverseFreshTestFailures = self
                    self.freshTestFailures = self.freshTestFailures?.setByAddingObject(issue)
                }
            }
        }
    }
}
