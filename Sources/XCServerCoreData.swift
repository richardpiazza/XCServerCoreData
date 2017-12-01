import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class XCServerCoreData {
    
    public static var sharedInstance: NSPersistentContainer = {
        let bundle = Bundle(for: XCServerCoreData.self)
        guard let modelURL = bundle.url(forResource: "XCServerCoreData", withExtension: "momd") else {
            fatalError("Failed to locate XCServerCoreData.momd")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load XCServerCoreData Model")
        }
        var storeURL: URL
        do {
            var searchPathDirectory: FileManager.SearchPathDirectory
            #if os(tvOS)
                searchPathDirectory = .cachesDirectory
            #else
                searchPathDirectory = .documentDirectory
            #endif
            storeURL = try FileManager.default.url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("XCServerCoreData.sqlite")
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
        
        let container = NSPersistentContainer(name: "XCServerCoreData", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.loadPersistentStores { (_, error) in
            if let e = error {
                fatalError(e.localizedDescription)
            }
        }
        
        return container
    }()
    
    public enum Errors: Error, LocalizedError {
        case unhandled
        case response
        case managedObjectContext
        case xcodeServer
        case bot
        case repository
        
        public var errorDescription: String? {
            switch self {
            case .unhandled: return "An unknown error occured."
            case .response: return "The API response was unexpectedly nil."
            case .managedObjectContext: return "The parameter entity has an invalid NSManagedObjectContext."
            case .xcodeServer: return "An Xcode Server could not be identified for the supplied parameter entity."
            case .bot: return "A Bot could not be identified for the supplied parameter entity."
            case .repository: return "A Repository could not be identified for the supplied parameter entity."
            }
        }
    }
    
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
    
    public static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }
    
    public static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
    public typealias XCServerCoreDataCompletion = (_ error: Error?) -> Void
    
    /// Ping the Xcode Server.
    /// A Status code of '204' indicates success.
    public static func ping(xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.ping { (statusCode, headers, data, error) in
            guard statusCode == 204 else {
                if let e = error {
                    completion(e)
                } else {
                    completion(Errors.unhandled)
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
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.versions { (version, apiVersion, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let version = version else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Version Data for Server '\(xcodeServer.fqdn)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let server = privateContext.object(with: xcodeServer.objectID) as? XcodeServer {
                    server.update(withVersion: version)
                    server.lastUpdate = Date()
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Retrieves all `Bot`s from the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    public static func syncBots(forXcodeServer xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.bots { (bots, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let bots = bots else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Bots for Server '\(xcodeServer.fqdn)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let server = privateContext.object(with: xcodeServer.objectID) as? XcodeServer {
                    server.update(withBots: bots)
                    server.lastUpdate = Date()
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Retrieves the information for a given `Bot` from the `XcodeServer`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncBot(bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.bot(withIdentifier: bot.identifier) { (responseBot, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let responseBot = responseBot else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Bot '\(bot.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.update(withBot: responseBot)
                    b.lastUpdate = Date()
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Gets the cumulative integration stats for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncStats(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.stats(forBotWithIdentifier: bot.identifier) { (stats, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let stats = stats else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Stats for Bot '\(bot.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.stats?.update(withStats: stats)
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Begin a new integration for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func triggerIntegration(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.runIntegration(forBotWithIdentifier: bot.identifier) { (integration, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let integration = integration else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Triggered Integration for Bot '\(bot.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.update(withIntegrations: [integration])
                    b.lastUpdate = Date()
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Gets a list of `Integration` for a specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    public static func syncIntegrations(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.integrations(forBotWithIdentifier: bot.identifier) { (integrations, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let integrations = integrations else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Integrations for Bot '\(bot.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let b = privateContext.object(with: bot.objectID) as? Bot {
                    b.update(withIntegrations: integrations)
                    b.lastUpdate = Date()
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Gets a single `Integration` from the `XcodeServer`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncIntegration(integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let bot = integration.bot else {
            completion(Errors.bot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.integration(withIdentifier: integration.identifier) { (responseIntegration, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let responseIntegration = responseIntegration else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Integration '\(integration.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let i = privateContext.object(with: integration.objectID) as? Integration {
                    i.update(withIntegration: responseIntegration)
                    i.lastUpdate = Date()
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Retrieves the `Repository` commits for a specified `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncCommits(forIntegration integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let bot = integration.bot else {
            completion(Errors.bot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.commits(forIntegrationWithIdentifier: integration.identifier) { (commits, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let commits = commits else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Commits for Integration '\(integration.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                let repositories = privateContext.repositories()
                let privateContextIntegration = privateContext.object(with: integration.objectID) as? Integration
                
                for repository in repositories {
                    repository.update(withIntegrationCommits: commits, integration: privateContextIntegration)
                }
                
                privateContextIntegration?.hasRetrievedCommits = true
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    /// Retrieves `Issue` related to a given `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    public static func syncIssues(forIntegration integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let bot = integration.bot else {
            completion(Errors.bot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let api = XCServerWebAPI.api(forFQDN: xcodeServer.fqdn)
        api.issues(forIntegrationWithIdentifier: integration.identifier) { (issues, error) in
            if let e = error {
                completion(e)
                return
            }
            
            guard let issues = issues else {
                completion(Errors.response)
                return
            }
            
            Log.debug("Retrieved Issues for Integration '\(integration.identifier)'")
            sharedInstance.performBackgroundTask({ (privateContext) in
                privateContext.automaticallyMergesChangesFromParent = true
                
                if let i = privateContext.object(with: integration.objectID) as? Integration {
                    i.issues?.update(withIntegrationIssues: issues)
                    i.hasRetrievedIssues = true
                }
                
                do {
                    try privateContext.save()
                } catch {
                    completion(error)
                    return
                }
                
                completion(nil)
            })
        }
    }
}
