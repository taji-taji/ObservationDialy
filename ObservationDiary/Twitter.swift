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
import RMUniversalAlert

struct Twitter {
    
    enum Status {
        case Granted
        case NotGranted
        case NoAccount
        case Error
    }
    
    var account: ACAccount
    
    init(account: ACAccount) {
        self.account = account
    }
    
    let uploadURL = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")
    let statusURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
    
    func postWithImage(tweet: String, fileName: String, success: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void, failure: ((error: NSError!) -> Void)?) {
        let photoUtility = PhotoUtility()
        let filePath = photoUtility.getFilePath(fileName)
        guard let mediaData = NSData(contentsOfFile: filePath) else {
            return
        }
        postMedia(tweet, mediaData: mediaData, success: success, failure: failure)
    }
    
    func postWithMovie(tweet: String, fileName: String, success: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void, failure: ((error: NSError!) -> Void)?) {
        let videoUtility = VideoUtility()
        guard let filePath = videoUtility.get(fileName),
            mediaData = NSData(contentsOfFile: filePath) else {
            return
        }
        postMedia(tweet, mediaData: mediaData, success: success, failure: failure)
    }
    
    private func postMedia(tweet: String, mediaData: NSData, success: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void, failure: ((error: NSError!) -> Void)?) {
        let mediaKey: NSString = "media"
        let parameters = [mediaKey: mediaData]
        let uploadRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: self.uploadURL, parameters: parameters)
        
        uploadRequest.account = account
        
        uploadRequest.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
            
            guard let mediaIDString = self.twit_extractStringForKey("media_id_string", fromJSONData:responseData) else {
                failure?(error: error)
                return
            }

            let statusKey: NSString = "status"
            let mediaIDKey: NSString = "media_ids"
            
            let statusRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: self.statusURL, parameters: [statusKey : tweet, mediaIDKey : mediaIDString])
            
            statusRequest.account = self.account
            
            statusRequest.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                    
                    if let error = error {
                        failure?(error: error)
                    }
                    success(responseData: responseData, urlResponse: urlResponse)
            }
        }
    }
    
    private func twit_extractStringForKey(key: String, fromJSONData data: NSData?) -> String? {
        guard let _ = data else {
            return nil
        }
        do {
            let response = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
            let result = response?.objectForKey(key) as? String
            return result
        } catch {
            return nil
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
