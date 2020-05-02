//
//  HippoMessage.swift
//  Fugu
//
//  Created by cl-macmini-117 on 06/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

class MessageCallbacks {
    var statusChanged: (() -> Void)? = nil
    var feedbackUpdated: (() -> Void)? = nil
    var leadFormUpdated: (() -> Void)? = nil
    var sendingStatusUpdated: (() -> Void)? = nil
    var messageRefresed: (() -> Void)? = nil
}


protocol FuguPublishable {
    func getJsonToSendToFaye() -> [String: Any]
}


class HippoMessage: MessageCallbacks, FuguPublishable {
    
    
    static var startTyping: HippoMessage {
        return HippoMessage(typingStatus: .startTyping)
    }
    static var stopTyping: HippoMessage {
        return HippoMessage(typingStatus: .stopTyping)
    }
    static var readAllNotification: HippoMessage {
        let message = HippoMessage(message: "", type: .normal, chatType: nil)
        message.notification = NotificationType.readAll
        return message
    }
    
//    private static let userType = 1 //1 means mobile user
    
    // MARK: - Properties
    var cellDetail: HippoCellDetail?
    var message: String
    var senderId: Int
    var senderFullName: String
    
    var status: ReadUnReadStatus = .none {
        didSet {
            statusChanged?()
        }
    }
    var senderImage: String?
    var creationDateTime: Date
    var type: MessageType = .none
    var messageUniqueID: String?
    var localImagePath: String?
    var imageUrl: String!
    var thumbnailUrl: String!
    private(set) var typingStatus: TypingMessage = .messageRecieved
    private(set) var notification: NotificationType?
    var actionableMessage: FuguActionableMessage?
    var userType: UserType = currentUserType()
    var attributtedMessage = MessageUIAttributes(message: "", senderName: "", isSelfMessage: false)
    var chatType: ChatType = .other
    var keyboardType: responseKeyboardType = .defaultKeyboard
    
    var wasMessageSendingFailed = false {
        didSet {
            sendingStatusUpdated?()
        }
    }
    var isDeleted = false
    
    //MARK: Bot variables
    var feedbackMessages = FeedbackMessage(json: [:])
    var defaultActionId: String?
    var is_rating_given = false {
        didSet {
            feedbackUpdated?()
        }
    }
    var total_rating = 0
    var rating_given = 0
    var comment = ""
    var messageId: Int?
    var botFormMessageUniqueID: String?
    var values: [String] = []
    var contentValues: [[String: Any]] = []
    var selectedActionId: String = ""
    var leadsDataArray = [FormData]() {
        didSet {
            leadFormUpdated?()
        }
    }
    var content = MessageContent()
    var isQuickReplyEnabled: Bool = true
    
    var isMissedCall = false
    
    var callDurationInSeconds: TimeInterval?
    var callType = CallType.video
    var messageSource: IntegrationSource = .normal
    var customAction :CustomAction?
    var fileUrl: String?
    var fileName: String?
    var fileSize: String?
    var documentType: FileType?
    
    var isFileUploading: Bool = false
    var imageWidth : Float?
    var imageHeight : Float?
    var parsedMimeType: String?
    
    var rawJsonToSend: [String: Any]?
    
    //MARK: Referncing detail
    var aboveMessageMuid: String?
    var belowMessageMuid: String?
    var aboveMessageUserId: Int?
    var belowMessageUserId: Int?
    var aboveMessageType: MessageType?
    var belowMessageType: MessageType?

   
  
    var cards: [HippoCard]?
    var selectedCardId: String?
    var selectedCard: HippoCard?
    var fallbackText: String?
    //
    var isActive: Bool = true
    var isSkipBotEnabled: Bool = false
    var isSkipEvent: Bool = false
    var isFromBot: Int?
    
