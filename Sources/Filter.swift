import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class Filter: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, deviceSpecification: DeviceSpecification) {
        self.init(managedObjectContext: managedObjectContext)
        self.deviceSpecification = deviceSpecification
    }
    
    public func update(withFilter filter: XCSFilter) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        self.filterType = filter.filterType as NSNumber?
        self.architectureType = filter.architectureType as NSNumber?
        
        if let filterPlatform = filter.platform {
            if self.platform == nil {
                self.platform = Platform(managedObjectContext: moc, filter: self)
            }
            
            if let platform = self.platform {
                platform.update(withPlatform: filterPlatform)
            }
        }
    }
}
