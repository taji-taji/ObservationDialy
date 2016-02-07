//
//  BaseNavigationBarView.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/05.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
class BaseNavigationBarView: NavigationBarView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = Constants.Theme.concept()
        self.statusBarStyle = .LightContent
    }
    
    func setTitle(title: String) {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(16, weight: 10)
        label.textColor = MaterialColor.white
        label.text = title
        label.textAlignment = .Center
        titleLabel = label
    }
    
}
