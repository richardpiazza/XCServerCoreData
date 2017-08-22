//
//  CommonExtensionTests.swift
//  XCServerCoreDataTests
//
//  Created by Richard Piazza on 8/22/17.
//  Copyright © 2017 Richard Piazza. All rights reserved.
//

import XCTest
@testable import XCServerCoreData

class CommonExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXCServerTestMethodName() {
        let input = "testPerformSomeAction()"
        let output = input.xcServerTestMethodName
        XCTAssertEqual(output, "Perform Some Action")
    }
    
    func testIncompleteMethodName() {
        let input = "testPerformSomeAction"
        let output = input.xcServerTestMethodName
        XCTAssertEqual(output, "Perform Some Action")
    }
}
