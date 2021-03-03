//
//  Fugu+Enums.swift
//  Fugu
//
//  Created by Gagandeep Arora on 13/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

@available(*, deprecated, renamed: "HippoEnvironment", message: "This Enum is renamed to HippoEnvironment")
public enum FuguEnvironment: Int {
   case live, dev, beta
   
   public static var selected: FuguEnvironment {
      if HippoConfig.shared.baseUrl != SERVERS.liveUrl {
        return HippoConfig.shared.baseUrl  == SERVERS.betaUrl ? .beta : .dev
      } else {
         return .live
      }
   }
}
public enum HippoEnvironment: Int {
    case live, dev, beta
    
    public static var selected: HippoEnvironment {
        if HippoConfig.shared.baseUrl != SERVERS.liveUrl {
            return HippoConfig.shared.baseUrl  == SERVERS.betaUrl ? .beta : .dev
        } else {
            return .live
        }
    }
}

enum ChatStatus: Int, CaseCountable {
    case open = 1
    case close = 2
}

enum FuguCredentialType: Int {
   case defaultType, reseller
}

enum TypingMessage: Int {
   case messageRecieved = 0, startTyping = 1, stopTyping = 2
}



enum channelType: Int {
    case DEFAULT_CHANNEL = 2
    case DEFAULT = 4
    case HELP_CHANNEL = 5
    case BROADCAST_CHANNEL = 6
    case SUPPORT_CHAT_CHANNEL = 9
}

enum SourceType: Int {
    case DEFAULT = 0
    case SDK = 1
    case AGENT_APP = 2
    case WEB = 3
    case WIDGET = 4
    case INTEGRATION = 5
    case OUTREACH = 6
}

enum PaymentPlanType: Int {
    case agentPlan = 1
    case businessPlan = 2
}

enum IntegrationSource: Int {
    case normal = 0
    case email = 5
    case facebook = 6
    case sms = 7
    case whatsApp = 9
    
    func getIcon() -> UIImage? {
        switch self {
        case .facebook:
            return HippoConfig.shared.theme.facebookSourceIcon
        case .email:
            return HippoConfig.shared.theme.emailSourceIcon
        case .sms:
            return HippoConfig.shared.theme.smsSourceIcon
        case .whatsApp:
            return HippoConfig.shared.theme.whatsappIcon
        case .normal:
            return nil
        }
    }
}

enum SocketEvent : String{
    case HANDSHAKE_CHANNEL = "/socketio/handshake"
    case SUBSCRIBE_USER = "/socketio/subscribe/user" //
    case UNSUBSCRIBE_USER = "/socketio/unsubscribe/user"
    case SUBSCRIBE_CHAT = "/socketio/subscribe/chat" //active channel
    case UNSUBSCRIBE_CHAT = "/socketio/unsubscribe/chat"
    case MESSAGE_CHANNEL = "/socketio/message"
    case SERVER_PUSH = "/socketio/server/push"
}

enum FilterOptionSection: Int, CaseCountable {
//    case people = 0
    case status
//    case chatType
//    case channels
//    case labels
//    case agents
//    case date
}
struct FilterField {
    var nameOfField: String = ""
    var selected: Bool = false
    var isAnyImage: Bool = true
    var isSectionTitle: Bool = false
    var id: Int = -1
    
    init(nameOfField: String, isAnyImage: Bool = true, selected: Bool = false, isSectionTitle: Bool = false) {
        self.nameOfField = nameOfField
        self.selected = selected
        self.isAnyImage = isAnyImage
        self.isSectionTitle = isSectionTitle
    }
    init(data: labelWithId) {
        self.nameOfField = data.label
        self.selected = data.isSelected
        self.id = data.id
    }
//    init(data: ChannelDetail) {
//        self.nameOfField = data.channelName
//        self.selected = data.isSelected
//        self.id = data.id
//    }
//    init(data: TagDetail) {
//        isSectionTitle = false
//        self.nameOfField = data.tagName ?? ""
//        self.selected = data.isSelected
//        self.id = data.tagId ?? -1
//    }
//    init(data: Agent, selectedAgentID: [Int]) {
//        isSectionTitle = false
//        self.nameOfField = data.fullName ?? ""
//        self.selected = false
//        self.id = data.userId ?? data.inviteId ?? -1
//
//        if id > 0 {
//            self.selected = selectedAgentID.contains(id)
//        }
//    }
}
struct labelWithId {
    var label: String
    var id: Int
    var isSelected: Bool
    
