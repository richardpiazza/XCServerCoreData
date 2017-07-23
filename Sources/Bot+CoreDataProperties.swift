//===----------------------------------------------------------------------===//
//
// Bot+CoreDataProperties.swift
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

public extension Bot {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bot> {
        return NSFetchRequest<Bot>(entityName: "Bot")
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var lastUpdate: Date?
    @NSManaged public var name: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var revision: String?
    @NSManaged public var configuration: Configuration?
    @NSManaged public var integrations: Set<Integration>?
    @NSManaged public var stats: Stats?
    @NSManaged public var xcodeServer: XcodeServer?
    
}

// MARK: Generated accessors for integrations
extension Bot {
    
    @objc(addIntegrationsObject:)
    @NSManaged public func addToIntegrations(_ value: Integration)
    
    @objc(removeIntegrationsObject:)
    @NSManaged public func removeFromIntegrations(_ value: Integration)
    
    @objc(addIntegrations:)
    @NSManaged public func addToIntegrations(_ values: Set<Integration>)
    
    @objc(removeIntegrations:)
    @NSManaged public func removeFromIntegrations(_ values: Set<Integration>)
    
}
