//
//  SchedulerModalViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 1/28/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class SchedulerModalViewController: UIViewController {
    var advancedTimeChosenDelegate : AdvancedSettingsChosenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTransparency(isTransparent: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.389 ) {
            UIView.animate(withDuration: 0.2) {
                self.setTransparency(isTransparent: false)
            }
        }
    }
    
    func setTransparency(isTransparent: Bool){
        self.view.backgroundColor = UIColor(
            red: 0,
            green: 0.0078,
            blue: 0.1333,
            alpha: isTransparent ? 0 : 0.20
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAdvancedSettigns"{
            if let destination = segue.destination as? SchedulerAdvancedViewController{
                destination.advancedTimeChosenDelegate = self.advancedTimeChosenDelegate
            }
        }
    }
}
