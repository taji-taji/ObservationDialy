//
//  PhotoViewController.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var commentTextView: UITextView!
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let selectedImage = selectedImage {
            photoImageView?.image = selectedImage
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
