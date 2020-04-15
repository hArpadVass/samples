//
//  Bubbly059TimeView.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 1/28/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class Bubbly059TimeView: UIView {

    var mTimePicker = UIPickerView()
    var pickerValue : Int {
        return mTimePicker.selectedRow(inComponent: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        regularInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        regularInit()
    }
    
    override func awakeFromNib() {
        let timePicker: UIPickerView = UIPickerView()
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.autoresizingMask = [.flexibleWidth]
        timePicker.frame = self.bounds
        self.addSubview(timePicker)
        mTimePicker = timePicker
    }
    
    func regularInit(){}
    
}
extension Bubbly059TimeView : UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        pickerView.reloadAllComponents()
    }
}
