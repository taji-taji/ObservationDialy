//
//  NavBarButton.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/07.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
class NavBarButton: FlatButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareView() {
        super.prepareView()
        self.pulseColor = UIColor.whiteColor()
        self.titleLabel!.font = RobotoFont.mediumWithSize(18)
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.backgroundColor = UIColor.clearColor()
        self.shadowColor = UIColor.clearColor()
        self.tintColor = UIColor.clearColor()
        self.contentInsetPreset = .WideRectangle3
    }
    
}
