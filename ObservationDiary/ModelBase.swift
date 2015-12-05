//
//  ModelBase.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class ModelBase: Object {
    dynamic var id: Int = 0
    
    // プライマリーキーを指定
    override static func primaryKey() -> String? {
        return "id"
    }
}
