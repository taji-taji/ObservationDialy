//
//  PhotoViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var commentCountLabel: UILabel!
    var photo: PhotoData?
    // 新規作成時に選択された画像
    var selectedImage: UIImage?
    // 編集の際に受け取るコメント
    var editCommentText: String?
    // 編集の際に受け取るID
    var selectedId: Int?
    var isObserving = false
    var screenOffsetY: CGFloat = 0
    var remainCount: Int = Constants.Photo.commentMaxCharacters
    private var realmNotificationTokenAdd: NotificationToken?
    private var realmNotificationTokenEdit: NotificationToken?
    let now = NSDate()
    let realm = try! Realm()
    var isKeyboardActive:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if selectedImage != nil {
            photoImageView?.image = selectedImage
        }
        
        if editCommentText != nil {
            commentTextView.text = editCommentText
        }

        // コメント入力欄の設定
        commentTextView.border(borderWidth: 0.5, borderColor: UIColor.lightGrayColor(), borderRadius: 3.0)
        commentTextView.delegate = self
        
        remainCount = remainCount - commentTextView.text.characters.count
        commentCountLabel.text = "あと\(remainCount)文字入力できます"
    
    }
    
    override func viewWillAppear(animated: Bool) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Text view delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = commentTextView.text + text
        
        // 文字数が最大値以下
        if str.characters.count <= Constants.Photo.commentMaxCharacters {
            commentCountLabel.textColor = UIColor.darkGrayColor()
            remainCount = Constants.Photo.commentMaxCharacters - str.characters.count
            commentCountLabel.text = "あと\(remainCount)文字入力できます"
        } else {
            commentCountLabel.textColor = UIColor.redColor()
            commentCountLabel.text = "最大文字数を超えています"
        }
        return true
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

    func onClickCompleteButton(sender: UIButton) {
        self.view.endEditing(true)
    }
    
    //キーボードが表示された時
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        // キーボードのアクティブフラグを立てる
        isKeyboardActive = true
        saveButton.title = "完了"
        
        // キーボード分、画面を上にずらす
        // 郵便入れみたいなもの
        let userInfo = notification.userInfo!
        // キーボードの大きさを取得
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // 画面のサイズを取得
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        // ViewControllerを基準にtextViewを囲っているviewの下辺までの距離を取得
        let commentTextWrapView = commentTextView.superview!.superview!
        let txtLimit = commentTextWrapView.frame.origin.y + commentTextWrapView.frame.height + 8.0 + 15.0
        // ViewControllerの高さからキーボードの高さを引いた差分を取得
        let kbdLimit = myBoundSize.height - keyboardRect.size.height

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
        // キーボードのアクティブフラグを下ろす
        isKeyboardActive = false
        saveButton.title = "保存"
    }
    
    // MARK: - Actions
    @IBAction func savePhoto(sender: UIBarButtonItem) {
        
        // キーボードがアクティブな時はキーボードを閉じるだけ
        if isKeyboardActive {
            self.view.endEditing(true)
            isKeyboardActive = false
            saveButton.title = "保存"
            return
        }
        
        // コメント文字数のバリデーション
        if !commentValidation() {
            let myAlert = UIAlertController(title: "最大文字数を超えています", message: "\(Constants.Photo.commentMaxCharacters)文字以内で入力してください", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            myAlert.addAction(ok)
            self.presentViewController(myAlert, animated: true, completion: nil)
            return
        }
        
        // self.selectedIdがあれば編集
        if self.selectedId != nil {
            
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
            Storage().update(PhotoData(), updateValues: updateValue)
            
            // targetのタイムスタンプ更新
            photo = Storage().find(PhotoData(), id: self.selectedId!)
            let target = photo!.target[0]
            let targetUpdateValues = ["id": target.id, "updated": now]
            Storage().update(TargetData(), updateValues: targetUpdateValues)
            
        // self.selectedIdがなければ新規
        } else {
        
            // ファイルを保存
            let fileName = PhotoUtility().insert((photoImageView?.image)!)
            
            photo = PhotoData()
    
            if fileName != nil {
                photo!.comment = commentTextView.text
                photo!.photo = fileName!
                photo!.created = now
                photo!.updated = now
            } else {
                return
            }

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

            // targetのタイムスタンプ更新
            let target = photo!.target[0]
            let targetUpdateValues = ["id": target.id, "updated": now]
            Storage().update(TargetData(), updateValues: targetUpdateValues)
            
            // 画像をすべて取得
            var photos: [UIImage] = []
            for targetPhoto in target.photos {
                let image = PhotoUtility().get(targetPhoto.photo)
                photos.append(image!)
            }
            
            if photos.count >= Constants.Video.minPhotos {
                VideoUtility().makeVideoFromTarget(target)
            }
        }
    }
    
    // コメントの文字数のバリデーション
    func commentValidation() -> Bool {
        if commentTextView.text.characters.count > Constants.Photo.commentMaxCharacters {
            return false
        }
        return true
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

}
