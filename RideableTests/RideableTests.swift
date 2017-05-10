//
//  RideableTests.swift
//  Rideable
//
//  Created by Donny Blaine on 5/8/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import XCTest
@testable import Rideable

class RideableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRemoveNonDigits(){
        let stringToTest = "89%".extractDigits()
        XCTAssert(stringToTest == "89")
    }
    
    func testStringReplace(){
        let temp = "testing".replace(target: "e", withString: "")
        XCTAssert(temp == "tsting")
    }
    
    func testMatchingRegex(){
        let pattern = "([0-9]{1,3})F|([0-9]{1,3})"
        var sentence = "Today it will be 38F".matchingStrings(regex: pattern)
        let correctArray = ["38F", "38", ""]
        XCTAssert(sentence[0] == correctArray)
    }
}
