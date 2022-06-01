//
//  SocketEmitter.swift
//  Hippo
//
//  Created by Arohi Sharma on 22/10/20.
//

import Foundation

extension SocketClient {
    
    func getJson()-> [String : Any]{
        var json = [String : Any]()
        json["app_secret_key"] = currentUserType() == .agent ? HippoConfig.shared.agentDetail?.appSecrectKey : HippoConfig.shared.appSecretKey
        json["en_user_id"] = currentEnUserId()
        json["device_type"] = Device_Type_iOS
        json["source"] = HippoSDKSource
        json["lang"] = getCurrentLanguageLocale()
        return json
    }
    
    ///Subscribe socket channel
    func subscribeSocketChannel(channel: String,completion: ((Error?,Bool) -> Void)? = nil){
        print("subscribeSocketChannel")
        if let someSocket = socket, someSocket.status.active {
            
            var eventToSubscribe = ""
            if currentUserType() == .agent{
                if channel == HippoConfig.shared.agentDetail?.userChannel{
                    eventToSubscribe = SocketEvent.SUBSCRIBE_USER.rawValue
                }else{
                    eventToSubscribe = SocketEvent.SUBSCRIBE_CHAT.rawValue
                }
            }else{
                if channel == HippoUserDetail.HippoUserChannelId ?? ""{
                    eventToSubscribe = SocketEvent.SUBSCRIBE_USER.rawValue
                }else{
                    eventToSubscribe = SocketEvent.SUBSCRIBE_CHAT.rawValue
                }
            }
            var channelIdForValidation = channel
            validate(channelID: &channelIdForValidation)
            
            var json = getJson()
            json["channel"] = channelIdForValidation
            
            if currentEnUserId().trimWhiteSpacesAndNewLine() == ""{
                print("returndddddddddddddddddd")
                return
            }
            
            print("status of socket ------->>>>>>>>\(SocketClient.shared.socket?.status)")
            
            socket?.emitWithAck(eventToSubscribe, json).timingOut(after: 20, callback: { (data) in
                print("DAATA IN SUCCESS OF EMITTTTTT\(data)")
                if data.isEmpty{
                    completion?(nil, false)
                }else{
                    self.subscribedChannel[channel] = true
                    NotificationCenter.default.post(name: .channelSubscribed, object: nil)
                    completion?(nil, true)
                }
            })
        }else{
            SocketClient.shared.connect()
//            subscribeSocketChannel(channel: channel, completion: completion)
        }
    }
    
    ///Unsubscribe socket channel
    func unsubscribeSocketChannel(fromChannelId channel : String){
        if let someSocket = socket, someSocket.status.active {
            var eventToSubscribe = ""
            if currentUserType() == .agent{
                if channel == HippoConfig.shared.agentDetail?.userChannel{
                    eventToSubscribe = SocketEvent.UNSUBSCRIBE_USER.rawValue
                }else{
                    eventToSubscribe = SocketEvent.UNSUBSCRIBE_CHAT.rawValue
                }
            }else{
                if channel == HippoUserDetail.HippoUserChannelId ?? ""{
                    eventToSubscribe = SocketEvent.UNSUBSCRIBE_USER.rawValue
                }else{
                    eventToSubscribe = SocketEvent.UNSUBSCRIBE_CHAT.rawValue
                }
            }
            var channelIdForValidation = channel
            validate(channelID: &channelIdForValidation)
            
            var json = getJson()
            json["channel"] = channelIdForValidation
            
            if currentEnUserId().trimWhiteSpacesAndNewLine() == ""{
                return
            }
            
            socket?.emitWithAck(eventToSubscribe, json).timingOut(after: 20, callback: { (data) in
                self.subscribedChannel[channel] = false
            })
        }else{
            SocketClient.shared.connect()
        }
    }
    
    ///Send message
    func send(messageDict: [String: Any], toChannelID channelID: String, completion: @escaping(EventAckResponse)->Void) {
        if let socket = socket, socket.status.active {
            var channelIdForValidation = channelID
            validate(channelID: &channelIdForValidation)
            
            var json = [String : Any]()
            json["data"] = messageDict
            json += getJson()
            json["channel"] = channelIdForValidation
            let authDic = ["user_id" : "\(currentUserId())","muid" : messageDict["muid"] as? String ?? ""] as [String : Any]
            let auth = jsonToString(json: authDic)
            let encryptedAuth = CryptoJS.AES().encrypt(auth, password: getSecretKey())
            json["auth0"] = encryptedAuth
            if currentEnUserId().trimWhiteSpacesAndNewLine() == ""{
                return
            }

            socket.emitWithAck(SocketEvent.MESSAGE_EVENT.rawValue, json).timingOut(after: 30, callback: { (data) in
                let ack = EventAckResponse(with: data)
                completion(ack)
            })
        }else{
            SocketClient.shared.connect()
            send(messageDict: messageDict, toChannelID: channelID, completion: completion)
        }
    }
    
    ///Returns Handshake dic for HANDSHAKE_CHANNEL after channel connect
    func handshake(){
        if let someSocket = socket, someSocket.status.active {
            let json = getJson()
            
            if currentEnUserId().trimWhiteSpacesAndNewLine() == ""{
                return
            }
            
            socket?.emitWithAck(SocketEvent.HANDSHAKE_CHANNEL.rawValue, json).timingOut(after: 20, callback: { (data) in
                print(data)
            })
        }else{
            SocketClient.shared.connect()
        }
     }
    
    private func validate(channelID: inout String) {
        guard channelID.first != nil else {
            return
        }
        
        if "\(channelID.first ?? Character(""))" != SocketClient.shared.channelPrefix {
            channelID = SocketClient.shared.channelPrefix + channelID
        }
    }
    
    struct EventAckResponse {
        var error: SocketClient.SocketError?
        var data = [String : Any]()
        var isSuccess: Bool = false
        
        init(with ack: [Any]) {
            if ack.count > 0 {
                if ack.count == 1 {
                    let errorData = ack.first as? [String : Any]
                    if let some = errorData {
                        error = SocketClient.SocketError(reasonInfo: some)
                    }
                    data = errorData ?? [String : Any]()
                    isSuccess = false
                }else  {
                    error = nil
                    data = ack[1] as? [String : Any] ?? [String : Any]()
                    isSuccess = true
                }
            }
        }
    }
}
