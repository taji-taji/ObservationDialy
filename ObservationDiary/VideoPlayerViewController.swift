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

class VideoPlayerViewController: AVPlayerViewController {
    
    var fileName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fileName != nil {
            
            let filePath = VideoUtility().get(fileName!)
        
            // 動画ファイルのURLを取得
            let url = NSURL(fileURLWithPath: filePath!)
        
            // アイテム取得
            let playerItem = AVPlayerItem(URL: url)
            
            // 生成
            player = AVPlayer(playerItem: playerItem)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
