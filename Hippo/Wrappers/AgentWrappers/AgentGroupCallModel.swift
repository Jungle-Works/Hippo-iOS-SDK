//
//  AgentGroupCallChat.swift
//  Hippo
//
//  Created by Arohi Sharma on 15/07/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

public struct AgentGroupCallModel {
    
    // reseller token from parent app
    public var resellerToken: String?
    
    // reference id from parent app
    public var referenceId: String?
    
    // agent email id
    public var email: String?
    
    // Set Group call room title
    public var roomTitle: String?
    
    // session start time
    public var sessionStartTime: String?
    
    // session end time
    public var sessionEndTime: String?
    
    // customer unique ids which should be present to attend session
    public var uniqueIds : [String]?
    
    // transaction id
    public var transactionId : String?
    
    //Multiple customer ids
    /// * Optional parameter
    public var userIds : [String]?
    
    //Multiple agent ids
    /// * Optional parameter
    public var agentIds : [String]?

    //Message
    /// * Optional parameter
    public var message : String?
    
    
    public init?(resellerToken: String, referenceId: String, email: String, roomTitle: String, sessionStartTime: String, sessionEndTime: String, uniqueIds : [String], transactionId : String, userIds : [String]?, agentIds : [String]?, message : String?){
        self.resellerToken = resellerToken
        self.referenceId = referenceId
        self.email = email
        self.roomTitle = roomTitle
        self.sessionStartTime = sessionStartTime
        self.sessionEndTime = sessionEndTime
        self.uniqueIds = uniqueIds
        self.userIds = userIds
        self.agentIds = agentIds
        self.message = message
        self.transactionId = transactionId
    }
}
extension AgentGroupCallModel{
    
    //MARK:- Generate Params
    
    func generateParamsForCreatingChannel() throws -> [String : Any]{
        var params = [String : Any]()
        
        guard HippoConfig.shared.appUserType == .agent else {
            HippoConfig.shared.log.trace("notAllowedForCustomer", level: .error)
            throw HippoError.notAllowedForAgent
        }
        params["app_secret_key"] = HippoConfig.shared.agentDetail?.appSecrectKey
        params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        params["user_id"] = currentUserId()
        params["en_user_id"] = currentEnUserId()
        params["user_ids"] = userIds
        params["agent_ids"] = agentIds
        params["reseller_token"] = resellerToken
        params["reference_id"] = referenceId
        params["agent_email"] = email
        params["room_title"] = roomTitle
        params["session_end_time"] = sessionEndTime
        params["session_start_time"] = sessionStartTime
        params["user_unique_ids"] = uniqueIds
        params["transaction_id"] = transactionId
        params["message"] = message
       
        return params
    }
    
}
