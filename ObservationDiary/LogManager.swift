//
//  LogManager.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/28.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK
import Fabric
import Crashlytics

struct LogManager {
    
    enum EventName: String {
        case AddTarget
        case EditTarget
        case DeleteTarget
        case AddPhoto
        case EditPhoto
        case DeletePhoto
        case DownloadPhoto
        case DownloadMovie
        case TapAddTargetButton
        case TapEditTargetGearButton
        case TapDeleteTargetButton
        case TapEditPhotoMenuButton
        case TapEditPhotoButton
        case TapDeletePhotoButton
        case TapDownloadPhotoButton
        case TapMovieButton
        case TapMovieDownloadButton
        case TapMovieTweetButton
        case TweetMovie
        
        func insertSpace() -> String {
            return self.rawValue.characters.reduce("") { (str, char) -> String in
                if String(char).lowercaseString == String(char) || str.characters.count == 0 {
                    return str + String(char)
                } else {
                    return str + " " + String(char)
                }
            }
        }
    }
    
    static func startLogSession() {
        Fabric.with([Crashlytics.self])
        if let keyString = NSBundle.mainBundle().objectForInfoDictionaryKey("FlurryAPIKey") as? String, flurryAPIKey = KeyManager().getValue(keyString) as? String {
            Flurry.startSession(flurryAPIKey)
            Flurry.logPageView()
        }
    }
    
    static func setLogEvent(eventName: EventName, withParameters params: [NSObject : AnyObject] = [:]) {
        Flurry.logEvent(eventName.insertSpace(), withParameters: params, timed: true)
    }

}