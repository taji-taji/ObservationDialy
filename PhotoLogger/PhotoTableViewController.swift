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
        //NSNotificationCenter.defaultCenter().removeObserver(self)
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
        if let userInfo = notification.userInfo {
            print(userInfo["photo"])
            let photo = userInfo["photo"] as! PhotoData
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            print(target?.photos)
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
            
            let photoData = target?.photos[indexPath.row]
            
            // ディレクトリ
            let DocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
            let PhotoDirectory = "/photos"
            let PhotoDirectoryPath = DocumentsDirectory + PhotoDirectory
            
            // ファイル名
            let fileName = photoData?.photo
            let filePath = PhotoDirectoryPath + "/" + fileName!
            
            let url = NSURL(fileURLWithPath: filePath)
            if let jpegData = NSData(contentsOfURL: url) {
                cell.photoImage.image = UIImage(data: jpegData)
                cell.createdLabel.text = target?.created
            }
            
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
