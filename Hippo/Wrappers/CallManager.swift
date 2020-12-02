//
//  CallManager.swift
//  SDKDemo1
//
//  Created by Vishal on 14/11/18.
//

import Foundation


struct CallData {
    var peerData: User
    var callType: CallType
    var muid: String
    var signallingClient: HippoChannel
}

struct GroupCallData{
    var peerData: User
    var callType: CallType
    var muid: String
    var signallingClient : GroupCallChannel
    var isMuted : Bool
}

#if canImport(HippoCallClient)
import HippoCallClient
#endif


class CallManager {
    
    static let shared = CallManager()
    
//    func startCall(call: CallData, completion: @escaping (Bool) -> Void) {
//        #if canImport(HippoCallClient)
//        let peerUser = call.peerData
//        guard let peer = HippoUser(name: peerUser.fullName, userID: peerUser.userID, imageURL: peerUser.image) else {
//            return
//        }
//        guard let currentUser = getCurrentUser() else {
//            return
//        }
//
//        let callToMake = Call(peer: peer, signalingClient: call.signallingClient, uID: call.muid, currentUser: currentUser, type: getCallTypeWith(localType: call.callType))
//        HippoCallClient.shared.startCall(call: callToMake, completion: completion)
//        #else
//        completion(false)
//        #endif
//    }
    
    
    
    func startGroupCall(call: GroupCallData, groupCallChannelData : GroupCallChannelData, completion: @escaping (Bool, NSError?) -> Void){
        #if canImport(JitsiMeet)
        let peerUser = call.peerData
        guard let peer = HippoUser(name: peerUser.fullName, userID: peerUser.userID, imageURL: peerUser.image) else {
            return
        }
        guard let currentUser = getCurrentUser() else {
            return
        }
        let callToMake = Call(peer: peer, signalingClient: call.signallingClient, uID: call.muid, currentUser: currentUser, type: getCallTypeWith(localType: call.callType), link: "", isGroupCall: true, jitsiUrl: HippoConfig.shared.jitsiUrl ?? "")
        
        let groupCallData = CallClientGroupCallData(roomTitle: groupCallChannelData.roomTitle ?? "", roomUniqueId: groupCallChannelData.roomUniqueId ?? "", transactionId :groupCallChannelData.transactionId ?? "", userType: currentUserType() == .agent ? "agent" : "customer", isMuted : call.isMuted)
        
        HippoCallClient.shared.startGroupCall(call: callToMake, groupCallData: groupCallData)
        #else
        completion(false,nil)
        #endif
    }
    
    // use this method if you are using jitsi branch for calling feature

    func startCall(call: CallData, completion: @escaping (Bool, NSError?) -> Void) {
        #if canImport(HippoCallClient)
        let peerUser = call.peerData
        guard let peer = HippoUser(name: peerUser.fullName, userID: peerUser.userID, imageURL: peerUser.image) else {
            return
        }
        guard let currentUser = getCurrentUser() else {
            return
        }
        #if canImport(JitsiMeet)
        let callToMake = Call(peer: peer, signalingClient: call.signallingClient, uID: call.muid, currentUser: currentUser, type: getCallTypeWith(localType: call.callType), link: "", jitsiUrl: HippoConfig.shared.jitsiUrl ?? "")
        #else
        let callToMake = Call(peer: peer, signalingClient: call.signallingClient, uID: call.muid, currentUser: currentUser, type: getCallTypeWith(localType: call.callType), link: "")
         #endif
        HippoCallClient.shared.startCall(call: callToMake, completion: completion)
        #else
        completion(false,nil)
        #endif
    }


    func startWebRTCCall(call: CallData, completion: @escaping (Bool) -> Void) {
        #if canImport(HippoCallClient)
        let peerUser = call.peerData
        guard let peer = HippoUser(name: peerUser.fullName, userID: peerUser.userID, imageURL: peerUser.image) else {
            return
        }
        guard let currentUser = getCurrentUser() else {
            return
        }
        #if canImport(JitsiMeet)
        let callToMake = Call(peer: peer, signalingClient: call.signallingClient, uID: call.muid, currentUser: currentUser, type: getCallTypeWith(localType: call.callType), link: "", jitsiUrl: HippoConfig.shared.jitsiUrl ?? "")
         #else
         let callToMake = Call(peer: peer, signalingClient: call.signallingClient, uID: call.muid, currentUser: currentUser, type: getCallTypeWith(localType: call.callType), link: "")
        
         #endif
        HippoCallClient.shared.startWebRTCCall(call: callToMake, completion: completion)
        #else
        completion(false)
        #endif
    }
    
    func startConnection(peerUser: User, muid: String, callType: CallType, completion: (Bool) -> Void) {
        #if canImport(HippoCallClient)
        guard let peer = HippoUser(name: peerUser.fullName, userID: peerUser.userID, imageURL: peerUser.image) else {
            return
        }
        let type = getCallTypeWith(localType: callType)
        let request = PresentCallRequest.init(peer: peer, callType: type, callUUID: muid)
        HippoCallClient.shared.startConnecting(call: request, uuid: muid)
        #endif
    }
    
