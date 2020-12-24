//
//  AgentConversation.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

//struct CustomerInfo {
//    let userUniqueKey: String
//    let userId: Int
//}
class AgentConversation: HippoConversation {
    
    var agent_id: Int?
    var agent_name: String?
    var bot_channel_name: String?
    var channel_id: Int?
    var channel_name: String?
    var created_at: String?
    var channel_type : Int?
    
    var status: Int?
    var user_image: String?
    var user_id: Int?
    var date_time: String?
    var notificationType: NotificationType?
    var customerUserUniqueKeys: [String] = []
    
    var displayingMessage = ""
    var formattedTime = ""
    var lastMessageDate: Date = Date()
    var assigned_by: Int?
    var assigned_to: Int?
    var assigned_by_name: String?
    var assigned_to_name: String?
    var isMyChat: Bool?
    var mutiLanguageMsg : String?
    var isBotInProgress: Bool = false
    var chatStatus : Int?

    var updateUnreadCountBy: Int {
        return isMyChat ?? false ? 1 : 0
    }
    
    override init() {
        
    }
    
    init?(channelId: Int, unreadCount: Int, lastMessage: HippoMessage) {
        super.init()
        guard channelId > 0 else {
            return nil
        }
        self.channel_id = channelId
        self.unreadCount = unreadCount
        self.status = lastMessage.status.rawValue
        self.lastMessageDate = lastMessage.creationDateTime
        self.date_time = lastMessage.creationDateTime.toUTCFormatString
        self.lastMessage = lastMessage
        
        self.displayingMessage = getDisplayMessage()
        setTime()
    }
    
    init(json: [String: Any]) {
        super.init()
        chatStatus = json["chat_status"] as? Int
        isBotInProgress = Bool.parse(key: "is_bot_in_progress", json: json, defaultValue: false)
        labelId = json["label_id"] as? Int ?? -1
        agent_id = json["agent_id"] as? Int
        agent_name = json["agent_name"] as? String
        bot_channel_name = json["bot_channel_name"]  as? String
        channel_id = json["channel_id"] as? Int ?? -1 //Int.parse(values: json, key: "channel_id") //json["channel_id"] as? Int
        channel_name = json["channel_name"] as? String
        channel_type = json["channel_type"] as? Int
        created_at = json["created_at"] as? String
        label = json["label"] as? String
        status = json["status"] as? Int
        user_image = String.parse(values: json, key: "user_image", defaultValue: "")
        user_id = Int.parse(values: json, key: "user_id") //json["user_id"] as? Int
        date_time = json["date_time"] as? String
        channelBackgroundColor = UIColor.hexStringToUIColor(hex: material[getColor(char: label?.initials ?? "")])
        
        assigned_to_name = json["assigned_to_name"] as? String
        assigned_by_name = json["assigned_by_name"] as? String
        assigned_to = Int.parse(values: json, key: "assigned_to")
        assigned_by = Int.parse(values: json, key: "assigned_by")
        unreadCount = Int.parse(values: json, key: "unread_count")
        isMyChat = Bool.parse(key: "is_my_chat", json: json)
        
        
        if let customer_unique_keys = json["customer_unique_keys"] as? [[String: Any]] {
            customerUserUniqueKeys.removeAll()
            for each in customer_unique_keys {
                guard let key = each["user_unique_key"] as? String, "0" != key else {
                    continue
                }
                customerUserUniqueKeys.append(key)
            }
        } else if let customerUserUniqueKeys = json["customerUserUniqueKeys"] as? [String] {
            self.customerUserUniqueKeys = customerUserUniqueKeys
        }
         
        assigned_to = json["assigned_to"] as? Int
        
        if let notification_type = json["notification_type"] as? Int, let type = NotificationType(rawValue: notification_type) {
            notificationType = type
        }
        if let chat_type = Int.parse(values: json, key: "chat_type"), let type = ChatType(rawValue: chat_type) {
            chatType = type
        }
        
        if let message = HippoMessage(convoDict: json) {
            lastMessage = message
        } else if let message = HippoMessage(dict: json) {
            lastMessage = message
        }
        
        if let mutiLanguageMsg = json["multi_lang_message"] as? String{
            self.mutiLanguageMsg = MultiLanguageMsg().matchString(mutiLanguageMsg)
            if self.mutiLanguageMsg != nil{
                lastMessage?.message = self.mutiLanguageMsg ?? ""
            }
        }
        
        self.displayingMessage = getDisplayMessage()
        setTime()
    }
    
    
    func getDisplayMessage() -> String {
        let lastMessage = self.lastMessage?.message ?? ""

        var title = ""
        var end = lastMessage.trimWhiteSpacesAndNewLine()
        
        
        if lastMessage.isEmpty {
            title = HippoStrings.customer
            end = HippoStrings.sentAPhoto
        }
        
        if self.lastMessage?.senderId == AgentDetail.id {
            title = HippoStrings.you + ":"
        }
        
        if notificationType  == NotificationType.assigned || self.lastMessage?.type == .assignAgent{
            title = ""
        }
        
//        else if self.lastMessage?.userType == UserType.customer {
//            let nameArray = self.lastMessage?.senderFullName.components(separatedBy: " ") ?? []
//            let count = nameArray.count
//            let name = nameArray[0]
//            if !name.isEmpty {
//             title = count > 0 ? "\(name):" : ""
//            }
//        }
        
        if let messageObject = self.lastMessage {
            switch messageObject.type {
            case .call:
                return messageObject.getVideoCallMessage(otherUserName: "")
            case .attachment:
                end = HippoStrings.sentAFile
            case .hippoPay, .actionableMessage:
                return "Payment initiated"
            default:
                break
            }
        }
        
        let fillMessage = title + " " + end
        return title.isEmpty ? end : fillMessage
    }
    
