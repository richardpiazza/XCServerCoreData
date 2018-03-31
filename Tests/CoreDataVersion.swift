import Foundation
import CoreData
import XCServerCoreData

class CoreDataVersion {
    
    public static var v_1_2_0 = CoreDataVersion(with: "XCServerCoreData_1.2.0")
    public static var v_1_2_0_empty = CoreDataVersion(with: "XCServerCoreData_1.2.0_empty")
    public static var v_2_0_0_empty = CoreDataVersion(with: "XCServerCoreData_2.0.0_empty")
    public static var v_2_0_1 = CoreDataVersion(with: "XCServerCoreData_2.0.1")
    
    public var resource: String
    
    public init(with resource: String) {
        self.resource = resource
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
        
        let replacementOptions = FileManager.ItemReplacementOptions()
        
        print("Copying/Overwriting SQLite File")
        do {
            try fileManager.copyItem(at: version.bundleSQLite!, to: tempSQLite)
            try fileManager.replaceItem(at: documentsSQLite, withItemAt: tempSQLite, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
        } catch {
            print(error)
            return false
        }
        
        if let url = version.bundleSHM {
            print("Copying/Overwriting SHM File")
            do {
                try fileManager.copyItem(at: url, to: tempSHM)
                try fileManager.replaceItem(at: documentsSHM, withItemAt: tempSHM, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
            } catch {
                print(error)
            }
        }
        
        if let url = version.bundleWAL {
            print("Copying/Overwriting WAL File")
            do {
                try fileManager.copyItem(at: url, to: tempWAL)
                try fileManager.replaceItem(at: documentsWAL, withItemAt: tempWAL, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
            } catch {
                print(error)
            }
        }
        
        return true
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    static var persistentContainer: NSPersistentContainer {
        let fileManager = FileManager.default
        
        var modelURL: URL
        
        let bundle = Bundle(for: XCServerCoreData.self)
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

extension CoreDataVersion {
    func url(for res: String, extension ext: CoreDataExtension) -> URL? {
        let bundle = Bundle(for: CoreDataVersion.self)
        if let url = bundle.url(forResource: res, withExtension: ext.rawValue) {
            return url
        }
        
        let path = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: path).appendingPathComponent("Tests").appendingPathComponent(res).appendingPathExtension(ext.rawValue)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            print("Unable to locate resource \(res).\(ext.rawValue)")
            return nil
        }
        
        return url
    }
    
    var bundleSQLite: URL? {
        return self.url(for: resource, extension: .sqlite)
    }
    var bundleSHM: URL? {
        return self.url(for: resource, extension: .shm)
    }
    var bundleWAL: URL? {
        return self.url(for: resource, extension: .wal)
    }
}
