//
//  Helper.swift
//  Hippo
//
//  Created by Vishal on 06/03/19.
//

import Foundation


class Helper {
    class func formatNumber(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        
        let str = numberFormatter.string(from: NSNumber.init(floatLiteral: number))
        
        return str ?? "\(number)"
    }
}
