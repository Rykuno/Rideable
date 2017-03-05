//
//  TodayVCTest.swift
//  Rideable
//
//  Created by Donny Blaine on 3/5/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import XCTest
import CoreData
@testable import Rideable

class TodayVCTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHourSorting(){
        let vc = TodayVC()
        var errorCount = 0
        var isLessThan: Bool = true {
            willSet(newValue) {
                if newValue == false{
                    errorCount+=1
                }
            }
        }
        
        //Create the Array of hours
        let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        let day = Day(context: stack.context)
        for _ in 0...5{
            let hour = Hour(context: stack.context)
            hour.id = Int16(Int(arc4random_uniform(UInt32(11))))
            day.addToHour(hour)
        }
        
        //Check if the array is sorted
        if let hourArray = vc.sortHourArray(day: day){
            for index in 0...hourArray.count-2{
                isLessThan = hourArray[index].id <= hourArray[index+1].id
            }
        }
        XCTAssertTrue(errorCount==0)
    }
    
    func testIsHourArraySorted(){
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
