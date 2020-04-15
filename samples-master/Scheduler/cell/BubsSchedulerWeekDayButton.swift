//
//  BubsSchedulerWeekDayButton.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class BubsSchedulerWeekDayButton: UIButton {

      var isOn = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        layer.borderWidth = 2.0
        layer.backgroundColor = UIColor.clear.cgColor
        layer.borderColor = ApplicationColors.color.primaryLight.cgColor
        layer.cornerRadius = frame.size.height/2
        self.setTitleColor(ApplicationColors.color.primaryLight, for: .normal)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        contentVerticalAlignment = .center

        //setTitleColor(.white, for: .normal)
        addTarget(self, action: #selector(BubsSchedulerWeekDayButton.buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isOn)
    }
    
    public func activateButton(bool: Bool) {
        isOn = bool
        
        let color = bool ? ApplicationColors.color.primaryLight : .clear
        let titleColor = bool ? UIColor.white : ApplicationColors.color.primaryLight
        
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
    }

}

extension UIButton {
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.titleLabel?.textColor = UIColor.white
    }
}
