//
//  PhotoTableViewCell.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var id: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
