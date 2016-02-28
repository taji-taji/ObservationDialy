//
//  TargetViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Material

class TargetViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var titleTextField: BasicTextField!
    @IBOutlet weak var targetSaveButton: FilledButton!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var imageView: ImageThumbnailView!
    @IBOutlet weak var completeButton: FilledButton!
    @IBOutlet weak var deleteButton: DestroyButton!
    @IBOutlet weak var cardView: ModalView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

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
        
        if let titleText = titleText {
            titleTextField.text = titleText
        }
        if let pageTitle = pageTitle {
            pageTitleLabel.text = pageTitle
        }
        if let targetImage = targetImage {
            imageView.image = targetImage
        }
        if let completeButtonText = completeButtonText {
            completeButton.setTitle(completeButtonText, forState: .Normal)
        }
        if !isUpdate {
            deleteButton.hidden = true
            LogManager.setLogEvent(.TapAddTargetButton)
        }
        
        titleTextField.becomeFirstResponder()
        titleTextField.titleLabelColor = MaterialColor.grey.lighten1
        titleTextField.titleLabelActiveColor = MaterialColor.grey.lighten1
        titleTextField.titleLabel?.text = "タイトル"
        titleTextField.placeholder = "例）ガジュマルの木"
        pageTitleLabel.textColor = Constants.Theme.textColor
        titleTextField.textColor = Constants.Theme.textColor
        titleTextField.delegate = self
        
        checkValidTargetTitle()

    }
    
    // MARK: Actions
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func deleteTarget(sender: UIButton) {
        LogManager.setLogEvent(.TapDeleteTargetButton)
        // アラート
        let alertController = UIAlertController(title: "削除します。", message: "この操作は取り消せません。", preferredStyle: .Alert)
        let deletePhoto = UIAlertAction(title: "削除する", style: .Default, handler: {
            (action: UIAlertAction!) in
            LogManager.setLogEvent(.DeleteTarget)
            let n: NSNotification = NSNotification(name: "deleteTarget", object: self, userInfo: ["indexPath": self.indexPath!])
            //通知を送る
            NSNotificationCenter.defaultCenter().postNotification(n)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction!) in
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
        if let _ = targetId {
            Storage().update(target!, updateValues: ["id": targetId!, "title": title, "updated": now])
            isUpdate = true
            LogManager.setLogEvent(.EditTarget)
        // なければ新規追加
        } else {
            target?.created = now
            Storage().add(target!)
            isUpdate = false
            LogManager.setLogEvent(.AddTarget)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTargetList", object: nil, userInfo: ["isUpdate": isUpdate, "target": target!])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkValidTargetTitle() {
        let text = titleTextField.text ?? ""
        targetSaveButton.enabled = !text.isEmpty
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
