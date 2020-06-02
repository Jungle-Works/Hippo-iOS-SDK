//
//  FuguChat.swift
//  Fugu
//
//  Created by cl-macmini-117 on 03/11/17.
//

import Foundation

struct FuguNewChatAttributes {
   static var defaultChat: FuguNewChatAttributes {
      let userId = HippoConfig.shared.userDetail?.userUniqueKey ?? ""
      return FuguNewChatAttributes(transactionId: "7865", userUniqueKey: userId, channelName: "", preMessage: "")
   }
   var transactionId: String?
   var userUniqueKey: String?
   var otherUniqueKey: [String]?
   var tags: [String]?
   var channelName: String?
   var preMessage = ""
   var isInAppChat = false
   var isCustomAttributesRequired: Bool = false
   var customAttributes = [String: Any]()
   var hideBackButton: Bool = false
    
   private var fuguChatType = ChatType.other
   var groupingTag: [String]?
   var botGroupId: String?
    
    
   
    init(transactionId: String, userUniqueKey: String? = nil, otherUniqueKey: [String]? = nil, tags: [String]? = nil, channelName: String? = nil, preMessage: String = "", groupingTag: [String]? = nil) {
      
      self.transactionId = transactionId
      self.userUniqueKey = userUniqueKey
      self.otherUniqueKey = otherUniqueKey
      self.tags = tags
      self.channelName = channelName
      self.preMessage = preMessage
      self.groupingTag = groupingTag
        
      let otherUserCount = otherUniqueKey?.count ?? 0
      self.fuguChatType = otherUserCount == 0 ? .other : .p2p
   }
   
   func getParamsToStartNewChat() -> [String: Any] {
      var params = [String: Any]()
      
      if let tempTransactionId = transactionId, !tempTransactionId.isEmpty {
         params["transaction_id"] = tempTransactionId
      }
      
      if let tempUserUniqueKey = userUniqueKey, !tempUserUniqueKey.isEmpty {
         params["user_unique_key"] = tempUserUniqueKey
      }
      
      if let tempOtherUniquekey = otherUniqueKey {
         params["other_user_unique_key"] = tempOtherUniquekey
      }
      
      if let tempTags = tags {
         params["tags"] = tempTags
      }
      
      if let tempChannelName = channelName, !tempChannelName.isEmpty {
         params["custom_label"] = tempChannelName
      }
      
      if isPreMessageValid() {
         let messageToSend = [preMessage]
         params["user_first_messages"] = messageToSend
      }
    
    if let botGroupId = self.botGroupId {
        params["initiate_bot_group_id"] = botGroupId
    }
      params["chat_type"] = fuguChatType.rawValue
      
      return params
   }
   
   private func isPreMessageValid() -> Bool {
      let messageAfterRemovingWhiteSpaces =  preMessage.replacingOccurrences(of: " ", with: "")
      let messageAfterTrimmingWhiteSpaces = messageAfterRemovingWhiteSpaces.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      return messageAfterTrimmingWhiteSpaces.count != 0
   }
   
   static func isValidTransactionID(id: String) -> Bool {
      guard !id.isEmpty, id != "0", id != "-1" else {
            return false
      }
      
      return true
   }
}
