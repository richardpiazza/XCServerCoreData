import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class Issue: NSManagedObject {
    
    internal func update(withIssue issue: XCSIssue) {
        self.identifier = issue._id
        self.revision = issue._rev
        self.status = issue.status as NSNumber?
        self.age = issue.age as NSNumber?
        self.type = issue.type
        self.issueType = issue.issueType
        self.message = issue.message
        self.fixItType = issue.fixItType
    }
    
    public var typeOfIssue: IssueType {
        guard let rawValue = self.type else {
            return .unknown
        }
        
        guard let enumeration = IssueType(rawValue: rawValue) else {
            return .unknown
        }
        
        return enumeration
    }
}
