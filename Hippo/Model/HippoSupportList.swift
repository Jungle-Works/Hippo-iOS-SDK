//
//  HippoSupportList.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation


class HippoSupportList: NSObject {
    
    static var currentPathArray = [ListIdentifiers]()
    
    static var FAQName = "FAQ"
    static var list = [HippoSupportList]()
    
    static var currentFAQVersion: Int {
        get {
            return UserDefaults.standard.value(forKey: UserDefaultkeys.currentFAQVersion) as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.currentFAQVersion)
        }
    }
    static var FAQData: [String: Any] {
        get {
            return UserDefaults.standard.value(forKey: UserDefaultkeys.TicketsKey) as? [String: Any] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.TicketsKey)
        }
    }
    
    var id = -1
    var title = ""
    var parent_id = -1
    var isActive = false
    var createdAt = ""
    var updatedAt = ""
    var action = ActionType.LIST
    var viewType = ViewType.list
    var content = HippoDescriptionContent()
    
    var items = [HippoSupportList]()
    
    
    override init() {
        
    }
    init(json: [String: Any]) {
        id = json["support_id"] as? Int ?? -1
        title = json["title"] as? String ?? ""
        parent_id = json["parent_id"] as? Int ?? -1
        createdAt = json["created_at"] as? String ?? ""
        updatedAt = json["updated_at"] as? String ?? ""
        
        if let action_type = json["action_type"] as? Int, let type = ActionType(rawValue: action_type) {
            action = type
        }
        
        if let view_type = json["view_type"] as? Int, let view = ViewType(rawValue: view_type) {
            viewType = view
        }
        if let is_active = json["is_active"] as? String {
            isActive = is_active == "1" ? true : false
        }
        
        if let content = json["content"] as? [String: Any] {
            self.content = HippoDescriptionContent(json: content)
        }
        
        guard let items = json["items"] as? [[String: Any]] else {
            return
        }
        
        for each in items {
            self.items.append(HippoSupportList(json: each))
        }
    }
    
    class func getObjectFrom(_ array: [[String: Any]]) -> [HippoSupportList] {
        var tempArr = [HippoSupportList]()
        for each in array {
            let obj = HippoSupportList(json: each)
            if obj.id > 0 {
                tempArr.append(obj)
            }
        }
        return tempArr
    }
    
    class func getDataFromJson(dict: [String: Any]) -> [HippoSupportList] {
        var tempArray = [HippoSupportList]()
        
        guard let is_faq_enabled = userDetailData["is_faq_enabled"] as? Bool, is_faq_enabled else {
            return tempArray
        }
        
        var defaultKey = "Default"
        
        guard let support_data = dict["data"] as? [String: Any] else {
            return tempArray
        }
        if let key = dict["defaultFaqName"] as? String {
            defaultKey = key
        }
        HippoSupportList.FAQData = dict
        
        var data = [String: Any]()
        var list =  [[String:Any]]()
        
        if !HippoConfig.shared.ticketDetails.FAQName.isEmpty, let temp = getListwhere(key: HippoConfig.shared.ticketDetails.FAQName, from: support_data), let lists = temp["list"] as? [[String: Any]] {
            list = lists
            data = temp
            
        } else if !defaultKey.isEmpty, let temp = getListwhere(key: defaultKey, from: support_data), let lists = temp["list"] as? [[String: Any]]  {
            list = lists
            data = temp
        }
        
        if let category_name = data["faq_name"] as? String {
            HippoSupportList.FAQName = category_name
        }
        tempArray = HippoSupportList.getObjectFrom(list)
        
        return tempArray
        
    }
    
    class func getListwhere(key: String, from data: [String: Any]) -> [String: Any]? {
        var response: [String: Any]?
        
        for (_, value) in data {
            guard let dict = value as? [String: Any], let name = dict["faq_name"] as? String else {
                continue
            }
            if name.lowercased() == key.lowercased(){
                response = dict
                return response
            }
        }
        return response
    }
    
    
    class func getListForBusiness(completion: ((_ success: Bool, _ objectArray: [HippoSupportList]?) -> Void)? = nil) {
        
        guard let userId = HippoUserDetail.fuguEnUserID else {
            return
        }
        let params: [String: Any] = ["app_secret_key" : HippoConfig.shared.appSecretKey,
                                     "en_user_id" : userId,
                                     "is_active": 1]
        print(params)
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params,  extendedUrl: "api/business/getBusinessSupportPanel") {(responseObject, error, tag, statusCode) in
            switch (statusCode ?? -1) {
            case StatusCodeValue.Authorized_Min.rawValue..<StatusCodeValue.Authorized_Max.rawValue:
                guard let response = responseObject as? [String: Any] else {
                    return
                }
                
                let array = HippoSupportList.getDataFromJson(dict: response)
                
                completion?(true, array)
            case 406:
                completion?(false, nil)
            default:
                completion?(false, nil)
                
            }
        }
    }
}

struct ListIdentifiers {
    var id = 0
    var title = ""
    var parentId = -1
    
    init(id: Int, title: String, parentId: Int) {
        self.id = id
        self.title = title
        self.parentId = parentId
    }
}

