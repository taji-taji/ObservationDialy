//
//  BaseScrollView.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/24.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit

class BaseScrollView: UIScrollView {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var bottomConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        setKeyboardObserver()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        guard let superview = self.superview else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraintEqualToAnchor(superview.topAnchor).active = true
        self.leadingAnchor.constraintEqualToAnchor(superview.leadingAnchor).active = true
        self.trailingAnchor.constraintEqualToAnchor(superview.trailingAnchor).active = true
        
        bottomConstraint = self.bottomAnchor.constraintEqualToAnchor(superview.bottomAnchor)
        bottomConstraint?.active = true
    }
    
    func setKeyboardObserver() {
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidHide", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, bottomConstraint = bottomConstraint {
            let keyboardRect = keyboard.CGRectValue()
            bottomConstraint.constant = -keyboardRect.height
        }
    }
    
    func keyboardDidHide() {
        if let bottomConstraint = bottomConstraint {
            bottomConstraint.constant = 0
        }
    }
    
}
