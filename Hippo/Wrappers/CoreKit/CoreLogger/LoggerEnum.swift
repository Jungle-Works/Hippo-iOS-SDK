//
//  LoggerEnum.swift
//  CoreKit
//
//  Created by Vishal on 11/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import Foundation


public enum LogType: Int {
    case applicationLevel = 0
    case apiLevel = 1
    case networkLevel = 2
    case socketLevel = 3
    case defaultError = 4
    case unknown = 5
    case custom = 6
    
    var description: String {
        return String(describing: self).uppercased()
    }
}

public enum LogLevel: Int {
    case trace = 0
    case debug
    case info
    case warning
    case error
    
    var description: String {
        return String(describing: self).uppercased()
    }
}
