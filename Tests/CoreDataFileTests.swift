//
//  CoreDataFileTests.swift
//  XCServerCoreDataTests
//
//  Created by Richard Piazza on 7/24/17.
//  Copyright © 2017 Richard Piazza. All rights reserved.
//

import XCTest
@testable import XCServerCoreData

class CoreDataFileTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    func testMigrateV120toV200() {
        CoreDataVersions.overwriteSQL(withVersion: CoreDataVersions.v_1_2_0)
        
        let loadExpectation = expectation(description: "Load CoreData Persistent Store")
        
        let coreData = XCServerCoreData.sharedInstance
        coreData.loadPersistentStores { (description, error) in
            if let e = error {
                print(e)
                XCTFail()
                return
            }
            
            loadExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let e = error {
                print(e)
                XCTFail()
            }
        }
        
        guard let integration = coreData.viewContext.integration(withIdentifier: "8a526f6a0ce6b83bb969758e0f262490") else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(integration.bot)
        XCTAssertNotNil(integration.startedTime)
    }
}
