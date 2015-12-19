//
//  MediaUtilityTests.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/18.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest

class MediaUtilityTests: XCTestCase {

    let testDirectory = "/test"
    var isDir: ObjCBool = false
    let fileManager = NSFileManager.defaultManager()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let DocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let mediaUtility = MediaUtility()
        XCTAssertEqual(DocumentsDirectory, mediaUtility.DocumentsDirectory)
    }
    
    func testMakeDirectoryIfNeeded() {
        let mediaUtility = MediaUtility()
        let testDirectoryPath = mediaUtility.DocumentsDirectory + testDirectory
        fileManager.fileExistsAtPath(testDirectoryPath, isDirectory: &isDir)
        
        //ディレクトリが存在しない場合に、ディレクトリを削除
        if isDir {
            // ディレクトリを削除
            do {
                try fileManager.removeItemAtPath(testDirectoryPath)
            } catch {
                print("error")
            }
        }
        mediaUtility.makeDirectoryIfNeeded(testDirectoryPath)
        // ディレクトリがあるか
        XCTAssertTrue(fileManager.fileExistsAtPath(testDirectoryPath))
    }

}
