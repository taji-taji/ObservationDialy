//
//  UIViewControllerExtension.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/05.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Material

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
    
    func addNavigationBar() -> BaseNavigationBarView {
        let navigationBarView = BaseNavigationBarView(frame: CGRectZero)
        view.addSubview(navigationBarView)
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignFromTop(view, child: navigationBarView)
        MaterialLayout.alignToParentHorizontally(view, child: navigationBarView)
        MaterialLayout.height(view, child: navigationBarView, height: 66)
        return navigationBarView
    }
    
}