//
//  FuguChannelTag.swift
//  SDKDemo1
//
//  Created by Vishal on 19/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

class TagDetail: NSObject {
    
    var colorCode: String?
    var status: Int?
    var tagId: Int?
    var tagName: String?
    var isSelected = false
    var tagType = 1 //1 for normal tag and 2 for grouping tag
    

    init(json: [String: Any]) {
        colorCode = json["color_code"] as? String
        status = json["status"] as? Int
        tagId = json["tag_id"] as? Int
        tagName = json["tag_name"] as? String
        tagType = json["tag_type"] as? Int ?? 1
    }
    init(original: TagDetail) {
        tagId = original.tagId
        tagName = original.tagName
        isSelected = original.isSelected
        colorCode = original.colorCode
        status = original.status
        tagType = original.tagType
    }
    
    static func getAllTeamObject() -> TagDetail {
        let obj = TagDetail(json: [:])
        
        obj.isSelected = false
        obj.tagName = HippoConfig.shared.strings.allTeamString
        obj.tagId = -100 //normal is just for check
        
        return obj
    }
    
    class func parseTagDetail(data: [[String:Any]]) -> [TagDetail] {
        var tempTagArray = [TagDetail]()
        for each in data {
            let tag = TagDetail(json: each)
            tempTagArray.append(tag)
        }
        return tempTagArray
    }
    
    class func getObjectToStore(tags: [TagDetail]) -> [[String: Any]] {
        var dictArray: [[String: Any]] = []
        
        for each in tags {
           dictArray.append(each.getDictToStore())
        }
        return dictArray
    }
    func getDictToStore() -> [String: Any] {
        var json: [String: Any] = [:]
        
        if colorCode != nil {
            json["color_code"] = colorCode!
        }
        if status != nil {
            json["status"] = status!
        }
        if tagId != nil {
            json["tag_id"] = tagId!
        }
        
        if tagName != nil {
            json["tag_name"] = tagName!
        }
        json["tag_type"] = tagType
        
        return json
    }
}
