//
//  DateUtilityTests.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/14.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest

class DateUtilityTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let dateFormat = "yyyy-MM-dd HH.mm.ss"
        let dateUtility1 = DateUtility(dateFormat: dateFormat)
        XCTAssertEqual(dateUtility1.formatter.dateFormat, dateFormat)
        
        let dateUtility2 = DateUtility(dateFormat: nil)
        XCTAssertEqual(dateUtility2.formatter.dateFormat, "yyyy/MM/dd HH:mm:ss")
    }

    func testDateToStr() {
        let dateFormat = "yyyy-MM-dd HH.mm.ss"
        let now = NSDate()
        
        let dateUtility = DateUtility(dateFormat: dateFormat)
        let dateStrFromDateUtility = dateUtility.dateToStr(now)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        let dateStr = formatter.stringFromDate(now)
        
        XCTAssertEqual(dateStrFromDateUtility, dateStr)
    }
    
}