    func hungupCall() {
        #if canImport(JitsiMeet)
        HippoCallClient.shared.hangupCall()
        #endif
    }
    
    #if canImport(HippoCallClient)
    func getCallTypeWith(localType: CallType) -> Call.CallType {
        var type = Call.CallType.audio
        
        switch localType {
        case .audio:
            type = .audio
        case .video:
            type = .video
        }
        return type
    }
    #endif
    
    func isCallClientAvailable() -> Bool {
        #if canImport(HippoCallClient)
        return true
        #else
        return false
        #endif
    }
    
    func initCallClientIfPresent() {
        #if canImport(HippoCallClient)
        setCredentials()
        setCallClientDelegate()
        #endif
    }
    
    private func setCredentials() {
        #if canImport(HippoCallClient)
        HippoCallClient.shared.setCredentials(rawCredentials: testCredentials())
        #endif
    }
    func findActiveCallUUID() -> String? {
        #if canImport(HippoCallClient)
        return HippoCallClient.shared.activeCallUUID
        #else
        return nil
        #endif
    }
    private func setCallClientDelegate() {
        #if canImport(HippoCallClient)
        HippoCallClient.shared.registerHippoCallClient(delegate: self)
        #endif
    }
    
 
    func voipNotificationRecievedForGroupCall(payloadDict: [String: Any]){
        #if canImport(JitsiMeet)

        guard let peer = HippoUser(json: payloadDict) else {
            return
        }
        var channelId : Int?
        
        if let channelID = payloadDict["channel_id"] as? Int{
            channelId = channelID
        }else if let channelID = Int.parse(values: payloadDict, key: "channel_id"){
            channelId = channelID
        }
        guard let channel_id = channelId else {
            return
        }
        
        let groupCallChannel = GroupCallChannel(channel_id)
        guard let currentUser = getCurrentUser() else {
            return
        }
        HippoCallClient.shared.voipNotificationRecievedForGroupCall(dictionary: payloadDict, peer: peer, signalingClient: groupCallChannel, currentUser: currentUser)
        
        #else
        print("cannot import HippoCallClient")
        #endif
    }
    
    
    func voipNotificationRecieved(payloadDict: [String: Any]) {
        #if canImport(HippoCallClient)
        guard let peer = HippoUser(json: payloadDict), let channelID = Int.parse(values: payloadDict, key: "channel_id") else {
            return
        }
        let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
        
        if HippoConfig.shared.userDetail == nil {
            HippoConfig.shared.userDetail = HippoUserDetail()
        } else if HippoConfig.shared.agentDetail == nil {
            HippoConfig.shared.setAgentStoredData()
        }
        
        guard let currentUser = getCurrentUser() else {
            return
        }
        HippoCallClient.shared.voipNotificationRecieved(dictionary: payloadDict, peer: peer, signalingClient: channel, currentUser: currentUser)
        #else
        print("cannot import HippoCallClient")
        #endif
    }
    
    private func testCredentials() -> [String :Any] {
        let ice_servers: [String: Any] = [
            "stun": ["stun:turnserver.fuguchat.com:19305"],
            "turn":  [
                "turn:turnserver.fuguchat.com:19305?transport=UDP",
                "turn:turnserver.fuguchat.com:19305?transport=TCP",
                "turns:turnserver.fuguchat.com:5349?transport=UDP",
                "turns:turnserver.fuguchat.com:5349?transport=TCP"
            ]]
        let json: [String: Any] =  ["credential": "3FXCGBCnDfqsrOqs",
                                    "username": "fuguadmin",
                                    "ice_servers": ice_servers,
                                    "turn_api_key": "VPlwuCJcizZye2znMflmJ75x0IraJ5cQ"]
        return json
    }
    
    #if canImport(HippoCallClient)
    func getCurrentUser() -> HippoUser? {
        switch HippoConfig.shared.appUserType {
        case .customer:
            guard let user = HippoConfig.shared.userDetail else {
                return nil
            }
            let name = user.fullName ?? ""
            let userID = HippoUserDetail.fuguUserID ?? -1
            let userImage = user.userImage
            return HippoUser(name: name, userID: userID, imageURL: userImage?.absoluteString)
        case .agent:
            guard let agentDetail = HippoConfig.shared.agentDetail else {
                return nil
            }
            return HippoUser(name: agentDetail.fullName, userID: agentDetail.id, imageURL: agentDetail.userImage)
        }
    }
    #endif
}

#if canImport(HippoCallClient)
extension CallManager: HippoCallClientDelegate {
    func callStarted(isCallStarted: Bool) {
         HippoConfig.shared.jitsiOngoingCall = isCallStarted
    }
    
    func loadCallPresenterView(request: CallPresenterRequest) -> CallPresenter? {
        return HippoConfig.shared.notifyCallRequest(request)
    }
}
#endif
