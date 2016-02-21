//
//  VideoPlayerOverlayViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/21.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import MobilePlayer
import RMUniversalAlert

class VideoPlayerOverlayViewController: MobilePlayerOverlayViewController {
    
    var filePath: String?
    var target: TargetData?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func saveVideo(sender: UIButton) {
        
        guard let filePath = filePath else {
            return
        }
        
        RMUniversalAlert.showAlertInViewController(self,
            withTitle: "ムービーの保存",
            message: "ムービーをカメラロールに保存します",
            cancelButtonTitle: "キャンセル",
            destructiveButtonTitle: "OK",
            otherButtonTitles: nil) { (alert, index) -> Void in
                if index == alert.destructiveButtonIndex {
                    LoadingProxy.set(self.parentViewController!)
                    LoadingProxy.on()
                    UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, "video:didFinishSavingWithError:contextInfo:", nil)
                }
        }
        
    }
    
    @IBAction func tweetWithVideo(sender: UIButton) {
        guard let shareMovieViewController = R.storyboard.shareMovie.shareMovieVC(), target = target else {
            return
        }
        shareMovieViewController.modalTransitionStyle = .CrossDissolve
        shareMovieViewController.modalPresentationStyle = .OverCurrentContext
        shareMovieViewController.target = target
        let photos = target.photos
        if photos.count > 0 {
            let photo = photos[0]
            let fileName = photo.photo
            if let jpeg = PhotoUtility().get(fileName) {
                shareMovieViewController.thumbImage = jpeg
            }
        }
        self.presentViewController(shareMovieViewController, animated: true, completion: nil)
    }
    
    func video(videoPath: String, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        var title: String
        LoadingProxy.off()
        if let _ = error {
            title = "ムービーの保存に失敗しました"
        } else {
            title = "ムービーを保存しました"
        }
        let myAlert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        myAlert.addAction(ok)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
}
