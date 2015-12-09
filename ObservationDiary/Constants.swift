//
//  Constants.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct Photo {
        // コメントの最大文字数
        static let commentMaxCharacters: Int = 300
    }
    
    struct Video {
        // 動画を作成する最小の画像数
        static let minPhotos = 3
        // 動画を作成する最大の画像数
        static let maxPhotos = 400
        // 動画の拡張子
        static let VideoExtension = "mp4"
    }
    
    struct Product {
        static func version() -> String {
            return "1.0.2"
        }
    }
    
    struct Theme {
        static func concept() -> UIColor {
            return UIColor(intRed: 87, green: 194, blue: 158, alpha: 1.0)
        }
        static func subConcept() -> UIColor {
            return UIColor(intRed: 197, green: 240, blue: 197, alpha: 1.0)
        }
        static func textColor() -> UIColor {
            return UIColor(intRed: 94, green: 85, blue: 81, alpha: 1.0)
        }
        static func base() -> UIColor {
            return UIColor(intRed: 242, green: 244, blue: 237, alpha: 1.0)
        }
        static func gray() -> UIColor {
            return UIColor(intRed: 26, green: 26, blue: 26, alpha: 1.0)
        }
    }
}
