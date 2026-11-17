//
//  Address.swift
//  Hippo
//
//  Created by Arohi Magotra on 29/04/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation

struct Address : Codable {
    var address : String?
    /// Place name, when the search returns one.
    var name : String?
    var lat : Double?
    var lng : Double?
    
    init() {
        
    }
}

