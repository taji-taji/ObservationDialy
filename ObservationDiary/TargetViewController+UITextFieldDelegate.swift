//
//  TargetViewController+UITextFieldDelegate.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/17.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

extension TargetViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // キーボードを隠す
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        checkValidTargetTitle()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidTargetTitle()
    }
    
}
