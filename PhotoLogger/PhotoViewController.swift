//
//  PhotoViewController.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Properties

    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var photo: PhotoData?
    var selectedImage: UIImage?
    var isObserving = false
    var screenOffsetY: CGFloat = 0
    private var realmNotificationToken: NotificationToken?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let selectedImage = selectedImage {
            photoImageView?.image = selectedImage
        }

        commentTextView.layer.masksToBounds = true
        commentTextView.backgroundColor = UIColor.grayColor()

    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
        // Viewの表示時にキーボード表示・非表示を監視するObserverを登録する
        super.viewWillAppear(animated)
        
        if(!isObserving) {
            let notification = NSNotificationCenter.defaultCenter()
            notification.addObserver(self, selector: "handleKeyboardWillShowNotification:"
                , name: UIKeyboardWillShowNotification, object: nil)
            notification.addObserver(self, selector: "handleKeyboardWillHideNotification:"
                , name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
    }
    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear")
        // Viewの表示時にキーボード表示・非表示時を監視していたObserverを解放する
        super.viewWillDisappear(animated)
        if(isObserving) {
            let notification = NSNotificationCenter.defaultCenter()
            notification.removeObserver(self)
            notification.removeObserver(self
                , name: UIKeyboardWillShowNotification, object: nil)
            notification.removeObserver(self
                , name: UIKeyboardWillHideNotification, object: nil)
            isObserving = false
        }
        if let token = self.realmNotificationToken {
            realm.removeNotification(token)
        }
    }

    //テキストビューが変更された
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange")
        //            let maxHeight = 80.0  // 入力フィールドの最大サイズ
        //            if(commentTextView.frame.size.height.native < maxHeight) {
        //                let size:CGSize = commentTextView.sizeThatFits(commentTextView.frame.size)
        //                CommentTextHeight.constant = size.height
        //            }
    }
    
    // テキストビューにフォーカスが移った
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing : \(textView.text)");
        return true
    }
    
    // テキストビューからフォーカスが失われた
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print("textViewShouldEndEditing : \(textView.text)");
        return true
    }

    //キーボードが表示された時
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        // 郵便入れみたいなもの
        let userInfo = notification.userInfo!
        // キーボードの大きさを取得
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // 画面のサイズを取得
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        //　ViewControllerを基準にtextFieldの下辺までの距離を取得
        let txtLimit = commentTextView.frame.origin.y + commentTextView.frame.height + 8.0
        // ViewControllerの高さからキーボードの高さを引いた差分を取得
        let kbdLimit = myBoundSize.height - keyboardRect.size.height
        
        // こうすることで高さを確認できる（なくてもいい）
        print("テキストフィールドの下辺：(\(txtLimit))")
        print("キーボードの上辺：(\(kbdLimit))")

        if screenOffsetY == 0 {
            screenOffsetY = photoScrollView.contentOffset.y
        }

        //スクロールビューの移動距離設定
        if txtLimit >= kbdLimit {
            photoScrollView.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    //ずらした分を戻す処理
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        photoScrollView.contentOffset.y = screenOffsetY
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: Actions
    @IBAction func savePhoto(sender: UIBarButtonItem) {
        
        let now = NSDate()
        let formatter = NSDateFormatter()
        
        /** 画像の保存 **/
        
        // 保存先の確認
        let DocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let PhotoDirectory = "/photos"
        let PhotoDirectoryPath = DocumentsDirectory + PhotoDirectory
        var isDir: ObjCBool = false
        let fileManager = NSFileManager.defaultManager()
        fileManager.fileExistsAtPath(PhotoDirectoryPath, isDirectory: &isDir)
        
        //ディレクトリが存在しない場合に、ディレクトリを作成する
        if !isDir {
            do {
                try fileManager.createDirectoryAtPath(PhotoDirectoryPath ,withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error: cannot create directory")
            }
        }
        
        let jpegData = UIImageJPEGRepresentation((photoImageView?.image)!, 0.8)!
        
        // ファイル名を指定して保存
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.stringFromDate(now) + ".jpg"
        let filePath = PhotoDirectoryPath + "/" + fileName
        jpegData.writeToFile(filePath, atomically: true)
        
        photo = PhotoData()
        photo?.comment = commentTextView.text
        photo?.photo = fileName
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        photo?.created = formatter.stringFromDate(now)

        //NSNotificationのインスタンスを作成
        let n: NSNotification = NSNotification(name: "photoAdded", object: self, userInfo: ["photo": photo!])
        
        realmNotificationToken = realm.addNotificationBlock{ notification, realm in
            if notification == .DidChange {
                defer {
                    //通知を送る
                    print("send")
                    NSNotificationCenter.defaultCenter().postNotification(n)
                }
                realm.removeNotification(self.realmNotificationToken!)
                print(notification)
                //self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        Storage().add(photo!)
    }

    // MARK: - Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // }

}
