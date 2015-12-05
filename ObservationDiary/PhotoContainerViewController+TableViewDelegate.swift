//
//  PhotoContainerViewController+TableViewDelegate.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/05.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

extension PhotoContainerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // headerのビュー
        let header = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, heightForHeaderInSection))
        header.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
        let headerBorder = UIView(frame: CGRectMake(0, header.bounds.size.height, header.bounds.size.width, 0.5))
        headerBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        
        // 作成日
        let createDate = UILabel(frame: CGRectMake(10, 0, tableView.bounds.size.width, header.bounds.size.height))
        createDate.text = DateUtility(dateFormat: "YYYY年 MM月 dd日").dateToStr(photos![section].created)
        createDate.font = UIFont.systemFontOfSize(17, weight: 0.3)
        createDate.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        createDate.textAlignment = .Center
        
        header.addSubview(createDate)
        header.addSubview(headerBorder)
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }

}
