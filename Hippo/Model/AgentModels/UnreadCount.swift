//
//  UnreadCount.swift
//  SDKDemo1
//
//  Created by Vishal on 27/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

class UnreadCountInteracter {
    
}

class UnreadCount {
    static var unreadCountList = [String: UnreadCount]()
    static var channelUniqueKeyMapping = [Int: [String]]()
    static var userUniqueKeyList = [String]()
    
    var hippoId: Int = -1
    var userUniqueKey: String = ""
    var count: Int = 0
    
    init(json: [String: Any]) {
        hippoId = json["user_id"] as? Int ?? -1
        userUniqueKey = json["user_unique_key"] as? String ?? ""
        count = json["unread_count"] as? Int ?? 0
    }
    class func refreshHashmaps(array: [[String: Any]]) {
        var list = [String: UnreadCount]()
        var mapping = [Int: [String]]()
        for each in array {
            let object = UnreadCount(json: each)
            list[object.userUniqueKey] = object
            
            let channels = each["channels"] as? [Int] ?? []
            for channel in channels {
                var channelList = mapping[channel] ?? []
                if !channelList.contains(object.userUniqueKey) {
                    channelList.append(object.userUniqueKey)
                    mapping[channel] = channelList
                }
            }
        }
        unreadCountList = list
        channelUniqueKeyMapping = mapping
    }
    class func getCustomerId(for userUniqueId: String) -> Int? {
        return unreadCountList[userUniqueId]?.hippoId
    }
    
    class func clearAllStoredUnreadCount() {
        unreadCountList = [String: UnreadCount]()
    }
    
    class func decreaseUnreadCount(for keys: [String], by count: Int) {
        guard !keys.isEmpty, count > 0 else {
            return
        }
        for each in keys {
            guard let obj = unreadCountList[each] else {
                return
            }
            let newCount = obj.count - count
            obj.count = newCount > 0 ? newCount : 0
            unreadCountList[each] = obj
        }
        sendUserUnreadCount()
    }
    class func increaseUnreadCount(for userUniqueKey: String, by count: Int = 1) {
        guard !userUniqueKey.isEmpty, count > 0 else {
            return
        }
        
        guard let obj = unreadCountList[userUniqueKey] else {
            return
        }
        let newCount = obj.count + count
        obj.count = newCount > 0 ? newCount : 0
        unreadCountList[userUniqueKey] = obj
        sendUserUnreadCount()
    }
    class func increaseUnreadCounts(for keys: [String], by count: Int = 1) {
        guard !keys.isEmpty, count > 0 else {
            return
        }
        for each in keys {
            guard let obj = unreadCountList[each] else {
                continue
            }
            let newCount = obj.count + count
            obj.count = newCount > 0 ? newCount : 0
            unreadCountList[each] = obj
        }
        sendUserUnreadCount()
    }
    
    class func getJsonToSend() -> [String: Int] {
        var array = [String: Int]()
        
        for (_, value) in unreadCountList {
            array[value.userUniqueKey] = value.count
        }
        return array
    }
    
    
    
}

extension UnreadCount {
    class func getUnreadCount(completion: @escaping ((_ result: ResponseResult) -> Void)) {
        
        guard HippoConfig.shared.appUserType == .agent, HippoConfig.shared.agentDetail != nil else {
            completion(ResponseResult(isSuccessful: false, error: HippoError.general))
            return
        }
        
        guard !userUniqueKeyList.isEmpty else {
            completion(ResponseResult(isSuccessful: false, error: HippoError.general))
            return
        }
        
        guard let params = paramsForGetCount() else {
            completion(ResponseResult(isSuccessful: false, error: HippoError.general))
            return
        }
        HippoConfig.shared.log.trace(params, level: .request)
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getUnreadCount.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                HippoConfig.shared.log.error(error ?? "Something went Wrong!!", level: .error)
                completion(ResponseResult(isSuccessful: false, error: error))
                return
            }
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            
            guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], let user_unread_count = data["user_unread_count"] as? [[String: Any]] else {
                HippoConfig.shared.log.error(error ?? "Something went Wrong!!!!", level: .error)
                completion(ResponseResult(isSuccessful: false, error: error))
                return
            }
            refreshHashmaps(array: user_unread_count)
            sendUserUnreadCount()
            let result = ResponseResult(isSuccessful: true, error: error)
            completion(result)
        }
    }
    
    fileprivate static func paramsForGetCount() -> [String: Any]? {
        var param = [String : Any]()
        
        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            return nil
        }
        
        param["access_token"] = agent.fuguToken
        param["user_unique_key"] = UnreadCount.userUniqueKeyList
        param["response_type"] = 1
        return param
    }
}
