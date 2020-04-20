//
//  CustomerInfo.swift
//  Fugu
//
//  Created by Vishal on 11/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation


class CustomerInfo: NSObject {
    var customerID: UInt?
    var customerName: String = ""
    var customerEmail: String = ""
    var unreadCount: Int = 0
    var lastActivity: String = ""
    var repliedOn: UInt?
    
    //MARK: Computed Property
    var lastActivityDate: Date?
    
    init(json: [String: Any]) {
        customerID = UInt.parse(values: json, key: "user_id")
        customerName = json["full_name"] as? String ?? ""
        customerEmail = json["email"] as? String ?? ""
        unreadCount = Int.parse(values: json, key: "unread_count") ?? 0
        lastActivity = json["last_activity"] as? String ?? ""
        repliedOn = UInt.parse(values: json, key: "replied_on")
        
        // Computed Property
        if !lastActivity.isEmpty {
            lastActivityDate = lastActivity.toDate
        }
    }
    
    class func parse(list: [[String: Any]]) -> [CustomerInfo] {
        var objects: [CustomerInfo] = []
        
        for each in list {
            let object = CustomerInfo(json: each)
            objects.append(object)
        }
        return objects
    }
}
