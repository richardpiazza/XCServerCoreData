//===----------------------------------------------------------------------===//
//
// IntegrationIssues+CoreDataProperties.swift
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

extension IntegrationIssues {

    @NSManaged var buildServiceErrors: NSSet?
    @NSManaged var buildServiceWarnings: NSSet?
    @NSManaged var freshAnalyzerWarnings: NSSet?
    @NSManaged var freshErrors: NSSet?
    @NSManaged var freshTestFailures: NSSet?
    @NSManaged var freshWarnings: NSSet?
    @NSManaged var integration: Integration?
    @NSManaged var resolvedAnalyzerWarnings: NSSet?
    @NSManaged var resolvedErrors: NSSet?
    @NSManaged var resolvedTestFailures: NSSet?
    @NSManaged var resolvedWarnings: NSSet?
    @NSManaged var unresolvedAnalyzerWarnings: NSSet?
    @NSManaged var unresolvedErrors: NSSet?
    @NSManaged var unresolvedTestFailures: NSSet?
    @NSManaged var unresolvedWarnings: NSSet?

}
