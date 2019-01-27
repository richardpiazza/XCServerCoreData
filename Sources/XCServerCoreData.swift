import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class XCServerCoreData {
    
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
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
        
        container.loadPersistentStores { (_, error) in
            if let e = error {
                fatalError(e.localizedDescription)
            }
            
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
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
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.ping { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value:
                Log.debug("Pinged Server '\(xcodeServer.fqdn)'")
                completion(nil)
            }
        }
    }
    
    /// Retreive the version information about the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncVersionData(forXcodeServer xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.versions { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Version Data for Server '\(xcodeServer.fqdn)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let server = privateContext.object(with: xcodeServer.objectID) as? XcodeServer {
                        server.update(withVersion: value.0)
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
    }
    
    /// Retrieves all `Bot`s from the `XcodeServer`
    /// Updates the supplied `XcodeServer` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncBots(forXcodeServer xcodeServer: XcodeServer, completion: @escaping XCServerCoreDataCompletion) {
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.bots { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Bots for Server '\(xcodeServer.fqdn)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let server = privateContext.object(with: xcodeServer.objectID) as? XcodeServer {
                        server.update(withBots: value)
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
    }
    
    /// Retrieves the information for a given `Bot` from the `XcodeServer`.
    /// Updates the supplied `Bot` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncBot(bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.bot(withIdentifier: bot.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Bot '\(bot.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let b = privateContext.object(with: bot.objectID) as? Bot {
                        b.update(withBot: value)
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
    }
    
    /// Gets the cumulative integration stats for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncStats(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.stats(forBotWithIdentifier: bot.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Stats for Bot '\(bot.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let b = privateContext.object(with: bot.objectID) as? Bot {
                        b.stats?.update(withStats: value)
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
    
    /// Begin a new integration for the specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func triggerIntegration(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.runIntegration(forBotWithIdentifier: bot.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Triggered Integration for Bot '\(bot.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let b = privateContext.object(with: bot.objectID) as? Bot {
                        b.update(withIntegrations: [value])
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
    }
    
    /// Gets a list of `Integration` for a specified `Bot`.
    /// Updates the supplied `Bot` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncIntegrations(forBot bot: Bot, completion: @escaping XCServerCoreDataCompletion) {
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.integrations(forBotWithIdentifier: bot.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Integrations for Bot '\(bot.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let b = privateContext.object(with: bot.objectID) as? Bot {
                        b.update(withIntegrations: value)
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
    }
    
    /// Gets a single `Integration` from the `XcodeServer`.
    /// Updates the supplied `Integration` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncIntegration(integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let bot = integration.bot else {
            completion(Errors.bot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.integration(withIdentifier: integration.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Integration '\(integration.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let i = privateContext.object(with: integration.objectID) as? Integration {
                        i.update(withIntegration: value)
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
    }
    
    /// Retrieves the `Repository` commits for a specified `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncCommits(forIntegration integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let bot = integration.bot else {
            completion(Errors.bot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.commits(forIntegrationWithIdentifier: integration.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Commits for Integration '\(integration.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    let repositories = privateContext.repositories()
                    let privateContextIntegration = privateContext.object(with: integration.objectID) as? Integration
                    
                    for repository in repositories {
                        repository.update(withIntegrationCommits: value, integration: privateContextIntegration)
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
    }
    
    /// Retrieves `Issue` related to a given `Integration`.
    /// Updates the supplied `Integration` entity with the response.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static func syncIssues(forIntegration integration: Integration, completion: @escaping XCServerCoreDataCompletion) {
        guard let bot = integration.bot else {
            completion(Errors.bot)
            return
        }
        
        guard let xcodeServer = bot.xcodeServer else {
            completion(Errors.xcodeServer)
            return
        }
        
        let client: XCServerClient
        do {
            client = try XCServerClient.client(forFQDN: xcodeServer.fqdn)
        } catch {
            completion(error)
            return
        }
        
        client.issues(forIntegrationWithIdentifier: integration.identifier) { (result) in
            switch result {
            case .error(let error):
                completion(error)
            case .value(let value):
                Log.debug("Retrieved Issues for Integration '\(integration.identifier)'")
                sharedInstance.performBackgroundTask({ (privateContext) in
                    privateContext.automaticallyMergesChangesFromParent = true
                    
                    if let i = privateContext.object(with: integration.objectID) as? Integration {
                        i.issues?.update(withIntegrationIssues: value)
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
}
