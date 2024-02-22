////
////  CannedReply.swift
////  Hippo
////
////  Created by Neha Vaish on 19/02/24.
////
//
//import UIKit
//
//class CannedReply: Mappable {
//    var message: String?
//    var message_id: Int?
//    var sku: String?
//    var title: String?
//
//    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
//    required init?(map: Map) {}
//
//    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
//    func mapping(map: Map) {
//        message <- map["message"]
//        message_id <- map["message_id"]
//        sku <- map["sku"]
//        title <- map["title"]
//    }
//
//    //MARK: - HELPERS
//    class func getArrayfrom(jsonArray: [[String: Any]]) -> [CannedReply] {
//        var rawReplies: [CannedReply] = []
//
//        for json in jsonArray {
//            guard let reply = CannedReply(JSON: json), let message = reply.message, !message.isEmpty else {
//                continue
//            }
//            rawReplies.append(reply)
//        }
//        return rawReplies
//    }
//
//    class func getJsonToStore(replies: [CannedReply]) -> [[String: Any]] {
//        var rawJson: [[String: Any]] = []
//        for each in replies {
//            rawJson.append(each.toJSON())
//        }
//        return rawJson
//    }
//
//    //MARK: API
//    class func getCannedMessages(enableLoader: Bool, completion: @escaping ((_ savedReplies: [CannedReply]?) -> ())) {
//        guard let accessToken = PersonInfo.getAccessToken() else {
//            completion(nil)
//            return
//        }
//
//        let params: [String : Any] = ["access_token": accessToken]
//
//
//        HTTPRequest(method: .post, path: EndPoints.getCannedMessages, parameters: params)
//            .config(isIndicatorEnable: enableLoader, isAlertEnable: enableLoader, isNetworkAlertEnable: enableLoader)
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
//        }
//    }
//}
