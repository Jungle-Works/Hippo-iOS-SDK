//
//  GeneralChat.swift
//  SDKDemo1
//
//  Created by Vishal on 17/08/18.
//

import Foundation

public struct GeneralChat {
    
    /// *  Unique ID you will use to recognize seprate chats between same peers.
    ///  * Could be set to `nil` if there is no need to create seprate chat between same peers.
    public var uniqueChatId: String
    
    public var userUniqueId: String = ""
    
    /// * Grouping tags that you want to assign
    public var groupingTags: [String]?
    
    
    /// * Normal tags that you want to assign
    public var tags: [String]?
    
    /// Name you want to give your chat
    public var channelName: String
    
    public var hideBackButton: Bool = false
    
    /**
     - parameter uniqueChatId: Unique ID you will use to recognize seprate chats between same peers. Could be set to `nil` if there is no need to create seprate chat between same peers.
     - parameter idsOfPeers: Unique IDs of peers with whom you want to start chat.
     - parameter channelName: Name you want to give your chat
     */
    public init(uniqueChatId: String, myUniqueId: String, groupingTags: [String]?, channelName: String, tags: [String]?) {
        
        self.userUniqueId = myUniqueId.trimWhiteSpacesAndNewLine()
        self.uniqueChatId = uniqueChatId.trimWhiteSpacesAndNewLine()
        self.groupingTags = groupingTags
        self.tags = tags
        self.channelName = channelName
    }
    
}
