//
//  AdView.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/16.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import GoogleMobileAds

@IBDesignable
class AdView: UIView {
    
    @IBOutlet weak var adBannerView: GADBannerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }

    private func comminInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "AdView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)
        adBannerView.adSize = kGADAdSizeSmartBannerPortrait
        
        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))

    }
    
}
