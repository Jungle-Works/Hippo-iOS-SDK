//
//  MultiSelectCard.swift
//  HippoChat
//
//  Created by Clicklabs on 12/17/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation


struct MultiSelectCard: HippoCard
{
    var cardHeight: CGFloat {
        return 50
    }
    
    let id: String
    let label: String
    let status : Bool
    
    
    init?(json: [String: Any]) {
        guard json["id"] != nil else {
            return nil
        }
        
        self.label = String.parse(values: json, key: "label")
        self.id = String.parse(values: json, key: "id")
        self.status = Bool.parse(key: "status", json: json, defaultValue: false)
    }
}
