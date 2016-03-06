//
//  VideoPlayerViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/16.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MobilePlayer

class VideoPlayerViewController: MobilePlayerViewController {
    
    var fileName: String?
    
    override init(contentURL: NSURL, config: MobilePlayerConfig, prerollViewController: MobilePlayerOverlayViewController?, pauseOverlayViewController: MobilePlayerOverlayViewController?, postrollViewController: MobilePlayerOverlayViewController?) {
        super.init(contentURL: contentURL, config: config, prerollViewController: prerollViewController, pauseOverlayViewController: pauseOverlayViewController, postrollViewController: postrollViewController)
    }
    
    convenience init(contentPath: String, target: TargetData?) {
        
        let contentURL = NSURL(fileURLWithPath: contentPath)
        
        let closeButtonDict = ["type": "button", "identifier": "close"]
        let dict: [String: AnyObject] = ["elements": [closeButtonDict]]
        
        let configDict: [String: AnyObject] = [
            "topBar": dict]
        let playerConfig = MobilePlayerConfig(dictionary: configDict)

        let overlayViewController = R.storyboard.videoPlayerOverlay.videoPlayerOverlayVC()
        overlayViewController?.filePath = contentPath
        overlayViewController?.target = target
        
        self.init(contentURL: contentURL, config: playerConfig, prerollViewController: overlayViewController, pauseOverlayViewController: overlayViewController, postrollViewController: nil)

        self.activityItems = nil
        self.shouldAutoplay = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
    }

}
