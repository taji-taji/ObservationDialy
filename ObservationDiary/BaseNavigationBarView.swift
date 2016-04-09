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
class BaseNavigationBarView: UIView {
    
    var navigationBarView: Toolbar = Toolbar()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clearColor()
        self.layer.zPosition = 10000
        initNavigationBarView()
    }
    
    private func initNavigationBarView() {
        navigationBarView.backgroundColor = Constants.Theme.concept
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15, weight: 10)
        label.textColor = MaterialColor.white
        navigationBarView.titleLabel = label
        navigationBarView.leftControls = []
        navigationBarView.rightControls = []
        self.addSubview(navigationBarView)
    }
    
    func setTitle(title: String) {
        navigationBarView.titleLabel?.text = title
    }
    
    override func updateConstraints() {
        super.updateConstraints()

        guard let superview = self.superview else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraintEqualToAnchor(superview.topAnchor).active = true
        self.leadingAnchor.constraintEqualToAnchor(superview.leadingAnchor).active = true
        self.trailingAnchor.constraintEqualToAnchor(superview.trailingAnchor).active = true
        self.heightAnchor.constraintEqualToAnchor(heightAnchor, multiplier: 1.0, constant: 70).active = true
        
        navigationBarView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        navigationBarView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        navigationBarView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        navigationBarView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 2).active = true
        
    }

}
