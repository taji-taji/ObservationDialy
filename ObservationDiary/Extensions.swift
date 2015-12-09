//
//  Extensions.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/06.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

// MARK: - UIImage

extension UIImage {
    
    // 画像が回転される問題を修正
    func fixOrientation () -> UIImage {
        if self.imageOrientation == .Up {
            return self
        }
        var transform = CGAffineTransformIdentity
        let width = self.size.width
        let height = self.size.height
        
        switch (self.imageOrientation) {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, width, height)
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default: // o.Up, o.UpMirrored:
            break
        }
        
        switch (self.imageOrientation) {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default: // o.Up, o.Down, o.Left, o.Right
            break
        }
        let cgimage = self.CGImage
        
        let ctx = CGBitmapContextCreate(nil, Int(width), Int(height),
            CGImageGetBitsPerComponent(cgimage), 0,
            CGImageGetColorSpace(cgimage),
            CGImageGetBitmapInfo(cgimage).rawValue)
        
        CGContextConcatCTM(ctx, transform)
        
        switch (self.imageOrientation) {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, height, width), cgimage)
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), cgimage)
        }
        let cgimg = CGBitmapContextCreateImage(ctx)
        let img = UIImage(CGImage: cgimg!)
        return img
    }
    
    func cropThumbnailImage(x x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {
        
        let fixedImage = self.fixOrientation()
        
        // 切り抜き処理
        let cropRect  = CGRectMake(x, y, width, height)
        let cropRef   = CGImageCreateWithImageInRect(fixedImage.CGImage!, cropRect)
        let cropImage = UIImage(CGImage: cropRef!)
        
        return cropImage
    }
}

// MARK: - NSDate

extension NSDate {
    class func strToDate(string: String) -> NSDate? {
        // タイムゾーンを言語設定にあわせる
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.dateFromString(string)
    }
    
    class func dateToStr(date: NSDate, format: String?) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        if format != nil {
            dateFormatter.dateFormat = format!
        } else {
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        }
        let dateString: String = dateFormatter.stringFromDate(date)
        return dateString
    }
}
