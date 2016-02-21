//
//  BasicTextView.swift
//  ObservationDiary
//
//  Created by tajika on 2016/02/14.
//  Copyright © 2016年 Tajika. All rights reserved.
//

import UIKit
import Material

@IBDesignable
public class BasicTextView: UIView {
    
    lazy var text: Text = Text()
    var textView: TextView = TextView()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        let layoutManager: NSLayoutManager = NSLayoutManager()
        let textContainer: NSTextContainer = NSTextContainer(size: self.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        text.textStorage.addLayoutManager(layoutManager)
        
        textView = TextView(textContainer: textContainer)
        textView.font = RobotoFont.regular
        
        textView.placeholderLabel = UILabel()
        textView.placeholderLabel?.textColor = MaterialColor.grey.base
        textView.placeholderLabel?.text = "Description"
        
        textView.titleLabel = UILabel()
        textView.titleLabel!.font = RobotoFont.mediumWithSize(12)
        textView.titleLabelColor = MaterialColor.grey.base
        textView.titleLabelActiveColor = MaterialColor.blue.accent3
        
        textView.scrollEnabled = true
        
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignToParent(self, child: textView, top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
