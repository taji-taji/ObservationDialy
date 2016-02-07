//
//  TargetTableViewCell.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import Material

class TargetTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: ImageThumbnailView!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var editTargetButton: BasicButton!
}
