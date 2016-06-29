//===----------------------------------------------------------------------===//
//
// XCServerCoreData.swift
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

public class XCServerCoreData: CoreData {
    
    private struct Config: CoreDataConfiguration {
        var applicationDocumentsDirectory: NSURL = {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            return urls[urls.count-1]
        }()
        
        var persistentStoreType: StoreType {
            return .SQLite
        }
        
        var persistentStoreURL: NSURL {
            return applicationDocumentsDirectory.URLByAppendingPathComponent("XCServerCoreData.sqlite")
        }
        
        var persistentStoreOptions: [String : AnyObject] {
            return [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        }
    }
    
    public convenience init?() {
        self.init(fromBundle: NSBundle(forClass: XCServerCoreData.self), modelName: "XCServerCoreData", delegate: Config())
    }
    
    public static var sharedInstance: XCServerCoreData {
        guard let instance = XCServerCoreData() else {
            fatalError()
        }
        
        return instance
    }
    
    public typealias XCServerCoreDataCompletion = (error: NSError?) -> Void
    
    private static let unhandledError = NSError(domain: String(XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Unhandled Error",
        NSLocalizedFailureReasonErrorKey : "An unknown error occured.",
        NSLocalizedRecoverySuggestionErrorKey : "Attempt your request again."
        ])
    
    private static let invalidResponse = NSError(domain: String(XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Response",
        NSLocalizedFailureReasonErrorKey : "The API response was unexpectedly nil.",
        NSLocalizedRecoverySuggestionErrorKey : "Please try your request again."
        ])
    
    private static let invalidManagedObjectContext = NSError(domain: String(XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid NSManagedObjectContext",
        NSLocalizedFailureReasonErrorKey : "The parameter entity has an invalid NSManagedObjectContext.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    private static let invalidXcodeServer = NSError(domain: String(XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Xcode Server",
        NSLocalizedFailureReasonErrorKey : "An Xcode Server could not be identified for the supplied parameter entity.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    private static let invalidBot = NSError(domain: String(XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Bot",
        NSLocalizedFailureReasonErrorKey : "A Bot could not be identified for the supplied parameter entity.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    private static let invalidRepository = NSError(domain: String(XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Repository",
        NSLocalizedFailureReasonErrorKey : "A Repository could not be identified for the supplied parameter entity.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    /// Ping the Xcode Server.
    /// A Status code of '204' indicates success.
    public static func ping(xcodeServer xcodeServer: XcodeServer, completion: XCServerCoreDataCompletion) {
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getPing { (statusCode, response, responseObject, error) in
            guard statusCode == 204 else {
                if let e = error {
                    completion(error: e)
                } else {
                    completion(error: self.unhandledError)
                }
                return
            }
            
            completion(error: nil)
        }
    }
    
    /// Retreive the version information about the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    public static func syncVersionData(forXcodeServer xcodeServer: XcodeServer, completion: XCServerCoreDataCompletion) {
        guard let moc = xcodeServer.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getVersion { (version, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let version = version else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                xcodeServer.update(withVersion: version)
                xcodeServer.lastUpdate = NSDate()
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Retrieves all `Bot`s from the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    public static func syncBots(forXcodeServer xcodeServer: XcodeServer, completion: XCServerCoreDataCompletion) {
        guard let moc = xcodeServer.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getBots { (bots, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let bots = bots else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                xcodeServer.update(withBots: bots)
                xcodeServer.lastUpdate = NSDate()
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Retrieves the information for a given `Bot` from the `XcodeServer`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncBot(bot bot: Bot, completion: XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getBot(bot) { (responseBot, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let responseBot = responseBot else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                bot.update(withBot: responseBot)
                bot.lastUpdate = NSDate()
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Gets the cumulative integration stats for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncStats(forBot bot: Bot, completion: XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getStats(forBot: bot) { (stats, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let stats = stats else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                bot.stats?.update(withStats: stats)
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Begin a new integration for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func triggerIntegration(forBot bot: Bot, completion: XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.postBot(forBot: bot) { (integration, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let integration = integration else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                bot.update(withIntegrations: [integration])
                bot.lastUpdate = NSDate()
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Gets a list of `Integration` for a specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncIntegrations(forBot bot: Bot, completion: XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getIntegrations(forBot: bot) { (integrations, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let integrations = integrations else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                bot.update(withIntegrations: integrations)
                bot.lastUpdate = NSDate()
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Gets a single `Integration` from the `XcodeServer`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncIntegration(integration integration: Integration, completion: XCServerCoreDataCompletion) {
        guard let moc = integration.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let bot = integration.bot else {
            completion(error: self.invalidBot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getIntegration(integration) { (responseIntegration, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let responseIntegration = responseIntegration else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                integration.update(withIntegration: responseIntegration)
                integration.lastUpdate = NSDate()
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Retrieves the `Repository` commits for a specified `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncCommits(forIntegration integration: Integration, completion: XCServerCoreDataCompletion) {
        guard let moc = integration.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let bot = integration.bot else {
            completion(error: self.invalidBot)
            return
        }
        
        guard let repositories = bot.configuration?.repositories else {
            completion(error: self.invalidRepository)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getCommits(forIntegration: integration) { (commits, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let commits = commits else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                for repository in repositories {
                    repository.update(withIntegrationCommits: commits)
                }
                
                integration.hasRetrievedCommits = true
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
    
    /// Retrieves `Issue` related to a given `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncIssues(forIntegration integration: Integration, completion: XCServerCoreDataCompletion) {
        guard let moc = integration.managedObjectContext else {
            completion(error: self.invalidManagedObjectContext)
            return
        }
        
        guard let bot = integration.bot else {
            completion(error: self.invalidBot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(error: self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forServer: xcodeServer)
        api.getIssues(forIntegration: integration) { (issues, error) in
            if let e = error {
                completion(error: e)
                return
            }
            
            guard let issues = issues else {
                completion(error: self.invalidResponse)
                return
            }
            
            var e = error
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = moc
            
            moc.registerForDidSaveNotification(privateContext: privateContext)
            
            privateContext.performBlockAndWait({
                integration.issues?.update(withIntegrationIssues: issues)
                integration.hasRetrievedIssues = true
                
                do {
                    try privateContext.save()
                } catch {
                    e = error as NSError
                }
            })
            
            moc.unregisterFromDidSaveNotification(privateContext: privateContext)
            
            completion(error: e)
        }
    }
}
