//
//  HippoChannel.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 20/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

struct HippoChannelCreationResult {
    let isSuccessful: Bool
    let error: Error?
    let channel: HippoChannel?
    let isChannelAvailableLocallay: Bool
}

protocol HippoChannelDelegate: class {
    func newMessageReceived(newMessage: HippoMessage)
    func typingMessageReceived(newMessage: HippoMessage)
    func sendingFailedFor(message: HippoMessage)
    func cancelSendingMessage(message: HippoMessage, errorMessage: String?)
}

//TODO: - Subscribe Fail-safe -> subscribe channel again if it is disconnected
class HippoChannel {
    
    typealias HippoChannelCreationHandler = (_ result: HippoChannelCreationResult) -> Void
    typealias HippoChannelHandler = (_ success: Bool, _ error: Error?) -> Void
    typealias MessagesAndHashMap = (messages: [HippoMessage], hashmap: [String: Int])
    
    var chatDetail: ChatDetail?
//    var tags = [TagDetail]()
    
    var isSendingDisabled = false
    let id: Int
    var signalReceivedFromPeer: (([String: Any]) -> Void)?
    weak var delegate: HippoChannelDelegate?
    var messages: [HippoMessage] {
        return sentMessages + unsentMessages
    }
    
    var messageHashMap = [String: Int]()
    var sentMessages = [HippoMessage]()
    var unsentMessages = [HippoMessage]()
    
    private var messageSender: MessageSender!
    
    //TODO: - Auto Subscription Logic
    // MARK: - Intializer
    init(id: Int) {
        self.id = id
        guard id != -1 else {
            return
        }
        addObserver()
        subscribe()
        addObserverIfAppIsKilled()
        loadCachedMessages()
        loadCachedHashMap()
        loadCachedChannelInfo()
        
        
        let uploadedMessages = unsentMessages.filter {$0.localImagePath == nil && $0.isSentByMe() }
        messageSender = MessageSender(messagesToSend: uploadedMessages, forChannelID: id, delegate: self)
    }
    
