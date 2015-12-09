////
////  TargetTableViewController.swift
////  ObservationDiary
////
////  Created by tajika on 2015/10/20.
////  Copyright © 2015年 Tajika. All rights reserved.
////
//
//import UIKit
//import iAd
//
//class TargetTableViewController: UITableViewController {
//    
//    // MARK: - Properties
//
//    var targets = Storage().findAll(TargetData(), orderby: "updated", ascending: false)
//    var addTargetTour: Tour
//    var editTargetTour: Tour
//    
//    // MARK: - Initialization
//    required init?(coder aDecoder: NSCoder) {
//        addTargetTour = Tour(text: Tour.ADD_TARGET_TEXT)
//        editTargetTour = Tour(text: Tour.EDIT_TARGET_TEXT)
//        super.init(coder: aDecoder)
//    }
//
//    // MARK: - View life cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.canDisplayBannerAds = true
//
//        addTargetTour.tour(.AddTarget, forView: self.navigationItem.rightBarButtonItem!, superView: nil)
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        self.targets = Storage().findAll(TargetData(), orderby: "updated", ascending: false)
//        self.tableView.reloadData()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    // MARK: - Actions
//
//    func deleteTarget(notification: NSNotification) {
//        if let userInfo = notification.userInfo, indexPath = userInfo["indexPath"] as? NSIndexPath {
//            NSNotificationCenter.defaultCenter().removeObserver(self)
//
//            // 削除ターゲットデータを取得
//            let deleteData: TargetData = self.targets[indexPath.row]
//        
//            // 画像ファイル名をすべて取得
//            var deleteFiles: [String] = []
//            for photo in deleteData.photos {
//                deleteFiles.append(photo.photo)
//            }
//        
//            // 動画ファイル名を取得
//            let deleteVideo = "\(deleteData.id).mp4"
//        
//            // データを削除
//            Storage().delete(deleteData)
//            self.targets.removeAtIndex(indexPath.row)
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        
//            // 画像ファイルをすべて削除
//            for fileName in deleteFiles {
//                PhotoUtility().delete(fileName)
//            }
//        
//            // 動画ファイル削除
//            VideoUtility().delete(deleteVideo)
//        }
//    }
//
//    // MARK: - Navigation
//
//    // 次の画面にデータを渡す
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//
//        addTargetTour.close()
//        editTargetTour.close()
//
//        if let selectedTargetCell = sender as? TargetTableViewCell {
//            
//            // 選択したセルのindexPathを取得
//            let indexPath = tableView.indexPathForCell(selectedTargetCell)!
//            // indexPathからTargetを取得
//            let selectedTarget = targets[indexPath.row]
//            
//            if segue.identifier == "targetPhotoSegue" {
//                // 次の画面のViewControllerを取得
//                let targetPhotoViewController = segue.destinationViewController as? PhotoContainerViewController
//                // 次のViewControllerに渡す
//                targetPhotoViewController?.target = selectedTarget
//            }
//            
//        } else if let senderButton = sender as? UIButton {
//            
//            if segue.identifier == "ModifyItem" {
//                
//                // 選択したセルを取得
//                let selectedTargetCell = TableUtility().findUITableViewCellFromSuperViewsForView(senderButton)
//                // 選択したセルのindexPathを取得
//                let indexPath = tableView.indexPathForCell(selectedTargetCell)!
//                // indexPathからTargetを取得
//                let selectedTarget = targets[indexPath.row]
//    
//                // 次の画面のViewControllerを取得
//                let targetViewController = segue.destinationViewController as? TargetViewController
//                print(selectedTarget, selectedTarget.title)
//                // 半透明にする処理
//                targetViewController!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//                
//                targetViewController!.titleText = selectedTarget.title
//                targetViewController!.pageTitle = "記録タイトルの編集"
//                targetViewController!.completeButtonText = "変更"
//                targetViewController!.targetId = selectedTarget.id
//                targetViewController!.isUpdate = true
//                targetViewController!.indexPath = indexPath
//                
//                if let photo = selectedTarget.photos.last {
//                    if let jpeg: UIImage? = PhotoUtility().get(photo.photo) {
//                        targetViewController!.targetImage = jpeg
//                    }
//                // 画像がない場合はデフォルト画像
//                } else {
//                    targetViewController!.targetImage = UIImage(named: "DefaultPhoto")
//                }
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteTarget:", name: "deleteTarget", object: nil)
//            }
//
//        } else if segue.identifier == "AddItem" {
//            let targetViewController = segue.destinationViewController as? TargetViewController
//            // 半透明にする処理
//            targetViewController!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//        }
//
//    }
//
//    @IBAction func unwindToTargetList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.sourceViewController as? TargetViewController, target = sourceViewController.target {
//            
//            if sourceViewController.isUpdate {
//                targets = Storage().findAll(TargetData(), orderby: "updated", ascending: false)
//                self.tableView.reloadData()
//            } else {
//                // targetの追加
//                // 0番目のindexPath
//                let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
//                // 0番目のindexPathに新規targetが来るように配列の0番目に追加
//                self.targets.insert(target, atIndex: 0)
//            
//                // テーブル挿入完了後の処理を書くため
//                CATransaction.begin()
//                self.tableView.beginUpdates()
//                
//                // テーブルに挿入
//                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
//                
//                // テーブル挿入完了後の処理
//                CATransaction.setCompletionBlock({ () -> Void in
//                    if let cell = self.tableView.cellForRowAtIndexPath(newIndexPath) as? TargetTableViewCell {
//                        self.editTargetTour.tour(.EditTarget, forView: cell.editTargetButton, superView: self.tableView)
//                    }
//                })
//                
//                self.tableView.endUpdates()
//                CATransaction.commit()
//            }
//        }
//    }
//
//}
//
//
//extension TargetTableViewController {
//
//    // MARK: - Table view data source
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return targets.count
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let target = targets[indexPath.row]
//        
//        let cellIdentifier = "TargetTableViewCell"
//        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TargetTableViewCell
//        cell.titleLabel.text = target.title
//        cell.updatedLabel.text = DateUtility(dateFormat: nil).dateFromNow(target.updated)
//        
//        // 最新の画像をサムネイルに入れる
//        if let photo = target.photos.last {
//            if let jpeg: UIImage? = PhotoUtility().get(photo.photo) {
//                cell.photoImageView.image = jpeg
//            }
//            // 画像がない場合はデフォルト画像
//        } else {
//            cell.photoImageView.image = UIImage(named: "DefaultPhoto")
//        }
//        
//        return cell
//        
//    }
//}
