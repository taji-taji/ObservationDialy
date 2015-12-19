//
//  VideoUtilityTests.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/17.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest
import AVFoundation

class VideoUtilityTests: XCTestCase {
    
    let VideoDirectory = "/videos"
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
        let videoDirectoryPath = DocumentsDirectory + VideoDirectory
        fileManager.fileExistsAtPath(videoDirectoryPath, isDirectory: &isDir)
        
        if isDir {
            XCTAssertTrue(fileManager.fileExistsAtPath(videoDirectoryPath))
            // ディレクトリが存在する場合に、ディレクトリを削除
            do {
                try fileManager.removeItemAtPath(videoDirectoryPath)
            } catch {
                print("error")
            }
        }
        XCTAssertFalse(fileManager.fileExistsAtPath(videoDirectoryPath))

        let videoUtility = VideoUtility()
        // ディレクトリがあるか
        XCTAssertTrue(fileManager.fileExistsAtPath(videoDirectoryPath))
        XCTAssertEqual(videoDirectoryPath, videoUtility.VideoDirectoryPath)
    }

}
