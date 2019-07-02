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
        
        guard idsOfPeers.count > 0 else {
            //NSLog("Ids of peers not found")
            return nil
        }
        
        self.userUniqueId = myUniqueId
        self.uniqueChatId = uniqueChatId
        self.idsOfPeers = idsOfPeers
        self.channelName = channelName
        
        self.peerName = peerName
        
        if let parsedImage = otherUserImage, let parsedURL = URL(string: parsedImage) {
            self.otherUserImage = parsedURL
        }
    }
   
}
