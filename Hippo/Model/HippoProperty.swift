//
//  HippoProperty.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import Foundation

class HippoProperty {
    static var current = HippoProperty()
    
    var forms: [FormData] = []
    var formCollectorTitle: String = ""
    var showMessageSourceIcon: Bool = false
    
    init() { }
}
