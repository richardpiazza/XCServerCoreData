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
    
    struct Bakeshop {
        static var Bot: BotJSON? {
            guard let path = NSBundle(forClass: Resources.self).pathForResource("bs_BotResponse", ofType: "txt") else {
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
    }
    
    struct CodeQuickKit {
        static var Bot: BotJSON? {
            guard let path = NSBundle(forClass: Resources.self).pathForResource("cqk_BotResponse", ofType: "txt") else {
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
    }
    
    struct MiseEnPlace {
        static var Bot: BotJSON? {
            guard let path = NSBundle(forClass: Resources.self).pathForResource("mep_BotResponse", ofType: "txt") else {
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
    }
    
    struct PocketBot {
        static var Bot: BotJSON? {
            guard let path = NSBundle(forClass: Resources.self).pathForResource("pb_BotResponse", ofType: "txt") else {
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
    }
    
    static var botsResponse: BotsResponse? {
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
    
    static var statsResponse: StatsJSON? {
        guard let path = NSBundle(forClass: self).pathForResource("StatsResponse", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let stats = StatsJSON(withJSON: json)
        
        return stats
    }
    
    static var integrationsResponse: IntegrationsResponse? {
        guard let path = NSBundle(forClass: self).pathForResource("IntegrationsResponse", ofType: "txt") else {
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
    
    static var integration: IntegrationJSON? {
        guard let path = NSBundle(forClass: self).pathForResource("IntegrationResponse", ofType: "txt") else {
            return nil
        }
        
        var json: String
        do {
            json = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
            print(error)
            return nil
        }
        
        let integration = IntegrationJSON(withJSON: json)
        
        return integration
    }
    
    static var integrationIssuesResponse: IntegrationIssuesResponse? {
        guard let path = NSBundle(forClass: self).pathForResource("IntegrationIssuesResponse", ofType: "txt") else {
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
    
    static var integrationCommitsResponse: IntegrationCommitsResponse? {
        guard let path = NSBundle(forClass: self).pathForResource("IntegrationCommitsResponse", ofType: "txt") else {
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
}
