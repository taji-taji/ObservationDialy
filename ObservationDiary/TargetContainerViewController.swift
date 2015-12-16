//
//  TargetContainerViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/10.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import iAd

class TargetContainerViewController: UIViewController, ADBannerViewDelegate {
    
    // MARK: - Properties
    var targets = Storage().findAll(TargetData(), orderby: "updated", ascending: false)
    var addTargetTour: Tour
    var editTargetTour: Tour
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTargetView: UIView!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        addTargetTour = Tour(text: Tour.ADD_TARGET_TEXT)
        editTargetTour = Tour(text: Tour.EDIT_TARGET_TEXT)
        super.init(coder: aDecoder)
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAndSwitchNoTargetView()
        
        addTargetTour.tour(.AddTarget, forView: self.navigationItem.rightBarButtonItem!, superView: nil)

        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.targets = Storage().findAll(TargetData(), orderby: "updated", ascending: false)
        self.tableView.reloadData()
        if self.targets.count == 0 {
            self.noTargetView.hidden = false
        }
        
        adView.adBannerView.delegate = self
        adView.adBannerView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adView.adBannerView.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adView.adBannerView.hidden = true
    }
    
    // MARK: - Actions
    
    func deleteTarget(notification: NSNotification) {
        if let userInfo = notification.userInfo, indexPath = userInfo["indexPath"] as? NSIndexPath {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            
            // 削除ターゲットデータを取得
            let deleteData: TargetData = self.targets[indexPath.row]
            
            // 画像ファイル名をすべて取得
            var deleteFiles: [String] = []
            for photo in deleteData.photos {
                deleteFiles.append(photo.photo)
            }
            
            // 動画ファイル名を取得
            let deleteVideo = "\(deleteData.id).mp4"
            
            // データを削除
            Storage().delete(deleteData)
            self.targets.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // 画像ファイルをすべて削除
            for fileName in deleteFiles {
                PhotoUtility().delete(fileName)
            }
            
            // 動画ファイル削除
            VideoUtility().delete(deleteVideo)
            
            checkAndSwitchNoTargetView()
        }
    }
    
    // MARK: - Navigation
    
    // 次の画面にデータを渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        addTargetTour.close()
        editTargetTour.close()
        
        if let selectedTargetCell = sender as? TargetTableViewCell {
            
            // 選択したセルのindexPathを取得
            let indexPath = tableView.indexPathForCell(selectedTargetCell)!
            // indexPathからTargetを取得
            let selectedTarget = targets[indexPath.row]
            
            if segue.identifier == "targetPhotoSegue" {
                // 次の画面のViewControllerを取得
                let targetPhotoViewController = segue.destinationViewController as? PhotoContainerViewController
                // 次のViewControllerに渡す
                targetPhotoViewController?.target = selectedTarget
            }
            
        } else if let senderButton = sender as? UIButton {
            
            if segue.identifier == "ModifyItem" {
                
                // 選択したセルを取得
                let selectedTargetCell = TableUtility().findUITableViewCellFromSuperViewsForView(senderButton)
                // 選択したセルのindexPathを取得
                let indexPath = tableView.indexPathForCell(selectedTargetCell)!
                // indexPathからTargetを取得
                let selectedTarget = targets[indexPath.row]
                
                // 次の画面のViewControllerを取得
                let targetViewController = segue.destinationViewController as? TargetViewController
                print(selectedTarget, selectedTarget.title)
                // 半透明にする処理
                targetViewController!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                
                targetViewController!.titleText = selectedTarget.title
                targetViewController!.pageTitle = "記録タイトルの編集"
                targetViewController!.completeButtonText = "変更"
                targetViewController!.targetId = selectedTarget.id
                targetViewController!.isUpdate = true
                targetViewController!.indexPath = indexPath
                
                if let photo = selectedTarget.photos.last {
                    if let jpeg: UIImage? = PhotoUtility().get(photo.photo) {
                        targetViewController!.targetImage = jpeg
                    }
                    // 画像がない場合はデフォルト画像
                } else {
                    targetViewController!.targetImage = UIImage(named: "DefaultPhoto")
                }
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteTarget:", name: "deleteTarget", object: nil)
            }
            
        } else if segue.identifier == "AddItem" {
            let targetViewController = segue.destinationViewController as? TargetViewController
            // 半透明にする処理
            targetViewController!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
        
    }
    
    @IBAction func unwindToTargetList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? TargetViewController, target = sourceViewController.target {
            
            if sourceViewController.isUpdate {
                targets = Storage().findAll(TargetData(), orderby: "updated", ascending: false)
                self.tableView.reloadData()
            } else {
                // targetの追加
                // 0番目のindexPath
                let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                // 0番目のindexPathに新規targetが来るように配列の0番目に追加
                self.targets.insert(target, atIndex: 0)
                
                // テーブル挿入完了後の処理を書くため
                CATransaction.begin()
                self.tableView.beginUpdates()
                
                // テーブルに挿入
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
                
                // テーブル挿入完了後の処理
                CATransaction.setCompletionBlock({ () -> Void in
                    if let cell = self.tableView.cellForRowAtIndexPath(newIndexPath) as? TargetTableViewCell {
                        self.editTargetTour.tour(.EditTarget, forView: cell.editTargetButton, superView: self.tableView)
                    }
                })
                
                self.tableView.endUpdates()
                CATransaction.commit()
                checkAndSwitchNoTargetView()
            }
        }
    }
    
    private func checkAndSwitchNoTargetView() {
        self.noTargetView.hidden = self.targets.count != 0
    }
    
}
