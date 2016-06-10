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
    
    func testImportBots() {
        guard let response = Resources.botsResponse else {
            XCTFail()
            return
        }
        
        server.update(withBots: response.results)
        
        XCTAssertEqual(server.bots?.count, 4)
        
        do {
            try coreData.managedObjectContext.save()
        } catch {
            XCTFail((error as NSError).localizedDescription)
        }
    }
    
    func testImportIntegrations() {
        guard let response = Resources.integrationsResponse else {
            XCTFail()
            return
        }
        
        guard let bakeshopBot = coreData.managedObjectContext.bot(withIdentifier: "bba9b6ff6d6f0899a63d1e347e040bb4") else {
            XCTFail()
            return
        }
        
        bakeshopBot.update(withIntegrations: response.results)
        
        guard let integrations = bakeshopBot.integrations as? Set<Integration> else {
            XCTFail()
            return
        }
        
        for integration in integrations {
            print("Integration '\(integration.integrationNumber)' Step: \(integration.integrationStep.description), Result: \(integration.integrationResult.description)")
        }
    }
}
