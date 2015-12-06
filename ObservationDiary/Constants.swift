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
            return UIColor.rgba(87, g: 194, b: 158, a: 1.0)
        }
        static func subConcept() -> UIColor {
            return UIColor.rgba(197, g: 240, b: 197, a: 1.0)
        }
        static func textColor() -> UIColor {
            return UIColor.rgba(94, g: 85, b: 81, a: 1.0)
        }
        static func base() -> UIColor {
            return UIColor.rgba(242, g: 244, b: 237, a: 1.0)
        }
        static func gray() -> UIColor {
            return UIColor.rgba(26, g: 26, b: 26, a: 1.0)
        }
    }
}