    func setTime() {
        let givenTime = created_at ?? (date_time ?? "")
        
        guard let givenDate = givenTime.toDate else {
            return
        }
        self.lastMessageDate = givenDate
        self.formattedTime = givenDate.toString
    }
    
    
    
    func update(channelId: Int, unreadCount: Int, lastMessage: HippoMessage) {
//        self.channel_id = channelId
        self.unreadCount = unreadCount
        
        self.lastMessage = lastMessage
        self.lastMessageDate = lastMessage.creationDateTime
        self.date_time = lastMessage.creationDateTime.toUTCFormatString
        
        self.displayingMessage = getDisplayMessage()
        setTime()
    }
    
    func update(newConversation: AgentConversation) {
//                self.channel_id = channelId
        self.unreadCount = getUnreadCountFor(newConversation: newConversation)
        
        self.lastMessageDate = newConversation.lastMessage?.creationDateTime ?? Date()
        self.date_time = newConversation.lastMessage?.creationDateTime.toUTCFormatString
        self.label = getUpdatedLabelFor(newConversation: newConversation)
        self.labelId = newConversation.labelId
        self.agent_id = newConversation.agent_id
        self.agent_name = newConversation.agent_name
        self.created_at = newConversation.created_at
        self.lastMessage = newConversation.lastMessage
        self.notificationType = newConversation.notificationType
        self.isMyChat = newConversation.isMyChat ?? self.isMyChat     
        self.assigned_to = newConversation.assigned_to
        self.assigned_to_name = newConversation.assigned_to_name
        self.assigned_by = newConversation.assigned_by
        self.assigned_by_name = newConversation.assigned_by_name
        
        if let type = newConversation.notificationType, type == .assigned {
            self.agent_name = newConversation.assigned_to_name
            self.status = newConversation.chatStatus
        }
        
        self.displayingMessage = getDisplayMessage().trimWhiteSpacesAndNewLine()
        setTime()
        
        self.messageUpdated?()
    }
    override func getJsonToStore() -> [String : Any] {
        var json = super.getJsonToStore()
        
        if let channel_id = channel_id {
            if channel_id != -1 {
                json["channel_id"] = channel_id
            }
        }
        
        if let agent_id = agent_id {
            json["agent_id"] = agent_id
        }
        if let agent_name = agent_name {
            json["agent_name"] = agent_name
        }
        if let bot_channel_name = bot_channel_name {
            json["bot_channel_name"] = bot_channel_name
        }
        if let channel_name = channel_name {
            json["channel_name"] = channel_name
        }
        if let created_at = created_at {
            json["created_at"] = created_at
        }
        if let status = status {
            json["status"] = status
        }
        if let user_image = user_image {
            json["user_image"] = user_image
        }
        if let user_id = user_id {
            json["user_id"] = user_id
        }
        if let date_time = date_time {
            json["date_time"] = date_time
        }
        if let created_at = created_at {
            json["created_at"] = created_at
        }
        json["customerUserUniqueKeys"] = customerUserUniqueKeys
        if let isMyChat = self.isMyChat {
            json["is_my_chat"] = isMyChat.intValue()
        }

        return json
    }
    func getUpdatedLabelFor(newConversation: AgentConversation) -> String {
        if newConversation.label == nil {
            return self.label ?? ""
        } else if let label = newConversation.label, label.isEmpty {
            return self.label ?? ""
        } else {
            return newConversation.label ?? ""
        }
    }
    func getUnreadCountFor(newConversation: AgentConversation) -> Int {
        if let lastMessage = newConversation.lastMessage, lastMessage.isSentByMe() {
            return 0
        }
        
        let unreadCount = self.unreadCount ?? 0
        
        //Check for multiple faye and unread count
        if lastMessage?.messageUniqueID == newConversation.lastMessage?.messageUniqueID {
            return unreadCount
        }
        
        return unreadCount + newConversation.updateUnreadCountBy
    }
}


extension AgentConversation {
    class func isAssignmentNotification(for conversation: AgentConversation) -> Bool {
        guard let type = conversation.notificationType, type == .assigned else {
            return false
        }
        return true
    }
    class func isAssignedToMe(for conversation: AgentConversation) -> Bool {
        guard conversation.agent_id == HippoConfig.shared.agentDetail?.id else {
            return false
        }
        return true
    }
    class func getIndex(in conversationList: [AgentConversation], for channelId: Int) -> Int? {
        let index = conversationList.firstIndex { (ac) -> Bool in
            return ac.channel_id == channelId
        }
        return index
    }
    
    class func getConversationArray(jsonArray: [[String: Any]]) -> [AgentConversation] {
        var conversationArray = [AgentConversation]()
        for each in jsonArray {
            let object = AgentConversation(json: each)
            conversationArray.append(object)
        }
        return conversationArray
    }
}
