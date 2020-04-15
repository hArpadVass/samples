//
//  BitAssistant.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 12/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
class BitAssistant {
    
    init() {}
    
        enum Bit: UInt8, CustomStringConvertible {
        case zero, one

        var description: String {
            switch self {
            case .one:
                return "1"
            case .zero:
                return "0"
            }
        }
    }
    
    func bits<T: FixedWidthInteger>(fromBytes bytes: T) -> [Bit] {
        var bytes = bytes
        var bits = [Bit](repeating: .zero, count: T.bitWidth)
        for i in 0..<T.bitWidth {
            let currentBit = bytes & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }

            bytes >>= 1
        }

        return bits
    }
}
