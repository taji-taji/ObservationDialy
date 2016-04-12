//
//  AppVersionManager.swift
//  ObservationDiary
//
//  Created by tajika on 2016/04/12.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit

struct AppVersionManager {
    
    static var version: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "0.0.0"
    }
    
    static var loadedVersion: String {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey("appVersion") ?? "0.0.0"
    }
    
    static func setAppVersion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(version, forKey: "appVersion")
    }
    
    /**
     targetよりgreaterThanの方が大きい場合にtrueを返す
     */
    static func compareVersion(target: String, greaterThan: String) -> Bool {
        switch target.compare(greaterThan, options: .NumericSearch, range: nil, locale: nil) {
        case .OrderedAscending:
            return true
        case .OrderedDescending:
            return false
        case .OrderedSame:
            return false
        }
    }
    
    /**
     バージョンアップ時処理
     */
    static func versionUp(target: UIViewController) {
        if compareVersion(loadedVersion, greaterThan: version) {

            versionUp_1_2_5(target)
            // 以降、バージョンアップに何かする時にはここに追加する

            setAppVersion()
        }
    }
    
    /**
     1.2.5にあげた時
     */
    static func versionUp_1_2_5(target: UIViewController) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let tourEnded = defaults.objectForKey(Tour.TourType.AddTarget.rawValue) as? Bool
        // このバージョンのみ、loadedVersionが全ユーザ "0.0.0" になり、新規登録ユーザも該当してしまう
        // そのため、初回ツアーが終わっているかでアップデートユーザかを判断している
        // 今後は、 loadedVersion != "0.0.0" && compareVersion(loadedVersion, greaterThan: "1.2.5")
        // でアップデートユーザを判断する
        if compareVersion(loadedVersion, greaterThan: "1.2.5") && tourEnded == true {
            let title = "新機能追加！！"
            let message = "記録ごとにムービーの再生スピードの設定が可能になりました！\n「記録リスト」の歯車アイコンから設定ができます。ぜひ、お好みのスピードで成長ムービーをお楽しみください。"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(ok)
            
            target.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}


