import Foundation

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
    
    static func overwriteSQL(withVersion version: CoreDataVersion) {
        let fileManager = FileManager.default
        let replacementOptions = FileManager.ItemReplacementOptions()
        
        print("Overwriting SQL at url: \(documentsSQLite.absoluteString)")
        
        do {
            try fileManager.replaceItem(at: documentsSQLite, withItemAt: version.bundleSQLite, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
            try fileManager.replaceItem(at: documentsSHM, withItemAt: version.bundleSHM, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
            try fileManager.replaceItem(at: documentsWAL, withItemAt: version.bundleWAL, backupItemName: nil, options: replacementOptions, resultingItemURL: nil)
        } catch {
            print(error)
        }
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
