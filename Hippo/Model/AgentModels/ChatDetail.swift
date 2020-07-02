//
//  ChatDetail.swift
//  SDKDemo1
//
//  Created by Vishal on 19/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation



class ChatDetail: NSObject {
    var channelId: Int = -1
    var assignedAgentID: Int = -1
    var assignedAgentName: String = ""
    var customerID: Int = -1
    var customerName: String = HippoStrings.visitor
    var customerEmail: String = ""
    var customerContactNumber: String = ""
    var channelTags: [TagDetail] = []
    var channelStatus = ChatStatus.open
    var otherUserImage: String?
    
    var isBotInProgress: Bool = false
    
    var chatType: ChatType = .none
    var channelImageUrl: String?
    var channelName: String?
    
    var peerDetail: User?
    var peerName: String = ""
    var allowVideoCall = false
    var allowAudioCall = false
    
    var botMessageMUID: String = ""
    var botMessageID: String = ""
    
    var agentAlreadyAssigned: Bool = false
    
    var disableReply = false
    
    init(channelID: Int) {
        self.channelId = channelID
    }
    
    init(json: [String: Any]) {
        channelId = Int.parse(values: json, key: "channel_id") ?? -1
        assignedAgentID = json["user_id"] as? Int ?? -1
        assignedAgentName = json["agent_name"] as? String ?? ""
        customerID = json["owner_id"] as? Int ?? -1
        customerName = json["customer_name"] as? String ?? ""
        customerEmail = json["customer_email"] as? String ?? ""
        customerContactNumber = json["customer_phone"] as? String ?? ""
        otherUserImage = json["other_user_image"] as? String
        
        isBotInProgress = Bool.parse(key: "is_bot_in_progress", json: json, defaultValue: false)
        
        agentAlreadyAssigned = json["agent_already_assigned"] as? Bool ?? false
        if let channel_status = json["channel_status"] as? Int, let status = ChatStatus(rawValue: channel_status) {
            channelStatus = status
        }
        
        
        if let chat_type = json["chat_type"] as? Int, let parsedChatType = ChatType(rawValue: chat_type) {
            chatType = parsedChatType
        }
        channelImageUrl = json["channel_image_url"] as? String
        
        if let tags = json["tags"] as? [[String: Any]] {
            let tagsObject = TagDetail.parseTagDetail(data: tags)
            self.channelTags = tagsObject
        }
        
        if assignedAgentID < 0 {
            assignedAgentName = HippoStrings.unassigned
        }
        
       var tempPeerDetail: User?
        
        let otherUsers = json["other_users"] as? [[String: Any]] ?? []
        
        allowVideoCall = Bool.parse(key: "allow_video_call", json: json, defaultValue: false)
        allowAudioCall = Bool.parse(key: "allow_audio_call", json: json, defaultValue: false)
        
        switch (HippoConfig.shared.appUserType, otherUsers.count > 0) {
        case (.agent, _):
            tempPeerDetail = User(name: customerName, imageURL: channelImageUrl, userId: customerID)
        case (.customer, true):
            let user = otherUsers[0]
            tempPeerDetail = User(dict: user)
        case (.customer, false):
            tempPeerDetail = User(name: assignedAgentName, imageURL: nil, userId: assignedAgentID)
        }
        
        if let id = tempPeerDetail?.userID, id > 0  {
            peerDetail = tempPeerDetail
        } else if let peerDetail = json["peerDetail"] as? [ String: Any] {
            self.peerDetail = User(dict: peerDetail)
        }
    }
    
    
    func toJson() -> [String: Any] {
        var param = [String: Any]()
        param["channel_id"] = channelId
        return param
    }
    
    func getJsonToStore() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["channel_id"] = channelId
        dict["user_id"] = assignedAgentID
        dict["agent_name"] = assignedAgentName
        dict["owner_id"] = customerID
        dict["customer_name"] = customerName
        dict["customer_email"] = customerEmail
        dict["customer_phone"] = customerContactNumber
        dict["channel_status"] = channelStatus.rawValue
        
        dict["is_bot_in_progress"] = isBotInProgress
        
        dict["tags"] = TagDetail.getObjectToStore(tags: channelTags)
        
        if let parsedPeerData = peerDetail {
            dict["peerDetail"] = parsedPeerData.toJson()
        }
        dict["chat_type"] = chatType.rawValue
        if let channel_image_url = channelImageUrl {
            dict["channel_image_url"] = channel_image_url
        }
        dict["allow_video_call"] = allowVideoCall
        dict["allow_audio_call"] = allowAudioCall
        return dict
    }
    
    
    func updatePeerData(users: [User]) {
        let filterUser = users.filter { (u) -> Bool in
            return u.userID != currentUserId()
        }
        guard let user  = filterUser.first else {
            return
        }
        peerDetail = user
    }
}
