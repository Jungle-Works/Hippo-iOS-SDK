//
//  Fugu+Enums.swift
//  Fugu
//
//  Created by Gagandeep Arora on 13/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

public enum HippoEnvironment: Int {
   case live, dev
   
   public static var selected: HippoEnvironment {
      if HippoConfig.shared.baseUrl != "https://api.fuguchat.com/" {
         return .dev
      } else {
         return .live
      }
   }
}


enum FuguCredentialType: Int {
   case defaultType, reseller
}

enum TypingMessage: Int {
   case messageRecieved = 0, startTyping = 1, stopTyping = 2
}

enum MessageType: Int {
    case none = 0, normal = 1, assignAgent = 2, privateNote = 3, imageFile = 10, actionableMessage = 12

   
   func isMessageTypeHandled() -> Bool {
      switch self {
      case .normal, .imageFile, .actionableMessage:
         return true
      default:
         return false
      }
   }
}

enum ChatType: Int {
   case p2p = 1
   case other = 0
}

enum FuguUserIntializationError: LocalizedError {
   case invalidAppSecretKey
   case invalidResellerToken
   case invalidReferenceId
   case invalidUserUniqueKey
   
   var errorDescription: String? {
      switch self {
      case .invalidAppSecretKey:
         return "Invalid App Secret Key"
      case . invalidResellerToken:
         return "Invalid reseller Token"
      case .invalidReferenceId:
         return "Invalid Reference ID"
      case .invalidUserUniqueKey:
         return "Invalid User Unique Key"
      }
   }
}

enum ReadUnReadStatus: Int { case none = 0, sent, delivered, read }

enum StatusCodeValue: Int {
    case Authorized_Min = 200
    case Authorized_Max = 300
    case Bad_Request = 400
    case Unauthorized = 401 //INCORRECT_PASSWORD
    case invalidToken = 403 //INVALID_TOKEN
}

enum NotificationType: Int {
    case assigned = 3
    case read_unread = 5
    case read_all = 6
}

enum ActionType: Int {
    case CATEGORY = 0
    case LIST = 1
    case CHAT_SUPPORT = 2
    case DESCRIPTION = 3
    case SHOW_CONVERSATION = 4
}


enum ButtonType: String {
    case none = ""
    case submit = "submit_button"
    case call = "call_button"
    case conversation = "chat_button"
}
enum ViewType: Int {
    case list = 2
    case description = 1
}
enum FuguEndPoints: String {
    case API_PUT_USER_DETAILS = "api/users/putUserDetails"
    case API_GET_CONVERSATIONS = "api/conversation/getConversations"
    case API_GET_MESSAGES = "api/conversation/getMessages"
    case API_CREATE_CONVERSATION = "api/conversation/createConversation"
    case API_GET_MESSAGES_BASED_ON_LABEL = "api/conversation/getByLabelId"
    case API_CLEAR_USER_DATA_LOGOUT = "api/users/userlogout"
    case API_Reseller_Put_User = "api/reseller/putUserDetails"
    case API_UPLOAD_FILE = "api/conversation/uploadFile"
    case API_CHECK_SEND_REQUEST_MONEY = "chat/payments/metadata"
    case API_CREATE_TICKET = "api/support/createConversation"
    case API_GET_SUPPORT_DATA = "api/business/getBusinessSupportPanel"
}
