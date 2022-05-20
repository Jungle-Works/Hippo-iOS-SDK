//
//  SearchCustomerData.swift
//  Hippo
//
//  Created by soc-admin on 20/05/22.
//

import Foundation

class SearchCustomerData {
  
    var user_id: Int?
    var user_type: Bool?
    var full_name: String?
    var phone_number: String?
    var email: String?
    var app_name: String?
    var user_image: String?
    var status: Bool?
    
    init(dict: [String: Any]){
        if let userId = dict["user_id"] as? Int{
            self.user_id = userId
        }
        
        if let userType = dict["user_type"] as? Bool{
            self.user_type = userType
        }
        
        if let fullName = dict["full_name"] as? String{
            self.full_name = fullName
        }
        
        if let phoneNumber = dict["phone_number"] as? String{
            self.phone_number = phoneNumber
        }
        
        if let email = dict["email"] as? String{
            self.email = email
        }
        
        if let appName = dict["app_name"] as? String{
            self.app_name = appName
        }
        
        if let userImage = dict["user_image"] as? String{
            self.user_image = userImage
        }
        
        if let status = dict["status"] as? Bool{
            self.status = status
        }
    }
}
