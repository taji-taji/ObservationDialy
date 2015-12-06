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

// MARK: - UIColor

extension UIColor {

    class func rgba(r: Int, g: Int, b: Int, a: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    class func hexString(hex: String) -> UIColor {
        let scanner = NSScanner(string: hex)
        var color:UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat((color & 0x0000FF)) / 255.0
            return UIColor(red:r, green:g, blue:b, alpha: 1)
        } else {
            print("invalid hex string")
            return UIColor.whiteColor()
        }
    }

}

// MARK: - UIView

extension UIView {
    
    enum BorderPosition {
        case Top
        case Right
        case Bottom
        case Left
    }

    func border(borderWidth borderWidth: CGFloat, borderColor: UIColor?, borderRadius: CGFloat?) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.CGColor
        if borderRadius != nil {
            self.layer.cornerRadius = borderRadius!
        }
        self.layer.masksToBounds = true
    }
    
    func border(position: BorderPosition, borderWidth: CGFloat, borderColor: UIColor?) {
        let line = CALayer()
        switch position {
        case .Top:
            line.frame = CGRectMake(0.0, 0.0, self.frame.width, borderWidth)
        case .Left:
            line.frame = CGRectMake(0.0, 0.0, borderWidth, self.frame.height)
        case .Bottom:
            line.frame = CGRectMake(0.0, self.frame.height - borderWidth, self.frame.width, borderWidth)
        case .Right:
            line.frame = CGRectMake(self.frame.width - borderWidth, 0.0, borderWidth, self.frame.height)
        }
        if borderColor != nil {
            line.backgroundColor = borderColor!.CGColor
        } else {
            line.backgroundColor = UIColor.whiteColor().CGColor
        }
        self.layer.addSublayer(line)
    }

}
