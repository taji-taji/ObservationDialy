//
//  LoadingProxy.swift
//  PhotoLogger
//
//  Created by tajika on 2015/11/17.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

struct LoadingProxy {
    static var myActivityIndicator: UIActivityIndicatorView!
    
    static func set(v: UIViewController) {
        self.myActivityIndicator = UIActivityIndicatorView()
        self.myActivityIndicator.frame = CGRectMake(0, 0, v.view.bounds.width, v.view.bounds.height)
        self.myActivityIndicator.center = v.view.center
        self.myActivityIndicator.hidesWhenStopped = false
        self.myActivityIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.myActivityIndicator.backgroundColor = UIColor.blackColor()
        self.myActivityIndicator.layer.masksToBounds = true
        self.myActivityIndicator.layer.cornerRadius = 5.0
        self.myActivityIndicator.layer.opacity = 0.6

        v.view.addSubview(self.myActivityIndicator)
        
        self.off()
    }
    
    static func on() {
        myActivityIndicator.startAnimating()
        myActivityIndicator.hidden = false
    }
    
    static func off() {
        myActivityIndicator.stopAnimating()
        myActivityIndicator.hidden = true
    }
}
