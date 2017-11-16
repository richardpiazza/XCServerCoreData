import Foundation
import CoreData
import XCServerCoreData

class CoreDataVersions {
    
    public static var v_1_2_0 = V_1_2_0()
    public static var v_1_2_0_empty = V_1_2_0_Empty()
    public static var v_2_0_0_empty = V_2_0_0_Empty()
    
    struct V_1_2_0: CoreDataVersion {
        var resource: String = "XCServerCoreData_1.2.0"
    }
    
    struct V_1_2_0_Empty: CoreDataVersion {
        var resource: String = "XCServerCoreData_1.2.0_empty"
    }
    
    struct V_2_0_0_Empty: CoreDataVersion {
        var resource: String = "XCServerCoreData_2.0.0_empty"
    }
    
    static var documentsDirectory: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            fatalError("Failed to find documents directory")
        }
    }
    
    static var tempDirectory: URL {
        return documentsDirectory.appendingPathComponent("temp")
    }
    
    static var baseResource: String = "XCServerCoreData"
    
    static var documentsSQLite: URL {
        return documentsDirectory.appendingPathComponent(baseResource).appendingPathExtension(CoreDataExtension.sqlite.rawValue)
    }
    
    static var documentsSHM: URL {
        return documentsDirectory.appendingPathComponent(baseResource).appendingPathExtension(CoreDataExtension.shm.rawValue)
    }
    
    static var documentsWAL: URL {
        return documentsDirectory.appendingPathComponent(baseResource).appendingPathExtension(CoreDataExtension.wal.rawValue)
    }
    
    static var tempSQLite: URL {
        return tempDirectory.appendingPathComponent(baseResource).appendingPathExtension(CoreDataExtension.sqlite.rawValue)
    }
    
    static var tempSHM: URL {
        return tempDirectory.appendingPathComponent(baseResource).appendingPathExtension(CoreDataExtension.shm.rawValue)
    }
    
    static var tempWAL: URL {
        return tempDirectory.appendingPathComponent(baseResource).appendingPathExtension(CoreDataExtension.wal.rawValue)
    }
    
    static func overwriteSQL(withVersion version: CoreDataVersion) -> Bool {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: tempDirectory.path) {
            do {
                print("Creating TEMP directory")
                try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return false
            }
        }
        
        print("Clearing TEMP directory")
        do {
            if fileManager.fileExists(atPath: tempSQLite.path) {
                try fileManager.removeItem(at: tempSQLite)
            }
            if fileManager.fileExists(atPath: tempSHM.path) {
                try fileManager.removeItem(at: tempSHM)
            }
            if fileManager.fileExists(atPath: tempWAL.path) {
                try fileManager.removeItem(at: tempWAL)
            }
        } catch {
            print(error)
            return false
        }
        
        print("Copying SQL files to TEMP")
        do {
            try fileManager.copyItem(at: version.bundleSQLite, to: tempSQLite)
            try fileManager.copyItem(at: version.bundleSHM, to: tempSHM)
            try fileManager.copyItem(at: version.bundleWAL, to: tempWAL)
        } catch {
            print(error)
            return false
        }
        
        print("Overwriting SQL at url: \(documentsSQLite.path)")
        let replacementOptions = FileManager.ItemReplacementOptions()
        
        do {
            try fileManager.replaceItem(at: documentsSQLite, withItemAt: tempSQLite, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
            try fileManager.replaceItem(at: documentsSHM, withItemAt: tempSHM, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
            try fileManager.replaceItem(at: documentsWAL, withItemAt: tempWAL, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
        } catch {
            print(error)
            return false
        }
        
        return true
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    static var persistentContainer: NSPersistentContainer {
        let fileManager = FileManager.default
        
        var modelURL: URL
        
        let bundle = Bundle(for: XCSCD.self)
        if let url = bundle.url(forResource: "XCServerCoreData", withExtension: "momd") {
            modelURL = url
        } else {
            modelURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent("Tests").appendingPathComponent("XCServerCoreData.momd")
        }
        
        guard fileManager.fileExists(atPath: modelURL.path) else {
            fatalError("Failed to locate XCServerCoreData.momd\n\(modelURL.path)")
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
        
        let instance = NSPersistentContainer(name: "XCServerCoreData", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        instance.persistentStoreDescriptions = [description]
        instance.viewContext.automaticallyMergesChangesFromParent = true
        return instance
    }
}

enum CoreDataExtension: String {
    case sqlite = "sqlite"
    case shm = "sqlite-shm"
    case wal = "sqlite-wal"
}

protocol CoreDataVersion {
    var resource: String { get }
}

extension CoreDataVersion {
    func url(for res: String, extension ext: CoreDataExtension) -> URL {
        let bundle = Bundle(for: CoreDataVersions.self)
        if let url = bundle.url(forResource: res, withExtension: ext.rawValue) {
            return url
        }
        
        let path = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: path).appendingPathComponent("Tests").appendingPathComponent(res).appendingPathExtension(ext.rawValue)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("Failed to locate resource \(res).\(ext.rawValue)")
        }
        
        return url
    }
    
    var bundleSQLite: URL {
        return self.url(for: resource, extension: .sqlite)
    }
    var bundleSHM: URL {
        return self.url(for: resource, extension: .shm)
    }
    var bundleWAL: URL {
        return self.url(for: resource, extension: .wal)
    }
}
