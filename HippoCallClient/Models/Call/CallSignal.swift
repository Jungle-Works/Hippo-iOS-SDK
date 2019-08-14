//
//  VideoSignal.swift
//  HippoCallClient
//
//  Created by Asim on 09/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation

#if canImport(WebRTC)
import WebRTC
#endif

public protocol Publishable {
    func getJsonToSend() -> [String: Any]
}

public struct CallSignal {
    // MARK: - Properties
    let rtcSignal: [String: Any]
    let signalType: SignalType
    let callUID: String
    let sender: CallPeer
    let senderDeviceID: String
    let callType: Call.CallType
    var isForceSilent: Bool = false
    var customData: CustomData?
    
    init(rtcSignal: [String: Any], signalType: SignalType, callUID: String, sender: CallPeer, senderDeviceID: String, callType: Call.CallType) {
        self.rtcSignal = rtcSignal
        self.signalType = signalType
        self.callUID = callUID
        self.sender = sender
        self.senderDeviceID = senderDeviceID
        self.callType = callType
    }
}

public extension CallSignal {
    enum SignalType: String {
        case startCall = "START_CALL"
        case readyToConnect = "READY_TO_CONNECT"
        case callHungUp = "CALL_HUNG_UP"
        case userBusy = "USER_BUSY"
        case offer = "VIDEO_OFFER"
        case newIceCandidate = "NEW_ICE_CANDIDATE"
        case answer = "VIDEO_ANSWER"
        case callRejected = "CALL_REJECTED"
        case custom = "CUSTOM_DATA"
    }
}



// MARK: - Type Methods
public extension CallSignal {
    static func getFrom(json: [String: Any]) -> CallSignal? {
        guard let rawSignalType = json["video_call_type"] as? String, let signalType = SignalType(rawValue: rawSignalType.uppercased()) else {
            return nil
        }
        
        let callUID = json["muid"] as? String ?? ""
        
        let signal: [String: Any]
        switch signalType {
        case .newIceCandidate:
            signal = json["rtc_candidate"] as? [String: Any] ?? [:]
        case .answer, .offer:
            signal = json["sdp"] as? [String: Any] ?? [:]
        default:
            signal = [:]
        }
        
        guard let user = HippoUser(json: json) else {
            print("User not intialized in Video Signal")
            return nil
        }
        
        var senderDeviceID = ""
        if let deviceID = (json["device_id"] as? String) {
            
            senderDeviceID = deviceID
        } else if let devicePayload = json["device_payload"] as? [String: Any], let deviceID = devicePayload["device_id"] as? String {
            senderDeviceID = deviceID
        }
        
        let callType: Call.CallType
        if let rawCallType = json["call_type"] as? String, let type = Call.CallType(rawValue: rawCallType.uppercased()) {
            callType = type
        } else {
            callType = .audio
        }
        let rawCustomData: [String: Any] = json["custom_data"] as? [String: Any] ?? [:]
        
        var signalObj = CallSignal(rtcSignal: signal, signalType: signalType, callUID: callUID, sender: user, senderDeviceID: senderDeviceID, callType: callType)
        signalObj.customData = CustomData(dict: rawCustomData)
        return signalObj
    }
}

extension CallSignal: Publishable {
    public func getJsonToSend() -> [String : Any] {
        
        var fayeDict = [String: Any]()
        
        switch signalType {
        case .answer, .offer:
            fayeDict["sdp"] = rtcSignal
        case .newIceCandidate:
            fayeDict["rtc_candidate"] = rtcSignal
        case .startCall, .readyToConnect:
            fayeDict["turn_creds"] = rtcSignal
        default:
            break
        }
        
        fayeDict["is_typing"] = 0
        fayeDict["user_id"] = Int(sender.peerId) ?? 0
        fayeDict["full_name"] = sender.name
        fayeDict["user_thumbnail_image"] = sender.image
        fayeDict["video_call_type"] = signalType.rawValue
        fayeDict["date_time"] = Date().toUTCFormatString
        fayeDict["muid"] = callUID
        fayeDict["message"] = ""
        fayeDict["is_silent"] = signalType != .startCall
        fayeDict["call_type"] = callType.rawValue
        
        if isForceSilent {
            fayeDict["is_silent"] = true
        }
        
        if let data = customData {
            fayeDict["custom_data"] = data.getJson()
            fayeDict["server_push"] = 1
            fayeDict["is_silent"] = true
        }
        
        return fayeDict
    }
}

extension Date {
    var toUTCFormatString: String {
        return convertDateTimeToUTC(date: self)
    }
    func convertDateTimeToUTC(date: Date? = nil) -> String {
        let formatterUTC = DateFormatter()
        formatterUTC.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatterUTC.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatterUTC.string(from: date ?? Date())
    }
}
