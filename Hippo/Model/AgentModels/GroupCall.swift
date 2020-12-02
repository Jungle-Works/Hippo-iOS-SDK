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
    
    class func createGroupCallChannel(request: GroupCallModel, callback: @escaping HippoResponseRecieved) {
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
    
    class func getGroupCallChannelDetails(request: GroupCallModel, callback: @escaping HippoResponseRecieved) {
        
        if let dict = ((HippoConfig.shared.groupCallData as NSDictionary).value(forKey: request.transactionId ?? "") as? [String : Any]){
            self.handleResponse(dict, dict["muid"] as? String ?? "", request.transactionId ?? "")
            return
        }
        
        let params: [String: Any]
        
        params = request.generateParamsForGettingChannel()
      
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.getGroupCallChannelDetals.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                callback(HippoError.general, nil)
                print("Error",error ?? "")
                return
            }
           
            guard var response = responseObject as? [String : Any] else{
                callback(HippoError.general, nil)
                return
            }
            
            if currentUserType() == .agent{
                var responseDict = HippoConfig.shared.groupCallData
                response["muid"] = String.uuid()
                responseDict[request.transactionId ?? ""] = response
                HippoConfig.shared.groupCallData = responseDict
            }
            
            self.handleResponse(response, response["muid"] as? String ?? "", request.transactionId ?? "")
            
            callback(nil, responseObject as? [String : Any])
        }
    }
    
    
    private class func handleResponse(_ responseObject : [String : Any], _ muid : String, _ tranactionId : String){
        var groupCall = GroupCallChannelData().getGroupCallChannelData(responseObject["data"] as? [String : Any] ?? [String : Any]())
        groupCall.transactionId = tranactionId
        let user = User(name: currentUserName(), imageURL: currentUserImage(), userId: currentUserId())
        
        let groupCallChannel = GroupCallChannel(groupCall.channelId ?? -1)
        
        
        let groupCallData = GroupCallData.init(peerData: user, callType: groupCall.callType ?? .audio, muid: muid, signallingClient: groupCallChannel, isMuted: groupCall.isAudioMuted ?? false)
         #if canImport(JitsiMeet)
            CallManager.shared.startGroupCall(call: groupCallData, groupCallChannelData: groupCall) { (status, error) in
            }
         #endif
        
    }
    
}
