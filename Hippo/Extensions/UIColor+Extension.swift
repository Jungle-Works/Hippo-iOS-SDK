//
//  UIColor+Extension.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    func createImage(withFrameSize frameSize: CGSize) -> UIImage {
        return UIImage.createImage(withColor: self, frameSize: frameSize)
    }
    
}

internal extension UIColor {
    
    class var themeColor: UIColor {
        return HippoConfig.shared.theme.themeColor//UIColor(red: 109/255, green: 212/255, blue: 0/255, alpha: 1)
//        return UIColor(red: 34/255, green: 150/255, blue: 255/255, alpha: 1)
        //return UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
    }
    class var textHighlightedColor: UIColor {
        return UIColor(red: 5/255, green: 122/255, blue: 125/255, alpha: 1)
    }
    class var textBlueColor: UIColor {
        return UIColor(red: 15/255, green: 150/255, blue: 242/255, alpha: 1)
    }
    
    class var purpleGrey: UIColor {
        return UIColor(red: 136/255, green: 131/255, blue: 140/255, alpha: 1)
    }
    
    class var veryLightBlue: UIColor {
        return UIColor(red: 248/255, green: 249/255, blue: 255/255, alpha: 1)
    }
    
    class var solitude: UIColor {
        return UIColor(red: 242/255, green: 244/255, blue: 250/255, alpha: 1)
    }
    
    class var pumpkinOrange: UIColor {
        return UIColor(red: 237/255, green: 125/255, blue: 0/255, alpha: 1)
    }
    
    class var textBlackColor: UIColor {
        return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
    }
    
    class var dirtyPurple: UIColor {
        return UIColor(red: 81/255, green: 68/255, blue: 92/255, alpha: 1)
    }
    
    class var darkColor: UIColor {
        return UIColor(red: 44/255, green: 35/255, blue: 51/255, alpha: 1)
    }
    
    class var greenApple: UIColor {
        return UIColor(red: 86/255, green: 186/255, blue: 51/255, alpha: 1)
    }
    class var appleColor: UIColor {
        return UIColor(red: 108/255, green: 198/255, blue: 77/255, alpha: 1)
    }
    
    class var borderStrokeColor: UIColor {
        return UIColor(red: 220/255, green: 224/255, blue: 230/255, alpha: 1)
    }
    
    class var incomingMessageBoxColor: UIColor {
        return UIColor(red: 120/255, green: 113/255, blue: 126/255, alpha: 1)
    }
    
    class var outGoingMessageBoxColor: UIColor {
        return UIColor(red: 248/255, green: 249/255, blue: 255/255, alpha: 1)
    }
    
    class var privateMessageBoxColor: UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 217/255, alpha: 1)
    }
    
    class var black40: UIColor {
        return UIColor(white: 0.0, alpha: 0.4)
    }
    
    class func makeColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    class var fadedOrange: UIColor {
        return UIColor(red: 240.0 / 255.0, green: 166.0 / 255.0, blue: 83.0 / 255.0, alpha: 1.0)
    }
    
    class var leafyGreen: UIColor {
        return UIColor(red: 94.0 / 255.0, green: 190.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)
    }
    class var paleGrey: UIColor {
        return UIColor(red: 228.0 / 255.0, green: 228.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
    class var lavenderBlue: UIColor {
        return UIColor(red: 131.0 / 255.0, green: 155.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0)
    }
    
    class var awayStatusColor: UIColor {
        return UIColor(red: 239.0 / 255.0, green: 161.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
    }
    class var availableStatusColor: UIColor {
        return UIColor(red: 108.0 / 255.0, green: 198.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
    class var offlineStatusColor: UIColor {
        return UIColor(red: 136.0 / 255.0, green: 131.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0)
    }
    
    class var crimson: UIColor {
        return UIColor(red: 227.0 / 255.0, green: 53.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
    }
    
    class var darkGrayColorForTag: UIColor {
        return UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)
    }
    
    class var lightGrayBgColorForTag: UIColor {
        return UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    class var unreadMessageColor : UIColor{
        return UIColor(red: 82  , green: 82, blue: 82, alpha: 1.0)
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
