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
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    var id: Int?
    
    @IBAction func deletePhoto(sender: UIButton) {

        let alertController = UIAlertController(title: "Hello!", message: "This is Alert sample.", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) {
            action in print(sender)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
            action in print("Pushed CANCEL!")
        }
    
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        //presentViewController(alertController, animated: true, completion: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
