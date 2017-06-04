//
//  MyDownPicker.swift
//  Cleanflight Configurator
//
//  Created by Raphael Jean-Leconte on 14/12/15.
//  Copyright © 2015 Raphael Jean-Leconte. All rights reserved.
//

import UIKit
import DownPicker

class MyDownPicker: DownPicker {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init!(textField tf: UITextField!) {
        super.init(textField: tf)
        setPlaceholder("")
    }
    
    override init!(textField tf: UITextField!, withData data: [AnyObject]!) {
        super.init(textField: tf, withData: data)
        setPlaceholder("")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let beginEditing = super.textFieldShouldBeginEditing(textField)
        if beginEditing {
            sendActionsForControlEvents(.EditingDidBegin)
        }
        
        return beginEditing
    }
    
    override func textFieldDidEndEditing(textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        sendActionsForControlEvents(.EditingDidEnd)
    }

    override var selectedIndex: Int {
        get {
            return super.selectedIndex
        }
        set(value) {
            // Hack to get the size of the data array
            let dataCount = super.pickerView(UIPickerView(), numberOfRowsInComponent: 0)
            if value < 0 || value >= dataCount {
                super.selectedIndex = -1
            } else {
                super.selectedIndex = value
            }
        }
    }
}
