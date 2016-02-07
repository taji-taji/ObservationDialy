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
        self.depth = .Depth1
        self.backgroundColor = Constants.Theme.concept()
        self.contentInsetPreset = .WideRectangle3
    }
    
}
