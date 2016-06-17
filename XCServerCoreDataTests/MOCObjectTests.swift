//===----------------------------------------------------------------------===//
//
// MOCObjectTests.swift
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

import XCTest
import CodeQuickKit
@testable import XCServerCoreData

class MOCObjectTests: XCTestCase {

    struct CDConfig: CoreDataConfiguration {
        var persistentStoreType: StoreType {
            return .SQLite
        }
        
        var persistentStoreURL: NSURL {
            let path = NSFileManager.defaultManager().sandboxDirectory?.URLByAppendingPathComponent("coredata.sqlite")
            return path!
        }
        
        var persistentStoreOptions: [String : AnyObject] {
            return [String : AnyObject]()
        }
    }
    
    static let coreDataConfig = CDConfig()
    
    lazy var coreData: CoreData = {
        return CoreData(fromBundle: NSBundle(forClass: XCServerCoreData.self), modelName: "XCServerCoreData", delegate: MOCObjectTests.coreDataConfig)!
    }()
    
    lazy var server: XcodeServer = {
        if let server = self.coreData.managedObjectContext.xcodeServer(withFQDN: "test.server.com") {
            return server
        }
        
        let dictionary: SerializableDictionary = ["fqdn" : "test.server.com"]
        return XcodeServer(managedObjectContext: self.coreData.managedObjectContext, withDictionary: dictionary)!
    }()
    
    override func setUp() {
        super.setUp()
        
        XCTAssertNotNil(coreData)
        XCTAssertNotNil(server)
        
        if let apiResponse = Resources.Bots {
            server.update(withBots: apiResponse.results)
        }
        
        // Bakeshop
        guard let bakeshopBot = coreData.managedObjectContext.bot(withIdentifier: Resources.Bakeshop.botIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.Bakeshop.Integrations {
            bakeshopBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.Bakeshop.Stats {
            bakeshopBot.stats?.update(withStats: apiResponse)
        }
        
        guard let bakeshopIntegration = coreData.managedObjectContext.integration(withIdentifier: Resources.Bakeshop.integrationIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.Bakeshop.Issues {
            bakeshopIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let bakeshopRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.Bakeshop.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.Bakeshop.Commits {
            bakeshopRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        // Pocket Bot
        guard let pocketBotBot = coreData.managedObjectContext.bot(withIdentifier: Resources.PocketBot.botIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.PocketBot.Integrations {
            pocketBotBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.PocketBot.Stats {
            pocketBotBot.stats?.update(withStats: apiResponse)
        }
        
        guard let pocketBotIntegration = coreData.managedObjectContext.integration(withIdentifier: Resources.PocketBot.integrationIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.PocketBot.Issues {
            pocketBotIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let pocketBotRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.PocketBot.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.PocketBot.Commits {
            pocketBotRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        // Code Quick Kit
        guard let codeQuickKitBot = coreData.managedObjectContext.bot(withIdentifier: Resources.CodeQuickKit.botIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.CodeQuickKit.Integrations {
            codeQuickKitBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.CodeQuickKit.Stats {
            codeQuickKitBot.stats?.update(withStats: apiResponse)
        }
        
        guard let codeQuickKitIntegration = coreData.managedObjectContext.integration(withIdentifier: Resources.CodeQuickKit.integrationIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.CodeQuickKit.Issues {
            codeQuickKitIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let codeQuickKitRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.CodeQuickKit.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.CodeQuickKit.Commits {
            codeQuickKitRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        // Mise En Place
        guard let miseEnPlaceBot = coreData.managedObjectContext.bot(withIdentifier: Resources.MiseEnPlace.botIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.MiseEnPlace.Integrations {
            miseEnPlaceBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.MiseEnPlace.Stats {
            miseEnPlaceBot.stats?.update(withStats: apiResponse)
        }
        
        guard let miseEnPlaceIntegration = coreData.managedObjectContext.integration(withIdentifier: Resources.MiseEnPlace.integrationIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.MiseEnPlace.Issues {
            miseEnPlaceIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let miseEnPlaceRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.MiseEnPlace.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.MiseEnPlace.Commits {
            miseEnPlaceRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        do {
            try coreData.managedObjectContext.save()
        } catch {
            print(error)
            XCTFail()
        }
        
        let xcodeServers = coreData.managedObjectContext.xcodeServers()
        XCTAssertTrue(xcodeServers.count == 1)
        
        let repositories = coreData.managedObjectContext.repositories()
        XCTAssertTrue(repositories.count == 4)
        
        let commits = coreData.managedObjectContext.commits()
        XCTAssertTrue(commits.count == 26)
        
        let bots = coreData.managedObjectContext.bots()
        XCTAssertTrue(bots.count == 4)
        
        let integrations = coreData.managedObjectContext.integrations()
        XCTAssertTrue(integrations.count == 23)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBakeshopData() {
        guard let
            repository = coreData.managedObjectContext.repository(withIdentifier: Resources.Bakeshop.repositoryIdentifier),
            bot = coreData.managedObjectContext.bot(withIdentifier: Resources.Bakeshop.botIdentifier),
            commit = coreData.managedObjectContext.commit(withHash: "acb245fde35565f98e09b02a5540f8735fd18682") else {
                XCTFail()
                return
        }
        
        XCTAssertTrue(repository.url == "ssh://bitbucket.org/richardpiazza/com.richardpiazza.bakeshop.git")
        
        guard let
            commits = repository.commits as? Set<Commit>,
            integrations = bot.integrations as? Set<Integration> else {
                XCTFail()
                return
        }
        
        XCTAssertTrue(commits.count == 7)
        XCTAssertTrue(integrations.count == 11)
        
        guard let
            commitRevisionBlueprints = commit.revisionBlueprints as? Set<RevisionBlueprint>,
            crb = commitRevisionBlueprints.first else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(commitRevisionBlueprints.count == 1)
        
        let crbIntegration = crb.integration
        let crbCommit = crb.commit
        
        for integration in integrations {
            print(integration.objectID.URIRepresentation())
            
            if let integrationRevisionBlueprints = integration.revisionBlueprints as? Set<RevisionBlueprint> {
                let objectIds = integrationRevisionBlueprints.map({ (rb: RevisionBlueprint) -> NSURL in
                    return rb.objectID.URIRepresentation()
                })
                print(objectIds)
            }
        }
    }
    
    func testPocketBotData() {
        guard let pocketBotRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.PocketBot.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(pocketBotRepository.url == "ssh://bitbucket.org/richardpiazza/com.richardpiazza.pocketbot.git")
    }
    
    func testCodeQuickKitData() {
        guard let codeQuickKitRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.CodeQuickKit.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(codeQuickKitRepository.url == "https://github.com/richardpiazza/CodeQuickKit")
    }
    
    func testMiseEnPlaceData() {
        guard let miseEnPlaceRepository = coreData.managedObjectContext.repository(withIdentifier: Resources.MiseEnPlace.repositoryIdentifier) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(miseEnPlaceRepository.url == "https://github.com/richardpiazza/MiseEnPlace")
    }
}
