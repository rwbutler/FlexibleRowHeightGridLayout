//
//  UIColorAdditions.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 21/06/2020.
//  Copyright © 2020 Ross Butler. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    
    static let darkestBlue = UIColor(hexString: "#230A59")
    static let darkBlue = UIColor(hexString: "#3E38F2")
    static let royalBlue = UIColor(hexString: "#0029FA")
    static let paleBlue = UIColor(hexString: "#5C73F2")
    static let palestBlue = UIColor(hexString: "#829FD9")
    
}

extension UIColor {
    
    private static let rgbHexStringCount = 6
    private static let rgbaHexStringCount = 8
    
    convenience init?(hexString: String) {
        let hexWithoutPrefix = hexString.hasPrefix("#")
            ? String(hexString[hexString.index(after: hexString.startIndex)...])
            : hexString
        
        guard hexWithoutPrefix.count >= type(of: self).rgbHexStringCount else {
            return nil
        }
        let redIndex = hexWithoutPrefix.startIndex
        let greenIndex = hexWithoutPrefix.index(hexWithoutPrefix.startIndex, offsetBy: 2)
        let blueIndex = hexWithoutPrefix.index(hexWithoutPrefix.startIndex, offsetBy: 4)
        let alphaIndex = hexWithoutPrefix.index(hexWithoutPrefix.startIndex, offsetBy: 6)
        let redString = String(hexWithoutPrefix[redIndex..<greenIndex])
        let greenString = String(hexWithoutPrefix[greenIndex..<blueIndex])
        let blueString = String(hexWithoutPrefix[blueIndex..<alphaIndex])
        let alphaString = (hexWithoutPrefix.count == type(of: self).rgbaHexStringCount)
            ? String(hexWithoutPrefix[alphaIndex..<hexWithoutPrefix.endIndex])
            : "255"
        guard let redBase16 = UInt(redString, radix: 16),
            let greenBase16 = UInt(greenString, radix: 16),
            let blueBase16 = UInt(blueString, radix: 16),
            let alphaBase16 = UInt(alphaString, radix: 16) else {
                return nil
        }
        let redFloat = CGFloat(redBase16) / 255
        let blueFloat = CGFloat(blueBase16) / 255
        let greenFloat = CGFloat(greenBase16) / 255
        let alphaFloat = CGFloat(alphaBase16) / 255
        self.init(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)
    }
    
}