    var mimeType: String? {
        guard parsedMimeType == nil else {
            return parsedMimeType
        }
        let type: String?
        if localImagePath != nil {
            type = localImagePath?.mimeTypeForPath()
        } else if fileUrl != nil {
            type = fileUrl?.mimeTypeForPath()
        } else if imageUrl != nil {
            type = imageUrl!.mimeTypeForPath()
        } else {
            type = nil
        }
        parsedMimeType = type
        return parsedMimeType
    }
    var concreteFileType: FileType? {
        guard documentType == nil else {
            return documentType
        }
        let mimeType = self.mimeType
        
        if isUnhandledType() {
            documentType = .document
            return documentType
        }
        
        guard self.fileUrl != nil else {
            if mimeType != nil {
                documentType = FileType.init(mimeType: mimeType!)
                return documentType
            }
            documentType = FileType.document
            return documentType
        }
        
        guard let unwrappedMimeType = mimeType else {
            return nil
        }
        documentType = FileType.init(mimeType: unwrappedMimeType)
        return documentType
    }
    
    var calculatedHeight: CGFloat? {
        switch type {
        case .card:
            return cards?.first?.cardHeight
        case .paymentCard:
            let cards = self.cards ?? []
            var height: CGFloat = 0
            
            for card in cards {
                height += card.cardHeight
            }
            return height + 5
        case .multipleSelect :
            guard let action = customAction else {
                return 0.01
            }
            var h: CGFloat = 0
            for each in action.buttonsArray ?? [] {
                h += each.cardHeight
            }
            
            if action.isReplied == 1
            {
                return h + action.messageHeight +  attributtedMessage.timeHeight + attributtedMessage.nameHeight + 10
            }
            else
            {
               return h + action.messageHeight + 60 + attributtedMessage.timeHeight + attributtedMessage.nameHeight
            }
            
            
        default:
            return nil
        }
    }
    
