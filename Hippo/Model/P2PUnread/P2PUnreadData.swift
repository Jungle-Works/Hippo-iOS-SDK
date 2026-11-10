//
//  P2PUnreadData.swift
//  Hippo
//
//  Created by Arohi Sharma on 04/09/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class P2PUnreadData {

    //MARK:-
    static var shared = P2PUnreadData()
    var p2pChannelCount = [String : P2PData]() //transaction id with corresponding dic of channel id and count
    
    
    //MARK:- Functions
    /**
        * for getting saved data from hashmap
        * @transactionId
    */
    func getData(with transactionId : String) -> P2PData? {
        return p2pChannelCount[transactionId]
    }
    
    /**
        * Used for saving data from fetch p2p unread count API
    */
    
    
    
    
    func updateChannelId(transactionId : String, channelId : Int, count : Int, muid : String? = nil, otherUserUniqueKey: String?){
        let previousData = getData(with: transactionId)
        if previousData?.muid != nil, muid != nil, previousData?.muid == muid{
            return
        }
        let data = P2PData(channelId: channelId, count: count, muid: muid, id: (transactionId + "-" + (otherUserUniqueKey ?? "")))
        p2pChannelCount[transactionId] = data
        if count >= 0{
            HippoConfig.shared.sendp2pUnreadCount(count, channelId)
        }
    }
    
    /**
        * Get transaction id from channel id
    */
    
    func getTransactionId(with channelId : Int) -> String{
        for (key,value) in p2pChannelCount{
            if channelId == value.channelId{
                return key
            }
        }
        return ""
    }

    /**
        * Sets the saved count for a channel to 0 and tells the app.
        * Used when the chat was opened without a transaction id (e.g. from a notification).
        * Keeps the saved id and muid, because later updates compare against them.
    */
    func clearCount(channelId : Int){
        guard channelId > 0 else { return }
        let transactionId = getTransactionId(with: channelId)
        guard !transactionId.isEmpty, var data = getData(with: transactionId) else { return }
        guard (data.count ?? 0) != 0 else { return }
        data.count = 0
        p2pChannelCount[transactionId] = data
        HippoConfig.shared.sendp2pUnreadCount(0, channelId)
    }

    /**
        * Transaction ids of saved chats with this person whose channel doesn't exist yet
        * (channelId -1 or -2), i.e. chats still waiting for their first message.
    */
    func pendingTransactionIds(otherUserUniqueKey : String) -> [String]{
        return p2pChannelCount.compactMap { (transactionId, data) in
            guard (data.channelId ?? -1) <= 0,
                  data.id == transactionId + "-" + otherUserUniqueKey else { return nil }
            return transactionId
        }
    }

    /**
        * Asks the server for the count of each chat. On success the saved entry gets the real
        * channel id and the app gets sendp2pUnreadCount.
    */
    func refreshFromServer(transactionIds : [String], otherUserUniqueKey : String){
        let myKey = HippoConfig.shared.userDetail?.userUniqueKey ?? ""
        for transactionId in transactionIds {
            guard let request = PeerToPeerChat(uniqueChatId: transactionId, myUniqueId: myKey, idsOfPeers: [otherUserUniqueKey], channelName: "") else { continue }
            UnreadCount.fetchP2PUnreadCount(request: request) { _, _ in }
        }
    }

}

struct P2PData {
    var channelId : Int?
    var count : Int?
    var muid : String?
    var id : String?
}
