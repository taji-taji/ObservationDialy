//
//  Constants.swift
//  PhotoLogger
//
//  Created by tajika on 2015/11/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    struct Video {
        // 動画を作成する最小の画像数
        static let minPhotos = 3
        // 動画を作成する最大の画像数
        static let maxPhotos = 400
    }
    
    struct Product {
        static func version() -> String {
            return "1.0"
        }
    }
    
    struct Theme {
        // Concept Theme RGB 127 214 154
        static func concept() -> UIColor {
            return UIColor(red: 127.0/255, green: 214.0/255, blue: 154.0/255, alpha: 1.0)
        }
        // Concept Theme RGB 147 196 125
        static func subConcept() -> UIColor {
            return UIColor(red: 71.0/255, green: 132.0/255, blue: 93.0/255, alpha: 1.0)
        }
        // Red RGB 245 245 245
        static func backGround() -> UIColor {
            return UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
        }
        // Red RGB 255 50 72 (#ff3248)
        static func reset() -> UIColor {
            return UIColor(red: 1.0, green: 50.0/255, blue: 72.0/255, alpha: 1.0)
        }
        // Twitter color RGB 62 150 238 (#3e96ee)
        static func twitter() -> UIColor {
            return UIColor(red: 62.0/255, green: 150.0/255, blue: 238.0/255, alpha: 1.0)
        }
        // Gray background RGB 242 244 237(#f2f4ed)
        static func base() -> UIColor {
            return UIColor(red: 242.0/255, green: 244.0/255, blue: 237.0/255, alpha: 1.0)
        }
        // Grayed font color 66 67 64
        static func gray() -> UIColor {
            return UIColor(red: 66.0/255, green: 67.0/255, blue: 64.0/255, alpha: 1.0)
        }
    }
}
