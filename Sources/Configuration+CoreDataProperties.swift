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

extension Configuration {

    @NSManaged var builtFromClean: NSNumber?
    @NSManaged var codeCoveragePreference: NSNumber?
    @NSManaged var hourOfIntegration: NSNumber?
    @NSManaged var minutesAfterHourToIntegrate: NSNumber?
    @NSManaged var performsAnalyzeAction: NSNumber?
    @NSManaged var performsArchiveAction: NSNumber?
    @NSManaged var performsTestAction: NSNumber?
    @NSManaged var periodicScheduleInterval: NSNumber?
    @NSManaged var scheduleType: NSNumber?
    @NSManaged var schemeName: String?
    @NSManaged var testingDestinationType: NSNumber?
    @NSManaged var weeklyScheduleDay: NSNumber?
    @NSManaged var bot: Bot?
    @NSManaged var deviceSpecification: DeviceSpecification?
    @NSManaged var repositories: Set<Repository>?
    @NSManaged var triggers: Set<Trigger>?

}
