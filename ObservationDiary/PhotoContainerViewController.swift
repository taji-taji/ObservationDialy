//
//  PhotoContainerViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/11/21.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift
import RMUniversalAlert

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
        if let _ = self.photos {
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
        
        if let _ = latestPhotoFile {
            latestPhotoImage = PhotoUtility().get(latestPhotoFile!)
        }
        
        performSegueWithIdentifier("showCameraView", sender: latestPhotoImage)
    }
    
    // 写真を追加
    func insertPhoto(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let userInfo = notification.userInfo, photo = userInfo["photo"] as? PhotoData {
            
            defer {
                // 全てのモーダルを閉じる
                self.presentedViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            do {
                try realm.write {
                    
                    // テーブル挿入完了後の処理を書くため
                    CATransaction.begin()
                    
                    // テーブル挿入完了後の処理
                    CATransaction.setCompletionBlock({ () -> Void in
                        self.checkMovieTour.tour(.CheckMovie, forView: self.navigationItem.rightBarButtonItem!, superView: nil)
                        if let cell = self.tableView.cellForRowAtIndexPath(newIndexPath) as? PhotoTableViewCell {
                            self.editPhotoTour.tour(.EditPhoto, forView: cell.editButton, superView: self.tableView)
                        }
                    })
                    
                    self.target?.photos.append(photo)
                    
                    self.tableView.reloadData()
                    
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

        RMUniversalAlert.showActionSheetInViewController(self,
            withTitle: nil,
            message: nil,
            cancelButtonTitle: "キャンセル",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["ムービーを見る", "ムービーをカメラロールに保存する", "ムービーをシェアする"],
            popoverPresentationControllerBlock: {(popover) in
                popover.barButtonItem = sender
            },
            tapBlock: {(alert, buttonIndex) in
                if (buttonIndex == alert.firstOtherButtonIndex) {
                    let videoPlayerViewController = VideoPlayerViewController()
                    videoPlayerViewController.fileName = videoFile
                    // 一時ファイルが残っている場合は動画の作成に失敗しているので、一時ファイルから戻す
                    if let _ = tmpVideoPath {
                        if let _ = videoPath  {
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
                } else if (buttonIndex == alert.firstOtherButtonIndex + 1) {
                    LoadingProxy.set(self.navigationController!)
                    LoadingProxy.on()
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath!, self, "video:didFinishSavingWithError:contextInfo:", nil)
                } else if (buttonIndex == alert.firstOtherButtonIndex + 2) {
                    guard let shareMovieViewController = R.storyboard.shareMovie.shareMovieVC() else {
                        return
                    }
                    shareMovieViewController.modalTransitionStyle = .CrossDissolve
                    shareMovieViewController.modalPresentationStyle = .OverCurrentContext
                    shareMovieViewController.target = self.target
                    self.presentViewController(shareMovieViewController, animated: true, completion: nil)
                }
        })
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
    
    // 既存の写真の編集ボタンを押した時の選択肢
    func editAlert(sender: UIGestureRecognizer) {

        let cell = TableUtility().findUITableViewCellFromSuperViewsForView(sender.view as! UIButton) as! PhotoTableViewCell
        
        let newIndexPath = self.tableView.indexPathForCell(cell)
        
        RMUniversalAlert.showActionSheetInViewController(self,
            withTitle: "コメントを編集・削除する",
            message: "",
            cancelButtonTitle: "キャンセル",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["編集する", "削除する"],
            popoverPresentationControllerBlock: {(popover) in
                popover.sourceView = sender.view
                //popover.sourceRect = sender.frame
            },
            tapBlock: {(alert, buttonIndex) in
                if (buttonIndex == alert.firstOtherButtonIndex) {
                    self.editPhoto(cell)
                } else if (buttonIndex == alert.firstOtherButtonIndex + 1) {
                    self.deleteAlert(cell.id!, indexPath: newIndexPath!)
                }
        })
        
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
        guard let photo = Storage().find(PhotoData(), id: id) else {
            return
        }
        let fileName = photo.photo
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
        Storage().delete(photo)
        
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
        
        RMUniversalAlert.showActionSheetInViewController(self,
            withTitle: "写真の保存",
            message: "",
            cancelButtonTitle: "キャンセル",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["カメラロールに保存する"],
            popoverPresentationControllerBlock: {(popover) in
                popover.sourceView = sender
                //popover.sourceRect = sender.frame
            },
            tapBlock: {(alert, buttonIndex) in
                if (buttonIndex == alert.firstOtherButtonIndex) {
                    // 保存中のビューを出す
                    LoadingOverlay.shared.showOverlay(self.navigationController?.view)
                    // カメラロールに保存
                    UIImageWriteToSavedPhotosAlbum(photoImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
                }
        })
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        // 保存中のビューを消す
        LoadingOverlay.shared.hideOverlayView()
        
        var title = "保存完了"
        var message = "カメラロールへ保存しました"
        
        if let _ = error {
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
                    photoViewController.targetId = target?.id
                }
            }
        } else if identifier == "showCameraView" {
            let cameraViewController = nav.viewControllers[0] as! CameraViewController
            cameraViewController.targetId = target?.id
            if let overlayImage = sender as? UIImage {
                cameraViewController.overlayImage = overlayImage
            }
        }
    }

}
