//===----------------------------------------------------------------------===//
//
// NSManagedObjectContext+XCServerCoreData.swift
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

public extension NSManagedObjectContext {
    
    // MARK: XcodeServer
    public func xcodeServers() -> [XcodeServer] {
        let fetchRequest = NSFetchRequest(entityName: XcodeServer.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [XcodeServer] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func xcodeServer(withFQDN identifier: String) -> XcodeServer? {
        let fetchRequest = NSFetchRequest(entityName: XcodeServer.entityName)
        fetchRequest.predicate = NSPredicate(format: "fqdn = %@", argumentArray: [identifier])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [XcodeServer], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    // MARK: Bot
    public func bots() -> [Bot] {
        let fetchRequest = NSFetchRequest(entityName: Bot.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Bot] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func bot(withIdentifier identifier: String) -> Bot? {
        let fetchRequest = NSFetchRequest(entityName: Bot.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Bot], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    // MARK: Integration
    public func integrations() -> [Integration] {
        let fetchRequest = NSFetchRequest(entityName: Integration.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Integration] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func integration(withIdentifier identifier: String) -> Integration? {
        let fetchRequest = NSFetchRequest(entityName: Integration.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Integration], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    // MARK: Repository
    public func repositories() -> [Repository] {
        let fetchRequest = NSFetchRequest(entityName: Repository.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Repository] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func repository(withIdentifier identifier: String) -> Repository? {
        let fetchRequest = NSFetchRequest(entityName: Repository.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Repository], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    // MARK: Commit
    public func commits() -> [Commit] {
        let fetchRequest = NSFetchRequest(entityName: Commit.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Commit] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func commit(withHash identifier: String) -> Commit? {
        let fetchRequest = NSFetchRequest(entityName: Commit.entityName)
        fetchRequest.predicate = NSPredicate(format: "commitHash = %@", argumentArray: [identifier])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Commit], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    // MARK: Device
    public func devices() -> [Device] {
        let fetchRequest = NSFetchRequest(entityName: Device.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Device] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func device(withIdentifier identifier: String) -> Device? {
        let fetchRequest = NSFetchRequest(entityName: Device.entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Device], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    // MARK: Revision Blueprints
    public func revisionBlueprints() -> [RevisionBlueprint] {
        let fetchRequest = NSFetchRequest(entityName: RevisionBlueprint.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [RevisionBlueprint] {
                return results
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return []
    }
    
    public func revisionBlueprint(withCommit commit: Commit, andIntegration integration: Integration) -> RevisionBlueprint? {
        let fetchRequest = NSFetchRequest(entityName: RevisionBlueprint.entityName)
        fetchRequest.predicate = NSPredicate(format: "commit = %@ AND integration = %@", argumentArray: [commit, integration])
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [RevisionBlueprint], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
}
