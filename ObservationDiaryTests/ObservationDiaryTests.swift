//
//  ObservationDiaryTests.swift
//  ObservationDiaryTests
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest
import RealmSwift
@testable import ObservationDiary

class ObservationDiaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // テスト用に新しいRealmファイルを使用する設定
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTargetAddData() {
        
        // Success cases.
        let successTarget = TargetData()
        successTarget.title = "test"
        successTarget.created = NSDate()
        let addSuccess = Storage().add(successTarget)
        XCTAssertEqual(addSuccess, true, "Success")
        
        
        // Failure cases.
        let failureTarget = TargetData()
        failureTarget.title = ""
        failureTarget.created = NSDate()
        let addFailure = Storage().add(failureTarget)
        XCTAssertEqual(addFailure, false, "Failure")
    }
    
    func testPhotoData() {
        
    }
    
}
