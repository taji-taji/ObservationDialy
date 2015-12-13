//
//  StorageTests.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/12.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest
import RealmSwift

class StorageTest: XCTestCase {
    
    var storage = Storage()

    override func setUp() {
        super.setUp()
        storage = Storage(defaultConfiguration: String(NSStringFromClass(self.dynamicType)))
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAdd() {
        let target = TargetData()
        target.title = "test"
        target.created = NSDate()
        let addSuccess = storage.add(target)
        XCTAssertEqual(addSuccess, true, "Success")
    }
    
    func testUpdate() {
        let target = TargetData()
        target.title = "test"
        target.created = NSDate()
        if storage.add(target) {
            let updateTitle = "test2"
            let update = ["id": target.id, "title": updateTitle]
            storage.update(TargetData(), updateValues: update)
            XCTAssertEqual(target.title, updateTitle, "Success")
        }
    }
    
    func testFind() {
        let target = TargetData()
        target.title = "test"
        target.created = NSDate()
        if storage.add(target) {
            
            // success case
            let foundTaret = storage.find(TargetData(), id: target.id)
            XCTAssertEqual(target.id, foundTaret!.id, "Success")
            
            // failure case
            XCTAssertNotEqual(target.id, (foundTaret!.id + 1), "Failure")
        }
    }

    func testFindWhere() {
        for var i = 0; i < 3; i++ {
            let target = TargetData()
            target.title = "test" + String(i)
            target.created = NSDate()
            storage.add(target)
        }
        let foundTargets = storage.findWhere(TargetData(), filter: "title = 'test0'")
        XCTAssertEqual(foundTargets?.count, 1, "Success")
        XCTAssertEqual(foundTargets![0].title, "test0", "Success")
    }
    
    func testDelete() {
        let target = TargetData()
        target.title = "test"
        target.created = NSDate()
        if storage.add(target) {
            if let foundTaret = storage.find(TargetData(), id: target.id) {
                let id = target.id
                storage.delete(foundTaret)
                XCTAssertNil(storage.find(TargetData(), id: id))
            }
        }
    }
    
}
