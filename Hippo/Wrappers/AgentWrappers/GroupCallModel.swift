//
//  AgentGroupCallChat.swift
//  Hippo
//
//  Created by Arohi Sharma on 15/07/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

public struct GroupCallModel {
    //call type
    public var callType : CallType?
    
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

    //Message
    /// * Optional parameter
    public var message : String?
    
    public var isAudioMuted : Bool?
    
    //init for creating group session
    ///*init for these parameters for creating channel for group calling from parent app*
    public init?(email: String, roomTitle: String, sessionStartTime: String, sessionEndTime: String, uniqueIds : [String], transactionId : String, userIds : [String]?, agentIds : [String]?, message : String?){
        self.email = email
        self.roomTitle = roomTitle
        self.sessionStartTime = sessionStartTime
        self.sessionEndTime = sessionEndTime
        self.uniqueIds = uniqueIds
        self.message = message
        self.transactionId = transactionId
    }
    
    //init for getting session details
    ///*init these parameters for getting session details*
    ///resellerToken,referenceid and email are optional params
    
    
    public init?(email : String?, transactionId : String){
        self.email = email
        self.transactionId = transactionId
    }
}
extension GroupCallModel{
    
    //MARK:- Generate Params
    ///Returns paramets for creating channel for group calling
    func generateParamsForCreatingChannel() throws -> [String : Any]{
        var params = [String : Any]()
        
        guard HippoConfig.shared.appUserType == .agent else {
            HippoConfig.shared.log.trace("notAllowedForCustomer", level: .error)
            throw HippoError.notAllowedForAgent
        }
        
        params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        params["user_id"] = currentUserId()
        params["en_user_id"] = currentEnUserId()
        params["agent_email"] = email
        params["room_title"] = roomTitle
        params["session_end_time"] = sessionEndTime
        params["session_start_time"] = sessionStartTime
        params["user_unique_ids"] = uniqueIds
        params["transaction_id"] = transactionId
        params["message"] = message
        params["is_audio_enabled"] = isAudioMuted
        params["is_video_enabled"] = callType == .audio ? false : true
       
        return params
    }
    
    ///Returns params for getting details of group calling session
    
    func generateParamsForGettingChannel()-> [String : Any]{
        var params = [String : Any]()
        if currentUserType() == .agent{
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }else{
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }
        params["user_id"] = currentUserId()
        params["en_user_id"] = currentEnUserId()
        params["transaction_id"] = transactionId
        params["call_type"] = callType?.rawValue
        return params
    }
}
