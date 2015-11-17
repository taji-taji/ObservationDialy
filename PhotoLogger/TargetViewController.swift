//
//  TargetViewController.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class TargetViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var targetSaveButton: UIBarButtonItem!
    var target: TargetData?
    var titleText: String?
    var targetId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self;
        
        // titleTextがnilでなければ名称変更
        if titleText != nil {
            titleTextField.text = titleText
            self.navigationItem.title = "タイトル変更"
        }
        
        checkValidTargetTitle()
        
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
        titleTextField.inputAccessoryView = myKeyboard
    }
    
    // MARK: Actions
    func onClickCompleteButton(sender: UIButton) {
        self.view.endEditing(true)
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
    
    // MARK: Navigation
    @IBAction func targetCancel(sender: UIBarButtonItem) {
        // キーボードが上がっている場合もあるので、キーボードを隠す処理
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if targetSaveButton === sender {
            let now = NSDate()

            let title = titleTextField.text ?? ""
            
            target = TargetData()
            target?.title = title
            target?.updated = now
            
            // targetIdがあればアップデート
            if targetId != nil {
                Storage().update(target!, updateValues: ["id": targetId!, "title": title, "updated": now])
            
            // なければ新規追加
            } else {
                let created = now
                target?.created = created
                Storage().add(target!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

