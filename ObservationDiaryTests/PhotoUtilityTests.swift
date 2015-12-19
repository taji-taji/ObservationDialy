//
//  PhotoUtilityTests.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/18.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest

class PhotoUtilityTests: XCTestCase {

    let PhotoDirectory = "/photos"
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
        let photoDirectoryPath = DocumentsDirectory + PhotoDirectory
        fileManager.fileExistsAtPath(photoDirectoryPath, isDirectory: &isDir)

        if isDir {
            // ディレクトリが存在する場合に、ディレクトリを削除
            XCTAssertTrue(fileManager.fileExistsAtPath(photoDirectoryPath))
            do {
                try fileManager.removeItemAtPath(photoDirectoryPath)
            } catch {
                print("error")
            }
        }
        XCTAssertFalse(fileManager.fileExistsAtPath(photoDirectoryPath))
        
        let photoUtility = PhotoUtility()
        // ディレクトリがあるか
        XCTAssertTrue(fileManager.fileExistsAtPath(photoDirectoryPath))
        XCTAssertEqual(photoDirectoryPath, photoUtility.PhotoDirectoryPath)
    }

//    func testInsert() {
//        let photoUtility = PhotoUtility()
//        if let image = UIImage(named: "AppIconWhite") {
//            var imageExists = fileManager.fileExistsAtPath(photoUtility.PhotoDirectoryPath + "AppIconWhite")
//            XCTAssertFalse(imageExists)
//            photoUtility.insert(image)
//            imageExists = fileManager.fileExistsAtPath(image)
//            XCTAssertTrue(imageExists)
//        } else {
//            fatalError("test image not found.")
//        }
//    }

}
