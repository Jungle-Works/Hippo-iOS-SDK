//
//  CoreKit.swift
//  CoreKit
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import Foundation


public class CoreKit {
    public static let shared = CoreKit()
    
    open var filesConfig: CoreFilesConfig = CoreFilesConfig.defaultConfig()
}
