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
    
   
    //
    
    func getGroupCallChannelData(_ dic : [String : Any]) -> GroupCallChannelData{
        var this = GroupCallChannelData()
        if let data = dic["channel_data"] as? [String : Any]{
            this.roomTitle = data["room_title"] as? String
            this.roomUniqueId = data["room_unique_id"] as? String
            this.sessionStartTime = data["session_start_time"] as? String
            this.sessionEndTime = data["session_start_time"] as? String
        }
        this.channelId = dic["channel_id"] as? Int
        return this
    }
    
}

class GroupCallChannel{
    
    //MARK:- Variables
    var channelId : Int?
    var signalReceivedFromPeer: (([String : Any]) -> Void)?
    
    //MARK:- Initialisation
    init(_ id : Int) {
        self.channelId = id
    }
}

#if canImport(HippoCallClient)
extension GroupCallChannel: SignalingClient {
    
    
    func connectClient(completion: @escaping (Bool) -> Void) {
        
    }
    
    func checkIfReadyForCommunication() -> Bool {
        return FayeConnection.shared.isConnected && FuguNetworkHandler.shared.isNetworkConnected
    }
    
    func sendSignalToPeer(signal: CallSignal, completion: @escaping (Bool, NSError?) -> Void) {
        
    }
    
    func sendJitsiObject(json: [String : Any], completion: @escaping (Bool, NSError?) -> Void) {
        
    }
    
}
#endif
