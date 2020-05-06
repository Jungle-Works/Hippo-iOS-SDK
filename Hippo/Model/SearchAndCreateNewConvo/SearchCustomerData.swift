//
//  SearchCustomerData.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 14/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

//import UIKit
//import ObjectMapper
//
//class SearchCustomerData: Mappable {
//
//
//    var user_id: Int?
//    var user_type: Bool?
//    var full_name: String?
//    var phone_number: String?
//    var email: String?
//    var app_name: String?
//    var user_image: String?
//    var status: Bool?
//
//    required init?(map: Map){}
//
//    func mapping(map: Map) {
//        user_id <- map["user_id"]
//        user_type <- map["user_type"]
//        full_name <- map["full_name"]
//        phone_number <- map["phone_number"]
//        email <- map["email"]
//        app_name <- map["app_name"]
//        user_image <- map["user_image"]
//        status <- map["status"]
//    }
//}


import Foundation

//class CustomerInfo: NSObject {}
class SearchCustomerData: NSObject {
    
    var user_id: Int?
    var user_type: Bool?
    var full_name: String?
    var phone_number: String?
    var email: String?
    var app_name: String?
    var user_image: String?
    var status: Bool?
    
    init(json: [String: Any]) {
        user_id = UInt.parse(values: json, key: "user_id")
        user_type = Bool.parse(key: "user_type", json: dict)
        full_name = json["full_name"] as? String ?? ""
        phone_number = json["phone_number"] as? String ?? ""
        email = json["email"] as? String ?? ""
        app_name = json["app_name"] as? String ?? ""
        user_image = json["user_image"] as? String ?? ""
        status = Bool.parse(key: "status", json: dict)
    }

}
