//
//  MediaUtility.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/18.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class MediaUtility {
    
    // MARK: - Properties
    
    let DocumentsDirectory: String
    var isDir: ObjCBool = false
    let fileManager = NSFileManager.defaultManager()
    let now = NSDate()
    let formatter = NSDateFormatter()
    
    init() {
        DocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    }
    
    func makeDirectoryIfNeeded(path: String) {
        //ディレクトリが存在しない場合に、ディレクトリを作成する
        if !isDir {
            do {
                try fileManager.createDirectoryAtPath(path ,withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error: cannot create directory")
            }
        }
    }
}