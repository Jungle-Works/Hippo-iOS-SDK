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
        
        subscribe()
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
        notificationCenter.addObserver(self, selector: #selector(checkForReconnection), name: .fayeConnected, object: nil)
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
            
            guard !isSubscribed() else {
                completion?(false, nil)
                return
            }
            
            FayeConnection.shared.subscribeTo(channelId: id, completion: { (success) in
    //            NotificationCenter.default.post(name: .userChannelChanged, object: nil)
                completion?(success, nil)
            }) { [weak self] (messageDict) in
                guard self != nil else {
                    return
                }
                if let messageType = messageDict["message_type"] as? Int, messageType == 18 {
                    
                    if HippoConfig.shared.appUserType == .agent  {
                        if versionCode >= 350 {
                            HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
                            CallManager.shared.voipNotificationRecieved(payloadDict: messageDict)
                        }
                    }

                    
//                HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
//                    CallManager.shared.voipNotificationRecieved(payloadDict: messageDict)
                }
                let conversation = AgentConversation(json: messageDict)
    //            HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
                self?.conversationRecieved(conversation)
                
            }
        }
    
    fileprivate func unSubscribe(completion: UserChannelHandler? = nil) {
        guard id != nil else {
            return
        }
        
        guard !id.isEmpty else {
            return
        }
        FayeConnection.shared.unsubscribe(fromChannelId: id, completion: { (success, error) in
            completion?(success, error)
        })
    }
    fileprivate func conversationRecieved(_ newConversation: AgentConversation) {
        guard let receivedChannelId = newConversation.channel_id, receivedChannelId > 0 else {
            return
        }
        
        guard let type = newConversation.notificationType, type.isNotificationTypeHandled else {
            return
        }
        
        if type == .readAll {
            handleReadAllForHome(newConversation: newConversation)
            return
        }
        
        handleAssignmentNotificationForChat(newConversation, channelID: receivedChannelId)
//        handleBotMessages(newConversation, channelID: receivedChannelId)
        
        delegate?.newConversationRecieved(newConversation, channelID: receivedChannelId)
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
        return FayeConnection.shared.isChannelSubscribed(channelID: id)
    }
    
    deinit {
        unSubscribe()
        NotificationCenter.default.removeObserver(self)
    }
}
