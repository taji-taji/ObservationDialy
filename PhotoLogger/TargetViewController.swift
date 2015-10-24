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

    /*
    This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
    or constructed as part of adding a new meal.
    */
    var target: TargetData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self;
        
        checkValidTargetTitle()
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if targetSaveButton === sender {
            let now = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

            let title = titleTextField.text ?? ""
            let created = formatter.stringFromDate(now)
            
            target = TargetData()
            target?.title = title
            target?.created = created
            Storage().add(target!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

