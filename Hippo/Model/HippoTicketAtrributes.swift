//
//  HippoTicketAtrributes.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

public class HippoTicketAtrributes: NSObject {
    var FAQName = ""
    var transactionId: String? = nil
    
    public override init() {
        
    }
    public init(categoryName: String, transactionId: String? = nil) {
        if !categoryName.trimWhiteSpacesAndNewLine().isEmpty {
            self.FAQName  = categoryName
        }
        if transactionId != nil, !transactionId!.isEmpty {
            self.transactionId = transactionId
        }
    }
}
