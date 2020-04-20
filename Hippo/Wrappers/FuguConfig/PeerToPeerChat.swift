//
//  PeerToPeerChat.swift
//  Fugu
//
//  Created by cl-macmini-117 on 03/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

public struct PeerToPeerChat {
   
   /// *  Unique ID you will use to recognize seprate chats between same peers.
   ///  * Could be set to `nil` if there is no need to create seprate chat between same peers.
   public var uniqueChatId: String?
   
   public var userUniqueId: String = ""
   
   /// * Unique IDs of peers with whom you want to start chat
   public var idsOfPeers: [String]
   
   /// Name you want to give your chat
   public var channelName: String
    
   //Other userImage to show
    public var otherUserImage: URL?
   
    
  // Name Of Peer
    public var peerName: String
   /**
    - parameter uniqueChatId: Unique ID you will use to recognize seprate chats between same peers. Could be set to `nil` if there is no need to create seprate chat between same peers.
    - parameter idsOfPeers: Unique IDs of peers with whom you want to start chat.
    - parameter channelName: Name you want to give your chat
    */
    public init?(uniqueChatId: String?, myUniqueId: String, idsOfPeers: [String], channelName: String, peerName: String = "", otherUserImage: String? = nil) {
        
        
        
        var parsedPeers = [String]()
        
        for each in idsOfPeers {
            let newPeer = each.trimWhiteSpacesAndNewLine()
            if !newPeer.isEmpty {
                parsedPeers.append(newPeer)
            }
        }
        guard parsedPeers.count > 0 else {
            HippoConfig.shared.log.error("id of peers are nil", level: .error)
            return nil
        }
        
        self.userUniqueId = myUniqueId.trimWhiteSpacesAndNewLine()
        self.uniqueChatId = uniqueChatId?.trimWhiteSpacesAndNewLine()
        self.idsOfPeers = parsedPeers
        self.channelName = channelName.trimWhiteSpacesAndNewLine()
        
        self.peerName = peerName.trimWhiteSpacesAndNewLine()
        
        if let parsedImage = otherUserImage?.trimWhiteSpacesAndNewLine(), let parsedURL = URL(string: parsedImage) {
            self.otherUserImage = parsedURL
        }
    }
    
    func generateParamForUnreadCount() throws -> [String: Any] {
        var json: [String: Any] = [:]
        
        let appSecretKey = HippoConfig.shared.appSecretKey
        
        guard HippoConfig.shared.appUserType == .customer else {
            HippoConfig.shared.log.trace("notAllowedForAgent", level: .error)
            throw HippoError.notAllowedForAgent
        }
        
        guard !appSecretKey.isEmpty else {
            HippoConfig.shared.log.trace("appSecret key found empty", level: .error)
            throw HippoError.invalidAppSecretKey
        }
        json["app_secret_key"] = appSecretKey
        
        let enUserId: String = currentEnUserId()
        
        guard !enUserId.isEmpty else {
            HippoConfig.shared.log.trace("updateUserDetail", level: .error)
            throw HippoError.updateUserDetail
        }
        json["en_user_id"] = enUserId
        
        json["user_unique_key"] = HippoConfig.shared.userDetail?.userUniqueKey ?? userUniqueId
        json["other_user_unique_key"] = idsOfPeers
        json["transaction_id"] = uniqueChatId
        
        return json
        
        
    }
   
}
