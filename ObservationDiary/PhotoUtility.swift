//
//  PhotoUtility.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/27.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class PhotoUtility {

    // MARK: Properties

    let DocumentsDirectory: String
    let PhotoDirectory: String = "/photos"
    let PhotoDirectoryPath: String
    var isDir: ObjCBool = false
    let fileManager = NSFileManager.defaultManager()
    let now = NSDate()
    let formatter = NSDateFormatter()
    
    init() {
        DocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        PhotoDirectoryPath = DocumentsDirectory + PhotoDirectory
        fileManager.fileExistsAtPath(PhotoDirectoryPath, isDirectory: &isDir)
    }
    
    // MARK: - Methods
    func get(fileName: String) -> UIImage? {
        let filePath = PhotoDirectoryPath + "/" + fileName
        if let jpeg: UIImage? = UIImage(contentsOfFile: filePath) {
            return jpeg
        } else {
            return nil
        }
    }

    func insert(image: UIImage) -> String? {
        
        //ディレクトリが存在しない場合に、ディレクトリを作成する
        if !isDir {
            do {
                try fileManager.createDirectoryAtPath(PhotoDirectoryPath ,withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error: cannot create directory")
            }
        }
        
        let jpegData = UIImageJPEGRepresentation(image, 1.0)!
        
        // ファイル名を指定して保存
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.stringFromDate(now) + ".jpg"
        let filePath = PhotoDirectoryPath + "/" + fileName
        jpegData.writeToFile(filePath, atomically: true)
        
        return fileName
    }
    
    func delete(fileName: String) {
        do {
            try fileManager.removeItemAtPath(PhotoDirectoryPath + "/" + fileName)
        } catch {
            print("failed: delete file")
        }
    }


}