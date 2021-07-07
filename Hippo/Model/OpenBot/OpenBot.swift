//
//  OpenBot.swift
//  Hippo
//
//  Created by Arohi Magotra on 02/07/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation

public class OpenBot {
    
    //MARK:- Variables
    private var channelId : Int
    public var conversationCreated: ((_ response: [String : Any])->())?
    public var messageRecieved: ((_ response: [String : Any])->())?

    private var listener : SocketListner?
    ///Send params if you want to create a new chat, otherwise subscribe old channel with channel id and hit get messages
    
    public init(params: [String: Any]? = nil, channelId: Int) {
        if SocketClient.shared.isConnected() == false {
            SocketClient.shared.connect()
        }
        self.channelId = channelId
        listener = SocketListner()
        if channelId < 0 {
            createNewConversationWith(params: params ?? [String : Any]())
        }else {
            if !isSubscribed() {
                subscribe()
            }
            startListening()
        }
        
    }
    
    public func sendMessage(messageJson: [String : Any], completion: @escaping (_ response: [String : Any]?,  _ error : Error?) -> Void) {
        if channelId > 0 {
            SocketClient.shared.send(messageDict: messageJson, toChannelID: "\(channelId)", completion: { (result) in
                completion(result.data, result.error)
            })
        }
    }
    
    
    public func createNewConversationWith(params: [String: Any]) {
        var requestParam = params
        if requestParam.keys.contains("en_user_id") == false{
            requestParam["en_user_id"] = currentEnUserId()
        }
        if requestParam.keys.contains("user_id") == false{
            requestParam["user_id"] = currentUserId()
        }
        
        HippoConfig.shared.log.debug("API_CREATE_CONVERSATION.....\(requestParam)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: requestParam, extendedUrl: FuguEndPoints.API_CREATE_CONVERSATION.rawValue) {[weak self] (response, error, _, statusCode) in
            if let response = response as? [String : Any]{
                self?.channelId = (response["data"] as? [String : Any])?["channel_id"] as? Int ?? -1
                if !(self?.isSubscribed() ?? true) {
                    self?.subscribe()
                }
                self?.startListening()
                self?.conversationCreated?(response)
            }
        }
    }
    
    public func getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: @escaping (_ response: [String : Any]?,  _ success : Bool) -> Void) {
        guard channelId != -1 else {
            completion(nil, false)
           return
        }
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            completion(nil, false)
           return
        }
        
        if HippoConfig.shared.appSecretKey.isEmpty {
            completion(nil, false)
           return
        }
        
        let request = MessageStore.messageRequest(pageStart: pageStart, showLoader: false, pageEnd: pageEnd, channelId: channelId, labelId: -1)
        
        MessageStore.getMessages(requestParam: request, ignoreIfInProgress: false) {(data, response, isCreateConversationRequired)  in
            completion(data, true)
        }
    }
   
    private func isSubscribed() -> Bool {
        return SocketClient.shared.isChannelSubscribed(channel: "\(channelId)")
    }
    
    private func subscribe() {
        SocketClient.shared.subscribeSocketChannel(channel: "\(channelId)")
    }
    
    private func startListening(){
        listener?.startListening(event: SocketEvent.SERVER_PUSH.rawValue, callback: { [weak self] (data) in
            if let messageDict = data as? [String : Any]{
                self?.messageRecieved?(messageDict)
            }
        })
    }
}
