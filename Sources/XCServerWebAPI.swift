//===----------------------------------------------------------------------===//
//
// XCServerWebAPI.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/XCServerCoreData
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation
import CodeQuickKit

public typealias XCServerWebAPICredentials = (username: String, password: String?)
public typealias XCServerWebAPICredentialsHeader = (value: String, key: String)

public protocol XCServerWebAPICredentialDelegate {
    func credentials(forAPI api: XCServerWebAPI) -> XCServerWebAPICredentials?
    func credentialsHeader(forAPI api: XCServerWebAPI) -> XCServerWebAPICredentialsHeader?
}

public extension XCServerWebAPICredentialDelegate {
    public func credentialsHeader(forAPI api: XCServerWebAPI) -> XCServerWebAPICredentialsHeader? {
        guard let creds = credentials(forAPI: api) else {
            return nil
        }
        
        let username = creds.username
        let password = creds.password ?? ""
        
        let userpass = "\(username):\(password)"
        
        guard let data = userpass.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
            return nil
        }
        
        let base64 = data.base64EncodedStringWithOptions([])
        let auth = "Basic \(base64)"
        
        return XCServerWebAPICredentialsHeader(value: auth, key: WebAPIHeaderKey.Authorization)
    }
}

/// Wrapper for `WebAPI` that implements common Xcode Server requests.
public class XCServerWebAPI: WebAPI {
    
    /// Class implementing the NSURLSessionDelegate which forcefully bypasses
    /// untrusted SSL Certificates.
    public class XCServerDefaultSessionDelegate: NSObject, NSURLSessionDelegate {
        // MARK: - NSURLSessionDelegate
        @objc public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            guard challenge.previousFailureCount < 1 else {
                completionHandler(.CancelAuthenticationChallenge, nil)
                return
            }
            
