//
//  Data.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/22.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class Data: Object {
    dynamic var id: Int = 0
}

class TargetData: Data {
    
    // MARK: Properties
    dynamic var title: String = ""
    dynamic var created: String = ""
    var photos = List<PhotoData>()
    
    // プライマリーキーを指定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class PhotoData: Data {
    
    // MARK: Properties
    dynamic var comment: String = ""
    dynamic var photo: AnyObject = UIImage()
    dynamic var created: String = ""
    var target: [TargetData] {
        return linkingObjects(TargetData.self, forProperty: "photos")
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }

}