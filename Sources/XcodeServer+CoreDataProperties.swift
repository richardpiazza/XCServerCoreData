//===----------------------------------------------------------------------===//
//
// XcodeServer+CoreDataProperties.swift
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

extension XcodeServer {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<XcodeServer> {
        return NSFetchRequest<XcodeServer>(entityName: "XcodeServer")
    }
    
    @NSManaged public var fqdn: String
    @NSManaged public var lastUpdate: Date?
    @NSManaged public var os: String?
    @NSManaged public var server: String?
    @NSManaged public var xcode: String?
    @NSManaged public var xcodeServer: String?
    @NSManaged public var apiVersion: NSNumber?
    @NSManaged public var bots: Set<Bot>?
    
}

// MARK: Generated accessors for bots
extension XcodeServer {
    
    @objc(addBotsObject:)
    @NSManaged public func addToBots(_ value: Bot)
    
    @objc(removeBotsObject:)
    @NSManaged public func removeFromBots(_ value: Bot)
    
    @objc(addBots:)
    @NSManaged public func addToBots(_ values: Set<Bot>)
    
    @objc(removeBots:)
    @NSManaged public func removeFromBots(_ values: Set<Bot>)
    
}
