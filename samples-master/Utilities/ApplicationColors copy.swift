//
//  ApplicationColors.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 2/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ApplicationColors {
    ///check if app is in darkMode or not
    var isDarkModeEnabled : Bool {
        guard #available(iOS 13.0, *) else {return false}
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    ///light colors
    let primaryLight =  UIColor(displayP3Red: 255/255, green: 62/255, blue: 0/255, alpha: 1)
    let secondaryLight = UIColor(red: 0.8431, green: 0.6275, blue: 0.9686, alpha: 1)

    ///dark colors
    let primaryDark =  UIColor.darkGray
    let secondaryDark = UIColor(displayP3Red: 255/255, green: 62/255, blue: 0/255, alpha: 1)

    var primary : UIColor   { return isDarkModeEnabled ? primaryDark   : primaryLight   }
    var secondary : UIColor { return isDarkModeEnabled ? secondaryDark : secondaryLight }
    
    var tertiary = UIColor.lightGray
}
