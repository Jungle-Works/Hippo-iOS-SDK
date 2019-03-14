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
    var customerName: String = "Visitor"
    var customerEmail: String = ""
    var customerContactNumber: String = ""
    var channelTags: [TagDetail] = []
    var channelStatus = ChannelStatus.open
    
    var chatType: ChatType = .none
    
    var peerDetail: [String: Any]?
    var peerName: String = ""
    var allowVideoCall = false
    var allowAudioCall = false
    
    
    
    init(json: [String: Any]) {
        channelId = json["channel_id"] as? Int ?? -1
        assignedAgentID = json["user_id"] as? Int ?? -1
        assignedAgentName = json["agent_name"] as? String ?? ""
        customerID = json["owner_id"] as? Int ?? -1
        customerName = json["customer_name"] as? String ?? ""
        customerEmail = json["customer_email"] as? String ?? ""
        customerContactNumber = json["customer_phone"] as? String ?? ""
        
        
        if let channel_status = json["channel_status"] as? Int, let status = ChannelStatus(rawValue: channel_status) {
            channelStatus = status
        }
        
        
        if let chat_type = json["chat_type"] as? Int, let parsedChatType = ChatType(rawValue: chat_type) {
            chatType = parsedChatType
        }
        
        if let tags = json["tags"] as? [[String: Any]] {
            let tagsObject = TagDetail.parseTagDetail(data: tags)
            self.channelTags = tagsObject
        }
        
        if assignedAgentID < 0 {
            assignedAgentName = "Unassigned"
        }
        
        var tempPeerId: Int = -1
        var tempPeerName: String = ""
        var tempPeerImage: String = ""
        
        let otherUsers = json["other_users"] as? [[String: Any]] ?? []
        
        allowVideoCall = Bool.parse(key: "allow_video_call", json: json, defaultValue: false)
        allowAudioCall = Bool.parse(key: "allow_audio_call", json: json, defaultValue: false)
        
        switch (HippoConfig.shared.appUserType, otherUsers.count > 0) {
        case (.agent, _):
            tempPeerId = customerID
            tempPeerName = customerName
        case (.customer, true):
            let user = otherUsers[0]
            tempPeerName = user["full_name"] as? String ?? ""
            tempPeerId = Int.parse(values: user, key: "user_id") ?? -1
            tempPeerImage = user["user_image"] as? String ?? ""
        case (.customer, false):
            tempPeerName = assignedAgentName
            tempPeerId = assignedAgentID
        }
        
        if tempPeerId > 0  {
            peerName = tempPeerName.trimWhiteSpacesAndNewLine()
            peerDetail = ["user_id": tempPeerId,
                          "full_name": tempPeerName,
                          "user_image": tempPeerImage]
        } else if let peerDetail = json["peerDetail"] as? [ String: Any] {
            self.peerName = (peerDetail["full_name"] as? String ?? "").trimWhiteSpacesAndNewLine()
            self.peerDetail = peerDetail
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
        
        dict["tags"] = TagDetail.getObjectToStore(tags: channelTags)
        
        if peerDetail != nil {
            dict["peerDetail"] = peerDetail
        }
        dict["allow_video_call"] = allowVideoCall
        dict["allow_audio_call"] = allowAudioCall
        return dict
    }
}