    init(label: String, id: Int, isSelected: Bool = false) {
        self.label = label
        self.id = id
        self.isSelected = isSelected
    }
}

enum MessageType: Int {
    case none = 0, normal = 1, assignAgent = 2, privateNote = 3, imageFile = 10, attachment = 11, actionableMessage = 12, feedback = 14, botText = 15, quickReply = 16, leadForm = 17, call = 18, hippoPay = 19, consent = 20, card = 21, paymentCard = 22, multipleSelect = 23, embeddedVideoUrl = 24, groupCall = 27//, address = 25, dateTime = 26

    
//    BUSINESS_SPECIFIC_MESSAGE : 4,
//    PUBLIC_NOTE : 5,
//    SUPPORT_MESSAGE : 13,
   
    
    var customerHandledMessages: [MessageType] {
        return [.normal, .imageFile, .feedback, .actionableMessage, .leadForm, .quickReply, .botText, .call, .hippoPay, .attachment, .consent, .card, .paymentCard , .multipleSelect, .embeddedVideoUrl]//, .address, .dateTime]
    }
    var agentHandledMessages: [MessageType] {
//        return [.normal, .imageFile, .privateNote, .assignAgent, .botText, .call, .attachment, .consent, .actionableMessage, .hippoPay]
        return [.normal, .imageFile, .privateNote, .assignAgent, .botText, .call, .attachment, .consent, .actionableMessage, .hippoPay, .feedback, .leadForm, .quickReply, .paymentCard, .multipleSelect, .embeddedVideoUrl]
    }
   
    func isMessageTypeHandled() -> Bool {
        let typeHandled = HippoConfig.shared.appUserType == .agent ? agentHandledMessages : customerHandledMessages
        return typeHandled.contains(self)
    }
    
    var isBotMessage: Bool {
        
//        let botMessages: [MessageType] = [.leadForm, .quickReply, .botText, .consent, .hippoPay, .actionableMessage]
////        let botMessages: [MessageType] = [.leadForm, .quickReply, .botText, .consent, .card , .multipleSelect,.normal]
        
//        let botMessages: [MessageType] = [.leadForm, .quickReply, .botText, .consent, .hippoPay, .actionableMessage, .card , .multipleSelect, .embeddedVideoUrl]//, .address, .dateTime]
        let botMessages: [MessageType] = [.leadForm, .quickReply, .botText, .consent, .hippoPay, .actionableMessage, .card , .multipleSelect, .normal, .embeddedVideoUrl, .paymentCard]//, .address, .dateTime]

        return botMessages.contains(self)
    }
}


enum ChatType: Int {
    case none = -1
    case other = 0
    case p2p = 1
    case o2o  = 2
    case privateGroup = 3
    case publicGroup  = 4
    case generalChat = 5
    
    var isImageViewAllowed: Bool {
//        guard HippoConfig.shared.appUserType == .customer else {
        guard HippoConfig.shared.appUserType == .customer || HippoConfig.shared.appUserType == .agent else {
            return false
        }
        return ChatType.allowedImageViewFor.contains(self)
    }
    
    private static let allowedImageViewFor: [ChatType] = [.other, .o2o]
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

enum ReadUnReadStatus: Int {
    case none = 0, sent, delivered, read
    
