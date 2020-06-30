//
//  ProfileDetail.swift
//  HippoChat
//
//  Created by Vishal on 26/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation

class ProfileDetail {
    var fullName: String?
    var rating: Double?
    var image: String?
    var id: String?
    var desc: String?
    var customField: [CustomField] = []
    var descriptionField: CustomField?
    
    var listToDisplay: [CustomField] = []
    
    
    init(json: [String: Any]) {
        fullName = String.parse(values: json, key: "full_name")
        rating = Double.parse(values: json, key: "rating")
        image = String.parse(values: json, key: "user_image")
        desc = String.parse(values: json, key: "description")
        id = String.parse(values: json, key: "agent_id") ?? String.parse(values: json, key: "user_id")
        
        if let rawCustomFields = json["custom_fields"] as? [[String: Any]] {
            customField = CustomField.parse(list: rawCustomFields)
        }
        descriptionField = CustomField(json: [:])
        descriptionField?.value = desc
        descriptionField?.displayName = HippoStrings.description
        
        filterList()
    }
    
    internal func filterList() {
        let list = customField.filter { (c) -> Bool in
            return c.showToCustomer && !(c.value ?? "").isEmpty
        }
        self.listToDisplay = list
    }
}
