import Foundation
import CoreData

public extension CommitContributor {

    @NSManaged var displayName: String?
    @NSManaged var emails: NSObject?
    @NSManaged var name: String?
    @NSManaged var commit: Commit?

}
