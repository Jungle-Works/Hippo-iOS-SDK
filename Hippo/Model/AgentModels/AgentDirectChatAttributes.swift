//
//  AgentDirectChatAttributes.swift
//  SDKDemo1
//
//  Created by Vishal on 27/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation



class AgentDirectChatAttributes: NSObject {
    
    private(set) var otherUserEmail = ""
    private(set) var otherUserUniqueKey: String = ""
    private(set) var channelName = HippoStrings.support
    private(set) var chatType: ChatType = .other
    private(set) var transactionID: String? = nil
    private(set) var customChannelName: String?
    
    
    
    init(otherUserUniqueKey: String, channelName: String?, transactionID: String? = nil) {
        self.otherUserUniqueKey = otherUserUniqueKey.trimWhiteSpacesAndNewLine()
        
        if let name = channelName?.trimWhiteSpacesAndNewLine() {
            self.channelName = name
            self.customChannelName = name
        }
        self.transactionID = transactionID
    }
    
    init?(otherUserEmail: String) {
        let email = otherUserEmail.trimWhiteSpacesAndNewLine()
        
        guard email.isValidEmail() else {
            HippoConfig.shared.log.debug(HippoError.invalidEmail.localizedDescription, level: .error)
            return nil
        }
        self.otherUserEmail = email
        self.chatType = .o2o
    }
    
    func getParamsToStartNewChat() -> [String: Any]? {
        guard let detail = HippoConfig.shared.agentDetail else {
            return nil
        }
        var param = [String: Any]()
        
        param["access_token"] = detail.fuguToken
        
        
        switch chatType {
        case .o2o:
            param["chat_with_email"] = otherUserEmail
        default:
            param["other_user_unique_key"] = [otherUserUniqueKey]
            param["initiator_en_agent_id"] = detail.enUserId
            param["chat_type"] = 0
        }
        if let transactionID = transactionID {
            param["transaction_id"] = transactionID
        }
        if let customChannelName = self.customChannelName {
            param["custom_label"] = customChannelName
        }
        return param
    }
}
