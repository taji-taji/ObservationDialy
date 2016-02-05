//
//  NSDateExtension.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/05.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import Foundation

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
