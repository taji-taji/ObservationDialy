//
//  AlphaControlSlider.swift
//  ObservationDiary
//
//  Created by tajika on 2016/01/20.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AlphaControlSlider: UISlider {
    
    override func awakeFromNib() {
        self.minimumTrackTintColor = Constants.Theme.concept()
        self.setThumbImage(R.image.sliderHandle(), forState: .Normal)
        self.minimumValue = 0
        self.maximumValue = 1
        self.value = 0.3
    }
    
}