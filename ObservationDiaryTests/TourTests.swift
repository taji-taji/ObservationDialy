//
//  TourTests.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/13.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest
import EasyTipView

class TourTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetInstance() {
        let instance = Tour(text: Tour.ADD_TARGET_TEXT).getInstance()
        XCTAssertEqual(String(instance.dynamicType), String(EasyTipView.self))
    }
    
    func testClose() {
        var tour = Tour(text: Tour.ADD_TARGET_TEXT)
        tour.isShowing = true
        tour.close()
        XCTAssertFalse(tour.isShowing)
    }
    
    func testTour() {
        var tour = Tour(text: Tour.ADD_TARGET_TEXT)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let tourType = Tour.TourType.AddTarget
        
        // forViewがUIViewの時
        if let _ = userDefaults.objectForKey(tourType.rawValue) {
            userDefaults.removeObjectForKey(tourType.rawValue)
        }
        tour.tour(tourType, forView: UIView(), superView: nil)

        XCTAssertNotNil(userDefaults.objectForKey(tourType.rawValue))
        
        // forViewがUIBarButtonItemの時
        if let _ = userDefaults.objectForKey(tourType.rawValue) {
            userDefaults.removeObjectForKey(tourType.rawValue)
        }
        tour.tour(tourType, forView: UIBarButtonItem(), superView: nil)
        
        XCTAssertNotNil(userDefaults.objectForKey(tourType.rawValue))
    }

}
