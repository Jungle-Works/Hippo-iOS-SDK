//
//  AgentUserChannel.swift
//  SDKDemo1
//
//  Created by Vishal on 20/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import NotificationCenter

protocol AgentUserChannelDelegate: class {
    func newConversationRecieved(_ newConversation: AgentConversation, channelID: Int)
    func readAllNotificationFor(channelID: Int)
}

class AgentUserChannel {
    typealias UserChannelHandler = (_ success: Bool, _ error: Error?) -> Void
    
    private(set) var id: String!
    weak var delegate: AgentUserChannelDelegate?
    
    var storeInteracter = ConversationStoreManager()
    var listener : SocketListner!
    
    static var shared: AgentUserChannel? {
        didSet {
            NotificationCenter.default.post(name: .userChannelChanged, object: nil)
        }
    }
    
    init?() {
        guard HippoConfig.shared.agentDetail?.userChannel != nil else {
            return nil
        }
        id = HippoConfig.shared.agentDetail?.userChannel
        
        guard id != nil, HippoConfig.shared.appUserType == .agent, !id.isEmpty else {
            return nil
        }
        listener = SocketListner()
        subscribe()
        subscribeMarkConversation()
        addObservers()
    }
    
    
    class func reIntializeIfRequired() {
        guard shared == nil else {
            return
        }
        
        if let newReference = AgentUserChannel() {
            shared = newReference
        }
        
