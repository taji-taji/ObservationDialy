//
//  ShareMovieViewController+TextViewDelegate.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/21.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

extension ShareMovieViewController: TextDelegate, TextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // 入力済みの文字と入力された文字を合わせて取得.
        var str = ""
        if range.length == 1 && text.isEmpty {
            let endIndex = tweetTextView.textView.text.startIndex.advancedBy(range.location)
            str = tweetTextView.textView.text.substringToIndex(endIndex)
        } else {
            str = tweetTextView.textView.text + text
        }
        
        setTweetTextCount(str)
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        setTweetTextCount(textView.text)
        tweetSendButton.enabled = validateTweet()
    }
    
    private func setTweetTextCount(text: String) {
        // 文字数が最大値以下
        if text.characters.count <= maxCount {
            countLabel.textColor = UIColor.darkGrayColor()
            let remainCount = maxCount - text.characters.count
            countLabel.text = "\(remainCount)"
        } else {
            countLabel.textColor = UIColor.redColor()
        }
    }
    
    private func validateTweet() -> Bool {
        return tweetTextView.textView.text.characters.count <= maxCount
    }
    
}