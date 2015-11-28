//
//  DateUtility.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/15.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import Foundation
import UIKit

class DateUtility {
    
    let formatter = NSDateFormatter()
    let now = NSDate()
    
    init(dateFormat: String?) {
        if dateFormat != nil {
            formatter.dateFormat = dateFormat
        } else {
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        }
    }
    
    func dateToStr(date: NSDate) -> String {
        return formatter.stringFromDate(date)
    }
    
    func dateFromNow(date: NSDate) -> String? {
        // 現在時刻との差
        let diff = NSDate().timeIntervalSinceDate(date)
        var fromNow: String
        if diff < 60 {
            fromNow = "1分以内"
        } else if (diff >= 60 && diff < 3600) {
            fromNow = String(Int(diff / 60)) + "分前"
        } else if (diff >= 3600 && diff < 3600 * 24) {
            fromNow = String(Int(diff / 3600)) + "時間前"
        } else {
            fromNow = String(Int(diff / (3600 * 24))) + "日前"
        }
        return fromNow
    }

    func strToDate(str: String) -> NSDate? {
        if let date = formatter.dateFromString(str) {
            return date
        }
        return nil
    }
    
    func strToDateFromNow(str: String) -> String? {
        if let date = strToDate(str) {
            // 現在時刻との差
            let diff = NSDate().timeIntervalSinceDate(date)
            var fromNow: String
            if diff < 60 {
                fromNow = "1分以内"
            } else if (diff >= 60 && diff < 3600) {
                fromNow = String(Int(diff / 60)) + "分前"
            } else if (diff >= 3600 && diff < 3600 * 24) {
                fromNow = String(Int(diff / 3600)) + "時間前"
            } else {
                fromNow = String(Int(diff / (3600 * 24))) + "日前"
            }
            return fromNow
        }
        return nil
    }
}
