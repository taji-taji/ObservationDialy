//
//  Target.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class TargetData: ModelBase {
    
    // MARK: - Properties

    dynamic var title: String = ""
    dynamic var created: NSDate = NSDate(timeIntervalSince1970: 1)
    dynamic var updated: NSDate = NSDate(timeIntervalSince1970: 1)
    var photos = List<PhotoData>()
    
}
