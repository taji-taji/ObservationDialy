//
//  Photo.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoData: ModelBase {
    
    // MARK: - Properties

    dynamic var comment: String = ""
    dynamic var photo: String = ""
    dynamic var created: NSDate = NSDate(timeIntervalSince1970: 1)
    dynamic var updated: NSDate = NSDate(timeIntervalSince1970: 1)
    var target: [TargetData] {
        return linkingObjects(TargetData.self, forProperty: "photos")
    }
    
}