    // MARK: - Intializer
    init?(dict: [String: Any]) {
        guard let userId = dict["user_id"] ?? dict["last_sent_by_id"] else {
            return nil
        }
        guard let senderId = Int("\(userId)") else {
            return nil
        }
        self.senderId = senderId
        let parsedMessage = (dict["message"] as? String ?? "").trimWhiteSpacesAndNewLine()
        message = parsedMessage.removeHtmlEntities()
        
        if let dateTimeString = dict["date_time"] as? String {
            creationDateTime = dateTimeString.toDate ?? dateTimeString.toDateWithLinent
        } else {
            creationDateTime = Date()
        }
        if let rawChatType = Int.parse(values: dict, key: "chat_type"), let parsedChatType = ChatType(rawValue: rawChatType) {
            self.chatType = parsedChatType
        }
        
        if let rawStatus = dict["message_status"] as? Int,
            let status = ReadUnReadStatus(rawValue: rawStatus) {
            self.status = status
        }
//        channelId = UIInt.parse
       
        self.rawJsonToSend = dict["rawJsonToSend"] as? [String: Any]
        self.localImagePath = dict["image_file"] as? String
        self.imageUrl = dict["image_url"] as? String
        self.thumbnailUrl = dict["thumbnail_url"] as? String
        self.senderFullName = ((dict["full_name"] as? String) ?? "").trimWhiteSpacesAndNewLine()
        self.messageUniqueID = dict["muid"] as? String
        self.parsedMimeType = dict["mime_type"] as? String
        
        var senderImage: String? = dict["user_image"] as? String ?? ""
        var type: MessageType = .none
        if let rawType = dict["message_type"] as? Int {
            type = MessageType(rawValue: rawType) ?? .none
            self.type = type
        }
        
        if (senderImage ?? "").isEmpty, (senderId <= 0  && type.isBotMessage) {
            senderImage = BussinessProperty.current.botImageUrl
        }
        
        self.senderImage = senderImage
        
        
        if let inputType = dict["input_type"] as? String
        {
            if inputType == responseKeyboardType.numberKeyboard.rawValue
            {
                self.keyboardType = .numberKeyboard
            }
            else if inputType == responseKeyboardType.none.rawValue
            {
                self.keyboardType = .none
            }
            else
            {
                self.keyboardType = .defaultKeyboard
            }
            
        }
        if let state = dict["message_state"] as? Int {
            isDeleted = state == 0
            isMissedCall = state == 2
        }
        if let rawCallType = dict["call_type"] as? String, let callType = CallType(rawValue: rawCallType.uppercased()) {
            self.callType = callType
        }
        self.fallbackText = dict["fallback_text"] as? String

        self.callDurationInSeconds = dict["video_call_duration"] as? Double
        if let user_type = dict["user_type"] as? Int, let type = UserType(rawValue: user_type) {
            self.userType = type
        }
        if let actionableData = dict["custom_action"] as? [String: Any] {
            self.actionableMessage = FuguActionableMessage(dict: actionableData)
        }
        let rawIntegrationSource = Int.parse(values: dict, key: "integration_source") ?? 0
        self.messageSource = IntegrationSource(rawValue: rawIntegrationSource) ?? .normal
        
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
        isFromBot = Int.parse(values: dict, key: "is_from_bot")
        isSkipBotEnabled = Bool.parse(key: "is_skip_button", json: dict, defaultValue: false)
        isSkipEvent = Bool.parse(key: "is_skip_event", json: dict, defaultValue: false)
        fileSize = dict["file_size"] as? String
        fileName = dict["file_name"] as? String
        fileUrl = dict["url"] as? String
        imageWidth = dict["image_width"] as? Float
        imageHeight = dict["image_height"] as? Float
        
        if let rawFileType = dict["document_type"] as? String, let parsedType = FileType(rawValue: rawFileType) {
            self.documentType = parsedType
        }
        
        self.localImagePath = dict["localImagePath"] as? String
        
        //MARK: Bot variables parsing
        self.messageId = dict["id"] as? Int ?? dict["message_id"] as? Int
        
        if let defaultActionId = dict["default_action_id"] as? String {
            self.defaultActionId = defaultActionId
        }
        if let values = dict["values"] as? [String] {
            self.values = values
        }
        

        self.comment = dict["comment"] as? String ?? ""
        self.is_rating_given = Bool.parse(key: "is_rating_given", json: dict, defaultValue: false)
        self.rating_given = dict["rating_given"] as? Int ?? 0
        self.total_rating = dict["total_rating"] as? Int ?? 0
        
        feedbackMessages = FeedbackMessage(json: dict)
        
        
        if let content_value = dict["content_value"] as? [[String: Any]] {
            switch type {
            case .card:
                self.selectedCardId = String.parse(values: dict, key: "selected_agent_id")
                let (cards, selectedCard) = MessageCard.parseList(cardsJson: content_value, selectedCardID: selectedCardId)
                self.cards = cards
                self.selectedCard = selectedCard
                
//                if cards.isEmpty {
//                    message = fallbackText ?? HippoConfig.shared.strings.defaultFallbackText
//                    type = .botText
//                }
            default:
                self.contentValues = content_value
                content = MessageContent(param: content_value)
                content.values = dict["values"] as? [String] ?? []//content.values
                let forms = FormData.getArray(object: content)
                leadsDataArray = forms
            }
        }
        switch type {
        case .paymentCard:
            let actions: [String: Any] = dict["custom_action"] as? [String: Any] ?? [:]
            let items = actions["items"] as? [[String: Any]] ?? []
            if actions.isEmpty && items.isEmpty {
                break
            }
            let selectedID = String.parse(values: actions, key: "selected_id") ?? ""
            self.selectedCardId = selectedID
            self.fallbackText = actions["result_message"] as? String ?? ""
            let (cards, selectedCard) = CustomerPayment.parse(list: items, selectedCardId: selectedID)
            self.selectedCard = selectedCard
            
            if let parsedSelectedCard = selectedCard {
                self.cards = [parsedSelectedCard]
            } else {
                let firstCard = cards.first
                firstCard?.isLocalySelected = true
                let buttonView = PayementButton.createPaymentOption()
                buttonView.selectedCardDetail = firstCard
                
                let header = PaymentHeader()
                let securePayment = PaymentSecurely.secrurePaymentOption()
                
                self.cards = [header] + cards
                self.cards?.append(securePayment)
                self.cards?.append(buttonView)
            }
            
        case .multipleSelect:
            self.customAction = CustomAction(dict:dict)
            
        case .embeddedVideoUrl:
            self.customAction = CustomAction(dict:dict)
            
        default:
            break
        }
        
        super.init()
        updateFileNameIfEmpty()
        changeMessageTypeIfReuired()
        changeMessageIfMessageTypeNotSupported()
        
        let isCellHavingImage = chatType.isImageViewAllowed && !userType.isMyUserType && HippoConfig.shared.appUserType != .agent
        attributtedMessage = MessageUIAttributes(message: message, senderName: senderFullName, isSelfMessage: userType.isMyUserType, isShowingImage: isCellHavingImage)
    }
    
