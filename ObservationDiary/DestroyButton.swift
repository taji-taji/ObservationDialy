//
//  DestroyButton.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/06.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
class DestroyButton: BasicButton {
    
    override func prepareView() {
        super.prepareView()
        self.pulseColor = MaterialColor.red.lighten1
        self.setTitleColor(MaterialColor.red.base, forState: .Normal)
    }
    
}
