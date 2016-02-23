//
//  ShareMovieViewController+PickerViewDelegate+DataSource.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/21.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit

extension ShareMovieViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Delegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "@\(accounts[row].username)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        account = accounts[row]
    }
    
    // MARK: DataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }

}

extension UIPickerView {
    public override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        if subview.bounds.height < 1.0 {
            subview.backgroundColor = UIColor.clearColor()
        }
    }
}
