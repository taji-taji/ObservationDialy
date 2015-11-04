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
    // 新規作成時に選択された画像
    var selectedImage: UIImage?
    // 編集の際に受け取るコメント
    var editCommentText: String?
    // 編集の際に受け取るID
    var selectedId: Int?
    var isObserving = false
    var screenOffsetY: CGFloat = 0
    private var realmNotificationTokenAdd: NotificationToken?
    private var realmNotificationTokenEdit: NotificationToken?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        if selectedImage != nil {
            photoImageView?.image = selectedImage
        }
        
        if editCommentText != nil {
            commentTextView.text = editCommentText
        }

        // コメント入力欄の設定
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.cornerRadius = 3
        commentTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        commentTextView.layer.masksToBounds = true
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
        if let token = self.realmNotificationTokenAdd {
            realm.removeNotification(token)
        }
        if let token = self.realmNotificationTokenEdit {
            realm.removeNotification(token)
        }
    }

    //テキストビューが変更された
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange")
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
        
        // self.selectedIdがあれば編集
        if (self.selectedId != nil) {
            
            //NSNotificationのインスタンスを作成
            let n: NSNotification = NSNotification(name: "photoEdited", object: self)
            
            realmNotificationTokenEdit = realm.addNotificationBlock{ notification, realm in
                if notification == .DidChange {
                    defer {
                        //通知を送る
                        NSNotificationCenter.defaultCenter().postNotification(n)
                    }
                    realm.removeNotification(self.realmNotificationTokenEdit!)
                }
                
            }

            let updateValue = ["id": self.selectedId!, "comment": self.commentTextView.text]
            do {
                try realm.write {
                    self.realm.create(PhotoData.self, value: updateValue, update: true)
                }
            } catch {
                print("error")
            }
            
        // self.selectedIdがなければ新規
        } else {
            let now = NSDate()
            let formatter = NSDateFormatter()
        
            // ファイルを保存
            photo = PhotoManager().insert((photoImageView?.image)!, comment: commentTextView.text)

            //NSNotificationのインスタンスを作成
            let n: NSNotification = NSNotification(name: "photoAdded", object: self, userInfo: ["photo": photo!])
        
            realmNotificationTokenAdd = realm.addNotificationBlock{ notification, realm in
                if notification == .DidChange {
                    defer {
                        //通知を送る
                        NSNotificationCenter.defaultCenter().postNotification(n)
                    }
                    realm.removeNotification(self.realmNotificationTokenAdd!)
                }
        
            }
            Storage().add(photo!)
        }
    }

    // MARK: - Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddPhotoMode = presentingViewController is UINavigationController
        if isPresentingInAddPhotoMode {
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
