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
import XCServerAPI

public class XCServerCoreData: CoreData {
    
    fileprivate struct Configuration {
        var directory: URL {
            var urls: [URL]
            #if os(tvOS)
                urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            #else
                urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            #endif
            
            guard let url = urls.last else {
                fatalError("Could not find url for storage directory.")
            }
            
            return url
        }
        
        var config: PersistentStoreConfiguration {
            var config = PersistentStoreConfiguration()
            config.storeType = .sqlite
            config.url = directory.appendingPathComponent("XCServerCoreData.sqlite")
            config.options = [NSMigratePersistentStoresAutomaticallyOption : true as AnyObject, NSInferMappingModelAutomaticallyOption : true as AnyObject]
            return config
        }
    }
    
    fileprivate static let config = Configuration()
    
    public convenience init() {
        self.init(fromBundle: Bundle(for: XCServerCoreData.self), modelName: "XCServerCoreData", configuration: XCServerCoreData.config.config)
    }
    
    public static var sharedInstance = XCServerCoreData()
    
    public typealias XCServerCoreDataCompletion = (_ error: NSError?) -> Void
    
    fileprivate static let unhandledError = NSError(domain: String(describing: XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Unhandled Error",
        NSLocalizedFailureReasonErrorKey : "An unknown error occured.",
        NSLocalizedRecoverySuggestionErrorKey : "Attempt your request again."
        ])
    
    fileprivate static let invalidResponse = NSError(domain: String(describing: XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Response",
        NSLocalizedFailureReasonErrorKey : "The API response was unexpectedly nil.",
        NSLocalizedRecoverySuggestionErrorKey : "Please try your request again."
        ])
    
    fileprivate static let invalidManagedObjectContext = NSError(domain: String(describing: XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid NSManagedObjectContext",
        NSLocalizedFailureReasonErrorKey : "The parameter entity has an invalid NSManagedObjectContext.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    fileprivate static let invalidXcodeServer = NSError(domain: String(describing: XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Xcode Server",
        NSLocalizedFailureReasonErrorKey : "An Xcode Server could not be identified for the supplied parameter entity.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    fileprivate static let invalidBot = NSError(domain: String(describing: XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Bot",
        NSLocalizedFailureReasonErrorKey : "A Bot could not be identified for the supplied parameter entity.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    fileprivate static let invalidRepository = NSError(domain: String(describing: XCServerCoreData.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey : "Invalid Repository",
        NSLocalizedFailureReasonErrorKey : "A Repository could not be identified for the supplied parameter entity.",
        NSLocalizedRecoverySuggestionErrorKey : "Retry the request with a valid entity."
        ])
    
    /// Ping the Xcode Server.
    /// A Status code of '204' indicates success.
    public static func ping(xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getPing { (statusCode, response, responseObject, error) in
            guard statusCode == 204 else {
                if let e = error {
                    completion(e)
                } else {
                    completion(self.unhandledError)
                }
                return
            }
            
            Log.debug("Pinged Server '\(xcodeServer.fqdn)'")
            
            completion(nil)
        }
    }
    
    /// Retreive the version information about the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    public static func syncVersionData(forXcodeServer xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = xcodeServer.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getVersion { (version, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let version = version else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Version Data for Server '\(xcodeServer.fqdn)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let server = privateContext.object(with: xcodeServer.objectID) as? XcodeServer {
                    server.update(withVersion: version)
                    server.lastUpdate = Date()
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Retrieves all `Bot`s from the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    public static func syncBots(forXcodeServer xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = xcodeServer.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getBots { (bots, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let bots = bots else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Bots for Server '\(xcodeServer.fqdn)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let server = privateContext.object(with: xcodeServer.objectID) as? XcodeServer {
                    server.update(withBots: bots)
                    server.lastUpdate = Date()
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Retrieves the information for a given `Bot` from the `XcodeServer`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncBot(bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getBot(bot: bot.identifier) { (responseBot, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let responseBot = responseBot else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Bot '\(bot.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.update(withBot: responseBot)
                    b.lastUpdate = Date()
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Gets the cumulative integration stats for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncStats(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getStats(forBot: bot.identifier) { (stats, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let stats = stats else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Stats for Bot '\(bot.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.stats?.update(withStats: stats)
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Begin a new integration for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func triggerIntegration(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.postBot(forBot: bot.identifier) { (integration, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let integration = integration else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Triggered Integration for Bot '\(bot.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.update(withIntegrations: [integration])
                    b.lastUpdate = Date()
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Gets a list of `Integration` for a specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncIntegrations(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = bot.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getIntegrations(forBot: bot.identifier) { (integrations, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let integrations = integrations else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Integrations for Bot '\(bot.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.update(withIntegrations: integrations)
                    b.lastUpdate = Date()
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Gets a single `Integration` from the `XcodeServer`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncIntegration(integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = integration.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let bot = integration.bot else {
            completion(self.invalidBot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getIntegration(integration: integration.identifier) { (responseIntegration, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let responseIntegration = responseIntegration else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Integration '\(integration.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let i = privateContext.object(with: integration.objectID) as? Integration {
                    i.update(withIntegration: responseIntegration)
                    i.lastUpdate = Date()
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Retrieves the `Repository` commits for a specified `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncCommits(forIntegration integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = integration.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let bot = integration.bot else {
            completion(self.invalidBot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getCommits(forIntegration: integration.identifier) { (commits, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let commits = commits else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Commits for Integration '\(integration.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                let repositories = privateContext.repositories()
                let privateContextIntegration = privateContext.object(with: integration.objectID) as? Integration
                
                for repository in repositories {
                    repository.update(withIntegrationCommits: commits, integration: privateContextIntegration)
                }
                
                privateContextIntegration?.hasRetrievedCommits = true
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
    
    /// Retrieves `Issue` related to a given `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncIssues(forIntegration integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let moc = integration.managedObjectContext else {
            completion(self.invalidManagedObjectContext)
            return
        }
        
        guard let bot = integration.bot else {
            completion(self.invalidBot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(self.invalidXcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.getIssues(forIntegration: integration.identifier) { (issues, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let issues = issues else {
                completion(self.invalidResponse)
                return
            }
            
            Log.debug("Retrieved Issues for Integration '\(integration.identifier)'")
            
            moc.mergeChanges(performingBlock: { (privateContext) in
                if let i = privateContext.object(with: integration.objectID) as? Integration {
                    i.issues?.update(withIntegrationIssues: issues)
                    i.hasRetrievedIssues = true
                }
                
                }, withCompletion: { (error) in
                    completion(error)
            })
        }
    }
}
