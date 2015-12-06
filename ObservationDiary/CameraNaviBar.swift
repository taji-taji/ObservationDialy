//
//  CameraNaviBar.swift
//  ObservationDiary
//
//  Created by tajika on 2015/12/06.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit

class CameraNaviBar: UINavigationBar {
    override func sizeThatFits(size: CGSize) -> CGSize {
        let newSize: CGSize = CGSizeMake(size.width, 66)
        return newSize
    }
}