    func getIcon() -> UIImage? {
        switch self {
        case .none:
            return HippoConfig.shared.theme.unsentMessageIcon
        case .read, .delivered:
            return HippoConfig.shared.theme.readMessageTick
        case .sent:
            return HippoConfig.shared.theme.unreadMessageTick
        }
    }
}

enum responseKeyboardType: String{
    case none = "NONE"
    case numberKeyboard = "NUMBER"
    case defaultKeyboard = "DEFAULT"
}




enum StatusCodeValue: Int {
    case Authorized_Min = 200
    case Authorized_Max = 300
    case Bad_Request = 400
    case Unauthorized = 401 //INCORRECT_PASSWORD
    case invalidToken = 403 //INVALID_TOKEN
}

enum NotificationType: Int {
    case none = 0
    case message = 1
    case assigned = 3
    case tagged = 4
    case readUnread = 5
    case readAll = 6
    case userMigration
    case userLogout = 8
    case agentsRefresh = 10
    case agentRefresh = 11
    case markConversation = 12
    case channelRefreshed = 13
    case call = 14
    case messageModified = 24
    case channelRefresh = 17
    
    var isNotificationTypeHandled: Bool {
        switch self {
//        case .message, .assigned, .readAll:
        case .message, .assigned, .readAll, .channelRefresh:
            return true
        default:
            return false
        }
    }
    var rejectOnActive: Bool {
        let rejectionList: [NotificationType] = rejectNotifcationActiveChannelList()
        return rejectionList.contains(self)
    }
    
    func rejectNotifcationActiveChannelList() -> [NotificationType] {
        let customerRejectionList: [NotificationType] = [.assigned, .tagged]
        let agentRejectionList: [NotificationType] = []
        switch HippoConfig.shared.appUserType {
        case .agent:
            return agentRejectionList
        case .customer:
            return customerRejectionList
            
        }
    }
}

enum UserType: Int {
    case none = -1
    case system = 0 //System Generated message
    case customer = 1 //Customer
    case agent = 2 //For web as well mobile app
    
    var isMyUserType: Bool {
        switch self {
        case .none, .system, .agent:
            return HippoConfig.shared.appUserType == .agent
        default:
            return HippoConfig.shared.appUserType == .customer
        }
    }
}


public enum CallType: String {
    case audio = "AUDIO"
    case video = "VIDEO"
}

enum ActionType: Int {
    case CATEGORY = 0
    case LIST = 1
    case CHAT_SUPPORT = 2
    case DESCRIPTION = 3
    case SHOW_CONVERSATION = 4
}

enum ConversationType {
    case myChat
    case allChat
    case o2oChat
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

enum UserSubscriptionStatus: Int {
    case notSubscribed = 0, subscribed
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
    case API_CREATE_TICKET = "api/support/createConversation"
    case API_FEEDBACK = "api/deal/feedback"
    case updateRideStatus = "api/users/inRideStatus"
    case fetchP2PUnreadCount = "api/conversation/fetchP2PUnreadCount"
    case makeSelectedPayment = "api/payment/makeSelectedPayment"
    case getInfoV2 = "api/agent/v1/getInfo"
    case getPaymentGateway = "api/payment/getPaymentGateway"
    case getPrePayment = "api/conversation/createOperationalChannel"
    case getLanguage = "api/apps/fetchAppLanguageData"
    case updateLanguage = "api/apps/updateUserLanguage"
    case createAgentConversation = "api/conversation/createAgentSupportChannel"
    case getUploadFileUrl = "api/conversation/getUploadFile"
    case getAndUpdateAnnouncement = "api/broadcast/getAndUpdateAnnouncement"
}

enum AgentEndPoints: String {
    case conversationUnread = "api/conversation/getAgentTotalUnreadCount"
    case getAgentLoginInfo = "api/agent/getAgentLoginInfo"
    case loginViaAuthToken = "api/agent/v1/agentLoginViaAuthToken"
    case loginViaToken = "api/agent/v1/agentLogin"
//    case getConversation = "api/conversation/v1/getConversations"
    case getConversation = "api/conversation/v2/getConversations"
    case markConversation = "api/conversation/markConversation"
    case logout = "api/agent/agentLogout"
    case getUnreadCount = "api/conversation/get_customer_unread_count"
//    case getUnreadCount = "api/conversation/getUnreadCount"
    case createConversation = "api/conversation/createConversation"
    