    func addObserverIfAppIsKilled() {
        NotificationCenter.default.addObserver(self, selector: #selector(HippoChannel.saveMessagesInCache), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HippoChannel.saveMessagesInCache), name: UIApplication.willResignActiveNotification, object: nil)
    }
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkForReconnection), name: .fayeConnected, object: nil)
    }
    private func loadCachedHashMap() {
        messageHashMap = HippoChannel.getCachedHashMapFor(channelId: id)
    }
    
    private func loadCachedChannelInfo() {
        let infoDict = HippoChannel.getChannelInfoFor(channelId: id)
        guard infoDict.count > 0 else {
            return
        }
        chatDetail = ChatDetail(json: infoDict)
    }
    
    func refreshHashMap() {
        messageHashMap = [:]
        for (index, message) in messages.enumerated() {
            guard let uniqueId = message.messageUniqueID else {
                continue
            }
            messageHashMap[uniqueId] = index
        }
    }
    
    class func getChannelInfoFor(channelId: Int) -> [String: Any] {
        return (FuguDefaults.object(forKey: "infoObject\(channelId)") as? [String: Any] ?? [:])
    }
    class func saveHashMapInCache(hashMap: [String: Int], forChannelID id: Int) {
        FuguDefaults.set(value: hashMap, forKey: "messageHashMap\(id)")
    }
    class func saveSentMessagesCache(json: [[String: Any]], forChannelID id: Int) {
        var allSentCache = getAllChannelsSentMessagesCache()
        allSentCache[id.description] = json
        FuguDefaults.set(value: allSentCache, forKey: DefaultName.sentMessagesData.rawValue)
    }
    
    class func getCachedHashMapFor(channelId: Int) -> [String: Int] {
        return (FuguDefaults.object(forKey: "messageHashMap\(channelId)") as? [String: Int] ?? [:])
    }
    class func getChannelUnsentMessageCacheFrom(withID id: Int) -> [[String: Any]] {
        let allChannelUnsentCache = getAllChannelsUnSentMessagesCache()
        return getChannelMessageCacheFrom(allChannelCache: allChannelUnsentCache, withID: id)
    }
    
    class func getChannelSentMessageCacheFrom(withID id: Int) -> [[String: Any]] {
        let allChannelUnsentCache = getAllChannelsSentMessagesCache()
        return getChannelMessageCacheFrom(allChannelCache: allChannelUnsentCache, withID: id)
    }
    class func getChannelMessageCacheFrom(allChannelCache: [String: Any]?, withID id: Int) -> [[String: Any]] {
        let thisChannelCache = allChannelCache?[id.description] as? [[String: Any]] ?? []
        return thisChannelCache
    }
    class func getAllChannelsSentMessagesCache() -> [String: Any] {
        let cache = FuguDefaults.object(forKey: DefaultName.sentMessagesData.rawValue) as? [String: Any]
        return cache ?? [:]
    }
    
    class func getAllChannelsUnSentMessagesCache() -> [String: Any] {
        let cache = FuguDefaults.object(forKey: DefaultName.unsentMessagesData.rawValue) as? [String: Any]
        return cache ?? [:]
    }
    class func getUnsentCachedMessagesFor(channelID: Int) -> MessagesAndHashMap {
        let thisChannelCache = getChannelUnsentMessageCacheFrom(withID: channelID)
        
        let (messages, hashMap) = HippoMessage.getArrayFrom(json: thisChannelCache)
        return (messages, hashMap)
    }
    
    class func getSentCachedMessagesFor(channelID: Int) -> MessagesAndHashMap {
        let thisChannelCache = getChannelSentMessageCacheFrom(withID: channelID)
        
        let (messages, hashMap) = HippoMessage.getArrayFrom(json: thisChannelCache)
        return (messages, hashMap)
        
    }
    
    // MARK: - Create New Channel/Conversation
    static var hashmapTransactionIdToChannelID = [String: Int]()
    
    class func get(withLabelId labelId: String, completion: @escaping HippoChannelCreationHandler) {
        
        let params = getParamsToStartConversation(WithLabelId: labelId)
        createNewConversationWith(params: params, completion: completion)
    }
    
    class func get(withFuguChatAttributes attributes: AgentDirectChatAttributes, completion: @escaping HippoChannelCreationHandler) {
        guard let params = attributes.getParamsToStartNewChat() else {
            let result = HippoChannelCreationResult(isSuccessful: false, error: HippoError.general, channel: nil, isChannelAvailableLocallay: false)
            completion(result)
            return
        }
        switch attributes.chatType {
        case .o2o:
            createOneToOneConversation(params: params, completion: completion)
        default:
            createNewConversationWith(params: params, completion: completion)
        }
        
    }
    
    private class func createOneToOneConversation(params: [String: Any], completion: @escaping HippoChannelCreationHandler) {
        HippoConfig.shared.log.debug("API_CREATE_O2O_CONVERSATION.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.createOneToOneChat.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let data = responseDict["data"] as? [String: Any],
                let channelID = data["channel_id"] as? Int else {
                    HippoConfig.shared.log.debug("API_CREATE_CONVERSATION_ ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    let result = HippoChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false)
                    completion(result)
                    return
            }
            
            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: false)
            if let transactionID = params["transaction_id"] as? String {
                hashmapTransactionIdToChannelID[transactionID] = channelID
            }
            completion(result)
        }
    }
    
    class func get(withFuguChatAttributes attributes: FuguNewChatAttributes, completion: @escaping HippoChannelCreationHandler) {
        
        if let transactionID = attributes.transactionId,
            FuguNewChatAttributes.isValidTransactionID(id: transactionID),
            let channelID = hashmapTransactionIdToChannelID[transactionID] {
            
            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: true)
            completion(result)
            return
        }
        
        let params = getParamsToStartConversation(fuguAttributes: attributes)
        createNewConversationWith(params: params, completion: completion)
    }
    
    private class func createNewConversationWith(params: [String: Any], completion: @escaping HippoChannelCreationHandler) {
        
        HippoConfig.shared.log.debug("API_CREATE_CONVERSATION.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CREATE_CONVERSATION.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let data = responseDict["data"] as? [String: Any],
                let channelID = data["channel_id"] as? Int else {
                    HippoConfig.shared.log.debug("API_CREATE_CONVERSATION_ ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    let result = HippoChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false)
                    completion(result)
                    return
            }
            
            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: false)
            if let transactionID = params["transaction_id"] as? String {
                hashmapTransactionIdToChannelID[transactionID] = channelID
            }
            completion(result)
        }
    }
    
    /// Creates new support conversation.
    ///
    /// - Parameters:
    ///   - params: Parameters for creation.
    ///   - completion: Callback for new channel creation.
    class func createNewConversationForTicket(params: [String: Any], completion: @escaping HippoChannelCreationHandler) {
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CREATE_TICKET.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any], let _ = responseDict["data"] else {
                let result = HippoChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false)
                completion(result)
                return
            }
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: nil, isChannelAvailableLocallay: false)
            completion(result)
        }
    }
    
    
    class func getParamsToStartConversation(WithLabelId labelId: String? = nil, fuguAttributes: FuguNewChatAttributes? = nil) -> [String: Any] {
        var params = [String: Any]()
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["en_user_id"] = HippoUserDetail.fuguEnUserID ?? -1
        
        if let unwrappedLabelId = labelId {
            params["label_id"] = unwrappedLabelId
        }
        
        var groupingTags = HippoConfig.shared.userDetail?.getUserTagNameArray() ?? [String]()
        
        
        if let attributeParams = fuguAttributes?.getParamsToStartNewChat() {
            params += attributeParams
        }
        //Check for getting new channelTags
        if let newGroupingTags = fuguAttributes?.groupingTag {
            groupingTags += newGroupingTags
        }
        params["grouping_tags"] = groupingTags
        
        return params
    }
    
    
    // MARK: - Messages
