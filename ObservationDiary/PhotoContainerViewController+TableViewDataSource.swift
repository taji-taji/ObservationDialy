//
//  PhotoContainerViewController+TableViewDataSource.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

extension PhotoContainerViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print((target?.photos)!.count)
        return (target?.photos)!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
            let cellIdentifier = "PhotoTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PhotoTableViewCell
            
            let photo = photos![indexPath.section]
            
            let fileName = photo.photo
            
            if let jpeg: UIImage? = PhotoUtility().get(fileName) {
                cell.photoImage.image = jpeg
                cell.commentText.text = photo.comment
                cell.timeLabel.text = DateUtility(dateFormat: "HH時mm分").dateToStr(photo.updated)
                cell.id = photo.id
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "editAlert:")
            cell.editButton.addGestureRecognizer(tapGestureRecognizer)
            cell.editButton.setImage(UIImage(named: "EditIconHighlighted"), forState: .Highlighted)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
    }
    
}
