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
    
    enum SignalSocketAction: Equatable {
        case subscribeNow
        case waitForConnection
        case startConnection
    }

    static func signalSocketAction(isSocketConnected: Bool, isSocketConnecting: Bool) -> SignalSocketAction {
        if isSocketConnected { return .subscribeNow }
        return isSocketConnecting ? .waitForConnection : .startConnection
    }

    func connectClient(completion: @escaping (Bool) -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.connectClient(completion: completion) }
            return
        }
        guard !isConnected() else {
            os_log("[connectClient] already connected — delivering signal immediately", log: channelLog, type: .default)
            completion(true)
            return
        }

        // A stale subscription must not send on a dead socket, and a live socket that has
        // not joined this channel must not wait for a connect event that already happened.
        var didComplete = false
        var observer: NSObjectProtocol?

        let finish: (Bool) -> Void = { success in
            guard !didComplete else { return }
            didComplete = true
            if let obs = observer {
                NotificationCenter.default.removeObserver(obs)
                observer = nil
            }
            os_log("[connectClient] delivering queued signal (success=%{public}@)", log: channelLog, type: .default, "\(success)")
            completion(success)
        }

        let channelID = id.description
        let subscribeThenFinish = {
            SocketClient.shared.subscribeSocketChannel(channel: channelID) { (_, success) in
                DispatchQueue.main.async { finish(success) }
            }
        }

        let status = SocketClient.shared.socket?.status
        let action = HippoChannel.signalSocketAction(isSocketConnected: status == .connected, isSocketConnecting: status == .connecting)
        os_log("[connectClient] socket status=%{public}@", log: channelLog, type: .default, "\(String(describing: status))")
        if action == .subscribeNow {
            subscribeThenFinish()
        } else {
            observer = NotificationCenter.default.addObserver(forName: .socketConnected, object: nil, queue: .main) { _ in
                subscribeThenFinish()
            }
            if action == .startConnection {
                SocketClient.shared.connect()
            }
        }

        // Never lose the signal completion if the socket cannot be reached.
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if !didComplete {
                os_log("[connectClient] TIMEOUT — sending without confirmed subscription", log: channelLog, type: .error)
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
            print(success)
            print(error)
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
