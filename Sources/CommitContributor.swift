import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class CommitContributor: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, commit: Commit) {
        self.init(managedObjectContext: managedObjectContext)
        self.commit = commit
    }
    
    internal func update(withCommitContributor contributor: XCSCommitContributor) {
        self.name = contributor.name
        self.displayName = contributor.displayName
        self.emails = contributor.emails as NSObject?
    }
    
    public var initials: String? {
        var tempComponents: [String]? = nil
        
        if let name = self.name {
            tempComponents = name.components(separatedBy: " ")
        } else if let displayName = self.displayName {
            tempComponents = displayName.components(separatedBy: " ")
        }
        
        guard let components = tempComponents else {
            return nil
        }
        
        var initials = ""
        
        for component in components {
            guard component != "" else {
                continue
            }
            
            if let character = component.first {
                initials.append(character)
            }
        }
        
        return initials
    }
    
    public var emailAddresses: [String] {
        guard let emails = self.emails as? [String] else {
            return []
        }
        
        return emails
    }
}
