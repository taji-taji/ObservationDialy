//
//  TargetEditView.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/06.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
class TargetEditView: MaterialView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.whiteColor()
        self.shape = .Square
        self.depth = .Depth2
    }
    
}
