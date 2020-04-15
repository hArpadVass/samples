//
//  MinuteTimePicker.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 1/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class MinuteTimePicker: Bubbly059TimeView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mTimePicker.delegate = self
    }
    
    override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return "Minute \(row)"
    }
}

class SecondTimePicker: Bubbly059TimeView {
        required init?(coder: NSCoder) {
        super.init(coder: coder)
        mTimePicker.delegate = self
    }
    
    override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Second \(row)"
    }
}

class HourTimePicker: Bubbly059TimeView {
        required init?(coder: NSCoder) {
        super.init(coder: coder)
        mTimePicker.delegate = self
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 24
    }
    
    override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Hour \(row + 1)"
    }
}


