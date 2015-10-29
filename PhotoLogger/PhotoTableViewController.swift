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
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let target = target {
            navigationItem.title = target.title
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "insertPhoto:", name: "photoAdded", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func AddPhoto(sender: UIBarButtonItem) {
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "写真を追加する", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // アクションを生成.
        let imageFromLibrary = UIAlertAction(title: "フォトライブラリー", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.pickImageFromLibrary()
        })
        
        let imageFromCamera = UIAlertAction(title: "カメラ", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.pickImageFromCamera()
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction!) in
            print("cancel")
        })
        
        // アクションを追加.
        myAlert.addAction(imageFromLibrary)
        myAlert.addAction(imageFromCamera)
        myAlert.addAction(cancel)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // 写真を撮ってそれを選択
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func insertPhoto(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let userInfo = notification.userInfo {
            let photo = userInfo["photo"] as! PhotoData
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            do {
                try realm.write {
                    self.target?.photos.append(photo)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } catch {
                print("error")
            }
        }
    }

    
    // 既存の写真の編集ボタンを押した時の選択肢
    func editAlert(sender: UITapGestureRecognizer) {
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "写真を編集・削除する", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cell = findUITableViewCellFromSuperViewsForView(sender.view as! UIButton) as! PhotoTableViewCell
        let newIndexPath = self.tableView.indexPathForCell(cell)
        
        // アクションを生成.
        let editPhoto = UIAlertAction(title: "編集する", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            // 編集のアクション
        })
        
        let deleteAlert = UIAlertAction(title: "削除する", style: .Default, handler: {
            (action: UIAlertAction!) in
            self.deleteAlert(cell.id!, indexPath: newIndexPath!)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction!) in
            print("cancel")
        })
        
        // アクションを追加.
        myAlert.addAction(editPhoto)
        myAlert.addAction(deleteAlert)
        myAlert.addAction(cancel)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
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
        let deleteIndex = (self.target?.photos.count)! - indexPath.row - 1
        do {
            try realm.write {
                self.target?.photos.removeAtIndex(deleteIndex)
                // Delete the row from the data source
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                PhotoManager().delete(photo!.photo)
                //self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    
    func findUITableViewCellFromSuperViewsForView(sender: UIView) -> UITableViewCell {
        var superView = sender
        while !(superView is UITableViewCell) {
            superView = superView.superview!
        }
        return superView as! UITableViewCell
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 写真を選択した時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("AddPhotoSegue", sender: selectedImage)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (target?.photos)!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> 
        UITableViewCell {
            let cellIdentifier = "PhotoTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PhotoTableViewCell
            
            let photos = target?.photos.sorted("created", ascending: false)
            
            let photoData = photos![indexPath.row]

            let fileName = photoData.photo

            if let jpeg: UIImage? = PhotoManager().get(fileName) {
                cell.photoImage.image = jpeg
                cell.createdLabel.text = photoData.created
                cell.commentText.text = photoData.comment
                cell.id = photoData.id
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "editAlert:")
            cell.editButton.addGestureRecognizer(tapGestureRecognizer)

            return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender is UIImage {
            if let selectedImage = sender as? UIImage {
                let photoViewController = segue.destinationViewController as! PhotoViewController
                photoViewController.selectedImage = selectedImage
            }
        }
    }

}