    convenience init?(convoDict: [String: Any]) {
        
        guard let sender_id = convoDict["last_sent_by_id"] as? Int else {
            return nil
        }
        self.init(dict: convoDict)
    
        
        self.senderId = sender_id

        if let tempMessage = convoDict["message"] as? String {
            message = tempMessage
        } else if let tempMessage = convoDict["new_message"] as? String {
            message = tempMessage
        } else {
            message = ""
        }
        message = message.trimWhiteSpacesAndNewLine().removeHtmlEntities()
        
//        self.type = self.message.isEmpty ? MessageType.imageFile : MessageType.normal
        let senderFullName = (convoDict["last_sent_by_full_name"] as? String) ?? ""
        self.senderFullName = senderFullName//.formatName()
        self.callDurationInSeconds = convoDict["video_call_duration"] as? Double
        if let rawCallType = convoDict["call_type"] as? String, let callType = CallType(rawValue: rawCallType.uppercased()) {
            self.callType = callType
        }
        
        if let rawStatus = convoDict["last_message_status"] as? Int, let status = ReadUnReadStatus(rawValue: rawStatus) {
            self.status = status
        }
        
        attributtedMessage = MessageUIAttributes(message: message, senderName: senderFullName, isSelfMessage: userType.isMyUserType)
    }
    
    init(message: String, type: MessageType, uniqueID: String? = nil, imageUrl: String? = nil, thumbnailUrl: String? = nil, localFilePath: String? = nil, senderName: String? = nil, senderId: Int? = nil, chatType: ChatType?) {
        self.message = message
        self.senderId = senderId ?? currentUserId()
        self.senderFullName = senderName ?? currentUserName()//.formatName()
        self.senderImage = currentUserImage()
        self.chatType = chatType ?? .none
        
        creationDateTime = Date()
        self.type = type
        self.messageUniqueID = uniqueID
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.localImagePath = localFilePath
        
        self.userType = currentUserType()
        
        attributtedMessage = MessageUIAttributes(message: message, senderName: senderFullName, isSelfMessage: userType.isMyUserType)
    }
    
    private convenience init(typingStatus: TypingMessage) {
        self.init(message: "", type: .normal, chatType: nil)
        self.userType = currentUserType()
        self.typingStatus = typingStatus
    }
    
