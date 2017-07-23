//===----------------------------------------------------------------------===//
//
// Issue+CoreDataProperties.swift
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

public extension Issue {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Issue> {
        return NSFetchRequest<Issue>(entityName: "Issue")
    }
    
    @NSManaged public var age: NSNumber?
    @NSManaged public var identifier: String?
    @NSManaged public var issueType: String?
    @NSManaged public var lineNumber: NSNumber?
    @NSManaged public var message: String?
    @NSManaged public var revision: String?
    @NSManaged public var status: NSNumber?
    @NSManaged public var target: String?
    @NSManaged public var type: String?
    @NSManaged public var fixItType: String?
    @NSManaged public var inverseBuildServiceErrors: IntegrationIssues?
    @NSManaged public var inverseBuildServiceWarnings: IntegrationIssues?
    @NSManaged public var inverseFreshAnalyserWarnings: IntegrationIssues?
    @NSManaged public var inverseFreshErrors: IntegrationIssues?
    @NSManaged public var inverseFreshTestFailures: IntegrationIssues?
    @NSManaged public var inverseFreshWarnings: IntegrationIssues?
    @NSManaged public var inverseResolvedAnalyzerWarnings: IntegrationIssues?
    @NSManaged public var inverseResolvedErrors: IntegrationIssues?
    @NSManaged public var inverseResolvedTestFailures: IntegrationIssues?
    @NSManaged public var inverseResolvedWarnings: IntegrationIssues?
    @NSManaged public var inverseUnresolvedAnalyzerWarnings: IntegrationIssues?
    @NSManaged public var inverseUnresolvedErrors: IntegrationIssues?
    @NSManaged public var inverseUnresolvedTestFailures: IntegrationIssues?
    @NSManaged public var inverseUnresolvedWarnings: IntegrationIssues?
    
}
