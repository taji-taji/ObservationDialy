//
//  PhotoTableViewController.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    var target: TargetData?
    var photos: Results<PhotoData>?
    let realm = try! Realm()
    let now = NSDate()
    let formatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let target = target {
            navigationItem.title = target.title
            photos = target.photos.sorted("created", ascending: false)
        }
        
        //高さ
        self.tableView.estimatedRowHeight = 850
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "insertPhoto:", name: "photoAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePhoto:", name: "photoEdited", object: nil)
        
        // ツールバーをセット
        self.navigationController?.setToolbarHidden(false, animated: true)
        let toolbar = self.navigationController?.toolbar
        toolbar!.tintColor = UIColor.whiteColor()
        toolbar!.barTintColor = Constants.Theme.concept()
        toolbar!.frame = CGRectMake(0, self.view.frame.height - 50, self.view.frame.width, 50)
        
        // ツールバーボタンのセット
        let cameraButton: UIButton = UIButton(type: UIButtonType.Custom)
        cameraButton.addTarget(self, action: "AddPhoto:", forControlEvents: .TouchUpInside)
        cameraButton.setImage(UIImage(named: "CameraIcon"), forState: .Normal)
        cameraButton.imageView?.contentMode = .ScaleAspectFit
        cameraButton.frame = CGRectMake(toolbar!.bounds.size.width / 3, 0, toolbar!.bounds.size.width / 3, 75)
        let barCameraButton: UIBarButtonItem = UIBarButtonItem(customView: cameraButton)
        
        let editButton: UIButton = UIButton(type: UIButtonType.Custom)
        editButton.addTarget(self, action: "editTarget:", forControlEvents: .TouchUpInside)
        editButton.setImage(UIImage(named: "EditPencil"), forState: .Normal)
        editButton.imageView?.contentMode = .ScaleAspectFit
        editButton.frame = CGRectMake(0, 0, toolbar!.bounds.size.width / 3, 50)
        let barEditButton: UIBarButtonItem = UIBarButtonItem(customView: editButton)

        let movieButton: UIButton = UIButton(type: UIButtonType.Custom)
        movieButton.addTarget(self, action: "movieAction:", forControlEvents: .TouchUpInside)
        movieButton.setImage(UIImage(named: "MovieIcon"), forState: .Normal)
        movieButton.imageView?.contentMode = .ScaleAspectFit
        movieButton.frame = CGRectMake(toolbar!.bounds.size.width / 3 * 2, 0, toolbar!.bounds.size.width / 3, 50)
        let barMovieButton: UIBarButtonItem = UIBarButtonItem(customView: movieButton)
        
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        let toolbarItems = [flexibleSpace, barEditButton, flexibleSpace, barCameraButton, flexibleSpace, barMovieButton, flexibleSpace]
        self.setToolbarItems(toolbarItems, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // ツールバーを隠す
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions

    // カメラビューへ遷移
    func AddPhoto(sender: UIBarButtonItem) {
        // 前回写真の取得
        let latestPhotoFile = target?.photos.last?.photo
        var latestPhotoImage: UIImage?

        if latestPhotoFile != nil {
            latestPhotoImage = PhotoManager().get(latestPhotoFile!)
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
        print("editTarget")
        performSegueWithIdentifier("ModifyItem", sender: self.target)
    }

    // ムービーの再生
    func movieAction(sender: UIBarButtonItem) {
        if photos?.count < Constants.Video.minPhotos {
            let myAlert = UIAlertController(title: "ムービーを再生できません", message: "ムービーは画像が３枚以上になると自動的に作成されます。", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            myAlert.addAction(ok)
            self.presentViewController(myAlert, animated: true, completion: nil)
            return
        }
        
        let videoFile = "\(self.target!.id).mp4"
        let videoPath = VideoManager().get(videoFile)
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let play = UIAlertAction(title: "ムービーを見る", style: .Default, handler: {
            (action: UIAlertAction!) in
            let videoPlayerViewController = VideoPlayerViewController()
            videoPlayerViewController.fileName = videoFile
            self.presentViewController(videoPlayerViewController, animated: true, completion: nil)
        })
        let download = UIAlertAction(title: "ムービーをカメラロールに保存する", style: .Default, handler: {
            (action: UIAlertAction!) in
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
        let myAlert = UIAlertController(title: "写真を編集・削除する", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        let cell = findUITableViewCellFromSuperViewsForView(sender.view as! UIButton) as! PhotoTableViewCell

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
        let photo = Storage().find(PhotoData(), id: id)
        let deleteIndex = (self.target?.photos.count)! - (indexPath.section + 1)
        do {
            try realm.write {
                self.target?.photos.removeAtIndex(deleteIndex)
                // Delete the row from the data source
                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                PhotoManager().delete(photo!.photo)
            }
        } catch {
            print("error")
        }
        
        // targetのタイムスタンプ更新
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let targetUpdated = formatter.stringFromDate(now)
        let targetUpdateValues = ["id": (self.target?.id)!, "updated": targetUpdated]
        Storage().update(TargetData(), updateValues: targetUpdateValues)

    }
    
    func findUITableViewCellFromSuperViewsForView(sender: UIView) -> UITableViewCell {
        var superView = sender
        while !(superView is UITableViewCell) {
            superView = superView.superview!
        }
        return superView as! UITableViewCell
    }

    // 写真をカメラロールに保存
    func savePhotoToCameraroll(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let photoImageView = sender.view as! UIImageView

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
    
        
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (target?.photos)!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> 
        UITableViewCell {
            let cellIdentifier = "PhotoTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PhotoTableViewCell
            
            let photoData = photos![indexPath.section]

            let fileName = photoData.photo

            if let jpeg: UIImage? = PhotoManager().get(fileName) {
                cell.photoImage.image = jpeg
                cell.commentText.text = photoData.comment
                cell.id = photoData.id
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "editAlert:")
            cell.editButton.addGestureRecognizer(tapGestureRecognizer)
            cell.editButton.setImage(UIImage(named: "EditIconHighlighted"), forState: .Highlighted)

            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // 画像長押しでカメラロールに保存
            let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "savePhotoToCameraroll:")
            gesture.minimumPressDuration = 0.5
            cell.photoImage.addGestureRecognizer(gesture)

            return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // headerのビュー
        let header = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 40))
        header.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
        let headerBorder = UIView(frame: CGRectMake(0, header.bounds.size.height, header.bounds.size.width, 0.5))
        headerBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        
        // 作成日
        let created = UILabel(frame: CGRectMake(10, 0, tableView.bounds.size.width, header.bounds.size.height))
        created.text = (DateUtility().dateToStr(photos![section].created) as NSString).substringWithRange(NSRange(location: 0, length: 16))
        created.font = UIFont.systemFontOfSize(15)
        created.textColor = UIColor.lightGrayColor()

        header.addSubview(created)
        header.addSubview(headerBorder)
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
        } else if identifier == "ModifyItem" {
            let targetViewController = nav.viewControllers[0] as! TargetViewController
            if sender is TargetData {
                if let target = sender as? TargetData {
                    targetViewController.titleText = target.title
                    targetViewController.targetId = target.id
                }
            }
        }
    }

}