    // MARK: - Methods
    func getJsonToSendToFaye() -> [String: Any] {
        var json = [String: Any]()
        if let parsedRawJsonToSend = rawJsonToSend {
            json += parsedRawJsonToSend
        }
        
        if BussinessProperty.current.encodeToHTMLEntities {
            json["message"] = message.addHTMLEntities()
        } else {
            json["message"] = message
        }
        
        json["user_id"] = senderId
        
        json["full_name"] = senderFullName//.formatName()
        json["date_time"] = creationDateTime.toUTCFormatString
        json["is_typing"] = typingStatus.rawValue
        json["message_type"] = type.rawValue
        json["user_type"] = userType.rawValue
        
        json["user_image"] = senderImage ?? ""
        
        json["source"] = SourceType.SDK.rawValue
        json["device_type"] = Device_Type_iOS
        
        if let parsedBotFormMUID = self.botFormMessageUniqueID {
            json["bot_form_muid"] = parsedBotFormMUID
        }
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
        
        if let tempFileUrl = self.fileUrl {
            json["url"] = tempFileUrl
        }
        if let fileName = self.fileName {
            json["file_name"] = fileName
        }
        if let parsedMimeType = self.mimeType {
            json["mime_type"] = parsedMimeType
        }
        if let fileSize = self.fileSize {
            json["file_size"] = fileSize
        }
        json["image_width"] = imageWidth
        json["image_height"] = imageHeight
        
        if let documentType = documentType {
            json["document_type"] = documentType.rawValue
        } else if let concreteFileType = concreteFileType {
            json["document_type"] = concreteFileType.rawValue
        }
        
        if let id = messageId {
            json["message_id"] = id
            json["id"] = id
        }
        
        if HippoProperty.current.shouldSendBotGroupId() {
            json["bot_group_id"] = HippoProperty.current.botGroupId
        }
        
        let notificationType = notification ?? .message
        if let rideDetail = RideDetail.current, let time = rideDetail.getRemaningTime(), typingStatus == .messageRecieved, notificationType == .message  {
            json["estimated_inride_secs"] = time
        }
        if type == .feedback {
            json["is_rating_given"] = self.is_rating_given.intValue()
            json["total_rating"] = 5
            json["rating_given"] = self.rating_given
            json["comment"] = self.comment
            json["line_after_feedback_1"] = feedbackMessages.line_after_feedback_1
            json["line_after_feedback_2"] = feedbackMessages.line_after_feedback_2
            json["line_before_feedback"] = feedbackMessages.line_before_feedback
        } else if type == .leadForm {
            var arrayOfMessages: [String] = []
            for lead in leadsDataArray {
                if lead.value.isEmpty {
                    break
                }
                arrayOfMessages.append(lead.value)
            }
            json["values"] = arrayOfMessages
            
            json["user_id"] = currentUserId()
            json["content_value"] = contentValues
            json["is_skip_button"] = isSkipBotEnabled
            json["is_skip_event"] = isSkipEvent
            if let is_from_bot = isFromBot {
                json["is_from_bot"] = is_from_bot
            }
        } else if type == .quickReply {
            json["bot_button_reply"] = true
            json["user_id"] = currentUserId()
            json["values"] = [selectedActionId]
            json["content_value"] = contentValues
        }
        return json
    }
    func getMessageSendingFailedWhenSavingInCache() -> Bool {
        let wasMessageSendingInProgress = status == .none
        let typeIsMedia = (type == .imageFile || type == .attachment)
        
        return (wasMessageSendingInProgress && typeIsMedia) || wasMessageSendingFailed
    }
    
    
    
    
    func getDictToSaveInCache() -> [String: Any] {
        var dict = [String: Any]()
        
        if let parsedRawJsonToSend = rawJsonToSend {
            dict["rawJsonToSend"] = parsedRawJsonToSend
        }
        
        switch self {
        case let customMessage as HippoActionMessage:
            dict = customMessage.getJsonToSendToFaye()
        default:
            dict = getJsonToSendToFaye()
        }
        
        if let fallbackText = self.fallbackText {
            dict["fallback_text"] = fallbackText
        }
        dict["message"] = message
        dict["wasMessageSendingFailed"] = getMessageSendingFailedWhenSavingInCache() 
        dict["message_status"] = status.rawValue
        
        if localImagePath != nil {
            dict["localImagePath"] = localImagePath!
        }
        dict["user_type"] = userType.rawValue
        
        if actionableMessage != nil {
            dict["custom_action"] = actionableMessage!.getDictToSaveToCache()
        }
        if let video_call_duration = callDurationInSeconds {
            dict["video_call_duration"] = video_call_duration
        }
        dict["call_type"] = callType.rawValue
        dict["integration_source"] = messageSource.rawValue
        return dict
    }
    
    func getJsonForConversationDict() -> [String: Any] {
        var json = [String: Any]()
        
        if BussinessProperty.current.encodeToHTMLEntities {
            json["message"] = message.addHTMLEntities()
        } else {
            json["message"] = message
        }
        json["date_time"] = creationDateTime.toUTCFormatString
        json["last_sent_by_id"] = senderId
        json["last_sent_by_full_name"] = senderFullName//.formatName()
        json["last_message_status"] = status.rawValue
        
        return json
    }
    
    func isANotification() -> Bool {
        if type == MessageType.actionableMessage || type == .hippoPay  {
            return false
        }
        guard message.isEmpty else {
            return false
        }
        if type == MessageType.actionableMessage || type == .hippoPay  {
            return false
        }
        if let unwrappedImageUrl = thumbnailUrl, !unwrappedImageUrl.isEmpty {
            return false
        }
        return true
    }
    
