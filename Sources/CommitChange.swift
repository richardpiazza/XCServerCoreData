import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class CommitChange: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, commit: Commit) {
        self.init(managedObjectContext: managedObjectContext)
        self.commit = commit
    }
    
    public func update(withCommitChange change: XCSCommitChangeFilePath) {
        self.status = change.status as NSNumber?
        self.filePath = change.filePath
    }
}
