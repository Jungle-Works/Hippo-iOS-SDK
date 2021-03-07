//
//  UnreadCount.swift
//  SDKDemo1
//
//  Created by Vishal on 27/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit

class UnreadCountInteracter {
    
}

public typealias P2PUnreadCountCompletion = ((_ response: HippoError?, _ unreadCount: Int?) -> ())
public typealias PrePaymentCompletion = ((_ response: HippoError?) -> ())


class PrePayment{
  
    class func callPrePaymentApi(paymentGatewayId : Int, paymentType : Int?, prePaymentDic: [String : Any], completion: @escaping ((_ result: HippoError?) -> Void)) {
         
        let params = PrePayment.getPrePaymentParams(paymentGatewayId,paymentType, prePaymentDic)
         HippoConfig.shared.log.trace(params, level: .request)
         
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.getPrePayment.rawValue) { (responseObject, error, tag, statusCode) in
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                //                HippoConfig.shared.log.error(error ?? "Something went Wrong!!", level: .error)
                completion(HippoError.general)
                print("Error",error ?? "")
                return
            }
            guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any] else {
                HippoConfig.shared.log.error(error ?? HippoStrings.somethingWentWrong, level: .error)
                completion(HippoError.general)
                return
            }
            let razorPayDic = RazorPayData().getRazorPayDic(data["payment_url"] as? [String : Any] ?? [String : Any]()) ?? RazorPayData()
            if razorPayDic.amount != nil{
    
                return
            }else{
                let channelId = data["channel_id"] as? Int
                let paymentUrl = (data["payment_url"] as? NSDictionary)?.value(forKey: "payment_url") as? String
                FuguFlowManager.shared.presentPrePaymentController(paymentUrl ?? "", channelId ?? -1)
            }
            completion(nil)
        }
     }
    
    static func getPrePaymentParams(_ paymentGatewayId : Int, _ paymentType : Int?, _ prePaymentDic : [String : Any]) -> [String : Any]{
        
        var json: [String: Any] = [:]
        
        let appSecretKey = HippoConfig.shared.appSecretKey
        json["app_secret_key"] = appSecretKey
        let enUserId: String = currentEnUserId()
        json["en_user_id"] = enUserId
        json["fetch_payment_url"] = 1
        json["operation_type"] = 1
        json["payment_items"] = [prePaymentDic]
        json["user_id"] = currentUserId()
        json["transaction_id"] = String.generateUniqueId()
        json["payment_gateway_id"] = paymentGatewayId
        json["is_sdk_flow"] = 1
        if (paymentType ?? 0) > 0{
            json["payment_type"] = paymentType
        }
        return json
    }
    
}


public typealias HippoResponseRecieved = ((_ error: HippoError?, _ param: [String : Any]?) -> ())


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
    class func fetchP2PUnreadCount(request: PeerToPeerChat, callback: @escaping P2PUnreadCountCompletion) {
        let data = P2PUnreadData.shared.getData(with: request.uniqueChatId ?? "")
        if let p2pdata = data{
            let id = ((request.uniqueChatId ?? "") + "-" + (request.idsOfPeers.first ?? ""))
            if ((p2pdata.id ?? "") == id){
                if (p2pdata.channelId ?? -1) > 0{
                    //if channel id is greater than 0
                    HippoConfig.shared.sendp2pUnreadCount(p2pdata.count ?? 0, p2pdata.channelId ?? -1)
                    return
                }else{
                    callback(HippoError.general, nil)
                    return
                }
            }
        }
        
        let params: [String: Any]
        
        do {
          params = try request.generateParamForUnreadCount()
        } catch {
            callback(error as? HippoError, nil)
            return
        }
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.fetchP2PUnreadCount.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                P2PUnreadData.shared.updateChannelId(transactionId: request.uniqueChatId ?? "", channelId: -2, count: 0, otherUserUniqueKey: request.idsOfPeers.first ?? "")
                callback(HippoError.general, nil)
                print("Error",error ?? "")
                return
            }
            guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], let unreadCount = Int.parse(values: data, key: "unread_count") else {
                HippoConfig.shared.log.error(error ?? HippoStrings.somethingWentWrong, level: .error)
                callback(HippoError.general, nil)
                return
            }
            
            if let unreadDic = (responseObject as? [String: Any])?["data"] as? [String : Any]{
//                var unreadHashMap = [String : Any]()
                  let channelId = unreadDic["channel_id"] as? Int ?? -1
                  let unreadCount = unreadDic["unread_count"] as? Int
//                unreadHashMap["\(channelId)"] = unreadCount
//                FuguDefaults.set(value: unreadHashMap, forKey: DefaultName.p2pUnreadCount.rawValue)
                P2PUnreadData.shared.updateChannelId(transactionId: request.uniqueChatId ?? "", channelId: channelId, count: unreadCount ?? 0, otherUserUniqueKey: request.idsOfPeers.first ?? "")
            }
        
          
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            callback(nil, unreadCount)
    
        }
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
                HippoConfig.shared.log.error(error ?? HippoStrings.somethingWentWrong, level: .error)
                completion(ResponseResult(isSuccessful: false, error: error))
                return
            }
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            
            guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], let user_unread_count = data["user_unread_count"] as? [[String: Any]] else {
                HippoConfig.shared.log.error(error ?? HippoStrings.somethingWentWrong, level: .error)
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
    
    fileprivate static func paramsForAgentUnreadCount() -> [String: Any]? {
         var param = [String : Any]()
         
         guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
             return nil
         }
         
         param["access_token"] = agent.fuguToken
     
         return param
     }
    
    
}
extension UnreadCount{
    class func getAgentTotalUnreadCount(completion: @escaping ((_ result: ResponseResult) -> Void)) {
         
         guard HippoConfig.shared.appUserType == .agent, HippoConfig.shared.agentDetail != nil else {
             completion(ResponseResult(isSuccessful: false, error: HippoError.general))
             return
         }
         
         guard let params = paramsForAgentUnreadCount() else {
             completion(ResponseResult(isSuccessful: false, error: HippoError.general))
             return
         }
         HippoConfig.shared.log.trace(params, level: .request)
         
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.conversationUnread.rawValue) { (responseObject, error, tag, statusCode) in
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                HippoConfig.shared.log.error(error ?? HippoStrings.somethingWentWrong, level: .error)
                completion(ResponseResult(isSuccessful: false, error: error))
                return
            }
            if let agentTotalUnreadCount = ((responseObject as? [String: Any])?["data"] as? [String: Any])?["agent_total_unread_count"] as? [NSDictionary]{
            
                let unreadCount = agentTotalUnreadCount.reduce(0) {(result, next) -> Int in
                    return result + (next.value(forKey: "unread_count") as? Int ?? 0)
                }
                var unreadHashMap = [String:Any]()
                for dic in agentTotalUnreadCount{
                    let channelId = dic.value(forKey: "channel_id") as? Int
                    let unreadCount = dic.value(forKey: "unread_count") as? Int
                    unreadHashMap["\(channelId ?? 0)"] = unreadCount
                }
               
                FuguDefaults.set(value: unreadHashMap, forKey: DefaultName.agentTotalUnreadHashMap.rawValue)
                UserDefaults.standard.set(unreadCount, forKey: DefaultName.agentUnreadCount.rawValue)
                HippoConfig.shared.sendAgentUnreadCount(unreadCount)
                HippoConfig.shared.sendAgentChannelsUnreadCount(unreadHashMap.count)
            }
        }
     }
    
}