    func isSentByMe() -> Bool {
        return senderId == currentUserId()
    }
    
    
    // MARK: - Type Methods
    static func getArrayFrom(json: [[String: Any]], chatType: ChatType?) -> (messages: [HippoMessage], hashmap: [String: Int]) {
        
        var arrayOfMessages = [HippoMessage]()
        var messageHashMap = [String: Int]()
        
        for rawMessage in json {

            guard let message = HippoMessage.createMessage(rawMessage: rawMessage, chatType: chatType) else {
                continue
            }
            
            
            if let muid = message.messageUniqueID {
                if messageHashMap[muid] != nil {
                    continue
                }
                messageHashMap[muid] = arrayOfMessages.count
            }
            arrayOfMessages.append(message)
        }
        
     //   arrayOfMessages.append(self.generateMessage()!)
        
        return (arrayOfMessages, messageHashMap)
    }
    
    static func getArrayOfJsonFrom(messages: [HippoMessage]) -> [[String: Any]] {
        var arrayOfDict = [[String: Any]]()
        
        for message in messages {
            arrayOfDict.append(message.getDictToSaveInCache())
        }
        return arrayOfDict
    }
    
    static func generateMessage() -> HippoMessage? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"
        let dateStr = dateFormatter.string(from: Date())
        
        let dict = [
            "full_name": "Docs Online",
            "user_type": 0,
            "user_image": "",
            "id": 387751158,
            "email": "",
            "user_id": 0,
            "date_time": dateStr,
            "message": "Welcome to Docs Online Please select options? Welcome to Docs Online Please select options? Welcome to Docs Online Please select options?  Welcome to Docs Online Please select options?",
            "message_type": 23,
            "message_state": 1,
            "muid": String.generateUniqueId(),
            "is_active": 0,
            "replied_by": "Test",
            "custom_action": [
                "min_selection": 1,
                "max_selection": 3,
                "is_replied":0,
                "multi_select_buttons": [
                [
                "btn_id": 1,
                "btn_title": "Tea",
                "status": 0
                ],
                [
                "btn_id": 2,
                "btn_title": "Coffee",
                "status": 0
                ],
                [
                "btn_id": 3,
                "btn_title": "Juice",
                "status": 0
                ],
                [
                "btn_id": 4,
                "btn_title": "Water",
                "status": 0
                ],
                [
                "btn_id": 4,
                "btn_title": "Water",
                "status": 0
                ],
                [
                "btn_id": 4,
                "btn_title": "Water",
                "status": 0
                ],
                [
                "btn_id": 4,
                "btn_title": "Water",
                "status": 0
                ],
                [
                "btn_id": 4,
                "btn_title": "Water",
                "status": 0
                ]
              ]
            ],
            "replied_by_id": 14917240,
            "integration_source": 0,
            "message_status": 3
            ] as [String : Any]
        
        let message = HippoMessage(dict: dict)
        
