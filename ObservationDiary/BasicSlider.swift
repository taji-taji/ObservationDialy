//
//  BasicSlider.swift
//  ObservationDiary
//
//  Created by tajika on 2016/04/10.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit

@IBDesignable
class BasicSlider: UISlider {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.minimumTrackTintColor = Constants.Theme.concept
        self.setThumbImage(R.image.sliderHandle(), forState: .Normal)
    }

}
