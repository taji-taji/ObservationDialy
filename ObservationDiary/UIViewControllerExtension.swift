//
//  UIViewControllerExtension.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/05.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIViewController: AdViewProtocol, GADBannerViewDelegate {
    
    func loadAd(adView: AdView) {
        prepareAdView(adView)
        adView.adBannerView.loadRequest(GADRequest())
    }
    
    private func prepareAdView(adView: AdView) {
        if let unitId = KeyManager().getValue("AdMobAdUnitID") as? String {
            adView.adBannerView.adUnitID = unitId
        }
        adView.adBannerView.delegate = self
        adView.adBannerView.rootViewController = self
    }
    
    public func adViewDidReceiveAd(bannerView: GADBannerView!) {
        bannerView.alpha = 1
    }
    
}