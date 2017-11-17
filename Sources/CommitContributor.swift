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
        if let emails = contributor.emails {
            do {
                let data = try JSONSerialization.data(withJSONObject: emails, options: JSONSerialization.WritingOptions())
                self.emailsData = data
            } catch {
                Log.error(error, message: "Failed to serialize XCSCommitContributor.emails: \(emails)")
            }
        }
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
        guard let data = self.emailsData else {
            return []
        }
        
        do {
            guard let emails = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String] else {
                return []
            }
            
            return emails
        } catch {
            Log.error(error, message: "Failed to deserialze CommitContributor.emailsData")
            return []
        }
    }
}
