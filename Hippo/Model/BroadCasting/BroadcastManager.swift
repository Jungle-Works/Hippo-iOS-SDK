//
//  BroadcastManager.swift
//  Hippo
//
//  Created by Vishal on 20/02/19.
//

import Foundation

class BroadcastManager {
    
    struct Request {
        var pageOffset: Int
        var channelId: UInt = 0
        var showLoader: Bool = false
        
        init(offset: Int, channelID: UInt? = nil) {
            pageOffset = offset
            channelId = channelID ?? 0
        }
        
        func generateParamForGetBroadcast() -> [String: Any] {
            var json: [String: Any] = [:]
            
            json["page_offset"] = pageOffset
            json["access_token"] = HippoConfig.shared.agentDetail?.fuguToken ?? ""
            
            return json
        }
        func generateParamForBroadcastDetail() -> [String: Any] {
            var json: [String: Any] = generateParamForGetBroadcast()
            
            json["channel_id"] = channelId
            
            return json
        }
    }
    
    struct BroadcastResponse {
        var channels: [BroadcastInfo]?
        var sccuess: Bool = true
        var canLoadMoreData: Bool = false
        var users: [CustomerInfo]?
        
        static func errorObject() -> BroadcastResponse {
            return BroadcastResponse(channels: nil, sccuess: false, canLoadMoreData: false, users: nil)
        }
    }
    func getBroadcastsFor(request: Request, completion: @escaping ((BroadcastResponse) -> ())) {
        let param = request.generateParamForGetBroadcast()
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: param, extendedUrl: AgentEndPoints.getBroadcastList.rawValue) { (response, error, _, statusCode) in
//            guard let responseDict = response as? [String: Any], let data = responseDict["data"] as? [String: Any], let broadcast_info = data["broadcasted_channels"] as? [[String :Any]] else {
//                completion(false, nil)
//                return
//            }
//            let list =
//            completion(true, list)
            
            guard let parsedResponse = response as? [String: Any] else {
                completion(BroadcastResponse.errorObject())
                return
            }
            guard let data = parsedResponse["data"] as? [String: Any] else {
                completion(BroadcastResponse.errorObject())
                return
            }
            let channelsList = data["broadcasted_channels"] as? [[String: Any]] ?? []
            let size = Int.parse(values: data, key: "page_size") ?? 0
            
            let channels = BroadcastInfo.parse(list: channelsList)
            
            let canLoadMoreData: Bool = channels.count - size >= 0
            let result = BroadcastResponse(channels: channels, sccuess: true, canLoadMoreData: canLoadMoreData, users: nil)
            completion(result)
        }
    }
    
    func getBroadcastStatus(request: Request, completion: @escaping ((BroadcastResponse) -> ())) {
        let param = request.generateParamForBroadcastDetail()
        
        HTTPClient.makeConcurrentConnectionWith(method: .GET, enCodingType: .url, para: param, extendedUrl: AgentEndPoints.broadcastStatus.rawValue) { (response, error, _, statusCode) in
            guard let parsedResponse = response as? [String: Any] else {
                completion(BroadcastResponse.errorObject())
                return
            }
            guard let data = parsedResponse["data"] as? [String: Any] else {
                completion(BroadcastResponse.errorObject())
                return
            }
            let usersList = data["users"] as? [[String: Any]] ?? []
            let size = Int.parse(values: data, key: "page_size") ?? 0
            
            let users = CustomerInfo.parse(list: usersList)
            
            let canLoadMoreData: Bool = usersList.count - size >= 0
            let result = BroadcastResponse(channels: nil, sccuess: true, canLoadMoreData: canLoadMoreData, users: users)
            completion(result)
        }
    }
}

