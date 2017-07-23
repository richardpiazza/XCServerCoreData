//===----------------------------------------------------------------------===//
//
// EmailConfiguration+CoreDataProperties.swift
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

public extension EmailConfiguration {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmailConfiguration> {
        return NSFetchRequest<EmailConfiguration>(entityName: "EmailConfiguration")
    }
    
    @NSManaged public var additionalRecipients: String?
    @NSManaged public var emailComitters: NSNumber?
    @NSManaged public var includeCommitMessages: NSNumber?
    @NSManaged public var includeIssueDetails: NSNumber?
    @NSManaged public var ccAddressesData: Data?
    @NSManaged public var allowedDomainNamesData: Data?
    @NSManaged public var includeLogs: NSNumber?
    @NSManaged public var replyToAddress: String?
    @NSManaged public var includeBotConfiguration: NSNumber?
    @NSManaged public var fromAddress: String?
    @NSManaged public var emailTypeRawValue: NSNumber?
    @NSManaged public var includeResolvedIssues: NSNumber?
    @NSManaged public var weeklyScheduleDay: NSNumber?
    @NSManaged public var minutesAfterHour: NSNumber?
    @NSManaged public var hour: NSNumber?
    @NSManaged public var trigger: Trigger?
    
}
