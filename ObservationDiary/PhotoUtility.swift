//
//  PhotoUtility.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/27.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class PhotoUtility: MediaUtility {

    // MARK: - Properties

    let PhotoDirectory: String = "/photos"
    var PhotoDirectoryPath: String = ""
    
    override init() {
        super.init()
        PhotoDirectoryPath = DocumentsDirectory + PhotoDirectory
        fileManager.fileExistsAtPath(PhotoDirectoryPath, isDirectory: &isDir)
        makeDirectoryIfNeeded(PhotoDirectoryPath)
    }
    
    // MARK: - Methods

    func get(fileName: String) -> UIImage? {
        let filePath = getFilePath(fileName)
        if let jpeg: UIImage? = UIImage(contentsOfFile: filePath) {
            return jpeg
        } else {
            return nil
        }
    }
    
    func getFilePath(fileName: String) -> String {
        return PhotoDirectoryPath + "/" + fileName
    }

    func insert(image: UIImage) -> String? {

        let jpegData = UIImageJPEGRepresentation(image, 1.0)!
        
        // ファイル名を指定して保存
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.stringFromDate(now) + ".jpg"
        let filePath = PhotoDirectoryPath + "/" + fileName
        jpegData.writeToFile(filePath, atomically: true)
        
        return fileName
    }
    
    func delete(fileName: String) -> Bool {
        do {
            try fileManager.removeItemAtPath(PhotoDirectoryPath + "/" + fileName)
            return true
        } catch {
            print("failed: delete file")
            return false
        }
    }

}