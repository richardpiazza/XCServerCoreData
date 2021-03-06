import Foundation
import CoreData
import CodeQuickKit

/// Extension to `NSManagedObjectContext` that has typed `NSFetchRequest` specific
/// to XCServerCoreData
public extension NSManagedObjectContext {
    
    // MARK: - XcodeServer -
    
    /// Retrieves all `XcodeServer` entities from the Core Data `NSManagedObjectContext`
    public func xcodeServers() -> [XcodeServer] {
        let fetchRequest = NSFetchRequest<XcodeServer>(entityName: XcodeServer.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `XcodeServer` entity from the Core Data `NSManagedObjectContext`
    /// that matches the specified FQDN identifier.
    public func xcodeServer(withFQDN identifier: String) -> XcodeServer? {
        let fetchRequest = NSFetchRequest<XcodeServer>(entityName: XcodeServer.entityName)
        fetchRequest.predicate = NSPredicate(format: "fqdn = %@", argumentArray: [identifier])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
    
    // MARK: - Bot -
    
    /// Retrieves all `Bot` entities from the Core Data `NSManagedObjectContext`
    public func bots() -> [Bot] {
        let fetchRequest = NSFetchRequest<Bot>(entityName: Bot.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `Bot` entity from the Core Data `NSManagedObjectContext`
    /// that matches the specified identifier.
    public func bot(withIdentifier identifier: String) -> Bot? {
        let fetchRequest = NSFetchRequest<Bot>(entityName: Bot.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
    
    // MARK: - Integration -
    
    /// Retrieves all `Integration` entities from the Core Data `NSManagedObjectContext`
    public func integrations() -> [Integration] {
        let fetchRequest = NSFetchRequest<Integration>(entityName: Integration.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `Integration` entity from the Core Data `NSManagedObjectContext`
    /// that matches the specified identifier.
    public func integration(withIdentifier identifier: String) -> Integration? {
        let fetchRequest = NSFetchRequest<Integration>(entityName: Integration.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
    
    // MARK: - Repository -
    
    /// Retrieves all `Repository` entities from the Core Data `NSManagedObjectContext`
    public func repositories() -> [Repository] {
        let fetchRequest = NSFetchRequest<Repository>(entityName: Repository.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `Repository` entity from the Core Data `NSManagedObjectContext`
    /// that matches the specified identifier.
    public func repository(withIdentifier identifier: String) -> Repository? {
        let fetchRequest = NSFetchRequest<Repository>(entityName: Repository.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
    
    // MARK: - Commit -
    
    /// Retrieves all `Commit` entities from the Core Data `NSManagedObjectContext`
    public func commits() -> [Commit] {
        let fetchRequest = NSFetchRequest<Commit>(entityName: Commit.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `Commit` entity from the Core Data `NSManagedObjectContext`
    /// that matches the specified Hash identifier.
    public func commit(withHash identifier: String) -> Commit? {
        let fetchRequest = NSFetchRequest<Commit>(entityName: Commit.entityName)
        fetchRequest.predicate = NSPredicate(format: "commitHash = %@", argumentArray: [identifier])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
    
    // MARK: - Device -
    
    /// Retrieves all `Device` entities from the Core Data `NSManagedObjectContext`
    public func devices() -> [Device] {
        let fetchRequest = NSFetchRequest<Device>(entityName: Device.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `Device` entity from the Core Data `NSManagedObjectContext`
    /// that matches the specified identifier.
    public func device(withIdentifier identifier: String) -> Device? {
        let fetchRequest = NSFetchRequest<Device>(entityName: Device.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
    
    // MARK: - Revision Blueprints -
    
    /// Retrieves all `RevisionBlueprint` entities from the Core Data `NSManagedObjectContext`
    public func revisionBlueprints() -> [RevisionBlueprint] {
        let fetchRequest = NSFetchRequest<RevisionBlueprint>(entityName: RevisionBlueprint.entityName)
        do {
            return try self.fetch(fetchRequest)
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return []
    }
    
    /// Retrieves the first `RevisionBlueprint` entity from the Core Data `NSManagedObjectContext`
    /// that has a specific `Commit` and `Integration` associated with it.
    public func revisionBlueprint(withCommit commit: Commit, andIntegration integration: Integration) -> RevisionBlueprint? {
        let fetchRequest = NSFetchRequest<RevisionBlueprint>(entityName: RevisionBlueprint.entityName)
        fetchRequest.predicate = NSPredicate(format: "commit = %@ AND integration = %@", argumentArray: [commit, integration])
        do {
            let results = try self.fetch(fetchRequest)
            if let result = results.first {
                return result
            }
        } catch {
            Log.error(error, message: "\(#function)")
        }
        
        return nil
    }
}
