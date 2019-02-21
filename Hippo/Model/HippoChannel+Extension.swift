//
//  HippoChannel+Extension.swift
//  SDKDemo1
//
//  Created by Vishal on 14/11/18.
//

import Foundation

#if canImport(HippoCallClient)
 import HippoCallClient
#endif

#if canImport(HippoCallClient)
extension HippoChannel: SignalingClient {
    
    func connectClient(completion: @escaping (Bool) -> Void) {
        guard !isConnected() else {
            completion(true)
            return
        }
        
        guard !isSubscribed() else {
            completion(false)
            return
        }
        
        subscribeChannel { (success) in
            completion(success)
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
            "app_version": versionCode,
            "device_details": AgentDetail.getDeviceDetails()
        ]
        fayeDict["device_token"] = HippoConfig.shared.deviceToken
        
        if !HippoConfig.shared.voipToken.isEmpty {
            fayeDict["voip_token"] = HippoConfig.shared.voipToken
        }
        
        send(dict: fayeDict) { (success, error)  in
            completion(success, error)
        }
    }
    
}
#endif
