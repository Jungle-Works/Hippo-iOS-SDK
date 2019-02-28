//
//  FuguConversation.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 21/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

class FuguConversation {
    
    let channelId: Int?
   var unreadCount: Int? {
      didSet {
         if (unreadCount ?? 0) > 0 {
            channelStatus = .open
         }
      }
   }
    var channelImage: String?
    var channelStatus: ChannelStatus = .close
    
    var label: String?
    var labelId: Int?
    var defaultMessage: String?
    var transactionId: String? = nil
    var chatType: Int? = nil
    var lastMessage: FuguMessage?
   
   init?(channelId: Int, unreadCount: Int, lastMessage: FuguMessage) {
      guard channelId > 0 else {
         return nil
      }
      
      self.channelId = channelId
      self.unreadCount = unreadCount
      self.lastMessage = lastMessage
   }
    
    init?(conversationDict: [String: Any]) {
        if let channel_status = conversationDict["channel_status"] as? Int, let channelStatus = ChannelStatus(rawValue: channel_status) {
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
        
        if let label = conversationDict["label"] as? String {
            self.label = label
        }
        if let default_message = conversationDict["default_message"] as? String {
            self.defaultMessage = default_message
        }
        if let channel_image = conversationDict["channel_image"] as? String {
            self.channelImage = channel_image
        }
        
        if let transaction_id = conversationDict["transaction_id"] as? String {
            self.transactionId = transaction_id
        }
        
        if let chat_type = conversationDict["chat_type"] as? Int {
            self.chatType = chat_type
        } else {
             self.chatType = 0
        }
        
        if let message = FuguMessage.init(convoDict: conversationDict) {
            self.lastMessage = message
        }
    }
   
   func getDictionary() -> [String: Any] {
      var params = [String: Any]()
      
      params["channel_status"] = channelStatus.rawValue
      params["label_id"] = labelId ?? -1
      
      params["unread_count"] = unreadCount ?? 0
      params["channel_id"] = channelId ?? "-1"
      params["label"] = label ?? ""
      
      params["default_message"] = defaultMessage ?? ""
      params["channel_image"] = channelImage ?? ""
      
      if let messageJson = lastMessage?.getJsonForConversationDict() {
         params += messageJson
      }
      
      return params
   }
   
   static func getAllConversationFromServer(completion: @escaping (_ result: GetConversationFromServerResult) -> Void) {
      
      let params = getParamsToGetAllConversation()
      
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
         
         let result = GetConversationFromServerResult(isSuccessful: true, error: nil, conversations: arrayOfConversation)
         completion(result)
      }
   }
      
   private static func getParamsToGetAllConversation() -> [String: Any] {
      var params = [String: Any]()
      
      params["app_secret_key"] = HippoConfig.shared.appSecretKey
      params["en_user_id"] = HippoConfig.shared.userDetail?.fuguEnUserID ?? "-1"
      
      return params
   }
   
   static func getConversationArrayFrom(json: [[String: Any]]) -> [FuguConversation] {
      var arrayOfConversation = [FuguConversation]()
      
      for rawConversation in json {
         if let conversation = FuguConversation(conversationDict: rawConversation) {
            if (conversation.unreadCount ?? 0) > 0 {
               conversation.channelStatus = .open
            }
            arrayOfConversation.append(conversation)
         }
      }
      
      return arrayOfConversation
   }
   
   static func getJsonFrom(conversations: [FuguConversation]) -> [[String: Any]] {
      var arrayOfDict = [[String: Any]]()
      
      for conv in conversations {
         let convDict = conv.getDictionary()
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
