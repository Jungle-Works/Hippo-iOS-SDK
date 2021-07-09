//
//  CustomerUserChannel.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/07/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation
import NotificationCenter


class CustomerUserChannel {
    
    private(set) var id: String!
    static var shared: CustomerUserChannel? {
        didSet {
            NotificationCenter.default.post(name: .userChannelChanged, object: nil)
        }
    }
    
    init?() {
        guard HippoUserDetail.HippoUserChannelId != nil else {
            return nil
        }
        id = HippoUserDetail.HippoUserChannelId
        
        guard id != nil, HippoConfig.shared.appUserType == .customer, !id.isEmpty else {
            return nil
        }
        subscribe()
        addObservers()
    }
    
    
    class func reIntializeIfRequired() {
        guard shared == nil else {
            return
        }
        
        if let newReference = CustomerUserChannel() {
            shared = newReference
        }
    }
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(internetDisConnected), name: .internetDisconnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(internetConnected), name: .internetConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(checkForReconnection), name: .socketConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleUserChannelNotification), name: .messageRecieved, object: nil)
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
    
    func subscribe() {
        guard id != nil, HippoConfig.shared.appUserType == .customer else {
            return
        }
        guard !id.isEmpty else {
            return
        }
        if !SocketClient.shared.isConnected(){
            SocketClient.shared.connect()
        }
        
        SocketClient.shared.subscribeSocketChannel(channel: id)
    }
    
    @objc private func handleUserChannelNotification(notification: NSNotification) {
        
        if let messageDict = notification.userInfo as? [String : Any] {
            if (messageDict["channel"] as? String)?.replacingOccurrences(of: "/", with: "") != id{
                return
            }
            
            HippoConfig.shared.log.trace("CustomerUserChannel:: --->\(messageDict)", level: .socket)
            
            if let messageType = messageDict["message_type"] as? Int, messageType == MessageType.call.rawValue {
                if let channel_id = messageDict["channel_id"] as? Int{ //isSubscribed(userChannelId: "\(channel_id)") == false {
                    
                    let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channel_id)
                    if versionCode < 350{//call for old version
                        channel.signalReceivedFromPeer?(messageDict)
                    }
                    CallManager.shared.voipNotificationRecieved(payloadDict: messageDict)
                }
            }else if let messageType = messageDict["message_type"] as? Int, messageType == MessageType.groupCall.rawValue{
                CallManager.shared.voipNotificationRecievedForGroupCall(payloadDict: messageDict)
            }
            
            if let notificationType = messageDict["notification_type"] as? Int{
                if notificationType == NotificationType.message.rawValue && messageDict["channel_id"] as? Int != HippoConfig.shared.getCurrentChannelId(){
                    if let channelId = messageDict["channel_id"] as? Int, let otherUserUniqueKey = ((messageDict["user_unique_keys"] as? [String])?.filter{$0 != HippoConfig.shared.userDetail?.userUniqueKey}.first){
                        let transactionId = P2PUnreadData.shared.getTransactionId(with: channelId)
                        if let data = P2PUnreadData.shared.getData(with: transactionId) , data.id == (transactionId + "-" + otherUserUniqueKey) {
                            let unreadCount = (data.count ?? 0) + 1
                            P2PUnreadData.shared.updateChannelId(transactionId: transactionId, channelId: channelId, count: unreadCount,muid: messageDict["muid"] as? String ,otherUserUniqueKey: otherUserUniqueKey)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func unSubscribe() {
        guard id != nil else {
            return
        }
        
        guard !id.isEmpty else {
            return
        }
        SocketClient.shared.unsubscribeSocketChannel(fromChannelId: id)
    }
    
    
    
    func isSubscribed() -> Bool {
        return SocketClient.shared.isChannelSubscribed(channel: id)
    }
    
    deinit {
        unSubscribe()
        NotificationCenter.default.removeObserver(self)
    }
}
