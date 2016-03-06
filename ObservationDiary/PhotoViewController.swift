//
//  PhotoViewController.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift
import Material

class PhotoViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var commentTextWrapView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationView: BaseNavigationBarView!
    var saveButton = FlatButton()
    var cancelButton = FlatButton()
    // 新規作成時に選択された画像
    var selectedImage: UIImage?
    // 編集の際に受け取るコメント
    var editCommentText: String?
    // 編集の際に受け取るID
    var selectedId: Int?
    var targetId: Int?
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
        
        setNavigationItems()

        if let selectedImage = selectedImage {
            photoImageView?.image = selectedImage
        }
        
        if let editCommentText = editCommentText where !editCommentText.isEmpty {
            commentTextView.text = editCommentText
        }

        // コメント入力欄の設定
        commentTextView.delegate = self
        commentTextView.clipsToBounds = true
        adjustTextViewHeight()
        
        remainCount = remainCount - commentTextView.text.characters.count
        commentCountLabel.text = "あと\(remainCount)文字入力できます"

        if(!isObserving) {
            let notification = NSNotificationCenter.defaultCenter()
            notification.addObserver(self, selector: "handleKeyboardWillShowNotification:"
                , name: UIKeyboardWillShowNotification, object: nil)
            notification.addObserver(self, selector: "handleKeyboardWillHideNotification:"
                , name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        commentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    
    private func setNavigationItems() {
        saveButton.pulseScale = false
        saveButton.pulseColor = MaterialColor.white
        saveButton.setTitle("保存", forState: .Normal)
        saveButton.setTitleColor(MaterialColor.white, forState: .Normal)
        saveButton.addTarget(self, action: "savePhoto:", forControlEvents: .TouchUpInside)
        self.navigationView.navigationBarView.rightControls = [saveButton]
        
        cancelButton.pulseScale = false
        cancelButton.pulseColor = MaterialColor.white
        cancelButton.setTitle("キャンセル", forState: .Normal)
        cancelButton.setTitleColor(MaterialColor.white, forState: .Normal)
        cancelButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
        self.navigationView.navigationBarView.leftControls = [cancelButton]
    }

    // MARK: - Text view delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // 入力済みの文字と入力された文字を合わせて取得.
        var str = ""
        if range.length == 1 && text.isEmpty {
            let endIndex = commentTextView.text.startIndex.advancedBy(range.location)
            str = commentTextView.text.substringToIndex(endIndex)
        } else {
            str = commentTextView.text + text
        }
        countCommentText(str)
        adjustTextViewHeight()
        return true
    }
    
    //テキストビューが変更された
    func textViewDidChange(textView: UITextView) {
        countCommentText(textView.text)
        adjustTextViewHeight()
    }
    
    // テキストビューにフォーカスが移った
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        adjustTextViewHeight()
        return true
    }
    
    // テキストビューからフォーカスが失われた
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    
    private func countCommentText(text: String) {
        if text.characters.count <= Constants.Photo.commentMaxCharacters {
            commentCountLabel.textColor = UIColor.darkGrayColor()
            remainCount = Constants.Photo.commentMaxCharacters - text.characters.count
            commentCountLabel.text = "あと\(remainCount)文字入力できます"
        } else {
            commentCountLabel.textColor = UIColor.redColor()
            commentCountLabel.text = "最大文字数を超えています"
        }
    }
    
    private func adjustTextViewHeight() {
        let currentSize = commentTextView.frame.size
        let fixedWidth = currentSize.width
        commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let diff = newSize.height - currentSize.height
        if newSize.height < 140 {
            textViewHeightConstraint.constant = newSize.height
            photoScrollView.contentOffset.y = photoScrollView.contentOffset.y + diff
        }
    }
    

    func onClickCompleteButton(sender: UIButton) {
        self.view.endEditing(true)
    }
    
    //キーボードが表示された時
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        // キーボードのアクティブフラグを立てる
        isKeyboardActive = true
        saveButton.setTitle("完了", forState: .Normal)
        
        // キーボード分、画面を上にずらす
        // 郵便入れみたいなもの
        let userInfo = notification.userInfo!
        // キーボードの大きさを取得
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.scrollViewBottomConstraint.constant = keyboardRect.height
        
        // 画面のサイズを取得
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        // ViewControllerを基準にtextViewを囲っているviewの下辺までの距離を取得
        let txtLimit = commentTextWrapView.frame.origin.y + commentTextWrapView.frame.height + 8.0 + 15.0
        // ViewControllerの高さからキーボードの高さを引いた差分を取得
        let kbdLimit = myBoundSize.height - keyboardRect.size.height

        if screenOffsetY == 0 {
            screenOffsetY = photoScrollView.contentOffset.y
        }

        //スクロールビューの移動距離設定
        if txtLimit >= kbdLimit {
            UIView.animateWithDuration(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval, animations: { () -> Void in
                self.photoScrollView.contentOffset.y = txtLimit - kbdLimit
            })
        }
    }
    
    //ずらした分を戻す処理
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        self.scrollViewBottomConstraint.constant = 0
        photoScrollView.contentOffset.y = screenOffsetY
        // キーボードのアクティブフラグを下ろす
        isKeyboardActive = false
        saveButton.setTitle("保存", forState: .Normal)
    }
    
    // MARK: - Actions
    func savePhoto(sender: UIButton) {
        
        // キーボードがアクティブな時はキーボードを閉じるだけ
        if isKeyboardActive {
            self.view.endEditing(true)
            isKeyboardActive = false
            saveButton.setTitle("保存", forState: .Normal)
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
        
        guard let targetId = targetId, target = Storage().find(TargetData(), id: targetId) else {
            return
        }
        
        // self.selectedIdがあれば編集
        if let selectedId = self.selectedId {
            
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

            let updateValue = ["id": selectedId, "comment": self.commentTextView.text]
            Storage().update(PhotoData(), updateValues: updateValue)
            LogManager.setLogEvent(.EditPhoto)
            
            // targetのタイムスタンプ更新
            if let photo = Storage().find(PhotoData(), id: selectedId) {
                let targetUpdateValues = ["id": target.id, "updated": now]
                Storage().update(TargetData(), updateValues: targetUpdateValues)
            }
            
        // self.selectedIdがなければ新規
        } else {
            
            let photo = PhotoData()
    
            if let fileName = PhotoUtility().insert((photoImageView?.image)!) {
                photo.comment = commentTextView.text
                photo.photo = fileName
                photo.created = now
                photo.updated = now
            } else {
                return
            }

            //NSNotificationのインスタンスを作成
            let n: NSNotification = NSNotification(name: "photoAdded", object: self, userInfo: ["photo": photo])
        
            realmNotificationTokenAdd = realm.addNotificationBlock{ notification, realm in
                if notification == .DidChange {
                    defer {
                        //通知を送る
                        NSNotificationCenter.defaultCenter().postNotification(n)
                    }
                    realm.removeNotification(self.realmNotificationTokenAdd!)
                }
        
            }
            Storage().add(photo)
            LogManager.setLogEvent(.AddPhoto)

            // targetのタイムスタンプ更新
            let targetUpdateValues = ["id": target.id, "updated": now]
            Storage().update(TargetData(), updateValues: targetUpdateValues)
            
            // 画像をすべて取得
            var photos: [UIImage] = []
            for targetPhoto in target.photos {
                if let image = PhotoUtility().get(targetPhoto.photo) {
                    photos.append(image)
                }
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
    func cancel(sender: UIButton) {
        let isPresentingInAddPhotoMode = presentingViewController is UINavigationController
        if isPresentingInAddPhotoMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }

}
