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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCoreDataImportFromAPIModels() {
        if let apiResponse = Resources.Bots {
            server.update(withBots: apiResponse.results)
        }
        
        // Bakeshop
        guard let bakeshopBot = coreData.managedObjectContext.bot(withIdentifier: "bba9b6ff6d6f0899a63d1e347e040bb4") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.Bakeshop.Integrations {
            bakeshopBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.Bakeshop.Stats {
            bakeshopBot.stats?.update(withStats: apiResponse)
        }
        
        guard let bakeshopIntegration = bakeshopBot.integration(withIdentifier: "bba9b6ff6d6f0899a63d1e347e4be8f0") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.Bakeshop.Issues {
            bakeshopIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let bakeshopRepository = coreData.managedObjectContext.repository(withIdentifier: "6139C8319FDE4527BFD4EA6334BA1CE5BC0DE9DF") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.Bakeshop.Commits {
            bakeshopRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        // Pocket Bot
        guard let pocketBotBot = coreData.managedObjectContext.bot(withIdentifier: "bba9b6ff6d6f0899a63d1e347e00ff15") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.PocketBot.Integrations {
            pocketBotBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.PocketBot.Stats {
            pocketBotBot.stats?.update(withStats: apiResponse)
        }
        
        guard let pocketBotIntegration = pocketBotBot.integration(withIdentifier: "445abd7c9c9ac0ab2d3b474f6a1f12ad") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.PocketBot.Issues {
            pocketBotIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let pocketBotRepository = coreData.managedObjectContext.repository(withIdentifier: "6D9FFC92170BF5EE19CA25700175BFFFBA40751A") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.PocketBot.Commits {
            pocketBotRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        // Code Quick Kit
        guard let codeQuickKitBot = coreData.managedObjectContext.bot(withIdentifier: "bba9b6ff6d6f0899a63d1e347e081b6a") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.CodeQuickKit.Integrations {
            codeQuickKitBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.CodeQuickKit.Stats {
            codeQuickKitBot.stats?.update(withStats: apiResponse)
        }
        
        guard let codeQuickKitIntegration = codeQuickKitBot.integration(withIdentifier: "d268530a92c37b78d5fe9634cd09d585") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.CodeQuickKit.Issues {
            codeQuickKitIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let codeQuickKitRepository = coreData.managedObjectContext.repository(withIdentifier: "3CBDEDAE95CE25E53B615AC684AAEE3F90A98DFE") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.CodeQuickKit.Commits {
            codeQuickKitRepository.update(withIntegrationCommits: apiResponse.results)
        }
        
        // Mise En Place
        guard let miseEnPlaceBot = coreData.managedObjectContext.bot(withIdentifier: "bba9b6ff6d6f0899a63d1e347e100570") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.MiseEnPlace.Integrations {
            miseEnPlaceBot.update(withIntegrations: apiResponse.results)
        }
        
        if let apiResponse = Resources.MiseEnPlace.Stats {
            miseEnPlaceBot.stats?.update(withStats: apiResponse)
        }
        
        guard let miseEnPlaceIntegration = miseEnPlaceBot.integration(withIdentifier: "bba9b6ff6d6f0899a63d1e347e100e75") else {
            XCTFail()
            return
        }
        
        if let apiResponse = Resources.MiseEnPlace.Issues {
            miseEnPlaceIntegration.issues?.update(withIntegrationIssues: apiResponse)
        }
        
        guard let miseEnPlaceRepository = coreData.managedObjectContext.repository(withIdentifier: "E72555C40C59CF258F530ADBA0314A60534D9864") else {
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
        
        // VERIFY
        
        for server in coreData.managedObjectContext.xcodeServers() {
            let json = server.json
            XCTAssertNotNil(json)
            print(json!)
        }
        
        for repository in coreData.managedObjectContext.repositories() {
            let json = repository.json
            XCTAssertNotNil(json)
            print(json!)
        }
    }
}
