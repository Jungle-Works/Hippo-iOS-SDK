//
//  HippoCallClient.swift
//  HippoCallClient
//
//  Created by Vishal on 14/11/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import Foundation


public class HippoCallClient {
   public static let shared = HippoCallClient()
   private(set) var delgate: HippoCallClientDelegate?
   
    
    /// This variable will send ongoing call uuid if any
    public var activeCallUUID: String? {
        return CallClient.shared.activeCall?.uID
    }
   
    /// set the delegate to communicate with callClient
    ///
    /// - Parameter delegate: Class that inherted protocol HippoCallClientDelegate
    public func registerHippoCallClient(delegate: HippoCallClientDelegate) {
        self.delgate = delegate
    }
    
    
    /// This function is public and called when ever you recieve a voip Notification
    ///
    /// - Parameters:
    ///   - dictionary: voip Payload
    ///   - peer: Information of caller who had called you
    ///   - signalingClient: Class that satisfy SignalingClient Protocol, and this class is used for your signaling
    ///   - currentUser: Information of current user in your app
    public func voipNotificationRecieved(dictionary: [AnyHashable: Any], peer: CallPeer, signalingClient: SignalingClient, currentUser: CallPeer) {
        CallClient.shared.voipNotificationReceived(dictionary: dictionary, peer: peer, signalingClient: signalingClient, currentUser: currentUser)
    }
    /// This is function is called to hangup current ongoing call if any
    public func hangupCall() {
        CallClient.shared.hangupCall()
    }
    
    /// This function is used to start call
    ///
    /// - Parameters:
    ///   - call: Call object that contain information about call
    ///   - completion: Callback that provide status whether the call is made or not
    public func startCall(call: Call, completion: @escaping (Bool) -> Void) {
        CallClient.shared.startNew(call: call, completion: completion)
    }
    
    
    /// This function is add on just to show Connecting status no actual call is made here
    ///
    /// - Parameters:
    ///   - call: Request param
    ///   - uuid: Call UUID
    public func startConnecting(call: PresentCallRequest, uuid: String) {
        CallClient.shared.startConnecting(call: call, uuid: uuid)
    }
    
    /// This function is requried to be full filled as it will set credentials for turn and stun server.
    ///
    /// let ice_servers: [String: Any] = [
    /// "stun": ["stun:turnserver.example.com:<PORT>"],
    /// "turn":  [
    ///     "turn:turnserver.example.com:<PORT>?transport=UDP",
    ///     "turn:turnserver.example.com:<PORT>?transport=TCP",
    ///     "turns:turnserver.example.com:<PORT>?transport=UDP",
    ///     "turns:turnserver.example.com:<PORT>?transport=TCP"
    ///  ]]
    /// let json: [String: Any] =  ["credential": "<Credential>",
    ///                            "username": "<User_name>",
    ///                            "ice_servers": ice_servers,
    ///                            "turn_api_key": <turn server api key>]
    ///
    /// - Parameter rawCredentials: raw data of stun and turn server.
    public func setCredentials(rawCredentials: [String: Any]) {
        CallClient.shared.setCredentials(rawCredentials: rawCredentials)
    }
    
}
