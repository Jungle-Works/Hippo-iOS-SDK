//
//  HippoChannel+Extension.swift
//  SDKDemo1
//
//  Created by Vishal on 14/11/18.
//

import UIKit
import os.log

private let channelLog = OSLog(subsystem: "com.hippo.sdk", category: "Socket")

public enum GroupCallStatus{
    case missed
    case rejected
    case sessionStarted
    case sessionEnded
    case agentSessionStarted
}



#if canImport(HippoCallClient)
 import HippoCallClient
#endif

#if canImport(HippoCallClient)
extension HippoChannel: SignalingClient {
    func sendSessionStatus(status: String, transactionId: String) {
        
    }
    
    func connectClient(completion: @escaping (Bool) -> Void) {
        guard !isConnected() else {
            completion(true)
            return
        }

        guard !isSubscribed() else {
            completion(false)
            return
        }

        // Socket not yet connected — observe socketConnected, then subscribe the channel.
        // subscribe(completion:) silently drops its completion argument, so we can't rely
        // on subscribeChannel to call back. Instead: connect → wait for the notification →
        // subscribe with ACK → call completion.
        var didComplete = false
        var observer: NSObjectProtocol?

        let finish: (Bool) -> Void = { success in
            guard !didComplete else { return }
            didComplete = true
            if let obs = observer {
                NotificationCenter.default.removeObserver(obs)
                observer = nil
            }
            os_log("[connectClient] socket ready, delivering queued signal (success=%{public}@)", log: channelLog, type: .default, "\(success)")
            completion(success)
        }

        observer = NotificationCenter.default.addObserver(
            forName: .socketConnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { finish(false); return }
            SocketClient.shared.subscribeSocketChannel(channel: self.id.description) { (_, success) in
                finish(success)
            }
        }

        // Kick off connection — if socket is already connecting this is a no-op effectively
        SocketClient.shared.connect()

        // 15-second timeout so completion is never permanently lost
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if !didComplete {
                os_log("[connectClient] TIMEOUT — socket never connected, signal dropped", log: channelLog, type: .error)
            }
            finish(false)
        }
    }
    
    
    func checkIfReadyForCommunication() -> Bool {
        return isConnected()
    }
    
    func sendSignalToPeer(signal: CallSignal, completion: @escaping (Bool, NSError?) -> Void) {
        var fayeDict = signal.getJsonToSend()
        
        fayeDict["message_type"] = MessageType.call.rawValue
        fayeDict["user_type"] = currentUserType().rawValue
        fayeDict["device_payload"] = [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? 0,
            "device_type": Device_Type_iOS,
            "app_version": fuguAppVersion,
            "device_details": AgentDetail.getDeviceDetails()
        ]
        fayeDict["device_token"] = TokenManager.deviceToken
        
        if !TokenManager.voipToken.isEmpty {
            fayeDict["voip_token"] = TokenManager.voipToken
        }
        
        send(dict: fayeDict) { (success, error)  in
            completion(success, error)
        }
    }
    
    func sendJitsiObject(json: [String : Any], completion: @escaping (Bool, NSError?) -> Void) {
        var fayeDict = json
        
        fayeDict["message_type"] = MessageType.call.rawValue
        fayeDict["user_type"] = currentUserType().rawValue
        fayeDict["device_payload"] = [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? 0,
            "device_type": Device_Type_iOS,
            "app_version": fuguAppVersion,
            "device_details": AgentDetail.getDeviceDetails()
        ]
        fayeDict["device_token"] = HippoConfig.shared.deviceToken
        
        if !HippoConfig.shared.voipToken.isEmpty {
            fayeDict["voip_token"] = HippoConfig.shared.voipToken
        }
        
        send(dict: fayeDict) { (success, error)  in
            completion(success, error)
        }
        
        if json["video_call_type"] as? String == "USER_BUSY_CONFERENCE"{
            sendOnUserChannel(json, completion: completion)
        }
    }
    
    
    func sendOnUserChannel(_ json : [String: Any],completion: @escaping  (Bool, NSError?) -> Void){
        var json = json
        
        json["server_push"] = true
        
        let userChannelId = currentUserType() == .agent ? HippoConfig.shared.agentDetail?.userChannel : HippoUserDetail.HippoUserChannelId
        
        SocketClient.shared.send(messageDict: json, toChannelID: userChannelId ?? "") { (result) in
            completion(result.isSuccess,result.error as NSError?)
        }
    }
}
#endif
