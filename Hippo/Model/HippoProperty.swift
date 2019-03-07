//
//  HippoProperty.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import Foundation

class HippoProperty: NSObject {
    static var current = HippoProperty()
    
    //Inital Form collector info
    var forms: [FormData] = []
    var formCollectorTitle: String = ""
    
    //Properties
    var showMessageSourceIcon: Bool = false
    private(set) var isPaymentRequestEnabled: Bool = false
    
    
    func updatePaymentRequestStatus(enable: Bool) {
        isPaymentRequestEnabled = enable
    }
}



