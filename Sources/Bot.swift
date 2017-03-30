//===----------------------------------------------------------------------===//
//
// Bot.swift
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

/// ## Bot
/// Represents an Xcode Server Bot.
/// "Bots are processes that Xcode Server runs to perform integrations on the current version of a project in a source code repository."
public class Bot: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String, server: XcodeServer) {
        self.init(managedObjectContext: managedObjectContext)
        self.identifier = identifier
        self.xcodeServer = server
        self.integrations = Set<Integration>()
        self.configuration = Configuration(managedObjectContext: managedObjectContext, bot: self)
        self.stats = Stats(managedObjectContext: managedObjectContext, bot: self)
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "xcodeServer":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    internal func update(withBot bot: BotJSON) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        self.name = bot.name
        self.type = bot.type as NSNumber?
        
        if let configuration = bot.configuration {
            self.configuration?.update(withConfiguration: configuration)
        }
        
        self.update(withIntegrations: bot.integrations)
        
        if let blueprint = bot.lastRevisionBlueprint {
            for id in blueprint.repositoryIds {
                if let repository = moc.repository(withIdentifier: id) {
                    repository.update(withRevisionBlueprint: blueprint)
                    continue
                }
                if let repository = Repository(managedObjectContext: moc, identifier: id) {
                    repository.update(withRevisionBlueprint: blueprint)
                }
            }
        }
    }
    
    internal func update(withIntegrations integrations: [IntegrationJSON]) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        for element in integrations {
            if let integration = moc.integration(withIdentifier: element._id) {
                integration.update(withIntegration: element)
                continue
            }
            
            if let integration = Integration(managedObjectContext: moc, identifier: element._id, bot: self) {
                integration.update(withIntegration: element)
            }
        }
    }
}
