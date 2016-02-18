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

class ShareMovieViewController: UIViewController, TextDelegate, TextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountPicker.delegate = self
        accountPicker.dataSource = self
        accountPicker.userInteractionEnabled = false
        tweetTextView.textView.delegate = self
        tweetTextView.textView.becomeFirstResponder()
        
        pickerViewHeightConstraint.constant = 0
        titleLabel.text = "Twitterアカウント"
        
        getAccounts()
        
        switch accountStatus {
        case .None:
            break
        case .Some(let status):
            switch status {
            case .NotGranted:
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancel(sender: BasicButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func send(sender: FilledButton) {
        guard let account = account, target = target else {
            return
        }
        let twitter = Twitter(account: account)
        twitter.postWithMovie(tweetTextView.textView.text,
            fileName: "\(target.id)\(Constants.Video.VideoExtension)",
            success: { (responseData, urlResponse) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }) { (error) -> Void in
                print("failure...")
        }
    }
    
    private func getAccounts() {
        Twitter.getAccounts { (accountList) -> Void in
            switch accountList.0 {
            case .None:
                self.accountStatus = .NoAccount
            case .Some(let someAccounts):
                self.accountStatus = accountList.1
                self.accounts = someAccounts
                self.account = self.accounts[0]
                if self.accounts.count == 1 {
                    self.pickerViewHeightConstraint.constant = 50
                } else {
                    self.pickerViewHeightConstraint.constant = 80
                    self.titleLabel.text = "Twitterアカウント選択"
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accounts[row].username
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        account = accounts[row]
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // 入力済みの文字と入力された文字を合わせて取得.
        var str = ""
        if range.length == 1 && text.isEmpty {
            let endIndex = tweetTextView.textView.text.startIndex.advancedBy(range.location)
            str = tweetTextView.textView.text.substringToIndex(endIndex)
        } else {
            str = tweetTextView.textView.text + text
        }
        
        countTweetText(str)
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        countTweetText(textView.text)
    }
    
    private func countTweetText(text: String) {
        let maxCount = 140

        // 文字数が最大値以下
        if text.characters.count <= maxCount {
            countLabel.textColor = UIColor.darkGrayColor()
            let remainCount = maxCount - text.characters.count
            countLabel.text = "\(remainCount)"
        } else {
            countLabel.textColor = UIColor.redColor()
        }
    }

}
