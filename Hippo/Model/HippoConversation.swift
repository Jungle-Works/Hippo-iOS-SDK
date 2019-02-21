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
    var channelStatus: ChannelStatus = ChannelStatus.open
    var label: String?
    var labelId: Int?
    
    
    
    var lastMessage: HippoMessage? {
        didSet {
            messageUpdated?()
        }
    }
    var unreadCount: Int? {
        didSet {
            if (unreadCount ?? 0) > 0 {
                channelStatus = .open
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
        
        if let messageJson = lastMessage?.getDictToSaveInCache() {
            params += messageJson
        }
        
        return params
    }
    
}
