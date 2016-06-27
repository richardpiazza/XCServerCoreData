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

    @NSManaged var age: NSNumber?
    @NSManaged var documentFilePath: String?
    @NSManaged var documentLocationData: String?
    @NSManaged var identifier: String
    @NSManaged var issueType: String?
    @NSManaged var lineNumber: NSNumber?
    @NSManaged var message: String?
    @NSManaged var revision: String?
    @NSManaged var status: NSNumber?
    @NSManaged var target: String?
    @NSManaged var testCase: String?
    @NSManaged var type: String?
    @NSManaged var inverseBuildServiceErrors: IntegrationIssues?
    @NSManaged var inverseBuildServiceWarnings: IntegrationIssues?
    @NSManaged var inverseFreshAnalyserWarnings: IntegrationIssues?
    @NSManaged var inverseFreshErrors: IntegrationIssues?
    @NSManaged var inverseFreshTestFailures: IntegrationIssues?
    @NSManaged var inverseFreshWarnings: IntegrationIssues?
    @NSManaged var inverseResolvedAnalyzerWarnings: IntegrationIssues?
    @NSManaged var inverseResolvedErrors: IntegrationIssues?
    @NSManaged var inverseResolvedTestFailures: IntegrationIssues?
    @NSManaged var inverseResolvedWarnings: IntegrationIssues?
    @NSManaged var inverseUnresolvedAnalyzerWarnings: IntegrationIssues?
    @NSManaged var inverseUnresolvedErrors: IntegrationIssues?
    @NSManaged var inverseUnresolvedTestFailures: IntegrationIssues?
    @NSManaged var inverseUnresolvedWarnings: IntegrationIssues?

}
