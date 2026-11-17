////
////  CannedReply.swift
////  Hippo
////
////  Created by Neha Vaish on 19/02/24.
////
//
import UIKit

public class CannedReply: NSObject {
    var message: String?
    var message_id: Int?
    var sku: String?
    var title: String?

    init?(dict: [String: Any])    {
        self.message_id = Int.parse(values: dict, key: "message_id") ?? 1
        self.title = (dict["title"] as? String) ?? ""
        self.sku = (dict["sku"] as? String ?? "")
        self.message = dict["message"] as? String ?? ""
    }


    func toJson() -> [String: Any] {
        var dict = [String: Any]()
        dict["message_id"] = message_id
        dict["title"] = title
        dict["sku"] = sku
        dict["message"] = message
        return dict
    }


    //MARK: - HELPERS
    class func getArrayfrom(jsonArray: [[String: Any]]) -> [CannedReply] {
        var rawReplies: [CannedReply] = []

        for json in jsonArray {
            guard let reply = CannedReply(dict: json), let message = reply.message, !message.isEmpty else {
                continue
            }
            rawReplies.append(reply)
        }
        return rawReplies
    }

    class  func getJsonToStore(replies: [CannedReply]) -> [[String: Any]] {
        var rawJson: [[String: Any]] = []
        for each in replies {
//            rawJson.append(each)
        }
        return rawJson
    }

    //MARK: API
    class  public func getCannedMessages(completion: @escaping ((_ savedReplies: [CannedReply]?) -> ())) {

        var params = [String : Any]()
//        var savedReplies:  [CannedReply] = []
        params = ["access_token" : HippoConfig.shared.agentDetail?.fuguToken ?? ""] as [String : Any]

        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getCannedMessages.rawValue) { (response, error, _, statusCode) in
            if let response = response as? [String : Any], let data = response["data"] as? [[String : Any]]{
                print(data)
                
                let savedReplies = CannedReply.getArrayfrom(jsonArray: data)
                Business.shared.savedReplies = savedReplies
                Business.shared.savedReplies = savedReplies
                CacheManager.storeCannedReply(replies: savedReplies)
                
                completion(savedReplies)
                
                
            }
        }
    }
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


}
