//
//  HippoConversation.swift
//  Branch
//
//  Created by Vishal on 24/01/19.
//

import Foundation
class HippoConversationCallBack {
    var messageUpdated: (() -> ())?
    var unreadCountupdated: (() -> ())?
}

class HippoConversation: HippoConversationCallBack {
    
    var channelId: Int?
    var channelStatus: ChatStatus = ChatStatus.open
    var label: String?
    var labelId: Int?
    var channelImageUrl: String?
    var chatType: ChatType = .none
    var channelBackgroundColor : UIColor?
    
    var lastMessage: HippoMessage? {
        didSet {
            messageUpdated?()
        }
    }
    var unreadCount: Int? {
        didSet {
            if (unreadCount ?? 0) > 0 {
//                channelStatus = .open
            }
        }
    }
    
    
    
    func getJsonToStore() -> [String: Any] {
        var params = [String: Any]()
        
        params["channel_status"] = channelStatus.rawValue
        params["label_id"] = labelId ?? -1
        
        params["unread_count"] = unreadCount ?? 0
        params["channel_id"] = channelId ?? "-1"
        params["label"] = label ?? ""
        params["chat_type"] = chatType.rawValue
        if let channel_image_url = channelImageUrl {
          params["channel_image_url"] = channel_image_url
        }
        if let messageJson = lastMessage?.getDictToSaveInCache() {
            params += messageJson
        }
        
        return params
    }
    
}
