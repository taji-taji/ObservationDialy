//
//  PhotoContainerViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/21.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoContainerViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var target: TargetData?
    var photos: Results<PhotoData>?
    var takePhotoTour: Tour
    var editPhotoTour: Tour
    var checkMovieTour: Tour
    let realm = try! Realm()
    let now = NSDate()
    let heightForHeaderInSection: CGFloat = 45
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var noPhotoView: UIView!

    // MARK: - Initializetion

    required init?(coder aDecoder: NSCoder) {
        takePhotoTour = Tour(text: Tour.TAKE_PHOTO_TEXT)
        editPhotoTour = Tour(text: Tour.EDIT_PHOTO_TEXT)
        checkMovieTour = Tour(text: Tour.CHECK_MOVIE_TEXT)
        super.init(coder: aDecoder)
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let target = target {
            navigationItem.title = target.title
            photos = target.photos.sorted("created", ascending: false)
        }
        
        checkAndSwitchNoPhotoView()
        
        // セルの高さ
        tableView.estimatedRowHeight = 850
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "insertPhoto:", name: "photoAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePhoto:", name: "photoEdited", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        takePhotoTour.tour(.TakePhoto, forView: cameraBarButton, superView: self.view)
    }
    
    override func viewWillDisappear(animated: Bool) {
        takePhotoTour.close()
        editPhotoTour.close()
        checkMovieTour.close()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func checkAndSwitchNoPhotoView() {
        if self.photos != nil {
            self.noPhotoView.hidden = self.photos!.count != 0
        } else {
            self.noPhotoView.hidden = self.photos != nil
        }
    }
    
    // MARK: - Actions
    
    // カメラビューへ遷移
    @IBAction func addPhoto(sender: UIButton) {
        // 前回写真の取得
        let latestPhotoFile = target?.photos.last?.photo
        var latestPhotoImage: UIImage?
        
        if latestPhotoFile != nil {
            latestPhotoImage = PhotoUtility().get(latestPhotoFile!)
        }
        
        performSegueWithIdentifier("showCameraView", sender: latestPhotoImage)
    }
    
    // 写真を追加
    func insertPhoto(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let userInfo = notification.userInfo {
            let photo = userInfo["photo"] as! PhotoData
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            do {
                try realm.write {
                    defer {
                        // 全てのモーダルを閉じる
                        self.presentedViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                    self.target?.photos.append(photo)
                    self.tableView.reloadData()
                    
                    // テーブル挿入完了後の処理を書くため
                    CATransaction.begin()
                    self.tableView.beginUpdates()
                    
                    // テーブル挿入完了後の処理
                    CATransaction.setCompletionBlock({ () -> Void in
                        self.checkMovieTour.tour(.CheckMovie, forView: self.navigationItem.rightBarButtonItem!, superView: nil)
                        if let cell = self.tableView.cellForRowAtIndexPath(newIndexPath) as? PhotoTableViewCell {
                            self.editPhotoTour.tour(.EditPhoto, forView: cell.editButton, superView: self.tableView)
                        }
                    })
                    
                    self.tableView.endUpdates()
                    CATransaction.commit()
                    self.checkAndSwitchNoPhotoView()
                }
            } catch {
                print("error")
            }
        }
    }
    
    // 写真のデータ更新
    func updatePhoto(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.tableView.reloadData()
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 記録タイトルの編集
    func editTarget(sender: UIBarButtonItem) {
        performSegueWithIdentifier("ModifyItem", sender: self.target)
    }
    
    // ムービーの再生 or 保存
    @IBAction func movieAction(sender: UIBarButtonItem) {
        if photos?.count < Constants.Video.minPhotos {
            let myAlert = UIAlertController(title: "ムービーを再生できません", message: "ムービーは画像が３枚以上になると自動的に作成されます。", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            myAlert.addAction(ok)
            self.presentViewController(myAlert, animated: true, completion: nil)
            return
        }
        
        let videoFile = "\(self.target!.id).mp4"
        let videoPath = VideoUtility().get(videoFile)
        let tmpVideoPath = VideoUtility().get("tmp_" + videoFile)
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let play = UIAlertAction(title: "ムービーを見る", style: .Default, handler: {
            (action: UIAlertAction!) in
            let videoPlayerViewController = VideoPlayerViewController()
            videoPlayerViewController.fileName = videoFile
            // 一時ファイルが残っている場合は動画の作成に失敗しているので、一時ファイルから戻す
            if tmpVideoPath != nil {
                if videoPath != nil  {
                    do {
                        try NSFileManager().removeItemAtPath(videoPath!)
                    } catch {
                        print("error: Cannot remove video file")
                    }
                }
                do {
                    try NSFileManager().moveItemAtPath(tmpVideoPath!, toPath: VideoUtility().getFilePath(videoFile))
                } catch {
                    print("error: Cannot move tmp video file")
                }
            }
            // トランジションのスタイルを変更
            videoPlayerViewController.modalTransitionStyle = .CrossDissolve
            self.presentViewController(videoPlayerViewController, animated: true, completion: nil)
        })
        let download = UIAlertAction(title: "ムービーをカメラロールに保存する", style: .Default, handler: {
            (action: UIAlertAction!) in
            LoadingProxy.set(self.navigationController!)
            LoadingProxy.on()
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath!, self, "video:didFinishSavingWithError:contextInfo:", nil)
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        myAlert.addAction(play)
        myAlert.addAction(download)
        myAlert.addAction(cancel)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func video(videoPath: String, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        var title: String
        LoadingProxy.off()
        if (error != nil) {
            title = "ムービーの保存に失敗しました"
        } else {
            title = "ムービーを保存しました"
        }
        let myAlert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        myAlert.addAction(ok)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    // 既存の写真の編集ボタンを押した時の選択肢
    func editAlert(sender: UIGestureRecognizer) {
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "コメントを編集・削除する", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cell = TableUtility().findUITableViewCellFromSuperViewsForView(sender.view as! UIButton) as! PhotoTableViewCell
        
        let newIndexPath = self.tableView.indexPathForCell(cell)
        
        // アクションを生成
        let editPhoto = UIAlertAction(title: "編集する", style: .Default, handler: {
            (action: UIAlertAction!) in
            self.editPhoto(cell)
        })
        
        let deleteAlert = UIAlertAction(title: "削除する", style: .Default, handler: {
            (action: UIAlertAction!) in
            self.deleteAlert(cell.id!, indexPath: newIndexPath!)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        // アクションを追加
        myAlert.addAction(editPhoto)
        myAlert.addAction(deleteAlert)
        myAlert.addAction(cancel)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    // 編集ボタンを押した時
    func editPhoto(cell: PhotoTableViewCell) {
        // 画面遷移
        performSegueWithIdentifier("DetailPhotoSegue", sender: cell)
    }
    
    // 削除ボタンを押した時にアラートを出す
    func deleteAlert(id: Int, indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: "削除します。", message: "この操作は取り消せません。", preferredStyle: .Alert)
        let deletePhoto = UIAlertAction(title: "削除する", style: .Default, handler: {
            (action: UIAlertAction!) in
            self.deletePhoto(id, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction!) in
            print("cancelAction")
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(deletePhoto)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 画像の削除操作
    func deletePhoto(id: Int, indexPath: NSIndexPath) {
        editPhotoTour.close()
        let photo = Storage().find(PhotoData(), id: id)
        let fileName = photo!.photo
        let deleteIndex = (self.target?.photos.count)! - (indexPath.section + 1)
        do {
            try realm.write {
                self.target?.photos.removeAtIndex(deleteIndex)
                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                if PhotoUtility().delete(fileName) {
                    // 動画の作り直し
                    VideoUtility().makeVideoFromTarget(self.target!)
                }
                self.checkAndSwitchNoPhotoView()
            }
        } catch {
            print("error")
        }
        
        // targetのタイムスタンプ更新
        let targetUpdateValues = ["id": (self.target?.id)!, "updated": now]
        Storage().update(TargetData(), updateValues: targetUpdateValues)
        
    }
    
    // 写真をカメラロールに保存
    @IBAction func savePhotoToCameraroll(sender: UIButton) {
        
        let cell = TableUtility().findUITableViewCellFromSuperViewsForView(sender) as! PhotoTableViewCell
        guard let photoImageView = cell.photoImage else {
            print("error")
            return
        }
        
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "写真の保存", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // アクションを生成.
        let savePhoto = UIAlertAction(title: "カメラロールに保存する", style: .Default, handler: {
            (action: UIAlertAction!) in
            // 保存中のビューを出す
            LoadingOverlay.shared.showOverlay(self.navigationController?.view)
            // カメラロールに保存
            UIImageWriteToSavedPhotosAlbum(photoImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction!) in
            print("cancel")
        })
        
        // アクションを追加.
        myAlert.addAction(savePhoto)
        myAlert.addAction(cancel)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        // 保存中のビューを消す
        LoadingOverlay.shared.hideOverlayView()
        
        var title = "保存完了"
        var message = "カメラロールへ保存しました"
        
        if error != nil {
            title = "エラー"
            message = "カメラロールへの保存に失敗しました"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let confirm = UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction!) in
        })
        alertController.addAction(confirm)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nav: UINavigationController = segue.destinationViewController as! UINavigationController
        let identifier = segue.identifier
        
        if identifier == "DetailPhotoSegue" {
            let photoViewController = nav.viewControllers[0] as! PhotoViewController
            if sender is PhotoTableViewCell {
                if let cell = sender as? PhotoTableViewCell {
                    photoViewController.selectedImage = cell.photoImage.image
                    photoViewController.editCommentText = cell.commentText.text
                    photoViewController.selectedId = cell.id
                }
            }
        } else if identifier == "showCameraView" {
            let cameraViewController = nav.viewControllers[0] as! CameraViewController
            if let overlayImage = sender as? UIImage {
                cameraViewController.overlayImage = overlayImage
            }
        }
    }

}
