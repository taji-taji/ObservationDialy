//
//  Target.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class Target {
    
    // MARK: Properties
    var title: String
    var photos: [Photo]?
    var created: String
    
    // MARK: Initialization
    init?(title: String, photos: [Photo]?, created: String) {
        // プロパティの初期化
        self.title = title
        self.photos = photos
        self.created = created

        // タイトルがなければnil
        if title.isEmpty {
            return nil
        }
    }
}