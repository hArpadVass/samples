//
//  SchedulerDayButtons.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class SchedulerDayButtons: UIButton {

      var isOn = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        
        let adaptiveColor = ApplicationColors.color.isDarkModeEnabled ? ApplicationColors.color.primaryDarkModeLight : ApplicationColors.color.primaryLight
        
        
        setTitle("A", for: .normal)
        layer.borderWidth = 2.0
        layer.backgroundColor = adaptiveColor.cgColor
        layer.borderColor = adaptiveColor.cgColor
        layer.cornerRadius = frame.size.height/2
        
        setTitleColor(.white, for: .normal)
        addTarget(self, action: #selector(SchedulerDayButtons.buttonPressed), for: .touchUpInside)
        
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isOn)
        UIView.animate(withDuration: 1.0) {
            //self.activateButton(bool: !self.isOn)
        }
        
    }
    
    public func activateButton(bool: Bool) {
        
        isOn = bool
        
        let adaptiveColor = ApplicationColors.color.isDarkModeEnabled ? ApplicationColors.color.primaryDarkModeLight : ApplicationColors.color.primaryLight
        
        let color = bool ? adaptiveColor : .clear
        let title = bool ? "A" : "B"
        let titleColor = bool ? UIColor.white : adaptiveColor
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
    }

}
