//
//  UserDetail.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//

import Foundation

class UserDetail {
    var name: String?
    var id = -1
    var email: String?
    var phoneNumber: String?
    var tagId: Int?
    var userUniqueKey: String?
    var image: String?
    
    var isSelected = false
    
    init(dict: [String: Any]) {
        name = dict["full_name"] as? String
        email = dict["email"] as? String
        phoneNumber = dict["phone_number"] as? String
        userUniqueKey = dict["user_unique_key"] as? String
        id = dict["user_id"] as? Int ?? -1
        tagId = dict["tag_id"] as? Int
        
    }
    
    
    class func getObjects(from array: [[String: Any]]) -> [UserDetail] {
        var tempArray = [UserDetail]()
        for each in array {
            tempArray.append(UserDetail(dict: each))
        }
        return tempArray
    }
    
    static func getAllAgentsDefaultObj() -> UserDetail {
        let obj = UserDetail(dict: [:])
        
        obj.name = HippoStrings.allAgentsString + " " + HippoConfig.shared.strings.displayNameForCustomers
        obj.id = -100
        obj.tagId = -100
        
        return obj
    }
    func copy() -> UserDetail {
        let newObject = UserDetail(dict: [:])
        newObject.email = email
        newObject.name = name
        newObject.id = id
        newObject.phoneNumber = phoneNumber
        newObject.tagId = tagId
        newObject.userUniqueKey = userUniqueKey
        newObject.image = image
        newObject.isSelected = isSelected
        
        return newObject
    }

    static func createCopy(oldObject: [UserDetail]) -> [UserDetail] {
        var newObjects = [UserDetail]()
        
        for each in oldObject {
            newObjects.append(each.copy())
        }
        return newObjects
    }
}

