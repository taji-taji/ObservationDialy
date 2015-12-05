////
////  Data.swift
////  ObservationDiary
////
////  Created by tajika on 2015/10/22.
////  Copyright © 2015年 Tajika. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class Data: Object {
//    dynamic var id: Int = 0
//}
//
//class TargetData: Data {
//    
//    // MARK: Properties
//    dynamic var title: String = ""
//    dynamic var created: NSDate = NSDate(timeIntervalSince1970: 1)
//    dynamic var updated: NSDate = NSDate(timeIntervalSince1970: 1)
//    var photos = List<PhotoData>()
//    
//    // プライマリーキーを指定
//    override static func primaryKey() -> String? {
//        return "id"
//    }
//    
//}
//
//class PhotoData: Data {
//    
//    // MARK: Properties
//    dynamic var comment: String = ""
//    dynamic var photo: String = ""
//    dynamic var created: NSDate = NSDate(timeIntervalSince1970: 1)
//    dynamic var updated: NSDate = NSDate(timeIntervalSince1970: 1)
//    var target: [TargetData] {
//        return linkingObjects(TargetData.self, forProperty: "photos")
//    }
//    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
//
//}