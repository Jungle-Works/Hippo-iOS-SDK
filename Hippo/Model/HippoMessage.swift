//
//  HippoMessage.swift
//  Fugu
//
//  Created by cl-macmini-117 on 06/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation



class MessageCallbacks {
    var statusChanged: (() -> Void)? = nil
    var feedbackUpdated: (() -> Void)? = nil
    var leadFormUpdated: (() -> Void)? = nil
    var sendingStatusUpdated: (() -> Void)? = nil
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
        let message = HippoMessage(message: "", type: .normal)
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
    
    var fileUrl: String?
    var fileName: String?
    var fileSize: String?
    var documentType: FileType?
    
    var isFileUploading: Bool = false
    var imageWidth : Float?
    var imageHeight : Float?
    var parsedMimeType: String?
    
    var rawJsonToSend: [String: Any]?

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
    
    // MARK: - Intializer
    init?(dict: [String: Any]) {
        guard let userId = dict["user_id"] ?? dict["last_sent_by_id"] else {
            return nil
        }
        guard let senderId = Int("\(userId)") else {
            return nil
        }
        self.senderId = senderId
        
        message = (dict["message"] as? String) ?? ""
        
        if let dateTimeString = dict["date_time"] as? String, let dateTime = dateTimeString.toDate {
            creationDateTime = dateTime
        } else {
            creationDateTime = Date()
        }
        
        if let rawStatus = dict["message_status"] as? Int,
            let status = ReadUnReadStatus(rawValue: rawStatus) {
            self.status = status
        }
        
        self.rawJsonToSend = dict["rawJsonToSend"] as? [String: Any]
        self.localImagePath = dict["image_file"] as? String
        self.imageUrl = dict["image_url"] as? String
        self.thumbnailUrl = dict["thumbnail_url"] as? String
        self.senderFullName = ((dict["full_name"] as? String) ?? "").trimWhiteSpacesAndNewLine()
        self.messageUniqueID = dict["muid"] as? String
        self.parsedMimeType = dict["mime_type"] as? String
        
        if let rawType = dict["message_type"] as? Int,
            let type = MessageType(rawValue: rawType) {
            self.type = type
        }
        if let state = dict["message_state"] as? Int {
            isDeleted = state == 0
            isMissedCall = state == 2
        }
        if let rawCallType = dict["call_type"] as? String, let callType = CallType(rawValue: rawCallType.uppercased()) {
            self.callType = callType
        }

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
            self.contentValues = content_value
            content = MessageContent(param: content_value)
            content.values = dict["values"] as? [String] ?? []//content.values
            leadsDataArray = FormData.getArray(object: content)
        }
        super.init()
        updateFileNameIfEmpty()
        changeMessageTypeIfReuired()
        changeMessageIfMessageTypeNotSupported()
        
        attributtedMessage = MessageUIAttributes(message: message, senderName: senderFullName, isSelfMessage: userType.isMyUserType)
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
        
//        self.type = self.message.isEmpty ? MessageType.imageFile : MessageType.normal
        let senderFullName = (convoDict["last_sent_by_full_name"] as? String) ?? ""
        self.senderFullName = senderFullName.formatName()
        self.callDurationInSeconds = convoDict["video_call_duration"] as? Double
        if let rawCallType = convoDict["call_type"] as? String, let callType = CallType(rawValue: rawCallType.uppercased()) {
            self.callType = callType
        }
        
        if let rawStatus = convoDict["last_message_status"] as? Int, let status = ReadUnReadStatus(rawValue: rawStatus) {
            self.status = status
        }
        
        attributtedMessage = MessageUIAttributes(message: message, senderName: senderFullName, isSelfMessage: userType.isMyUserType)
    }
    
    init(message: String, type: MessageType, uniqueID: String? = nil, imageUrl: String? = nil, thumbnailUrl: String? = nil, localFilePath: String? = nil) {
        self.message = message
        senderId = currentUserId()
        self.senderFullName = currentUserName().formatName()
        
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
        self.init(message: "", type: .normal)
        self.userType = currentUserType()
        self.typingStatus = typingStatus
    }
    
    // MARK: - Methods
    func getJsonToSendToFaye() -> [String: Any] {
        var json = [String: Any]()
        if let parsedRawJsonToSend = rawJsonToSend {
            json += parsedRawJsonToSend
        }
        
        json["message"] = message
        json["user_id"] = senderId
        json["full_name"] = senderFullName.formatName()
        json["date_time"] = creationDateTime.toUTCFormatString
        json["is_typing"] = typingStatus.rawValue
        json["message_type"] = type.rawValue
        json["user_type"] = currentUserType().rawValue
        
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
        } else if type == .botFormMessage {
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
        
        json["message"] = message
        json["date_time"] = creationDateTime.toUTCFormatString
        json["last_sent_by_id"] = senderId
        json["last_sent_by_full_name"] = senderFullName.formatName()
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
    static func getArrayFrom(json: [[String: Any]]) -> (messages: [HippoMessage], hashmap: [String: Int]) {
        
        var arrayOfMessages = [HippoMessage]()
        var messageHashMap = [String: Int]()
        
        for rawMessage in json {

            guard let message = HippoMessage.createMessage(rawMessage: rawMessage) else {
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
        return (arrayOfMessages, messageHashMap)
    }
    
    static func getArrayOfJsonFrom(messages: [HippoMessage]) -> [[String: Any]] {
        var arrayOfDict = [[String: Any]]()
        
        for message in messages {
            arrayOfDict.append(message.getDictToSaveInCache())
        }
        return arrayOfDict
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
        let unsuppportedMessage = HippoConfig.shared.unsupportedMessageString
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
    
    class func createMessage(rawMessage: [String: Any]) -> HippoMessage? {
        let message_type = rawMessage["message_type"] as? Int ?? 0
        let type = MessageType(rawValue: message_type) ?? .none
        
        let tempMessage: HippoMessage?
        
        switch type {
        case .consent:
            tempMessage = HippoActionMessage(dict: rawMessage)
        default:
            tempMessage = HippoMessage(dict: rawMessage)
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

