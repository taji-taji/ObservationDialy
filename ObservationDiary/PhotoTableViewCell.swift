//
//  PhotoTableViewCell.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var id: Int?

}
