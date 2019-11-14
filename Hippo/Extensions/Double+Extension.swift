
//
//  Double+Extension.swift
//  HippoChat
//
//  Created by Vishal on 04/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation

extension Double {
    static func parse(values: [String: Any], key: String) -> Double? {
        guard let temp = values[key] else {
            return nil
        }
        
        switch temp {
        case let val as Double:
            return val
        case let val as Int64:
            return Double(integerLiteral: val)
        case let val as NSNumber:
            return Double(exactly: val)
        default:
            return nil
        }
    }
}
