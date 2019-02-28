//
//  FuguMessage.swift
//  Fugu
//
//  Created by cl-macmini-117 on 06/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

class FuguMessage {
   
   static var startTyping: FuguMessage {
      return FuguMessage(typingStatus: .startTyping)
   }
   static var stopTyping: FuguMessage {
      return FuguMessage(typingStatus: .stopTyping)
   }
   static var readAllNotification: FuguMessage {
      let message = FuguMessage(message: "", type: .normal)
      message.notification = NotificationType.read_all
      return message
   }
   
   private static let userType = 1 //1 means mobile user
   
   // MARK: - Properties
   let message: String
   let senderId: Int
   let senderFullName: String
   var status: ReadUnReadStatus = .none
   var creationDateTime: Date
   var type: MessageType = .normal
   var messageUniqueID: String?
   var localImagePath: String?
   var imageUrl: String!
   var thumbnailUrl: String!
   private(set) var typingStatus: TypingMessage = .messageRecieved
   private(set) var notification: NotificationType?
   var actionableMessage: HippoActionableMessage?
   
   var wasMessageSendingFailed = false
   var isImageUploading = false
   
   // MARK: - Intializer
   init?(dict: [String: Any]) {
      guard let senderId = Int("\(dict["user_id"]!)") else {
         return nil
      }
      self.senderId = senderId
      
      message = (dict["message"] as? String) ?? ""
      
      if let dateTimeString = dict["date_time"] as? String,
         let dateTime = dateTimeString.toDate {
         creationDateTime = dateTime
      } else {
         print("Message does not contain Date Time")
         creationDateTime = Date()
      }
      
      if let rawStatus = dict["message_status"] as? Int,
         let status = ReadUnReadStatus(rawValue: rawStatus) {
         self.status = status
      }
      
      self.localImagePath = dict["image_file"] as? String
      self.imageUrl = dict["image_url"] as? String
      self.thumbnailUrl = dict["thumbnail_url"] as? String
      self.senderFullName = ((dict["full_name"] as? String) ?? "").trimWhiteSpacesAndNewLine()
      self.messageUniqueID = dict["muid"] as? String
      
      if let rawType = dict["message_type"] as? Int,
         let type = MessageType(rawValue: rawType) {
         self.type = type
      }
    
    if self.type == .actionableMessage, let actionableData = dict["custom_action"] as? [String: Any] {
        self.actionableMessage = HippoActionableMessage(dict: actionableData)
    }
      
      if !type.isMessageTypeHandled() {
         return nil
      }
      
      if let rawNotificationType = dict["notification_type"] as? Int,
         let notificationType = NotificationType(rawValue: rawNotificationType) {
         self.notification = notificationType
      }
      
      if let wasMessageSendingFailed = dict["wasMessageSendingFailed"] as? Bool {
         self.wasMessageSendingFailed = wasMessageSendingFailed
      }
      
      if let isTypingRawValue = dict["is_typing"] as? Int, let isTyping = TypingMessage(rawValue: isTypingRawValue) {
         self.typingStatus = isTyping
      }
      
      self.localImagePath = dict["localImagePath"] as? String
   }
    
    init?(convoDict: [String: Any]) {

      
      self.senderId = (convoDict["last_sent_by_id"] as? Int) ?? -1

      
      if let tempMessage = convoDict["message"] as? String {
         message = tempMessage
      } else if let tempMessage = convoDict["new_message"] as? String {
         message = tempMessage
      } else {
         message = ""
      }
      
        self.type = self.message.isEmpty ? MessageType.imageFile : MessageType.normal

      if let rawType = convoDict["message_type"] as? Int,
         let type = MessageType(rawValue: rawType) {
         self.type = type
      }
      
      self.imageUrl = convoDict["image_url"] as? String
      self.thumbnailUrl = convoDict["thumbnail_url"] as? String
      
        if let dateTimeString = convoDict["date_time"] as? String, let dateTime = dateTimeString.toDate {
            creationDateTime = dateTime
        } else {
         print("Message does not contain Date Time")
         creationDateTime = Date()
      }
        
        if let rawStatus = convoDict["last_message_status"] as? Int, let status = ReadUnReadStatus(rawValue: rawStatus) {
            self.status = status
        }
      
      let senderFullName = (convoDict["last_sent_by_full_name"] as? String) ?? ""
      self.senderFullName = senderFullName.formatName()
      
    }
   
   init(message: String, type: MessageType, uniqueID: String? = nil, imageUrl: String? = nil, thumbnailUrl: String? = nil, localFilePath: String? = nil) {
      self.message = message
      senderId = HippoConfig.shared.userDetail!.fuguUserID!
      
      let senderFullName = HippoConfig.shared.userDetail?.fullName ?? "Visitor"
      self.senderFullName = senderFullName.formatName()
      
      creationDateTime = Date()
      self.type = type
      self.messageUniqueID = uniqueID
      self.imageUrl = imageUrl
      self.thumbnailUrl = thumbnailUrl
   }
   
   private convenience init(typingStatus: TypingMessage) {
      self.init(message: "", type: .normal)
      self.typingStatus = typingStatus
   }
    
    // MARK: - Methods
    func getJsonToSendToFaye() -> [String: Any] {
      var json = [String: Any]()
      
      json["message"] = message
      json["user_id"] = senderId
      json["full_name"] = senderFullName.formatName()
      json["date_time"] = creationDateTime.toUTCFormatString
      json["is_typing"] = typingStatus.rawValue
      json["message_type"] = type.rawValue
      json["user_type"] = FuguMessage.userType
      
      if let unwrappedNotification = notification {
         json["notification_type"] = unwrappedNotification.rawValue
      }
      if let unwrappedImageUrl = imageUrl {
         json["image_url"] = unwrappedImageUrl
      }
      if let unwrappedThumbnailUrl = thumbnailUrl {
         json["thumbnail_url"] = unwrappedThumbnailUrl
      }
      if let unwrappedMessageIndex = messageUniqueID {
         json["muid"] = unwrappedMessageIndex
      }
      
      return json
    }
   
   func getDictToSaveInCache() -> [String: Any] {
      var dict = getJsonToSendToFaye()
      dict["wasMessageSendingFailed"] = wasMessageSendingFailed
      dict["message_status"] = status.rawValue
      
      if localImagePath != nil {
         dict["localImagePath"] = localImagePath!
      }
    
    if actionableMessage != nil {
        dict["custom_action"] = actionableMessage!.getDictToSaveToCache()
    }
      return dict
   }
   
   func getJsonForConversationDict() -> [String: Any] {
      var json = [String: Any]()
      
      json["message"] = message
      json["date_time"] = creationDateTime.toUTCFormatString
      json["last_sent_by_id"] = senderId
      json["last_sent_by_full_name"] = senderFullName.formatName()
      json["last_message_status"] = status.rawValue
      
      return json
   }
   
   func isANotification() -> Bool {
      
      guard message.isEmpty else {
         return false
      }
   
    if type.rawValue == MessageType.actionableMessage.rawValue  {
        return false
    }
      if let unwrappedImageUrl = thumbnailUrl, !unwrappedImageUrl.isEmpty {
         return false
      }
      
      return true
   }
   
   
   
   // MARK: - Type Methods
   static func getArrayFrom(json: [[String: Any]]) -> [FuguMessage] {
      var arrayOfMessages = [FuguMessage]()
      
      for rawMessage in json {
         if let message = FuguMessage(dict: rawMessage) {
            arrayOfMessages.append(message)
         }
      }
      
      return arrayOfMessages
   }
}