        //        if shared != nil {
        //            NotificationCenter.default.post(name: .userChannelChanged, object: nil)
        //        }
    }
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(internetDisConnected), name: .internetDisconnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(internetConnected), name: .internetConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(checkForReconnection), name: .socketConnected, object: nil)
    }
    @objc fileprivate func checkForReconnection() {
        guard !isSubscribed() else {
            return
        }
        subscribe()
    }
    
    @objc func internetDisConnected() {
        
    }
    
    @objc func internetConnected() {
        
        
    }
    
    //    func subscribe(completion: UserChannelHandler? = nil) {
    //        guard id != nil, HippoConfig.shared.appUserType == .agent else {
    //            completion?(false, nil)
    //            return
    //        }
    //        guard !id.isEmpty else {
    //            completion?(false, nil)
    //            return
    //        }
    //
    //        guard !isSubscribed() else {
    //            completion?(false, nil)
    //            return
    //        }
    //
    //        FayeConnection.shared.subscribeTo(channelId: id, completion: { (success) in
    ////            NotificationCenter.default.post(name: .userChannelChanged, object: nil)
    //            completion?(success, nil)
    //        }) { [weak self] (messageDict) in
    //            guard self != nil else {
    //                return
    //            }
    //            let conversation = AgentConversation(json: messageDict)
    //            HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
    //            self?.conversationRecieved(conversation)
    //
    //        }
    //    }
    
    func subscribe(completion: UserChannelHandler? = nil) {
        guard id != nil, HippoConfig.shared.appUserType == .agent else {
            completion?(false, nil)
            return
        }
        guard !id.isEmpty else {
            completion?(false, nil)
            return
        }
        if !SocketClient.shared.isConnected(){
            SocketClient.shared.connect()
        }
       
        SocketClient.shared.subscribeSocketChannel(channel: id)
        listener.startListening(event: SocketEvent.SERVER_PUSH.rawValue, callback: { (data) in
            if let messageDict = data as? [String : Any]{
                
                if (messageDict["channel"] as? String)?.replacingOccurrences(of: "/", with: "") != self.id{
                   return
                }
                
                HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
                
                if let messageType = messageDict["message_type"] as? Int, messageType == 18 {
                    
                    if HippoConfig.shared.appUserType == .agent  {
                        if versionCode >= 350 {
                            HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
                            CallManager.shared.voipNotificationRecieved(payloadDict: messageDict)
                        }
                    }
                }else if let messageType = messageDict["message_type"] as? Int, messageType == MessageType.groupCall.rawValue{
                    if messageDict["video_call_type"] as? String == "END_GROUP_CALL"{
                        CallManager.shared.voipNotificationRecievedForGroupCall(payloadDict: messageDict)
                    }
                }
                let conversation = AgentConversation(json: messageDict)
                //paas data to parent app if chat is assigned to self
                
                if conversation.notificationType == .assigned {
                    if conversation.assigned_to == currentUserId(){
                        //pass data
                        HippoConfig.shared.sendDataIfChatIsAssignedToSelfAgent(messageDict)
                    }else{
                        removeChannelForUnreadCount(conversation.channel_id ?? -1)
                    }
                }
                
                self.conversationRecieved(conversation, dict: messageDict)
            }
        })
       
    }
    
    fileprivate func unSubscribe(completion: UserChannelHandler? = nil) {
        guard id != nil else {
            return
        }
        
        guard !id.isEmpty else {
            return
        }
        SocketClient.shared.unsubscribeSocketChannel(fromChannelId: id)
    }
    //    fileprivate func conversationRecieved(_ newConversation: AgentConversation) {
    fileprivate func conversationRecieved(_ newConversation: AgentConversation, dict: [String: Any]) {
        
        guard let receivedChannelId = newConversation.channel_id, receivedChannelId > 0 else {
            return
        }
        
        guard let type = newConversation.notificationType, type.isNotificationTypeHandled else {
            return
        }
        
        //update count
        //if channel id is not equal to current channel id

        if HippoConfig.shared.getCurrentAgentSdkChannelId() != newConversation.channel_id && type == .message{
            if newConversation.lastMessage?.senderId != currentUserId(){
                calculateTotalAgentUnreadCount(newConversation.channel_id ?? -1, newConversation.unreadCount ?? 0)
            }
        }
        
        switch type {
            case .message:
                delegate?.newConversationRecieved(newConversation, channelID: receivedChannelId)
                break
            case .readAll:
                removeChannelForUnreadCount(newConversation.channel_id ?? -1)
                handleReadAllForHome(newConversation: newConversation)
                break
            case .channelRefresh:
                let chatDetail = ChatDetail(json: dict)
                handleChannelRefresh(chatDetail: chatDetail)
                break
            case .assigned:
                delegate?.newConversationRecieved(newConversation, channelID: receivedChannelId)
                handleAssignmentNotificationForChat(newConversation, channelID: receivedChannelId)
                break
            default:
                break
        }
        
    }
        
        func handleChannelRefresh(chatDetail: ChatDetail) {
            if let chatVC = getLastVisibleController() as? AgentConversationViewController {
                if chatVC.channelId == chatDetail.channelId {
                    chatVC.handleChannelRefresh(detail: chatDetail)
                }
            }else if let chatHomeVC = getLastVisibleController() as? AgentHomeViewController{
                chatHomeVC.channelRefresh(chatDetail: chatDetail, chatDetail.channelId)
            }
        }
        
        func handleReadAllForHome(newConversation: AgentConversation) {
            guard let receivedChannelId = newConversation.channel_id, receivedChannelId > 0 else {
                return
            }
            guard newConversation.user_id == currentUserId() else {
                return
            }
            storeInteracter.readAllNotificationFor(channelID: receivedChannelId)
            delegate?.readAllNotificationFor(channelID: receivedChannelId)
        }
        
        func handleAssignmentNotificationForChat(_ newConversation: AgentConversation, channelID: Int) {
            guard let chatVC = getLastVisibleController() as? AgentConversationViewController, newConversation.notificationType  == NotificationType.assigned else {
                return
            }
            guard chatVC.channelId == channelID, let message = newConversation.lastMessage else {
                return
            }
            chatVC.channel?.messageReceived(message: message)
            //        chatVC.setAssignAlert(conversation: newConversation)
        }
        
        //    func handleBotMessages(_ newConversation: AgentConversation, channelID: Int) {
        //        guard let chatVC = getLastVisibleController() as? AgentConversationViewController else {
        //            return
        //        }
        //        guard chatVC.channelId == channelID else {
        //            return
        //        }
        //
        //        guard let message = newConversation.lastMessage, (message.type == .botFormMessage || message.type == .botText) else {
        //            return
        //        }
        //        message.status = .sent
        //        chatVC.handleBotFaye(message: message, channelId: channelID)
        //    }
        
        func isSubscribed() -> Bool {
            return SocketClient.shared.isChannelSubscribed(channel: id)
        }
        
        deinit {
            unSubscribe()
            NotificationCenter.default.removeObserver(self)
        }
}
