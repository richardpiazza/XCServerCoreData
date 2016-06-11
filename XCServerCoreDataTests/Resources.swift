//
//  Resources.swift
//  XCServerCoreData
//
//  Created by Richard Piazza on 6/10/16.
//  Copyright © 2016 Richard Piazza. All rights reserved.
//

import Foundation
@testable import XCServerCoreData

class Resources {
    
    private static func bot(forPrefix prefix: String) -> BotJSON? {
        guard let path = NSBundle(forClass: Resources.self).pathForResource("\(prefix)_BotResponse", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let bot = BotJSON(withJSON: json)
        guard bot._id != "" else {
            return nil
        }
        
        return bot
    }
    
    private static func integrations(forPrefix prefix: String) -> IntegrationsResponse? {
        guard let path = NSBundle(forClass: self).pathForResource("\(prefix)_IntegrationsResponse", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let response = IntegrationsResponse(withJSON: json)
        guard response.count > 0 && response.results.count > 0 else {
            return nil
        }
        
        return response
    }
    
    private static func integration(forPrefix prefix: String) -> IntegrationJSON? {
        guard let path = NSBundle(forClass: self).pathForResource("\(prefix)_Integration", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let response = IntegrationJSON(withJSON: json)
        
        return response
    }
    
    private static func stats(forPrefix prefix: String) -> StatsJSON? {
        guard let path = NSBundle(forClass: self).pathForResource("\(prefix)_Stats", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let response = StatsJSON(withJSON: json)
        
        return response
    }
    
    private static func commits(forPrefix prefix: String) -> IntegrationCommitsResponse? {
        guard let path = NSBundle(forClass: self).pathForResource("\(prefix)_Commits", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let response = IntegrationCommitsResponse(withJSON: json)
        
        return response
    }
    
    private static func issues(forPrefix prefix: String) -> IntegrationIssuesResponse? {
        guard let path = NSBundle(forClass: self).pathForResource("\(prefix)_Issues", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let response = IntegrationIssuesResponse(withJSON: json)
        
        return response
    }
    
    struct Bakeshop {
        static let prefix: String = "bs"
        static let Bot: BotJSON? = Resources.bot(forPrefix: prefix)
        static let Integrations: IntegrationsResponse? = Resources.integrations(forPrefix: prefix)
        static let Integration: IntegrationJSON? = Resources.integration(forPrefix: prefix)
        static let Stats: StatsJSON? = Resources.stats(forPrefix: prefix)
        static let Commits: IntegrationCommitsResponse? = Resources.commits(forPrefix: prefix)
        static let Issues: IntegrationIssuesResponse? = Resources.issues(forPrefix: prefix)
    }
    
    struct CodeQuickKit {
        static let prefix: String = "cqk"
        static let Bot: BotJSON? = Resources.bot(forPrefix: prefix)
        static let Integrations: IntegrationsResponse? = Resources.integrations(forPrefix: prefix)
        static let Integration: IntegrationJSON? = Resources.integration(forPrefix: prefix)
        static let Stats: StatsJSON? = Resources.stats(forPrefix: prefix)
        static let Commits: IntegrationCommitsResponse? = Resources.commits(forPrefix: prefix)
        static let Issues: IntegrationIssuesResponse? = Resources.issues(forPrefix: prefix)
    }
    
    struct MiseEnPlace {
        static let prefix: String = "mep"
        static let Bot: BotJSON? = Resources.bot(forPrefix: prefix)
        static let Integrations: IntegrationsResponse? = Resources.integrations(forPrefix: prefix)
        static let Integration: IntegrationJSON? = Resources.integration(forPrefix: prefix)
        static let Stats: StatsJSON? = Resources.stats(forPrefix: prefix)
        static let Commits: IntegrationCommitsResponse? = Resources.commits(forPrefix: prefix)
        static let Issues: IntegrationIssuesResponse? = Resources.issues(forPrefix: prefix)
    }
    
    struct PocketBot {
        static let prefix: String = "pb"
        static let Bot: BotJSON? = Resources.bot(forPrefix: prefix)
        static let Integrations: IntegrationsResponse? = Resources.integrations(forPrefix: prefix)
        static let Integration: IntegrationJSON? = Resources.integration(forPrefix: prefix)
        static let Stats: StatsJSON? = Resources.stats(forPrefix: prefix)
        static let Commits: IntegrationCommitsResponse? = Resources.commits(forPrefix: prefix)
        static let Issues: IntegrationIssuesResponse? = Resources.issues(forPrefix: prefix)
    }
    
    static var Bots: BotsResponse? {
        guard let path = NSBundle(forClass: Resources.self).pathForResource("BotsResponse", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let response = BotsResponse(withJSON: json)
        guard response.count > 0 && response.results.count > 0 else {
            return nil
        }
        
        return response
    }
}
