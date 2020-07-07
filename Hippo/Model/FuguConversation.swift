//
//  FuguConversation.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 21/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit

class FuguConversation: HippoConversation {
    
    var channelImage: String?
    var defaultMessage: String?
    var mutiLanguageMsg : String?
    
    init?(channelId: Int, unreadCount: Int, lastMessage: HippoMessage, labelID: Int?) {
        guard channelId > 0 else {
            return nil
        }
        super.init()
        self.labelId = labelID
        self.channelId = channelId
        self.unreadCount = unreadCount
        self.lastMessage = lastMessage
    }
    
    init?(conversationDict: [String: Any]) {
        super.init()
        
        if let mutiLanguageMsg = conversationDict["multi_lang_message"] as? String{
            self.mutiLanguageMsg = MultiLanguageMsg().matchString(mutiLanguageMsg) 
        }
        
        if let channel_status = conversationDict["channel_status"] as? Int, let channelStatus = ChatStatus(rawValue: channel_status) {
            self.channelStatus = channelStatus
        }
        if let label_id = conversationDict["label_id"] as? Int {
            self.labelId = label_id
        }
        
        if let unread_count = conversationDict["unread_count"] as? Int {
            unreadCount = unread_count
        }
        if let channel_id = conversationDict["channel_id"] as? Int, channel_id > 0 {
            self.channelId = channel_id
        } else {
            self.channelId = nil
        }
        
        if let rawChatType = Int.parse(values: conversationDict, key: "chat_type"), let parsedChatType = ChatType(rawValue: rawChatType) {
            self.chatType = parsedChatType
        }
        
        if let channel_image_url = conversationDict["channel_image_url"] as? String {
            channelImageUrl = channel_image_url
        }
        if let label = conversationDict["label"] as? String {
            self.label = label
        }
        self.channelBackgroundColor = UIColor.hexStringToUIColor(hex: material[getColor(char: label?.initials ?? "")])
        
        if let default_message = conversationDict["default_message"] as? String {
            self.defaultMessage = default_message
        }
        if let channel_image = conversationDict["channel_image"] as? String {
            self.channelImage = channel_image
        }
        
        if let message = HippoMessage.init(convoDict: conversationDict) {
            self.lastMessage = message
        } else if let message = HippoMessage(dict: conversationDict) {
            self.lastMessage = message
        }
        //For default channel
        if channelId == nil, let otherLanguageDic = conversationDict["channel_other_lang_data"] as? [String : Any]{
            self.lastMessage?.message = otherLanguageDic["channel_message"] as? String ?? conversationDict["message"] as? String ?? self.lastMessage?.message ?? ""
            self.label = otherLanguageDic["channel_name"] as? String ?? conversationDict["label"] as? String
        }else if channelId == nil {
            self.lastMessage?.message = conversationDict["message"] as? String ?? self.lastMessage?.message ?? ""
        }
        
        if self.mutiLanguageMsg != nil{
            self.lastMessage?.message = mutiLanguageMsg ?? ""
        }
        
    }
    
    override func getJsonToStore() -> [String: Any] {
        var params = super.getJsonToStore()
        
        params["default_message"] = defaultMessage ?? ""
        params["channel_image"] = channelImage ?? ""
        
        return params
    }
    
    static func getAllConversationFromServer(config: AllConversationsConfig, completion: @escaping (_ result: GetConversationFromServerResult) -> Void) {
        
        let params = getParamsToGetAllConversation(config: config)
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_GET_CONVERSATIONS.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode,
                let response = responseObject as? [String: Any],
                let data = response["data"] as? [String: Any],
                let conversationArrayJson = data["conversation_list"] as? [[String: Any]],
                unwrappedStatusCode == STATUS_CODE_SUCCESS else {
                    let result = GetConversationFromServerResult(isSuccessful: false, error: error, conversations: nil)
                    
                    completion(result)
                    return
            }
            
            FuguDefaults.set(value: conversationArrayJson, forKey: DefaultName.conversationData.rawValue)
            let arrayOfConversation = getConversationArrayFrom(json: conversationArrayJson)
            
            if let lastVisibleController = getLastVisibleController() as? ConversationsViewController, let channelId = lastVisibleController.channel?.id {
                lastVisibleController.clearUnreadCountForChannel(id: channelId)
            }

            let result = GetConversationFromServerResult(isSuccessful: true, error: HippoError.general, conversations: arrayOfConversation)
            completion(result)
        }
    }
    
    private static func getParamsToGetAllConversation(config: AllConversationsConfig) -> [String: Any] {
        var params = [String: Any]()
        
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["en_user_id"] = HippoUserDetail.fuguEnUserID ?? "-1"
        
        if !config.enabledChatStatus.isEmpty {
            params["status"] = config.getChatStatusToSend()
        }
        
        return params
    }
    
    static func getConversationArrayFrom(json: [[String: Any]]) -> [FuguConversation] {
        var arrayOfConversation = [FuguConversation]()
        
        for rawConversation in json {
            if let conversation = FuguConversation(conversationDict: rawConversation) {
                if (conversation.unreadCount ?? 0) > 0 {
//                    conversation.channelStatus = .open
                }
                arrayOfConversation.append(conversation)
            }
        }
        
        return arrayOfConversation
    }
    
    static func getJsonFrom(conversations: [FuguConversation]) -> [[String: Any]] {
        var arrayOfDict = [[String: Any]]()
        
        for conv in conversations {
            let convDict = conv.getJsonToStore()
            arrayOfDict.append(convDict)
        }
        
        return arrayOfDict
    }
    
    
}

struct GetConversationFromServerResult {
    let isSuccessful: Bool
    let error: Error?
    let conversations: [FuguConversation]?
}
