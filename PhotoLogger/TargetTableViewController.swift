//
//  TargetTableViewController.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class TargetTableViewController: UITableViewController {
    
    // MARK: Properties
    var targets = Storage().findAll(TargetData())

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        navigationItem.leftBarButtonItem = editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TargetTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TargetTableViewCell

        let target = targets[indexPath.row]
        
        cell.titleLabel.text = target.title
        // ここは後で直す
        cell.updatedLabel.text = target.created

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let deleteData: TargetData = targets[indexPath.row]
            Storage().delete(deleteData)
            targets.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // 次の画面にデータを渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 次の画面のViewControllerを取得
        let targetPhotoView = segue.destinationViewController as? PhotoTableViewController
        // segueを判定して処理を振り分ける
        if segue.identifier == "targetPhotoSegue" {
            // 選択したセルを取得
            if let selectedTargetCell = sender as? TargetTableViewCell {
                // 選択したセルのindexPathを取得
                let indexPath = tableView.indexPathForCell(selectedTargetCell)!
                // indexPathからTargetDataを取得
                let selectedTarget = targets[indexPath.row]
                // 次のViewControllerに渡す
                targetPhotoView?.target = selectedTarget
            }
        }
    }

    @IBAction func unwindToTargetList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? TargetViewController, target = sourceViewController.target {
            // targetの追加
            // 0番目のindexPath
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            // 0番目のindexPathに新規targetが来るように配列の0番目に追加
            targets.insert(target, atIndex: 0)
            
            // テーブルに挿入
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
        }
    }
}
