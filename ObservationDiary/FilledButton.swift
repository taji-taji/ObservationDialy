//
//  FilledButton.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/06.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
class FilledButton: RaisedButton {
    
    override var enabled: Bool {
        didSet {
            self.alpha = enabled ? 1 : 0.6
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareView() {
        super.prepareView()
        self.depth = .None
        self.backgroundColor = Constants.Theme.subConcept
        self.setTitleColor(Constants.Theme.textColor, forState: .Normal)
        self.titleLabel?.font = RobotoFont.mediumWithSize(16)
        self.contentInsetPreset = .WideRectangle3
    }
    
}
