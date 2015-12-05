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
            return "1.0"
        }
    }
    
    struct Theme {
        static func concept() -> UIColor {
            return UIColor(red: 87.0/255, green: 194.0/255, blue: 158.0/255, alpha: 1.0)
        }
        static func subConcept() -> UIColor {
            return UIColor(red: 197.0/255, green: 240.0/255, blue: 197.0/255, alpha: 1.0)
        }
        static func textColor() -> UIColor {
            return UIColor(red: 94.0/255, green: 85.0/255, blue: 81.0/255, alpha: 1.0)
        }
        static func base() -> UIColor {
            return UIColor(red: 242.0/255, green: 244.0/255, blue: 237.0/255, alpha: 1.0)
        }
        static func gray() -> UIColor {
            return UIColor(red: 66.0/255, green: 67.0/255, blue: 64.0/255, alpha: 1.0)
        }
    }
}