//    private func loadCachedMessages() {
//        let sentMessages = getSentCachedMessages()
//        let unsentMessages = getUnsentCachedMessages()
//
//        messages = sentMessages + unsentMessages
//    }
    func loadCachedMessages() {
        let sentMessages = HippoChannel.getSentCachedMessagesFor(channelID: id).messages
        let allUnsentMessages = HippoChannel.getUnsentCachedMessagesFor(channelID: id).messages
        
        self.sentMessages = sentMessages
        self.unsentMessages = allUnsentMessages
    }
    
//    private func getUnsentCachedMessages() -> [HippoMessage] {
//        let cacheOfAllChannels = FuguDefaults.object(forKey: DefaultName.unsentMessagesData.rawValue) as? [String: Any]
//        let thisChannelCache = getChannelMessageCacheFrom(allChannelCache: cacheOfAllChannels)
//
//        let messages = HippoMessage.getArrayFrom(json: thisChannelCache)
//        return messages
//    }
//
//    private func getSentCachedMessages() -> [HippoMessage] {
//        let cachedOfAllChannels = FuguDefaults.object(forKey: DefaultName.sentMessagesData.rawValue) as? [String: Any]
//        let thisChannelCache = getChannelMessageCacheFrom(allChannelCache: cachedOfAllChannels)
//
//        let messages = HippoMessage.getArrayFrom(json: thisChannelCache)
//        return messages
//    }
//
    private func getChannelMessageCacheFrom(allChannelCache: [String: Any]?) -> [[String: Any]] {
        let thisChannelCache = allChannelCache?[id.description] as? [[String: Any]] ?? []
        return thisChannelCache
    }
    
    @objc fileprivate func saveMessagesInCache() {
        var arrayOfSentMessages = [[String: Any]]()
        var arrayOfUnsentMessages = [[String: Any]]()
        
        for message in messages {
            if message.status == .none && message.isSentByMe() {
                let messageDict = message.getDictToSaveInCache()
                arrayOfUnsentMessages.append(messageDict)
            } else {
                let messageDict = message.getDictToSaveInCache()
                arrayOfSentMessages.append(messageDict)
            }
        }
        //TODO: Refactor this
        
        var sentMessageObject = (FuguDefaults.object(forKey: DefaultName.sentMessagesData.rawValue) as? [String: Any]) ?? [String: Any]()
        var unsentMessageObject = FuguDefaults.object(forKey: DefaultName.unsentMessagesData.rawValue) as? [String: Any] ?? [String: Any]()
        
        sentMessageObject[id.description] = arrayOfSentMessages
        unsentMessageObject[id.description] = arrayOfUnsentMessages
        
        let infoJson = chatDetail?.getJsonToStore() ?? [:]
        
        FuguDefaults.set(value: sentMessageObject, forKey: DefaultName.sentMessagesData.rawValue)
        FuguDefaults.set(value: unsentMessageObject, forKey: DefaultName.unsentMessagesData.rawValue)
        FuguDefaults.set(value: messageHashMap, forKey: "messageHashMap\(id)")
        FuguDefaults.set(value: infoJson, forKey: "infoObject\(id)")
    }
    
    
    func isMessageSentByMe(senderId: Int) -> Bool {
        return currentUserId() == senderId
    }
    
    fileprivate func updateAllMessagesStatusToRead() {
        for message in messages {
            if message.status != .none {
                message.status = .read
            }
        }
    }
    /// Updates the feedback message in channel messages
    ///
    /// - Parameter newMessage: Hippo Message object
    func upateFeedbackStatus(newMessage: HippoMessage) {
        for message in messages where message.messageUniqueID == newMessage.messageUniqueID {
            message.is_rating_given = newMessage.is_rating_given
            message.comment = newMessage.comment
            message.rating_given = newMessage.rating_given
            message.total_rating = newMessage.total_rating
        }
    }
    func updateBotButtonMessage(newMessage: HippoMessage) {
        for message in messages where message.messageId == newMessage.messageId {
            message.values = newMessage.values
        }
    }
    
    func sendFormValues(message: HippoMessage, completion: @escaping () -> Void) {
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            fuguDelay(2, completion: {
                message.wasMessageSendingFailed = true
                completion()
            })
            return
        }
        if !isSubscribed()  {
            subscribe()
        }
        let messageDict = message.getJsonToSendToFaye()
        
