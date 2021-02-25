//
//  O2OChat.swift
//  Hippo
//
//  Created by Arohi Sharma on 15/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

class O2OChat{

    class func createO2OChat(request : O2OChatModel, callback: @escaping HippoResponseRecieved){
        
        let params: [String: Any]
        
        do {
            params = try request.generateParamO2OSupportChat()
        } catch {
            callback(error as? HippoError, nil)
            return
        }
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.createAgentConversation.rawValue) { (responseObject, error, tag, statusCode) in
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                callback(HippoError.general, nil)
                print("Error",error ?? "")
                return
            }
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            
            if let response = responseObject as? [String : Any], let data = response["data"] as? [String : Any], let channelId = data["channel_id"] as? Int{
                FuguFlowManager.shared.pushAgentConversationViewController(channelId: channelId, channelName: "", channelType: .SUPPORT_CHAT_CHANNEL)
            }
        }
    }

}

public struct O2OChatModel{
    public var transactionId : String?
    public var initiatedByAgent : Bool?
    public var otherUserEmail : String?
    public var groupingTag = [String]()
    public var singleChannelByTransactionId : Int?
    
    public init(){
        
    }
    
    public init(transactionId : String?, initiatedByAgent : Bool?, otherUserEmail : String, groupingTag : [String], singleChannelByTransactionId : Int?){
        self.transactionId = transactionId
        self.initiatedByAgent = initiatedByAgent
        self.otherUserEmail = otherUserEmail
        self.groupingTag = groupingTag
        self.singleChannelByTransactionId = singleChannelByTransactionId
    }
    
    func generateParamO2OSupportChat() throws -> [String: Any] {
        var json: [String: Any] = [:]
       
        guard HippoConfig.shared.appUserType == .agent else {
            HippoConfig.shared.log.trace("notAllowedForCustomer", level: .error)
            throw HippoError.notAllowedForAgent
        }
    
        json["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        if initiatedByAgent ?? false{
           json["initiated_by_agent"] = initiatedByAgent
           json["other_user_email"] = otherUserEmail
        }
        
        json["transaction_id"] = transactionId
        json["grouping_tags"] = groupingTag
        json["single_channel_by_transaction_id"] = singleChannelByTransactionId
        
        return json
    }
}

