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
    let now = NSDate()
    let formatter = NSDateFormatter()
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

        // キーボードの完了ボタン
        let myKeyboard = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        myKeyboard.backgroundColor = UIColor.whiteColor()
        let myKeyboardLine = UIView(frame: CGRectMake(0, 0, myKeyboard.frame.size.width, 0.5))
        myKeyboardLine.backgroundColor = UIColor.lightGrayColor()
        myKeyboard.addSubview(myKeyboardLine)
        
        //完了ボタンの生成
        let completeButton = UIButton(frame: CGRectMake(300, 5, 70, 30))
        completeButton.backgroundColor = Constants.Theme.concept()
        completeButton.setTitle("完了", forState: .Normal)
        completeButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20)
        completeButton.layer.cornerRadius = 3.0
        completeButton.addTarget(self, action: "onClickCompleteButton:", forControlEvents: .TouchUpInside)
        
        //Viewに完了ボタンを追加する。
        myKeyboard.addSubview(completeButton)
        
        //ViewをFieldに設定する
        commentTextView.inputAccessoryView = myKeyboard
    
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

    // MARK: Actions
    
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
        // 郵便入れみたいなもの
        let userInfo = notification.userInfo!
        // キーボードの大きさを取得
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // 画面のサイズを取得
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        // ViewControllerを基準にtextFieldの下辺までの距離を取得
        let txtLimit = commentTextView.frame.origin.y + commentTextView.frame.height + 8.0
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
            Storage().update(PhotoData(), updateValues: updateValue)
            
            // targetのタイムスタンプ更新
            photo = Storage().find(PhotoData(), id: self.selectedId!)
            let target = photo!.target[0]
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let targetUpdated = formatter.stringFromDate(now)
            let targetUpdateValues = ["id": target.id, "updated": targetUpdated]
            Storage().update(TargetData(), updateValues: targetUpdateValues)
            
        // self.selectedIdがなければ新規
        } else {
        
            // ファイルを保存
            let fileName = PhotoManager().insert((photoImageView?.image)!)
            
            photo = PhotoData()
    
            if fileName != nil {
                photo!.comment = commentTextView.text
                photo!.photo = fileName!
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                photo!.created = formatter.stringFromDate(now)
                photo!.updated = formatter.stringFromDate(now)
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
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let targetUpdated = formatter.stringFromDate(now)
            let targetUpdateValues = ["id": target.id, "updated": targetUpdated]
            Storage().update(TargetData(), updateValues: targetUpdateValues)
            
            // 画像をすべて取得
            var photos: [UIImage] = []
            for photoData in target.photos {
                let image = PhotoManager().get(photoData.photo)
                photos.append(image!)
            }
            
            if photos.count > 2 {
                VideoManager().makeVideoFromPhotos(photos, fileName: "\(target.id).mp4")
            }
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
