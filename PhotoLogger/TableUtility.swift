//
//  TableUtility.swift
//  PhotoLogger
//
//  Created by tajika on 2015/11/21.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class TableUtility {

    // セル内の要素からセル要素を探し出す
    func findUITableViewCellFromSuperViewsForView(sender: UIView) -> UITableViewCell {
        var superView = sender
        while !(superView is UITableViewCell) {
            superView = superView.superview!
        }
        return superView as! UITableViewCell
    }

}