//        print("@@@@@@@@@@\(messageDict)")
        
        FayeConnection.shared.send(messageDict: messageDict, toChannelID: id.description) { (result) in
            if result.success {
                message.status = ReadUnReadStatus.sent
                if message.type == .quickReply && !message.values.isEmpty {
                    self.updateBotButtonMessage(newMessage: message)
                }
            }
            message.wasMessageSendingFailed = !result.success
            message.creationDateTime = Date()
            completion()
        }
    }
    func subscribe(completion: HippoChannelHandler? = nil) {
        FayeConnection.shared.subscribeTo(channelId: id.description, completion: {(success) in
            completion?(success, nil)
        }) {[weak self] (messageDict) in
            HippoConfig.shared.log.trace("Active channel -\(self?.id ?? 0000) >>>>> \(messageDict)", level: .socket)
            guard let message = HippoMessage.createMessage(rawMessage: messageDict) else {
                return
            }
            if message.type == .call {
                
                DispatchQueue.main.async {
                    self?.signalReceivedFromPeer?(messageDict)
                }
                return
            }
            
            self?.messageReceived(message: message)
        }
    }
    func messageReceived(message: HippoMessage) {
        
        if message.isANotification() && canChangeStatusOfMessagesToReadAllIf(messageReceived: message) {
            updateAllMessagesStatusToRead()
        }
        if message.isTypingMessage() {
            delegate?.typingMessageReceived(newMessage: message)
            return
        }
        guard !message.isReadAllNotification() else {
            return
        }
        guard message.type.isMessageTypeHandled() else {
            return
        }
        let muid = message.messageUniqueID
        let messageReference = getMessageWith(muid: muid)
        
        if message.isSentByMe(), let refernece = messageReference {
            refernece.status = .sent
        }
        if let oldMessage = messageReference {
            updateReferenceMessage(oldMessage: oldMessage, newMessage: message)
            return
        }
        appendMessageIfRequired(message: message)
        delegate?.newMessageReceived(newMessage: message)
    }
    
    func updateReferenceMessage(oldMessage: HippoMessage, newMessage: HippoMessage) {
        switch newMessage.type {
        case .consent:
            if let oldActionMessage = oldMessage as? HippoActionMessage, let newActionMessage = newMessage as? HippoActionMessage {
                oldActionMessage.updateObject(with: newActionMessage)
            }
        case .feedback:
            oldMessage.updateObject(with: newMessage)
        default:
            break
        }
    }
    
    func getMessageWith(muid: String?) -> HippoMessage? {
        guard let parsedMuid = muid else {
            return nil
        }
        if let index = messageHashMap[parsedMuid], index > 0, messages.count > index, messages[index].messageUniqueID == muid {
            return messages[index]
        }
        let index = messages.index(where: { (mes) -> Bool in
            return mes.messageUniqueID == parsedMuid
        })
        return index == nil ? nil : messages[index!]
    }
    func isMessageExist(message: HippoMessage) -> Bool {
        guard let muid = message.messageUniqueID, let _ = messageHashMap[muid] else {
            return false
        }
        return true
        
    }
    func updateMessageIfRequired(recievedMessage: HippoMessage) {
        if recievedMessage.type == .feedback, let muid = recievedMessage.messageUniqueID, let oldMessage = getMessageWith(muid: muid) {
            oldMessage.updateObject(with: recievedMessage)
        }
    }
    func appendMessageIfRequired(message: HippoMessage) {
        if isMessageExist(message: message) {
            return
        } else {
            message.status = .sent
            sentMessages.append(message)
            refreshHashMap()
        }
    }
    
    @objc fileprivate func checkForReconnection() {
        guard !isSubscribed() else {
            return
        }
        subscribe()
    }
    
    
    // MARK: - Methods
    func send(message: HippoMessage, completion: (() -> Void)?) {
        guard !message.isANotification() else {
            FayeConnection.shared.send(messageDict: message.getJsonToSendToFaye(), toChannelID: id.description, completion: {_ in completion?()})
            return
        }
        
        if !isSubscribed() {
            subscribe()
        }
        
        if message.messageUniqueID != nil {
            let value = messageHashMap[message.messageUniqueID!] ?? self.messages.count - 1
            set(message: message, positionInHashMap: value)
        }
        message.creationDateTime = Date()
        messageSender.addMessagesInQueueToSend(message: message)
        completion?()
    }
    
    fileprivate func set(message: HippoMessage, positionInHashMap position: Int) {
        messageHashMap[message.messageUniqueID!] = position
    }
    
    fileprivate func changeStatusToRead(message: HippoMessage) {
        if self.canChangeStatusOfMessagesToReadAllIf(messageReceived: message) {
            self.updateAllMessagesStatusToRead()
        } else {
            // Handle Later
        }
    }
    fileprivate func canHandleBotMessage(message: HippoMessage) -> Bool {
        switch message.type {
        case .quickReply:
            if message.values.isEmpty {
                message.status = ReadUnReadStatus.read
                self.sentMessages.append(message) // Appends the message in channel messages.
            } else {
                self.updateBotButtonMessage(newMessage: message) // Updates the quick reply message in the channel message.
            }
        case .botFormMessage:
            if !message.content.values.isEmpty {
                return false // Returns because already filled the form.
            } else {
                message.status = ReadUnReadStatus.read // Marks the status read.
            }
        case .feedback:
            if message.is_rating_given {
                self.upateFeedbackStatus(newMessage: message) // Updates the feedback message in the channel message.
            } else {
                
            }
        default:
            break
        }
        return true
    }
    fileprivate func unSubscribe(completion: HippoChannelHandler? = nil) {
        FayeConnection.shared.unsubscribe(fromChannelId: id.description, completion: { (success, error) in
            completion?(success, error)
        })
    }
    func send(dict: [String: Any], completion: @escaping  (Bool, NSError?) -> Void) {
        var json = dict
        json["channel_id"] = id.description
        
        FayeConnection.shared.send(messageDict: json, toChannelID: id.description) { (result) in
            completion(result.success, result.error?.error as NSError?)
        }
    }
    func send(publishable: FuguPublishable, completion: @escaping  (Bool, NSError?) -> Void) {
        var json = publishable.getJsonToSendToFaye()
        json["channel_id"] = id.description
        
        FayeConnection.shared.send(messageDict: json, toChannelID: id.description) { (result) in
            completion(result.success, result.error?.error as NSError?)
        }
    }
    
    func isSubscribed() -> Bool {
        return FayeConnection.shared.isChannelSubscribed(channelID: id.description)
    }
    
    func isConnected() -> Bool {
        return isSubscribed() && FayeConnection.shared.isConnected && FuguNetworkHandler.shared.isNetworkConnected
    }
    
    
    func canChangeStatusOfMessagesToReadAllIf(messageReceived: HippoMessage) -> Bool {
        return (messageReceived.typingStatus == .startTyping || messageReceived.notification == NotificationType.readAll) && !isMessageSentByMe(senderId: messageReceived.senderId)
    }
    
    // MARK: - Deintializer
    deinit {
        NotificationCenter.default.removeObserver(self)
        unSubscribe()
        saveMessagesInCache()
        print("Channel with \(id) Deintialized")
    }
    
}

