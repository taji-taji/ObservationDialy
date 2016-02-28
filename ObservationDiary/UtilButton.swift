//
//  UtilButton.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/07.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
class UtilButton: FlatButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareView() {
        super.prepareView()
        self.pulseColor = Constants.Theme.concept
        self.contentEdgeInsetsPreset = .WideRectangle2
    }
    
}
