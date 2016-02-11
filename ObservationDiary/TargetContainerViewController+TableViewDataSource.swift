//
//  TargetContainerViewController+TableViewDataSource.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/10.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

extension TargetContainerViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let target = targets[indexPath.row]
        
        let cellIdentifier = "TargetTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TargetTableViewCell
        cell.titleLabel.text = target.title
        cell.editTargetButton.contentInsetPreset = .None
        cell.updatedLabel.text = DateUtility(dateFormat: nil).dateFromNow(target.updated)
        
        // 最新の画像をサムネイルに入れる
        if let photo = target.photos.last {
            if let jpeg: UIImage? = PhotoUtility().get(photo.photo) {
                cell.photoImageView.image = jpeg
            }
            // 画像がない場合はデフォルト画像
        } else {
            cell.photoImageView.image = R.image.defaultPhoto()
        }
        
        return cell
        
    }
}
