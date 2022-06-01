//
//  SearchCustomAttr.swift
//  Hippo
//
//  Created by soc-admin on 20/05/22.
//

import Foundation

struct SearchCustomAttr{
    let keyName: String
    let predicateName: String
    let isCustomKey: Bool
    
    init(keyName: String, predicateName: String, isCustomKey: Bool? = false) {
        self.keyName = keyName
        self.predicateName = predicateName
        self.isCustomKey = isCustomKey ?? false
    }
}
