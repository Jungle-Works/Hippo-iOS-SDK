//
//  CannedReply.swift
//  Hippo
//
//  Created by sreshta bhagat on 06/04/21.
//

import UIKit

class CannedReply {
    var message: String?
    var message_id: Int?
    var sku: String?
    var title: String?
    
    
    init(data : [String : Any]) {
        if let msg = data["message"] as? String{
            message = msg
        }
        if let msgId = data["message_id"] as? Int{
            message_id = msgId
        }
        if let msgSKU = data["sku"] as? String{
            sku = msgSKU
        }
        if let msgTitle = data["title"] as? String{
            title = msgTitle
        }
    }
    
    //var arrayCannedReply = [CannedReply]()
    var arrayCannedReply : (()->())?
    ////var CannedReply1 : (()->())?
 
    class func getArrayfrom(jsonArray: [[String: Any]]) -> [CannedReply] {
        var rawReplies: [CannedReply] = []
        
        for json in jsonArray {
        
            print(json)
            let reply = CannedReply.init(data: json)
            rawReplies.append(reply)
//            let reply = CannedReply.init()
//
//
//            guard let reply = CannedReply(JSON: json), let message = reply.message, !message.isEmpty else {
//                continue
//            }
//            rawReplies.append(reply)
        }
        return rawReplies
    }
    
    class func getJsonToStore(replies: [CannedReply]) -> [[String: Any]] {
        var rawJson: [[String: Any]] = []
        for each in replies {
            let jsn = CannedReply.toJson(each)
            rawJson.append(jsn)
        }
        return rawJson
    }
    
    class func toJson(_ reply : CannedReply) -> [String: Any] {
        var dict = [String: Any]()
        dict["message"] = reply.message
        dict["message_id"] = reply.message_id
        dict["sku"] = reply.sku
        dict["title"] = reply.title
        return dict
    }
    
    // MARK: API
    class func getCannedMessages(enableLoader: Bool, completion: @escaping ((_ savedReplies: [CannedReply]?) -> ())) {
        guard let accessToken = HippoConfig.shared.agentDetail?.fuguToken else {
            completion(nil)
            return
        }
        let params: [String : Any] = ["access_token": accessToken]
        //
        //    HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.getCannedMessages.rawValue) { (responseObject, error, tag, statusCode) in
        
        //        HTTPRequest(method: .post, path: AgentEndPoints.getCannedMessages, parameters: params)
        //            .config(isIndicatorEnable: enableLoader, isAlertEnable: enableLoader, isNetworkAlertEnable: enableLoader)
        //            .handler { (response) in
        
        
            
        let url = "api/business/getCannedMessages"
        
        print("url------->",url)
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: url) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    completion([])
                    return
            }
            if let data = responseDict["data"] as? [[String : Any]]{
                let savedReplies = CannedReply.getArrayfrom(jsonArray: data)
                Business.shared.savedReplies = savedReplies
             //   CacheManager.storeCannedReply(replies: savedReplies)
                completion(savedReplies)
            }else{
                completion([])
            }
        }
        
//        HTTPRequest(method: .post, fullURLStr: url, parameters: params, encoding: .json, files: nil)
//            .config(isIndicatorEnable: true, isAlertEnable: true)
//
//            .handler { (response) in
//                guard response.isSuccess, let value = response.value as? [String: Any], let data = value["data"] as? [[String: Any]] else {
//                    completion(nil)
//                    return
//                }
//
//                let savedReplies = CannedReply.getArrayfrom(jsonArray: data)
//                Business.shared.savedReplies = savedReplies
//                CacheManager.storeCannedReply(replies: savedReplies)
//                completion(savedReplies)
//            }
        
        
        
    }
}



