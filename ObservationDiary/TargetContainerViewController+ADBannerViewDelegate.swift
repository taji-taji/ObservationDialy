//
//  TargetContainerViewController+ADBannerViewDelegate.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/17.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import iAd

extension TargetContainerViewController: ADBannerViewDelegate {

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adView.adBannerView.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adView.adBannerView.hidden = true
    }

}