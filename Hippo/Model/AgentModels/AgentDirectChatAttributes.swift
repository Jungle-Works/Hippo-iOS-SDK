//
//  AgentDirectChatAttributes.swift
//  SDKDemo1
//
//  Created by Vishal on 27/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation



class AgentDirectChatAttributes: NSObject {
    
    var otherUserUniqueKey: String = ""
    var channelName = "Support"
    
    
    init(otherUserUniqueKey: String) {
        self.otherUserUniqueKey = otherUserUniqueKey.trimWhiteSpacesAndNewLine()
    }
    
    
    func getParamsToStartNewChat() -> [String: Any]? {
        guard let detail = HippoConfig.shared.agentDetail else {
            return nil
        }
        var param = [String: Any]()
        param["other_user_unique_key"] = [otherUserUniqueKey]
        param["initiator_en_agent_id"] = detail.enUserId
        param["access_token"] = detail.fuguToken
        param["chat_type"] = 0
        
        return param
    }
}
