//
//  Data.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/22.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class TargetData: Object {
    
    // MARK: Properties
    dynamic var id: Int = 0
    dynamic var title: String = ""
    dynamic var created: String = ""
    var photos = List<PhotoData>()
    
    // プライマリーキーを指定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class PhotoData: Object {
    
    // MARK: Properties
    dynamic var id: Int = 0
    dynamic var comment: String = ""
    dynamic var photo: AnyObject = UIImage()
    dynamic var created: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }

}