            var credentials: NSURLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    credentials = NSURLCredential(trust: serverTrust)
                }
            }
            
            completionHandler(.UseCredential, credentials)
        }
    }
    
    /// Class implementing the XCServerWebAPICredentialDelgate
    public class XCServerDefaultCredentialDelegate: XCServerWebAPICredentialDelegate {
        // MARK: - XCServerWebAPICredentialsDelegate
        public func credentials(forAPI api: XCServerWebAPI) -> XCServerWebAPICredentials? {
            return nil
        }
    }
    
    public static var sessionDelegate: NSURLSessionDelegate = XCServerDefaultSessionDelegate()
    public static var credentialDelegate: XCServerWebAPICredentialDelegate = XCServerDefaultCredentialDelegate()
    private static var apis = [String : XCServerWebAPI]()
    
    public static func api(forServer xcodeServer: XcodeServer) -> XCServerWebAPI {
        if let api = self.apis[xcodeServer.fqdn] {
            return api
        }
        
        let api = XCServerWebAPI(xcodeServer: xcodeServer)
        api.session.configuration.timeoutIntervalForRequest = 8
        api.session.configuration.timeoutIntervalForResource = 16
        api.session.configuration.HTTPCookieAcceptPolicy = .Never
        
        self.apis[xcodeServer.fqdn] = api
        
        return api
    }
    
    public static func resetAPI(forServer xcodeServer: XcodeServer) {
        if let _ = self.apis[xcodeServer.fqdn] {
            self.apis[xcodeServer.fqdn] = nil
        }
    }
    
    private let invalidXcodeServer = NSError(domain: String(XCServerWebAPI.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Invalid Xcode Server",
        NSLocalizedFailureReasonErrorKey: "This class was initialized without an XcodeServer entity.",
        NSLocalizedRecoverySuggestionErrorKey: "Re-initialize this class using init(xcodeServer:)."
        ])
    
    private let invalidResponseCast = NSError(domain: String(XCServerWebAPI.self), code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Invalid responseObject",
        NSLocalizedFailureReasonErrorKey: "The response object could not be cast into the requested type.",
        NSLocalizedRecoverySuggestionErrorKey: "Check the request is sending a valid response."
        ])
    
    private var xcodeServer: XcodeServer?
    
    public convenience init(xcodeServer: XcodeServer) {
        self.init(baseURL: xcodeServer.apiURL, sessionDelegate: XCServerWebAPI.sessionDelegate)
        self.xcodeServer = xcodeServer
    }
    
    public override func request(forPath path: String, queryItems: [NSURLQueryItem]?, method: WebAPIRequestMethod, data: NSData?) -> NSMutableURLRequest? {
        guard let request = super.request(forPath: path, queryItems: queryItems, method: method, data: data) else {
            return nil
        }
        
        if let xcodeServer = self.xcodeServer where xcodeServer.fqdn == self.baseURL?.host {
            if let header = XCServerWebAPI.credentialDelegate.credentialsHeader(forAPI: self) {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return request
    }
    
    // MARK: - Endpoints
    
    /// Requests the '`/ping`' endpoint from the Xcode Server API.
    func getPing(completion: WebAPICompletion) {
        guard let _ = self.xcodeServer else {
            completion(statusCode: 0, response: nil, responseObject: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("ping", completion: completion)
    }
    
    typealias XCServerWebAPIVersionCompletion = (version: VersionJSON?, error: NSError?) -> Void
    
    /// Requests the '`/version`' endpoint from the Xcode Server API.
    func getVersion(completion: XCServerWebAPIVersionCompletion) {
        guard let _ = self.xcodeServer else {
            completion(version: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("version") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(version: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(version: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = VersionJSON(withDictionary: dictionary)
            
            completion(version: typedResponse, error: nil)
        }
    }
    
    typealias XCServerWebAPIBotsCompletion = (bots: [BotJSON]?, error: NSError?) -> Void
    
    /// Requests the '`/bots`' endpoint from the Xcode Server API.
    func getBots(completion: XCServerWebAPIBotsCompletion) {
        guard let _ = self.xcodeServer else {
            completion(bots: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("bots") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(bots: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(bots: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = BotsResponse(withDictionary: dictionary)
            
            completion(bots: typedResponse.results, error: nil)
        }
    }
    
    typealias XCServerWebAPIBotCompletion = (bot: BotJSON?, error: NSError?) -> Void
    
    /// Requests the '`/bots/{id}`' endpoint from the Xcode Server API.
    func getBot(bot: Bot, completion: XCServerWebAPIBotCompletion) {
        guard let _ = self.xcodeServer else {
            completion(bot: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("bot/\(bot.identifier)") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(bot: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(bot: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = BotJSON(withDictionary: dictionary)
            
            completion(bot: typedResponse, error: nil)
        }
    }
    
    typealias XCServerWebAPIStatsCompletion = (stats: StatsJSON?, error: NSError?) -> Void
    
    /// Requests the '`/bots/{id}/stats`' endpoint from the Xcode Server API.
    func getStats(forBot bot: Bot, completion: XCServerWebAPIStatsCompletion) {
        guard let _ = self.xcodeServer else {
            completion(stats: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("bot/\(bot.identifier)/stats") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(stats: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(stats: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = StatsJSON(withDictionary: dictionary)
            
            completion(stats: typedResponse, error: nil)
        }
    }
    
    typealias XCServerWebAPIIntegrationCompletion = (integration: IntegrationJSON?, error: NSError?) -> Void
    
    /// Posts a request to the '`/bots/{id}`' endpoint from the Xcode Server API.
    func postBot(forBot bot: Bot, completion: XCServerWebAPIIntegrationCompletion) {
        guard let _ = self.xcodeServer else {
            completion(integration: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.post(nil, path: "bots/\(bot.identifier)/integrations") { (statusCode, response, responseObject, error) in
            guard statusCode == 201 else {
                completion(integration: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(integration: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = IntegrationJSON(withDictionary: dictionary)
            
            completion(integration: typedResponse, error: nil)
        }
    }
    
    typealias XCServerWebAPIIntegrationsCompletion = (integrations: [IntegrationJSON]?, error: NSError?) -> Void
    
    /// Requests the '`/bots/{id}/integrations`' endpoint from the Xcode Server API.
    func getIntegrations(forBot bot: Bot, completion: XCServerWebAPIIntegrationsCompletion) {
        guard let _ = self.xcodeServer else {
            completion(integrations: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("bots/\(bot.identifier)/integrations") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(integrations: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(integrations: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = IntegrationsResponse(withDictionary: dictionary)
            
            completion(integrations: typedResponse.results, error: nil)
        }
    }
    
    /// Requests the '`/integrations/{id}`' endpoint from the Xcode Server API.
    func getIntegration(integration: Integration, completion: XCServerWebAPIIntegrationCompletion) {
        guard let _ = self.xcodeServer else {
            completion(integration: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("integrations/\(integration.identifier)") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(integration: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(integration: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = IntegrationJSON(withDictionary: dictionary)
            
            completion(integration: typedResponse, error: nil)
        }
    }
    
    typealias XCServerWebAPICommitsCompletion = (commits: [IntegrationCommitJSON]?, error: NSError?) -> Void
    
    /// Requests the '`/integrations/{id}/commits`' endpoint from the Xcode Server API.
    func getCommits(forIntegration integration: Integration, completion: XCServerWebAPICommitsCompletion) {
        guard let _ = self.xcodeServer else {
            completion(commits: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("integrations/\(integration.identifier)/commits") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(commits: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(commits: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = IntegrationCommitsResponse(withDictionary: dictionary)
            
            completion(commits: typedResponse.results, error: nil)
        }
    }
    
    typealias XCServerWebAPIIssuesCompletion = (issues: IntegrationIssuesResponse?, error: NSError?) -> Void
    
    /// Requests the '`/integrations/{id}/issues`' endpoint from the Xcode Server API.
    func getIssues(forIntegration integration: Integration, completion: XCServerWebAPIIssuesCompletion) {
        guard let _ = self.xcodeServer else {
            completion(issues: nil, error: self.invalidXcodeServer)
            return
        }
        
        self.get("integrations/\(integration.identifier)/issues") { (statusCode, response, responseObject, error) in
            guard statusCode == 200 else {
                completion(issues: nil, error: error)
                return
            }
            
            guard let dictionary = responseObject as? SerializableDictionary else {
                completion(issues: nil, error: self.invalidResponseCast)
                return
            }
            
            let typedResponse = IntegrationIssuesResponse(withDictionary: dictionary)
            
            completion(issues: typedResponse, error: nil)
        }
    }
}
