import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class RevisionBlueprint: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, commit: Commit, integration: Integration) {
        self.init(managedObjectContext: managedObjectContext)
        self.commit = commit
        self.integration = integration
    }
}
