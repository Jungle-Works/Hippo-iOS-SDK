//
//  FuguChannelTag.swift
//  SDKDemo1
//
//  Created by Vishal on 19/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

class TagDetail: NSObject, Copying {
    
    var colorCode: String?
    var status: Int?
    var tagId: Int?
    var tagName: String?
    var isSelected = false
    var tagType = 1 //1 for normal tag and 2 for grouping tag
    
    var searchableString: String = ""

    init(json: [String: Any]) {
        colorCode = json["color_code"] as? String
        status = json["status"] as? Int
        tagId = json["tag_id"] as? Int
        tagName = json["tag_name"] as? String
        tagType = json["tag_type"] as? Int ?? 1
        
        searchableString = tagName?.lowercased() ?? ""
    }
    
    required init(original: TagDetail) {
        tagId = original.tagId
        tagName = original.tagName
        isSelected = original.isSelected
        colorCode = original.colorCode
        status = original.status
        tagType = original.tagType
        
        searchableString = tagName?.lowercased() ?? ""
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
    
    class func parseTagDetailWithSelected(data: [[String:Any]], sortList: Bool, existingTagsArray: [TagDetail]) -> [TagDetail] {
        let allTags = parseTagDetail(data: data)
        
        var index = -1
        for each in allTags {
            index += 1
            let isPresent = existingTagsArray.contains(where: { (t) -> Bool in
                t.tagId == each.tagId
            })
            guard isPresent else {
                continue
            }
            allTags[index].isSelected = true
            allTags[index].status = 1
        }
        
        let sortedTags = allTags.sorted { (t1, t2) -> Bool in
            t1.isSelected && (t2.isSelected == false)
        }
        return sortedTags
    }
}

extension TagDetail: Storing {
    func getJsonToStore() -> [String: Any]? {
        var json: [String: Any] = [:]
        
        if let color_code = colorCode {
            json["color_code"] = color_code
        }
        if let status = self.status {
            json["status"] = status
        }
        if let tag_id = tagId {
            json["tag_id"] = tag_id
        }
        if let tag_name = tagName {
            json["tag_name"] = tag_name
        }
        return json
    }
}


protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}


extension Array where Element: Storing {
    func getJsonToStore() -> [[String: Any]] {
        var copiedArray: [[String: Any]] = []
        for element in self {
            guard let obj = element.getJsonToStore() else {
                continue
            }
            copiedArray.append(obj)
        }
        return copiedArray
    }
}

protocol Storing: class {
    func getJsonToStore() -> [String: Any]?
}
