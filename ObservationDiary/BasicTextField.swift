//
//  BasicTextField.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/06.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
public class BasicTextField: TextField {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.font = RobotoFont.regularWithSize(20)
        self.textColor = MaterialColor.black
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = RobotoFont.mediumWithSize(12)
        self.titleLabelColor = MaterialColor.grey.lighten1
        self.titleLabelActiveColor = MaterialColor.blue.accent3
        self.clearButtonMode = .WhileEditing
    }
    
}