    //Broadcasting
    case getGroupingTag = "api/broadcast/getGroupingTag"
    case sendBroadcastMessage = "api/broadcast/sendBroadcastMessage"
    case getBroadcastList = "api/broadcast/getBroadcastList"
    case broadcastStatus = "api/broadcast/broadcastStatus"
    case getAnnouncements = "api/broadcast/getAnnouncements"
    case createOneToOneChat = "api/chat/createOneToOneChat"
    
    case clearAnnouncements = "api/broadcast/clearAnnouncements"
    
    case assignAgent = "api/agent/assignAgent"
    case agentStatus = "api/agent/editInfo"
    
    case sendPayment = "api/payment/sendPaymentUrl"
//    case serverGetConfig = "api/apps/getConfig"
    case getPaymentPlans = "api/agent/getPaymentPlans"
    case editPaymentPlans = "api/agent/editPaymentPlans"
    case getBotActions = "api/agent/getAllBotActions"
    case getAgents = "api/agent/getAgents"
    case createGroupCallChannel = "api/conversation/createGroupCallChannel"
    case getGroupCallChannelDetals = "api/conversation/getGroupCallChannelDetails"
    case editDeleteMessage = "api/conversation/deleteOrEditMessage"
    case getAgentSupportChannelListing = "api/conversation/getAgentSupportChannels"
    case getAgentInfo = "api/users/getUserDetails"
    case getTemplates = "api/business/getTemplates"
    case createAndSendPresciption = "api/conversation/createAndSendPrescription"
}

struct MultiLanguageMsg{
    
    //MARK:- Variables
 
    //MARK:- Functions
    private func getMultiLanguageMsg(_ tag : String) -> String{
        switch tag{
        case MultiLanguageTags.RATING_AND_REVIEW.rawValue:
            return HippoStrings.ratingReview
        case MultiLanguageTags.PAYMENT_REQUESTED.rawValue:
            return HippoStrings.paymentRequested
        case MultiLanguageTags.ASSIGNED_TO_THEMSELVES.rawValue:
            return HippoStrings.assignedToThemselves
        case MultiLanguageTags.NEW_CHAT_ASSIGNED_TO_YOU.rawValue:
            return HippoStrings.newChatAssignedToYou
        case MultiLanguageTags.ASSIGNED_CHAT_TO.rawValue:
            return HippoStrings.chatAssigned
        case MultiLanguageTags.CHAT_REOPENED_BY.rawValue:
            return HippoStrings.chatReopenedby
        case MultiLanguageTags.CHAT_WAS_AUTO_OPENED.rawValue:
            return HippoStrings.chatAutoOpened
        case MultiLanguageTags.CHAT_WAS_AUTO_CLOSED.rawValue:
            return HippoStrings.chatAutoClosed
        case MultiLanguageTags.CHAT_WAS_RE_OPENED.rawValue:
            return HippoStrings.chatReopened
        case MultiLanguageTags.CHAT_WAS_CLOSED.rawValue:
            return HippoStrings.chatClosedBy
        case MultiLanguageTags.WAS_AUTO_ASSIGNED.rawValue:
            return HippoStrings.chatAutoAssigned
        case MultiLanguageTags.WAS_FORCE_ASSIGNED.rawValue:
            return HippoStrings.forceAssigned
        case MultiLanguageTags.TAGGED.rawValue:
            return HippoStrings.tagged
        case MultiLanguageTags.MENTIONED_YOU.rawValue:
            return HippoStrings.mentionedYou
        case MultiLanguageTags.CALLING_YOU.rawValue:
            return HippoStrings.isCallingYou
        case MultiLanguageTags.newCustomer.rawValue:
            return HippoStrings.newCustomer
        case MultiLanguageTags.botSkipped.rawValue:
            return HippoStrings.botSkipped
        case MultiLanguageTags.missedCallFrom.rawValue:
            return HippoStrings.missedCallFrom
        case MultiLanguageTags.fileImage.rawValue:
            return HippoStrings.sentAPhoto
        case MultiLanguageTags.fileAttachment.rawValue:
            return HippoStrings.sentAFile
            
        default:
            return ""
        }
    }
    
