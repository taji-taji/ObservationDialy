//
//  Tour.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/25.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import Foundation
import UIKit
import EasyTipView

struct Tour {
    
    var preferences = EasyTipView.Preferences()
    let easyTipView: EasyTipView
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var isShowing = false
    
    static let ADD_TARGET_TEXT = "「+」ボタンから新しい記録を追加することができます。\n早速、新しい記録を追加してみましょう！"
    static let EDIT_TARGET_TEXT = "歯車ボタンをタップすると記録のタイトルの編集・記録の削除ができる画面に移動します。"
    static let TAKE_PHOTO_TEXT = "カメラボタンから写真を撮影して記録をつけていきましょう！"
    static let EDIT_PHOTO_TEXT = "ここからコメントの編集や写真の削除ができます。"
    static let CHECK_MOVIE_TEXT = "写真を3枚以上撮ると自動的にムービーが作成されます。作成されたムービーはここから確認できます。"
    
    enum TourType: String {
        case AddTarget
        case EditTarget
        case TakePhoto
        case EditPhoto
        case CheckMovie
    }
    
    init (text: String) {
        preferences.drawing.backgroundColor = Constants.Theme.subConcept
        preferences.drawing.foregroundColor = Constants.Theme.textColor
        //preferences.drawing.font = UIFont(name: "HelveticaNeue-Regular", size: 10)!
        preferences.drawing.textAlignment = NSTextAlignment.Center
        easyTipView = EasyTipView(text: text, preferences: preferences, delegate: nil)
    }

    mutating func tour(tourType: TourType, forView: AnyObject, superView: UIView?) {
        if load(tourType) {
            return
        }
        // それぞれのツアー
        start(forView, superView: superView)
        save(tourType, value: true)
    }
    
    func getInstance() -> EasyTipView {
        return easyTipView
    }
    
    mutating func close() {
        if isShowing {
            easyTipView.dismiss()
            isShowing = false
        }
    }
    
    // ツアーが終わっているかを読み込む
    private func load(tourType: TourType) -> Bool {
        if let value = userDefaults.objectForKey(tourType.rawValue) {
            return value as! Bool
        }
        return false
    }
    
    // ツアー完了を保存する
    private func save(tourType: TourType, value: Bool) {
        userDefaults.setObject(value, forKey: tourType.rawValue)
        userDefaults.synchronize()
    }

    // それぞれのツアーを開始
    private mutating func start(forView: AnyObject, superView: UIView?) {
        if forView is UIView {
            easyTipView.show(
                animated: true,
                forView: forView as! UIView,
                withinSuperview: superView
            )
        } else if forView is UIBarButtonItem {
            easyTipView.show(
                animated: true,
                forItem: forView as! UIBarButtonItem,
                withinSuperView: superView
            )
        }
        isShowing = true
    }
}