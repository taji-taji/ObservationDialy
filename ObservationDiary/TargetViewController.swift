//
//  TargetViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import iAd

class TargetViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var targetSaveButton: UIButton!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var target: TargetData?
    var pageTitle: String?
    var titleText: String?
    var targetImage: UIImage?
    var completeButtonText: String?
    var targetId: Int?
    var isKeyboardActive: Bool = false
    var isUpdate: Bool = false
    var indexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if titleText != nil {
            titleTextField.text = titleText
        }
        if pageTitle != nil {
            pageTitleLabel.text = pageTitle
        }
        if targetImage != nil {
            imageView.image = targetImage
        }
        if completeButtonText != nil {
            completeButton.setTitle(completeButtonText, forState: .Normal)
        }
        if !isUpdate {
            deleteButton.hidden = true
        }
        
        pageTitleLabel.textColor = Constants.Theme.textColor()
        titleTextField.textColor = Constants.Theme.textColor()
        titleTextField.delegate = self
        
        checkValidTargetTitle()
        
        self.canDisplayBannerAds = true
    }
    
    // MARK: Actions
    @IBAction func cancelAdd(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func deleteTarget(sender: UIButton) {
        // アラート
        let alertController = UIAlertController(title: "削除します。", message: "この操作は取り消せません。", preferredStyle: .Alert)
        let deletePhoto = UIAlertAction(title: "削除する", style: .Default, handler: {
            (action: UIAlertAction!) in
            
            let n: NSNotification = NSNotification(name: "deleteTarget", object: self, userInfo: ["indexPath": self.indexPath!])
            //通知を送る
            NSNotificationCenter.defaultCenter().postNotification(n)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction!) in
            print("cancelAction")
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(deletePhoto)
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func addItem(sender: UIButton) {
        let now = NSDate()
        
        let title = titleTextField.text ?? ""
        
        target = TargetData()
        target?.title = title
        target?.updated = now
        
        // targetIdがあればアップデート
        if targetId != nil {
            Storage().update(target!, updateValues: ["id": targetId!, "title": title, "updated": now])
            isUpdate = true
            
        // なければ新規追加
        } else {
            target?.created = now
            Storage().add(target!)
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // キーボードを隠す
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // 入力中のsaveボタンを使用不可にする
        targetSaveButton.enabled = false
    }
    
    func checkValidTargetTitle() {
        let text = titleTextField.text ?? ""
        targetSaveButton.enabled = !text.isEmpty
    }

    func textFieldDidEndEditing(textField: UITextField) {
        checkValidTargetTitle()
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        targetSaveButton.enabled = !sender.text!.isEmpty
    }
    
    // MARK: Navigation
    @IBAction func targetCancel(sender: UIBarButtonItem) {
        // キーボードが上がっている場合もあるので、キーボードを隠す処理
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