    func matchString(_ str : String) -> String{
        let tag = MultiLanguageTags.allCases.filter{str.contains($0.rawValue)}
        let replacementStr = self.getMultiLanguageMsg(tag.first?.rawValue ?? "")
        return str.replacingOccurrences(of: tag.first?.rawValue ?? "", with: " " + replacementStr, options: .caseInsensitive, range: nil)
    }
}

enum MultiLanguageTags : String, CaseIterable{
    case RATING_AND_REVIEW = "{{{RATING_AND_REVIEW}}}"
    case PAYMENT_REQUESTED = "{{{PAYMENT_REQUESTED}}}"
    case ASSIGNED_TO_THEMSELVES = "{{{ASSIGNED_TO_THEMSELVES}}}"
    case NEW_CHAT_ASSIGNED_TO_YOU = "{{{NEW_CHAT_ASSIGNED_TO_YOU}}}"
    case ASSIGNED_CHAT_TO = "{{{ASSIGNED_CHAT_TO}}}"
    case CHAT_REOPENED_BY = "{{{CHAT_REOPENED_BY}}}"
    case CHAT_WAS_AUTO_OPENED = "{{{CHAT_WAS_AUTO_OPENED}}}"
    case CHAT_WAS_AUTO_CLOSED = "{{{CHAT_WAS_AUTO_CLOSED}}}"
    case CHAT_WAS_RE_OPENED = "{{{CHAT_WAS_RE_OPENED}}}"
    case CHAT_WAS_CLOSED = "{{{CHAT_WAS_CLOSED}}}"
    case WAS_AUTO_ASSIGNED = "{{{WAS_AUTO_ASSIGNED}}}"
    case WAS_FORCE_ASSIGNED = "{{{WAS_FORCE_ASSIGNED}}}"
    case TAGGED = "{{{TAGGED}}}"
    case MENTIONED_YOU = "{{{MENTIONED_YOU}}}"
    case CALLING_YOU = "{{{CALLING_YOU}}}"
    case newCustomer = "{{{NEW_CUSTOMER}}}"
    case botSkipped = "{{{BOT_SKIPPED_FOR_THIS_SESSION}}}"
    case missedCallFrom = "{{{MISSED_CALL_FROM}}}"
    case fileImage = "{{{FILE_IMAGE}}}"
    case fileAttachment = "{{{FILE_ATTACHMENT}}}"
}
      
        
enum BroadcastType: String, CaseCountable {
    case unknown = ""
    case none = "Broadcast"
    case tookan = "TOOKAN"
    case inApp = "IN_APP"
    case email = "EMAIL"
    
    var description: String {
        switch self {
        case .email:
            return HippoStrings.email
        case .unknown:
            return ""
        default:
            return HippoStrings.inApp
        }
    }
}

enum MessageState : Int{
    case Call = 2
    case MessageDeleted = 4
    case MessageEdited = 5
}


enum FileType: String {
    case image = "image"
    case audio = "audio"
    case video = "video"
    case document = "file"
    
    init(mimeType: String) {
        let prefix = mimeType.components(separatedBy: "/").first ?? "application"
        
        switch prefix {
        case "audio":
            self = FileType.audio
        case "video":
            self = FileType.video
        case "image":
            self = FileType.image
        default:
            self = FileType.document
        }
    }
    
    func getTypeString() -> String {
        switch self {
        case .image:
            return HippoStrings.image
        case .audio:
            return HippoStrings.audio
        case .video:
            return HippoStrings.video
        case .document:
            return HippoStrings.document
        }
    }
}