        return message
    }
    
    
    func updateObjectForFeedback(is_rating_given: Bool = false, rating_given: Int = 0, total_rating: Int = 5, line_after_feedback_1: String, line_after_feedback_2: String, line_before_feedback: String) {
        self.is_rating_given = is_rating_given
        self.rating_given = rating_given
        self.total_rating = total_rating
        feedbackMessages.line_before_feedback = line_before_feedback
        feedbackMessages.line_after_feedback_1 = line_after_feedback_1
        feedbackMessages.line_after_feedback_2 = line_after_feedback_2
    }
    
    func updateObject(with newObject: HippoMessage) {
        //Updating for Feedback
        total_rating = newObject.total_rating
        rating_given = newObject.rating_given
        comment = newObject.comment
        feedbackMessages.line_after_feedback_1 = newObject.feedbackMessages.line_after_feedback_1
        feedbackMessages.line_after_feedback_2 = newObject.feedbackMessages.line_after_feedback_2
        feedbackMessages.line_before_feedback = newObject.feedbackMessages.line_before_feedback
        is_rating_given = newObject.is_rating_given
        //Updating for leadForm
        leadsDataArray = newObject.leadsDataArray
        contentValues = newObject.contentValues
        content = newObject.content
        senderImage = newObject.senderImage
        senderFullName = newObject.senderFullName
        
        isSkipEvent = newObject.isSkipEvent
        isSkipBotEnabled = newObject.isSkipBotEnabled
        
        messageRefresed?()
    }
    func updateFileNameIfEmpty() {
        let name = fileName ?? ""
        guard name.isEmpty else {
            return
        }
        if localImagePath != nil {
            fileName =  localImagePath?.fileName()
        }
        if imageUrl != nil {
            fileName = imageUrl?.fileName()
        }
        if fileUrl != nil {
            fileName =  fileUrl?.fileName()
        }
    }
    //MARK: Handling case for svg file sharing
    func changeMessageIfMessageTypeNotSupported() {
        guard !self.type.isMessageTypeHandled() else {
            return
        }
        let unsuppportedMessage = BussinessProperty.current.unsupportedMessageString
        message = unsuppportedMessage
    }
    func changeMessageTypeIfReuired() {
        let isUnhandledFileType: Bool = isUnhandledType()
        switch type {
        case .imageFile:
            if isUnhandledFileType {
                type = .attachment
                documentType = .image
                fileUrl = imageUrl
            }
        case .attachment:
            if isUnhandledFileType {
                documentType = .document
            }
        default:
            break
        }
    }
    func isUnhandledType() -> Bool {
        guard let mimeType = self.mimeType else {
            return false
        }
        let type = mimeType.components(separatedBy: "/")
        guard let parsedType = type.last?.lowercased(), !parsedType.isEmpty else {
            return false
        }
        let unhandledMimeType = ["vnd.adobe.photoshop", "psd", "tiff", "svg", "svg+xml"]
        return unhandledMimeType.contains(parsedType)
    }
    
    func shouldShowSkipButton() -> Bool {
        var isAllFieldCompleted: Bool = true
        
        for each in leadsDataArray {
            if !each.isCompleted {
                isAllFieldCompleted = false
            }
        }
        
        return (!isSkipEvent && isSkipBotEnabled && !isAllFieldCompleted)
    }
    
    func isInValidMessage() -> Bool {
        switch type {
        case .card:
            let fallbackText = self.fallbackText ?? HippoConfig.shared.strings.defaultFallbackText
            message = fallbackText.isEmpty ? HippoConfig.shared.strings.defaultFallbackText : fallbackText
            attributtedMessage = MessageUIAttributes(message: message, senderName: senderFullName, isSelfMessage: userType.isMyUserType)
            return cards?.isEmpty ?? true
        default:
            return false
        }
    }
    func isTypingMessage() -> Bool {
        let message = self.message
        let imageUrl = self.imageUrl ?? ""
        let fileUrl = self.fileUrl ?? ""
        
        if type == .hippoPay || type == .actionableMessage {
            return false
        }

        if imageUrl.isEmpty && message.isEmpty && fileUrl.isEmpty {
            return true
        }
        return false
    }
    func isReadAllNotification() -> Bool {
        return (notification ?? .none) == .readAll
    }
    
    func isSelfMessage(for chatType: ChatType) -> Bool {
        switch  HippoConfig.shared.appUserType {
        case .agent:
            switch chatType {
            case .o2o:
                return senderId == currentUserId()
            default:
                return userType.isMyUserType
            }
        case .customer:
            return senderId == currentUserId()
        }
    }
    
    class func createMessage(rawMessage: [String: Any], chatType: ChatType?) -> HippoMessage? {
        var messageJson = rawMessage
        if let parsedChatType = chatType {
            messageJson["chat_type"] = parsedChatType.rawValue
        }
        
        let message_type = messageJson["message_type"] as? Int ?? 0
        let type = MessageType(rawValue: message_type) ?? .none
        
        let tempMessage: HippoMessage?
        
        switch type {
        case .consent:
            tempMessage = HippoActionMessage(dict: messageJson)
        default:
            tempMessage = HippoMessage(dict: messageJson)
        }
        return tempMessage
    }
    
}
struct FeedbackMessage {
    var line_after_feedback_1 = "Your response is recorded"
    var line_after_feedback_2 = "Thank you"
    var line_before_feedback = "Please Proview feedback for our conversation"
    
    init(json: [String: Any]) {
        line_after_feedback_1 = json["line_after_feedback_1"] as? String ?? line_after_feedback_1
        line_after_feedback_2 = json["line_after_feedback_2"] as? String ?? line_after_feedback_2
        line_before_feedback = json["line_before_feedback"] as? String ?? line_before_feedback
    }
}
