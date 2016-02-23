//
//  Twitter.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/13.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Social
import Accounts
import SwiftyJSON

struct Twitter {
    
    enum Status {
        case Granted
        case NotGranted
        case NoAccount
        case Error
    }
    
    var account: ACAccount
    let fileManager = NSFileManager.defaultManager()
    
    init(account: ACAccount) {
        self.account = account
    }
    
    let uploadURL = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")
    let statusURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
    
    func postWithMovie(tweet: String, fileName: String, success: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void, failure: ((error: NSError!) -> Void)?) {
        let videoUtility = VideoUtility()
        guard let filePath = videoUtility.get(fileName),
            mediaData = NSData(contentsOfFile: filePath) else {
            return
        }
        do {
            let fileAttr = try fileManager.attributesOfItemAtPath(filePath)
            if let fileSize = fileAttr[NSFileSize] as? Int {
                postMedia(tweet, mediaData: mediaData, fileSize: String(fileSize), success: success, failure: failure)
            }
        } catch {
            return
        }
    }
    
    private func postMedia(tweet: String, mediaData: NSData, fileSize: String, success: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void, failure: ((error: NSError!) -> Void)?) {

        uploadVideoInitRequest(fileSize, success: { (responseData) -> () in
            let json = JSON(data: responseData)
            let mediaIdString = json["media_id_string"].stringValue
            self.uploadVideoAppendRequest(mediaData, mediaIdString: mediaIdString, success: { () -> () in
                self.uploadVideoFinalizeRequest(mediaIdString, success: { (responseData) -> () in
                    
                    let statusKey: NSString = "status"
                    let mediaIDKey: NSString = "media_ids"
                    
                    let statusRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: self.statusURL, parameters: [statusKey : tweet, mediaIDKey : mediaIdString])
                    
                    statusRequest.account = self.account
                    
                    statusRequest.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                        if let error = error {
                            failure?(error: error)
                        }
                        success(responseData: responseData, urlResponse: urlResponse)
                    }
                    
                    }, failure: { (error) -> () in
                        failure?(error: error)
                })
                }, failure: { (error) -> () in
                    failure?(error: error)
            })
            }) { (error) -> () in
                failure?(error: error)
        }
    }

    private func uploadVideoInitRequest(fileSize: String, success: (responseData: NSData) -> (), failure: ((error: NSError) -> ())?) {
        let commandKey: NSString = "command"
        let mediaTypeKey: NSString = "media_type"
        let totalBytesKey: NSString = "total_bytes"
        let initParams: [NSString: AnyObject] = [commandKey: "INIT", mediaTypeKey: "video/mp4", totalBytesKey: fileSize]
        let initRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: self.uploadURL, parameters: initParams)
        initRequest.account = account
        initRequest.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
            if let error = error {
                failure?(error: error)
            }
            success(responseData: responseData)
        }
    }
    
    private func uploadVideoAppendRequest(mediaData: NSData, mediaIdString: String, success: () -> (), failure: ((error: NSError) -> ())?) {
        let commandKey: NSString = "command"
        let mediaIdKey: NSString = "media_id"
        let segmentIndexKey: NSString = "segment_index"
        let appendParam: [NSString: AnyObject] = [commandKey: "APPEND", mediaIdKey: mediaIdString, segmentIndexKey: "0"]
        let appendRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: self.uploadURL, parameters: appendParam)
        appendRequest.addMultipartData(mediaData, withName: "media", type: "video/mp4", filename: nil)
        appendRequest.account = account
        appendRequest.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
            if let error = error {
                failure?(error: error)
            }
            if urlResponse.statusCode < 300 && urlResponse.statusCode >= 200 {
                success()
            }
        }
    }
    
    private func uploadVideoFinalizeRequest(mediaIdString: String, success: (responseData: NSData) -> (), failure: ((error: NSError) -> ())?) {
        let commandKey: NSString = "command"
        let mediaIdKey: NSString = "media_id"
        let finalizeParam: [NSString: AnyObject] = [commandKey: "FINALIZE", mediaIdKey: mediaIdString]
        let finalizeRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: self.uploadURL, parameters: finalizeParam)
        finalizeRequest.account = account
        finalizeRequest.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
            if let error = error {
                failure?(error: error)
            }
            success(responseData: responseData)
        }
    }
    
    static func getAccounts(callback: (([ACAccount]?, Status)) -> Void) {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        var status = Status.Error
        var accounts: [ACAccount]?
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
            accounts = accountStore.accountsWithAccountType(accountType) as? [ACAccount]
            if let _ = error {
                status = Status.Error
            } else if accounts?.count == 0 {
                status = Status.NoAccount
            } else if !granted {
                status = Status.NotGranted
            } else {
                status = Status.Granted
            }
            callback((accounts, status))
        }
    }
    
}
