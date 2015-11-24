//
//  TargetTableViewEditCell.swift
//  PhotoLogger
//
//  Created by tajika on 2015/11/21.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class TargetTableViewEditCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var endEditButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
