//
//  GroupCall.swift
//  Hippo
//
//  Created by Arohi Sharma on 15/07/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

class GroupCall{
    
    //MARK:- API Call for create group calling session from Agent SDK
    ///Call this api for creating new channel for group calling
    ///*This method should be called from agent sdk*
    
    class func createGroupCallChannel(request: AgentGroupCallModel, callback: @escaping HippoResponseRecieved) {
        let params: [String: Any]
        
        do {
            params = try request.generateParamsForCreatingChannel()
        } catch {
            callback(error as? HippoError, nil)
            return
        }
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.createGroupCallChannel.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                //                HippoConfig.shared.log.error(error ?? "Something went Wrong!!", level: .error)
                callback(HippoError.general, nil)
                print("Error",error ?? "")
                return
            }
            
            callback(nil, responseObject as? [String : Any])
        }
    }
 
}
extension GroupCall{
    
    //MARK:- API Call for getting details of group calling session created by agent
    ///*Returns the channel data to parent app*
    
    class func getGroupCallChannelDetails(request: AgentGroupCallModel, callback: @escaping HippoResponseRecieved) {
        let params: [String: Any]
        
        params = request.generateParamsForGettingChannel()
      
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.getGroupCallChannelDetals.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                callback(HippoError.general, nil)
                print("Error",error ?? "")
                return
            }
            let groupCall = GroupCallChannelData().getGroupCallChannelData((responseObject as? [String : Any])?["data"] as? [String : Any] ?? [String : Any]())
            
            let user = User(name: currentUserName(), imageURL: currentUserImage(), userId: currentUserId())
            
            let groupCallChannel = GroupCallChannel(groupCall.channelId ?? -1)
            let groupCallData = GroupCallData.init(peerData: user, callType: .audio, muid: String.uuid(), signallingClient: groupCallChannel)
            CallManager.shared.startGroupCall(call: groupCallData, groupCallChannelData: groupCall) { (status, error) in
                
            }
            
            callback(nil, responseObject as? [String : Any])
        }
    }
}
