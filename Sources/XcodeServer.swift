//===----------------------------------------------------------------------===//
//
// XcodeServer.swift
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

/// An `XcodeServer` is one of the root elements in the object graph.
/// This represents a single Xcode Server, uniquely identified by its
/// FQDN (Fully Qualified Domain Name).
public class XcodeServer: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, fqdn: String) {
        self.init(managedObjectContext: managedObjectContext)
        self.fqdn = fqdn
        
        Logger.info("Created `XcodeServer` entity with FQDN '\(fqdn)'", callingClass: self.dynamicType)
    }
    
    func update(withVersion version: VersionJSON) {
        self.os = version.os
        self.server = version.server
        self.xcodeServer = version.xcodeServer
        self.xcode = version.xcode
    }
    
    func update(withBots data: [BotJSON]) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        guard let bots = self.bots else {
            return
        }
        
        var ids: [String] = bots.map({ $0.identifier })
        
        for element in data {
            if let index = ids.indexOf(element._id) {
                ids.removeAtIndex(index)
            }
            
            if let bot = moc.bot(withIdentifier: element._id) {
                bot.update(withBot: element)
                continue
            }
            
            if let bot = Bot(managedObjectContext: moc, identifier: element._id, server: self) {
                bot.update(withBot: element)
            }
        }
        
        for id in ids {
            if let bot = moc.bot(withIdentifier: id) {
                bot.xcodeServer = nil
                moc.deleteObject(bot)
            }
        }
    }
    
    /// The root API URL for this `XcodeServer`.
    /// Apple by default requires the HTTPS scheme and port 20343.
    public var apiURL: NSURL? {
        return NSURL(string: "https://\(self.fqdn):20343/api")
    }
}
