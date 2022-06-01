//
//  GroupCallChannel.swift
//  Hippo
//
//  Created by Arohi Sharma on 15/07/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation
#if canImport(HippoCallClient)
 import HippoCallClient
#endif

struct GroupCallChannelData {
    
    //MARK:- Variables
    
    var roomTitle : String?
    var roomUniqueId : String?
    var sessionStartTime : String?
    var sessionEndTime : String?
    var channelId : Int?
    var status : Bool?
    var callType : CallType?
    var transactionId : String?
    var isAudioMuted : Bool?
   
    //
    
    func getGroupCallChannelData(_ dic : [String : Any]) -> GroupCallChannelData{
        var this = GroupCallChannelData()
        if let data = dic["channel_data"] as? [String : Any]{
            this.roomTitle = data["room_title"] as? String
            this.roomUniqueId = data["room_unique_id"] as? String
            this.sessionStartTime = data["session_start_time"] as? String
            this.sessionEndTime = data["session_start_time"] as? String
            if let isVideoEnabled = data["is_video_enabled"] as? String{
                this.callType = isVideoEnabled == "1" ? .video : .audio
            }else if let isVideoEnabled = data["is_video_enabled"] as? Int{
                this.callType = isVideoEnabled == 1 ? .video : .audio
            }else if let isVideoEnabled = data["is_video_enabled"] as? Bool{
                this.callType = isVideoEnabled ? .video : .audio
            }
            

            if let isAudioEnabled = data["is_audio_enabled"] as? String{
                this.isAudioMuted = isAudioEnabled == "1" ? false : true
            }else if let isAudioEnabled = data["is_audio_enabled"] as? Int{
                this.isAudioMuted = isAudioEnabled == 1 ? false : true
            }else if let isAudioEnabled = data["is_audio_enabled"] as? Bool{
                this.isAudioMuted = isAudioEnabled ? false : true
            }
        }
        this.channelId = dic["channel_id"] as? Int
        return this
    }
    
}

class GroupCallChannel{
    
    //MARK:- Variables
    var channelId : Int?
    var userChannelId : String?{
        get{
            return HippoUserDetail.HippoUserChannelId
        }
        set{}
    }
    var signalReceivedFromPeer: (([String : Any]) -> Void)?
    var dict : [String : Any]?
    
    //MARK:- Initialisation
    init(_ id : Int) {
        self.channelId = id
    }
    
    deinit {
        SocketClient.shared.unsubscribeSocketChannel(fromChannelId: channelId?.description ?? "")
    }
}

#if canImport(HippoCallClient)
extension GroupCallChannel: SignalingClient {
    func sendSessionStatus(status: String, transactionId: String) {
        if status == "MISSED_GROUP_CALL"{
            HippoConfig.shared.HippoSessionStatus?(.missed)
        }else if status == "JOIN_GROUP_CALL"{
            HippoConfig.shared.HippoSessionStatus?(.sessionStarted)
        }else if status == "REJECT_GROUP_CALL"{
            HippoConfig.shared.HippoSessionStatus?(.rejected)
        }else if status == "END_GROUP_CALL"{
            HippoConfig.shared.HippoSessionStatus?(.sessionEnded)
        }else if status == "START_GROUP_CALL"{
           HippoConfig.shared.HippoSessionStatus?(.agentSessionStarted)
        }
    }
    
    func connectClient(completion: @escaping (Bool) -> Void) {
        guard isConnected() else {
            completion(false)
            return
        }
        
        guard !isSubscribed() else {
            completion(true)
            return
        }
      
        if currentUserType() == .customer{
            subscribeCustomerUserChannel(userChannelId: userChannelId ?? "")
        }
        
        subscribeChannel { (error,success)  in
            completion(success)
        }
    }
    
    
    private func isConnected() -> Bool {

        return SocketClient.shared.isConnected() && FuguNetworkHandler.shared.isNetworkConnected

    }
    
    private func isSubscribed() -> Bool {
        guard let channelId = channelId else{
            return false
        }
        return SocketClient.shared.isChannelSubscribed(channel: "\(channelId)")
    }
       
    private func subscribeChannel(completion: @escaping (Error?,Bool) -> Void){
        guard let channelId = channelId else{
            completion(HippoError.ChannelIdNotFound,false)
            return
        }
        SocketClient.shared.subscribeSocketChannel(channel: "\(channelId)"){(error,success) in
            completion(error,success)
        }
    }
    
    func checkIfReadyForCommunication() -> Bool {
        return SocketClient.shared.isConnected() && FuguNetworkHandler.shared.isNetworkConnected
    }
    
    func sendSignalToPeer(signal: CallSignal, completion: @escaping (Bool, NSError?) -> Void) {
        
    }
    
    func sendJitsiObject(json: [String : Any], completion: @escaping (Bool, NSError?) -> Void) {
        var fayeDict = json
        
        fayeDict["message_type"] = MessageType.groupCall.rawValue
        fayeDict["user_type"] = currentUserType().rawValue
        fayeDict["device_payload"] = [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? 0,
            "device_type": Device_Type_iOS,
            "app_version": fuguAppVersion,
            "device_details": AgentDetail.getDeviceDetails()
        ]
  
        send(dict: fayeDict) { (success, error)  in
            completion(success,error)
            print(success)
            print(error)
            
        }
    }
    
    func send(dict: [String: Any], completion: @escaping  (Bool, NSError?) -> Void) {
        var json = dict
        guard let channelId = channelId else{
            completion(false,HippoError.ChannelIdNotFound as NSError)
            return
        }
        
        json["channel_id"] = "\(channelId)"
        
        if currentUserType() == .agent{
            
            SocketClient.shared.send(messageDict: json, toChannelID: "\(channelId)") { (result) in
                completion(result.isSuccess,result.error as NSError?)
            }
        }else{
            if json["video_call_type"] as? String != "START_GROUP_CALL"{
                SocketClient.shared.send(messageDict: json, toChannelID: "\(channelId)") { (result) in
                    
                }
                sendOnUserChannel(json, completion: completion)
            }
        }
    }
    
    func sendOnUserChannel(_ json : [String: Any],completion: @escaping  (Bool, NSError?) -> Void){
        var json = json
        json["server_push"] = true
        SocketClient.shared.send(messageDict: json, toChannelID: userChannelId ?? "") { (result) in
            completion(result.isSuccess,result.error as NSError?)
        }
    }
  
}
#endif
