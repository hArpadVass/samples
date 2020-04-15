//
//  BubblySlider.swift
//  nRFMeshProvision_Example
//
//  Created by App BubblyNet on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class BubblySlider: UISlider {
    //10
    let defaultThumbSpace: Float = 20
    lazy var startingOffset: Float = 0 - defaultThumbSpace
    lazy var endingOffset: Float = 2 * defaultThumbSpace
    var delegate : BubblySliderDelegate? = nil
    var isScrollSlider = false
    

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let xTranslation =  startingOffset + (minimumValue + endingOffset) / maximumValue * value
        return super.thumbRect(forBounds: CGRect(x: 0, y: 0, width: 20, height: 20),
                               trackRect: rect.applying(CGAffineTransform(translationX: CGFloat(xTranslation),
                               y: 0)),
                               value: value)
        
    }
    
        func locationForTouches(_ touches: Set<UITouch>) -> CGPoint? {
            return touches.first?.location(in: self)
        }
        
        open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard locationForTouches(touches) != nil else {return}
            delegate?.sendLightnessMessage()
        }
        
        open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if isScrollSlider{
                super.touchesMoved(touches, with: event)
            }else{
                guard let location = locationForTouches(touches) else { return }
                let percentage = Float(location.x / self.bounds.width)
                let delta = percentage * (self.maximumValue - self.minimumValue)
                let value = self.minimumValue + delta
                self.setValue(value, animated: false)
                super.touchesMoved(touches, with: event)
            }
            delegate?.updateLabel()
        }
        
        open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard locationForTouches(touches) != nil else {return}
            delegate?.sendLightnessMessage()
        }
    }

    
    protocol BubblySliderDelegate {
        func sendLightnessMessage()
        func updateLabel()
}
