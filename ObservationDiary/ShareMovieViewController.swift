//
//  ShareMovieViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/13.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material
import Social
import Accounts
import RMUniversalAlert

class ShareMovieViewController: UIViewController {
    
    @IBOutlet weak var twitterBaseView: ModalView!
    @IBOutlet weak var tweetTextView: BasicTextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: ImageThumbnailView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var tweetSendButton: FilledButton!
    @IBOutlet weak var accountPicker: UIPickerView!
    @IBOutlet weak var pickerViewHeightConstraint: NSLayoutConstraint!
    var accounts = [ACAccount]()
    var accountStatus: Twitter.Status?
    var account: ACAccount?
    var target: TargetData?
    var thumbImage: UIImage?
    let maxCount = 140

    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountPicker.delegate = self
        accountPicker.dataSource = self
        accountPicker.userInteractionEnabled = false
        tweetTextView.textView.delegate = self
        tweetTextView.textView.placeholderLabel?.text = "ツイート内容を入力してください"
        tweetTextView.textView.becomeFirstResponder()
        LoadingProxy.set(self)
    
        pickerViewHeightConstraint.constant = 0
        titleLabel.text = "Twitterアカウント"
        
        if let thumbImage = thumbImage {
            imageView.image = thumbImage
        }

        getAccounts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let target = target else {
            self.close()
            return
        }
        let fileName = "\(target.id)\(Constants.Video.VideoExtension)"
        if !checkFileDuration(fileName) {
            RMUniversalAlert.showAlertInViewController(self,
                withTitle: "動画の再生時間が短いためTwitterに投稿できません。",
                message: "0.5秒以上になると動画Twitterへ動画の共有ができるようになります。もう少し成長記録をつけてみましょう。",
                cancelButtonTitle: "OK",
                destructiveButtonTitle: nil,
                otherButtonTitles: nil, tapBlock: { (alert, index) -> Void in
                    self.close()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancel(sender: BasicButton) {
        self.close()
    }

    @IBAction func send(sender: FilledButton) {
        guard let account = account, target = target else {
            return
        }
        let fileName = "\(target.id)\(Constants.Video.VideoExtension)"
        LoadingProxy.on()
        tweetTextView.textView.resignFirstResponder()
        let twitter = Twitter(account: account)
        twitter.postWithMovie(tweetTextView.textView.text,
            fileName: fileName,
            success: { (responseData, urlResponse) -> Void in
                LogManager.setLogEvent(.TweetMovie)
                RMUniversalAlert.showAlertInViewController(self,
                    withTitle: "ツイートしました！",
                    message: nil,
                    cancelButtonTitle: "OK",
                    destructiveButtonTitle: nil,
                    otherButtonTitles: nil,
                    tapBlock: {(alert, index) -> Void in
                        LoadingProxy.off()
                        self.close()
                })
            }) { (error) -> Void in
                LoadingProxy.off()
        }
    }
    
    private func getAccounts() {
        LoadingProxy.on()
        Twitter.getAccounts { (accountList) -> Void in
            LoadingProxy.off()
            guard let someAccounts = accountList.0 where someAccounts.count > 0 else {
                self.accountStatus = .NoAccount
                RMUniversalAlert.showAlertInViewController(self,
                    withTitle: "アカウントが設定されていません",
                    message: "Twitterのアカウントを設定の上、ご利用ください",
                    cancelButtonTitle: "OK",
                    destructiveButtonTitle: nil,
                    otherButtonTitles: nil, tapBlock: {(alert, index) -> Void in
                        self.close()
                })
                return
            }
            self.accountStatus = accountList.1
            self.accounts = someAccounts
            self.account = self.accounts[0]
            if self.accounts.count == 1 {
                self.pickerViewHeightConstraint.constant = 50
            } else {
                self.pickerViewHeightConstraint.constant = 80
                self.titleLabel.text = "Twitterアカウント選択"
            }
            self.setPickerEnabled()
        }
    }
    
    private func setPickerEnabled() {
        switch accountStatus {
        case .None:
            break
        case .Some(let status):
            switch status {
            case .NotGranted:
                RMUniversalAlert.showAlertInViewController(self,
                    withTitle: "アカウントの利用が許可されていません",
                    message: nil,
                    cancelButtonTitle: "OK",
                    destructiveButtonTitle: nil,
                    otherButtonTitles: nil, tapBlock: { (alert, index) -> Void in
                        self.close()
                })
                break
            case .Error:
                break
            case .Granted:
                accountPicker.userInteractionEnabled = true
            default:
                break
            }
        }
    }
    
    private func checkFileDuration(fileName: String) -> Bool {
        guard let duration = VideoUtility().duration(fileName) where duration > 0.5 else {
            return false
        }
        print(duration)
        return true
    }
    
    private func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
