//
//  HippoChannel+Extension.swift
//  SDKDemo1
//
//  Created by Vishal on 14/11/18.
//

import UIKit

public enum GroupCallStatus{
    case missed
    case rejected
    case sessionStarted
    case sessionEnded
}



#if canImport(HippoCallClient)
 import HippoCallClient
#endif

#if canImport(HippoCallClient)
extension HippoChannel: SignalingClient {
    
    func sendSessionStatus(status: String) {
       
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
                "app_version": versionCode,
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
    //            if success {
    //                completion(true,nil)
    //            }else{
    //                let responseData = response.data
    //                guard let statusCode = responseData["statusCode"] as? Int else{
    //                    completion(false,response.error as NSError?)
    //                    return
    //                }
    //                if statusCode == 415 {
    //                    completion(false, NSError.init(domain: responseData["type"] as? String ?? "FuguSocketResponse", code: 415, userInfo: responseData))
    //                }
    //            }
            }
        }
    
}
#endif
