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

extension NSManagedObjectContext {
    // MARK: XcodeServer
    func xcodeServer(withFQDN: String) -> XcodeServer? {
        let fetchRequest = NSFetchRequest(entityName: XcodeServer.entityName)
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
    func bot(withIdentifier: String) -> Bot? {
        let fetchRequest = NSFetchRequest(entityName: Bot.entityName)
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
    func integration(withIdentifier: String) -> Integration? {
        let fetchRequest = NSFetchRequest(entityName: Integration.entityName)
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
    func repository(withIdentifier: String) -> Repository? {
        let fetchRequest = NSFetchRequest(entityName: Repository.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Repository], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
    
    func updateRepositories(withBlueprint blueprint: RevisionBlueprintJSON?) {
        guard let blueprint = blueprint else {
            return
        }
        
        
    }
    
    // MARK: Commit
    func commit(withHash: String) -> Commit? {
        let fetchRequest = NSFetchRequest(entityName: Commit.entityName)
        do {
            if let results = try self.executeFetchRequest(fetchRequest) as? [Commit], result = results.first {
                return result
            }
        } catch {
            Logger.error(error as NSError, message: "\(#function)", callingClass: self.dynamicType)
        }
        
        return nil
    }
}