extension HippoChannel: MessageSenderDelegate {
    func subscribeChannel(completion: @escaping (Bool) -> Void) {
        subscribe { (success, error) in
            completion(success)
        }
    }
    
    func messageSent(message: HippoMessage) {
        
        for (index, unsentMessage) in unsentMessages.enumerated() {
            if unsentMessage.messageUniqueID == message.messageUniqueID {
                unsentMessages.remove(at: index)
                sentMessages.append(message)
                break
            }
        }
        messageHashMap[message.messageUniqueID!] = sentMessages.count - 1
    }
    
    func messageExpired(message: HippoMessage) {
        delegate?.sendingFailedFor(message: message)
    }
    
    func duplicateMuidOf(message: HippoMessage) {
        let newUniqueID = String.generateUniqueId()
        let value = messageHashMap.removeValue(forKey: message.messageUniqueID!) ?? (messages.count - 1)
        message.messageUniqueID = newUniqueID
        set(message: message, positionInHashMap: value)
    }
    func messageSendingFailed(message: HippoMessage, result: FayeConnection.FayeResult) {
        guard let _ = result.error?.error else {
            return
        }
        message.wasMessageSendingFailed = true
        let showErrorMessage = result.error?.showError ?? false
        let messageToShow: String? = showErrorMessage ? result.error?.message : nil
        delegate?.cancelSendingMessage(message: message, errorMessage: messageToShow)
    }
    
}
