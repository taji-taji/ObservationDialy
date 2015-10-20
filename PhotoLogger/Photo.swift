//
//  Photo.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class Photo {
    
    // MARK: Properties
    var comment: String
    var photo: UIImage
    var created: String
    
    // MARK: Initialization
    init(comment: String, photo: UIImage, created: String) {
        self.comment = comment
        self.photo = photo
        self.created = created
    }
}