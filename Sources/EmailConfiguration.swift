//===----------------------------------------------------------------------===//
//
// EmailConfiguration.swift
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

public class EmailConfiguration: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, trigger: Trigger) {
        self.init(managedObjectContext: managedObjectContext)
        self.trigger = trigger
    }
    
    internal func update(withEmailConfiguration configuration: XCSEmailConfiguration) {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            if let ccas = configuration.ccAddresses {
                do {
                    self.ccAddressesData = try XCServerCoreData.jsonEncoder.encode(ccas)
                } catch {
                    Log.error(error, message: "Failed to encode EmailConfiguration ccAddresses")
                }
            }
            if let adn = configuration.allowedDomainNames {
                do {
                    self.allowedDomainNamesData = try XCServerCoreData.jsonEncoder.encode(adn)
                } catch {
                    Log.error(error, message: "Failed to encode EmailConfiguration allowedDomainNames")
                }
            }
        }
        
        self.includeCommitMessages = configuration.includeCommitMessages as NSNumber?
        self.includeLogs = configuration.includeLogs as NSNumber?
        self.replyToAddress = configuration.replyToAddress
        self.includeIssueDetails = configuration.includeIssueDetails as NSNumber?
        self.includeBotConfiguration = configuration.includeBotConfiguration as NSNumber?
        self.additionalRecipients = configuration.additionalRecipients?.joined(separator: ",")
        self.emailComitters = configuration.emailCommitters as NSNumber?
        self.fromAddress = configuration.fromAddress
        self.emailTypeRawValue = configuration.type?.rawValue as NSNumber?
        self.includeResolvedIssues = configuration.includeResolvedIssues as NSNumber?
        self.weeklyScheduleDay = configuration.weeklyScheduleDay as NSNumber?
        self.minutesAfterHour = configuration.minutesAfterHour as NSNumber?
        self.hour = configuration.hour as NSNumber?
    }
}
