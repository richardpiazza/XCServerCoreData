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

class Bot: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, server: XcodeServer) {
        self.init(managedObjectContext: managedObjectContext)
        self.xcodeServer = server
        self.integrations = Set<Integration>()
        self.configuration = Configuration(managedObjectContext: managedObjectContext, bot: self)
        self.stats = Stats(managedObjectContext: managedObjectContext, bot: self)
    }
    
    func update(withBot bot: BotJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        self.identifier = bot._id
        self.name = bot.name
        self.type = bot.type
        
        if let configuration = bot.configuration {
            self.configuration?.update(withConfiguration: configuration)
        }
        
        if let integrationsSet = self.integrations as? Set<Integration> {
            var integrations = integrationsSet
            
            for item in bot.integrations {
                if let existing = self.integration(withIdentifier: item._id) {
                    existing.update(withIntegration: item)
                } else {
                    if let integration = Integration(managedObjectContext: moc, bot: self) {
                        integration.update(withIntegration: item)
                        integrations.insert(integration)
                    }
                }
            }
        }
        
        if let blueprint = bot.lastRevisionBlueprint {
            if let remoteRepositories = blueprint.DVTSourceControlWorkspaceBlueprintRemoteRepositoriesKey {
                for remoteRepository in remoteRepositories {
                    if let identifier = remoteRepository.DVTSourceControlWorkspaceBlueprintRemoteRepositoryIdentifierKey {
                        let _ = moc.repository(withIdentifier: identifier)
                        moc.update(withRevisionBlueprint: blueprint)
                    }
                }
            }
        }
    }
    
    func integration(withIdentifier identifier: String) -> Integration? {
        guard let integrations = self.integrations as? Set<Integration> else {
            return nil
        }
        
        let results = integrations.filter({ (integration: Integration) -> Bool in return integration.identifier == identifier })
        
        guard let integration = results.first else {
            return nil
        }
        
        return integration
    }
}
