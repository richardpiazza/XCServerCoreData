import Foundation
import CoreData
import CodeQuickKit
import XCServerAPI

public class EmailConfiguration: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, trigger: Trigger) {
        self.init(managedObjectContext: managedObjectContext)
        self.trigger = trigger
    }
    
    public func update(withEmailConfiguration configuration: XCSEmailConfiguration) {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            if let ccas = configuration.ccAddresses {
                do {
                    self.ccAddressesData = try XCServerCoreData.jsonEncoder.encode(ccas)
                } catch {
                    Log.error(error, message: "Failed to encode EmailConfiguration ccAddresses")
                }
            }
            if let adn = configuration.allowedDomainNames {
                do {
                    self.allowedDomainNamesData = try XCServerCoreData.jsonEncoder.encode(adn)
                } catch {
                    Log.error(error, message: "Failed to encode EmailConfiguration allowedDomainNames")
                }
            }
        }
        
        self.includeCommitMessages = configuration.includeCommitMessages as NSNumber?
        self.includeLogs = configuration.includeLogs as NSNumber?
        self.replyToAddress = configuration.replyToAddress
        self.includeIssueDetails = configuration.includeIssueDetails as NSNumber?
        self.includeBotConfiguration = configuration.includeBotConfiguration as NSNumber?
        self.additionalRecipients = configuration.additionalRecipients?.joined(separator: ",")
        self.emailComitters = configuration.emailCommitters as NSNumber?
        self.fromAddress = configuration.fromAddress
        self.emailTypeRawValue = configuration.type?.rawValue as NSNumber?
        self.includeResolvedIssues = configuration.includeResolvedIssues as NSNumber?
        self.weeklyScheduleDay = configuration.weeklyScheduleDay as NSNumber?
        self.minutesAfterHour = configuration.minutesAfterHour as NSNumber?
        self.hour = configuration.hour as NSNumber?
    }
}
