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
    let botMessageID: String?
    
    var isReplyMessageSent: Bool = false
    var isGetMesssagesSuccess: Bool = false
    
    init(isSuccessful: Bool, error: Error?, channel: HippoChannel?, isChannelAvailableLocallay: Bool, botMessageID: String?) {
        self.isSuccessful = isSuccessful
        self.error = error
        self.channel = channel
        self.isChannelAvailableLocallay = isChannelAvailableLocallay
        self.botMessageID = botMessageID
    }
}

protocol HippoChannelDelegate: class {
    func newMessageReceived(newMessage: HippoMessage)
    func typingMessageReceived(newMessage: HippoMessage)
    func sendingFailedFor(message: HippoMessage)
    func cancelSendingMessage(message: HippoMessage, errorMessage: String?,errorCode : SocketClient.SocketError?)
    func channelDataRefreshed()
    func closeChatActionFromRefreshChannel()
}
struct CreateConversationWithLabelId {
    var replyMessage: HippoMessage?
    var botGroupId: Int?
    var labelId: Int
    var initalMessages: [HippoMessage]
    var channelName : String?
    
    func shouldSendInitalMessages() -> Bool {
        guard let gID = botGroupId else {
            return false
        }
        return gID > 0 && labelId > 0
    }
    
    func getJson() -> [String: Any] {
        var messagesList: [[String: Any]] = []
        var params: [String: Any] = [:]
        var skipReplyMessage: Bool = false
        
        for each in initalMessages {
            if each.messageUniqueID == nil {
                each.messageUniqueID = String.generateUniqueId()
            } else if each.messageUniqueID == replyMessage?.messageUniqueID {
                skipReplyMessage = true
            }
            var json: [String: Any] = each.getJsonToSendToFaye()
            
            if each.type == .consent {
                json["user_id"] = 0
                json["user_type"] = UserType.system.rawValue
            }
            
            messagesList.append(json)
            
        }
        
        if let replyMessage = replyMessage, !skipReplyMessage {
            if replyMessage.messageUniqueID == nil {
                replyMessage.messageUniqueID = String.generateUniqueId()
            }
            messagesList.append(replyMessage.getJsonToSendToFaye())
        }
        if let botGroupId = botGroupId {
            params["initiate_bot_group_id"] = botGroupId
        }
      
        if let vc = getLastVisibleController() as? HippoConversationViewController{
            if vc.storeResponse?.createNewChannel == true{
                //params["initial_bot_messages"] = []
            }else if !messagesList.isEmpty {
                params["initial_bot_messages"] = messagesList
            }
        }else if !messagesList.isEmpty {
            params["initial_bot_messages"] = messagesList
        }
        
        return params
    }
}

//TODO: - Subscribe Fail-safe -> subscribe channel again if it is disconnected
class HippoChannel {
    
    typealias HippoChannelCreationHandler = (_ result: HippoChannelCreationResult) -> Void
    typealias HippoChannelHandler = (_ success: Bool, _ error: Error?) -> Void
    typealias MessagesAndHashMap = (messages: [HippoMessage], hashmap: [String: Int])
    
    
    //MARK: Class variable
    static var botMessageMUID: String?
    
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
    var listener : SocketListner?
    
    private var messageSender: MessageSender!
    
    //TODO: - Auto Subscription Logic
    // MARK: - Intializer
    init(id: Int) {
        self.id = id
        guard id != -1 else {
            return
        }
        listener = SocketListner()
        addObserver()
        subscribe()
        startListening()
        addObserverIfAppIsKilled()
        loadCachedMessages()
        loadCachedHashMap()
        loadCachedChannelInfo()
        
        
        let uploadedMessages = unsentMessages.filter {$0.localImagePath == nil && $0.isSentByMe() }
        messageSender = MessageSender(messagesToSend: uploadedMessages, forChannelID: id, delegate: self)
    }
    
    func addObserverIfAppIsKilled() {
        NotificationCenter.default.addObserver(self, selector: #selector(HippoChannel.saveMessagesInCache), name: HippoVariable.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HippoChannel.saveMessagesInCache), name: HippoVariable.willResignActiveNotification, object: nil)
    }
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkForReconnection), name: .socketConnected, object: nil)
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
        
        let (messages, hashMap) = HippoMessage.getArrayFrom(json: thisChannelCache, chatType: nil)
        return (messages, hashMap)
    }
    
    class func getSentCachedMessagesFor(channelID: Int) -> MessagesAndHashMap {
        let thisChannelCache = getChannelSentMessageCacheFrom(withID: channelID)
        
        let (messages, hashMap) = HippoMessage.getArrayFrom(json: thisChannelCache, chatType: nil)
        return (messages, hashMap)
        
    }
    
    // MARK: - Create New Channel/Conversation
    static var hashmapTransactionIdToChannelID = [String: Int]()
    
    class func saveHashMapTransactionIdToChannelIDInCache(hashMap: [String: Int]) {
        
        var sourceDict = hashMap
        var uniqueValues = Set<Int>()
        var resultDict = [String: Int](minimumCapacity: sourceDict.count)
        //The reserveCapacity() function doesn't exist for Dictionaries, as pointed
        //out by Hamish in the comments. See the initializer with minimumCapacity,
        //above. That's the way you have to set up a dictionary with an initial capacity.
        //resultDict.reserveCapacity(sourceDict.count)
        for (key, value) in sourceDict {
            if !uniqueValues.contains(value) {
                uniqueValues.insert(value)
                resultDict[key] = value
            }
        }
        
//        FuguDefaults.set(value: hashMap, forKey: "hashmapTransactionIdToChannelID")
        FuguDefaults.set(value: resultDict, forKey: "hashmapTransactionIdToChannelID")
        
    }
    class func getHashMapTransactionIdToChannelIDFromCache() -> [String: Int] {
        return (FuguDefaults.object(forKey: "hashmapTransactionIdToChannelID") as? [String: Int] ?? [:])
    }    
    
    class func get(request: CreateConversationWithLabelId, completion: @escaping HippoChannelCreationHandler) {
        
        let params = getParamsToStartConversation(WithLabelId: request)
        createNewConversationWith(params: params, chatType: .other) { (result) in
            if result.isSuccessful {
                request.replyMessage?.status = .sent
            }
            completion(result)
        }
    }
    
    class func get(withFuguChatAttributes attributes: AgentDirectChatAttributes, completion: @escaping HippoChannelCreationHandler) {
        guard let params = attributes.getParamsToStartNewChat() else {
            let result = HippoChannelCreationResult(isSuccessful: false, error: HippoError.general, channel: nil, isChannelAvailableLocallay: false, botMessageID: nil)
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
                    let result = HippoChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false, botMessageID: nil)
                    completion(result)
                    return
            }
            
            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            let botMessageID: String? = String.parse(values: data, key: "bot_message_id")
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: false, botMessageID: botMessageID)
            if var transactionID = params["transaction_id"] as? String {
                if let otherUserUniqueKey = params["other_user_unique_key"] as? String{
                    if otherUserUniqueKey.trimWhiteSpacesAndNewLine().count > 0{
                        transactionID = transactionID + "-" + otherUserUniqueKey
                    }
                }
                hashmapTransactionIdToChannelID[transactionID] = channelID
                
                saveHashMapTransactionIdToChannelIDInCache(hashMap: HippoChannel.hashmapTransactionIdToChannelID)
                
            }
            completion(result)
        }
    }
    
//    class func get(withFuguChatAttributes attributes: FuguNewChatAttributes, completion: @escaping HippoChannelCreationHandler) {
    class func get(withFuguChatAttributes attributes: FuguNewChatAttributes, isComingFromConsultNow: Bool = false, methodIsOnlyCallForChannelAvailableInLocalOrNot: Bool = false, completion: @escaping HippoChannelCreationHandler) {
    
        if isComingFromConsultNow {
            let params = getParamsToStartConversation(fuguAttributes: attributes)
            createNewConversationWith(params: params, completion: completion)
        } else {
            
            let hashMapTransactionIdToChannelIDFromCache = getHashMapTransactionIdToChannelIDFromCache()
            if hashMapTransactionIdToChannelIDFromCache != [:]{
                hashmapTransactionIdToChannelID = hashMapTransactionIdToChannelIDFromCache
            }
            
            if var transactionID = attributes.transactionId, let otherUserUniqueKey = attributes.otherUniqueKey?.first{
                if otherUserUniqueKey.trimWhiteSpacesAndNewLine().count > 0{
                  transactionID = transactionID + "-" + otherUserUniqueKey
                }
                if FuguNewChatAttributes.isValidTransactionID(id: transactionID),
                let channelID = hashmapTransactionIdToChannelID[transactionID] {
                    
                    let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
                    let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: true, botMessageID: nil)
                    completion(result)
                    return
                    
                }
            }
            
            if methodIsOnlyCallForChannelAvailableInLocalOrNot == true{
                //methodIsOnlyCallForChannelAvailableInLocalOrNot = false
                let result = HippoChannelCreationResult(isSuccessful: false, error: nil, channel: nil, isChannelAvailableLocallay: false, botMessageID: nil)
                completion(result)
                return
            }
            
            let params = getParamsToStartConversation(fuguAttributes: attributes)
            createNewConversationWith(params: params, completion: completion)
        }
    }
    
    private class func createNewConversationWith(params: [String: Any], chatType: ChatType? = nil, completion: @escaping HippoChannelCreationHandler) {
        var requestParam = params
        if let parsedBotMessageMUID = botMessageMUID {
            requestParam["bot_form_muid"] = parsedBotMessageMUID
        }
        
        //requestParam["initiate_bot_group_id"] = 569
        
        HippoConfig.shared.log.debug("API_CREATE_CONVERSATION.....\(requestParam)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: requestParam, extendedUrl: FuguEndPoints.API_CREATE_CONVERSATION.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let data = responseDict["data"] as? [String: Any],
                let channelID = data["channel_id"] as? Int else {
                    HippoConfig.shared.log.debug("API_CREATE_CONVERSATION_ ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    let result = HippoChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false, botMessageID: nil)
                    completion(result)
                    return
            }
            
//            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            print("API_CREATE_CONVERSATION_RESPONSE******* ", response)
            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            channel.chatDetail?.agentAlreadyAssigned = data["agent_already_assigned"] as? Bool ?? false
            
            if channel.chatDetail == nil {
                channel.chatDetail = ChatDetail(json: data)
            } else if channel.chatDetail?.channelId == nil {
                channel.chatDetail?.channelId = channelID
            }
            
//            if let parsedChatType = chatType {
//                channel.chatDetail?.chatType = parsedChatType
//            }
            
            let botMessageID: String? = String.parse(values: data, key: "bot_message_id")
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: false, botMessageID: botMessageID)
            if var transactionID = params["transaction_id"] as? String {
                if let otherUserUniqueKey = (params["other_user_unique_key"] as? [String])?.first{
                    if otherUserUniqueKey.trimWhiteSpacesAndNewLine().count > 0{
                        transactionID = transactionID + "-" + (otherUserUniqueKey)
                    }
                }
                
                hashmapTransactionIdToChannelID[transactionID] = channelID
                
                saveHashMapTransactionIdToChannelIDInCache(hashMap: HippoChannel.hashmapTransactionIdToChannelID)
                
            }
            completion(result)
        }
    }
    
    class func getToCallAgent(withFuguChatAttributes attributes: FuguNewChatAttributes, agentEmail: String, completion: @escaping HippoChannelCreationHandler) {
        guard let transactionID = attributes.transactionId,
            FuguNewChatAttributes.isValidTransactionID(id: transactionID) else {
                let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: nil, isChannelAvailableLocallay: true, botMessageID: nil)
                completion(result)
                return
        }
        let params = getParamsToCallAgent(agentEmail: agentEmail, fuguAttributes: attributes)
        createNewConversationWith(params: params, completion: completion)
    }
    
    class func callAssignAgentApi(withParams params: [String: Any], completion: @escaping (Bool) -> Void) {//HippoChannelCreationHandler) {
        callAssignAgentApi(params: params, completion: completion)
    }
    private class func callAssignAgentApi(params: [String: Any],  completion: @escaping (Bool) -> Void) {//HippoChannelCreationHandler) {
        HippoConfig.shared.log.debug("API_AssignAgent.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.assignAgent.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    HippoConfig.shared.log.debug("API_AssignAgent ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    completion(false)
                    return
            }
            
            completion(true)
            
        }
    }
    
    /// Creates new support conversation.
    ///
    /// - Parameters:
    ///   - params: Parameters for creation.
    ///   - completion: Callback for new channel creation.
    class func createNewConversationForTicket(params: [String: Any], completion: @escaping HippoChannelCreationHandler) {
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CREATE_TICKET.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any], let data = responseDict["data"] as? [String: Any] else {
                let result = HippoChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false, botMessageID: nil)
                completion(result)
                return
            }
            let botMessageID: String? = String.parse(values: data, key: "bot_message_id")
            let result = HippoChannelCreationResult(isSuccessful: true, error: nil, channel: nil, isChannelAvailableLocallay: false, botMessageID: botMessageID)
            completion(result)
        }
    }
    
    
    class func getParamsToStartConversation(WithLabelId labelRequest: CreateConversationWithLabelId? = nil, fuguAttributes: FuguNewChatAttributes? = nil) -> [String: Any] {
       
        var params = [String: Any]()
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["en_user_id"] = HippoUserDetail.fuguEnUserID ?? -1
        
        if HippoConfig.shared.isSkipBot
        {
            params["skip_bot"] = "1"
        }
        
        if let unwrappedLabelId = labelRequest?.labelId {
            params["label_id"] = unwrappedLabelId
        }
        
        if let request = labelRequest, request.shouldSendInitalMessages() {
            params = params.updating(request.getJson())
        }
        
        var groupingTags = HippoConfig.shared.userDetail?.getUserTagNameArray() ?? [String]()
        
        if let attributeParams = fuguAttributes?.getParamsToStartNewChat() {
            params += attributeParams
        }
        if labelRequest != nil, HippoProperty.current.singleChatApp {
            var tags = params["tags"] as? [String] ?? []
            tags.append("iOS")
            params["tags"] = tags
        }
        
        //Check for getting new channelTags
        if let newGroupingTags = fuguAttributes?.groupingTag {
            groupingTags += newGroupingTags
        }
        params["grouping_tags"] = groupingTags

        if let skipBot = HippoProperty.current.skipBot {
            params["skip_bot"] = skipBot.intValue()
            params["skip_bot_reason"] = HippoProperty.current.skipBotReason ?? ""
        }
        if let ticketCustomAttributes = HippoProperty.current.ticketCustomAttributes, !ticketCustomAttributes.isEmpty {
            params["ticket_custom_attributes"] = ticketCustomAttributes
        }

        if HippoProperty.current.singleChatApp {
            params["multi_channel_label_mapping_app"] = 1
        }
        
        //if getCurrentLanguageLocale() != "en"{
        if (labelRequest?.botGroupId ?? 0) <= 0{
            params["multi_language_default_message"] = labelRequest?.initalMessages.first?.message
        }
        params["multi_language_label"] = labelRequest?.channelName
        //}
        
        return params
    }
    
    class func getParamsToCallAgent(agentEmail: String, fuguAttributes: FuguNewChatAttributes? = nil) -> [String: Any] {
        var params = [String: Any]()
        if let transactionID = fuguAttributes?.transactionId,
            FuguNewChatAttributes.isValidTransactionID(id: transactionID){
            params["transaction_id"] = transactionID
        }
        if let tempUserUniqueId = fuguAttributes?.otherUniqueKey {
            params["other_user_unique_key"] = tempUserUniqueId
        }
        params["agent_email"] = agentEmail
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["chat_type"] = 0
        params["app_version"] = fuguAppVersion
        params["device_type"] = Device_Type_iOS
        params["source_type"] = SourceType.SDK.rawValue
//        params["in_app_support_channel"] = 0
//        params["label_id"] = -1
//        params["grouping_tags"] = []
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
    
    @objc func saveMessagesInCache() {
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
        if message.messageUniqueID == nil {
            message.messageUniqueID = String.generateUniqueId()
        }
        refreshHashMap()
        let messageDict = message.getJsonToSendToFaye()
        
        HippoConfig.shared.log.debug("sendFormValues \(messageDict)", level: .socket)
       
        SocketClient.shared.send(messageDict: messageDict, toChannelID: id.description) { (result) in
            if result.isSuccess {
                message.status = ReadUnReadStatus.sent
                if message.type == .quickReply && !message.values.isEmpty {
                    self.updateBotButtonMessage(newMessage: message)
                }
            }
            message.wasMessageSendingFailed = !result.isSuccess
            message.creationDateTime = Date()
            completion()
        }
    }
    func subscribe(completion: HippoChannelHandler? = nil) {
        SocketClient.shared.subscribeSocketChannel(channel: id.description)
    }
    
    func startListening(){
        listener?.startListening(event: SocketEvent.SERVER_PUSH.rawValue, callback: { [weak self](data) in
            if let messageDict = data as? [String : Any]{
                
                if (messageDict["channel"] as? String)?.replacingOccurrences(of: "/", with: "") != self?.id.description{
                    return
                }
                
                HippoConfig.shared.log.trace("Active channel Recieveddddd -\(self?.id ?? 0000) >>>>> \(messageDict)", level: .socket)
                guard let weakSelf = self, weakSelf.handleByNotification(dict: messageDict) else {
                    return
                }
                let chatType = self?.chatDetail?.chatType
                guard let message = HippoMessage.createMessage(rawMessage: messageDict, chatType: chatType) else {
                    return
                }
                if message.type == .call {
                    if versionCode < 350 && HippoConfig.shared.appUserType == .agent{
                        DispatchQueue.main.async {
                            self?.signalReceivedFromPeer?(messageDict)
                            CallManager.shared.voipNotificationRecieved(payloadDict: messageDict)
                        }
                    }
                    return
                }
                
                self?.messageReceived(message: message)
            }
        })
    }
    
    
    //should Continue after handling NotificationType
    func handleByNotification(dict: [String: Any]) -> Bool {
        guard let rawNotificationType = Int.parse(values: dict, key: "notification_type"), let notificationType = NotificationType(rawValue: rawNotificationType) else {
            return true
        }
        switch notificationType {
        case .channelRefreshed:
            channelRefreshed(dict: dict)
            return false
        case .messageModified://message modified if its edit or deleted
            messageModified(dict: dict)
            return false
        case .message:
            print("***** \(notificationType)")
            return true
        default:
            break
        }
        return true
    }
    
    func messageModified(dict: [String: Any]){
        let chatType = self.chatDetail?.chatType
        guard let message = HippoMessage.createMessage(rawMessage: dict, chatType: chatType) else {
            return
        }
        
        
        if let channelId = dict["channel_id"] as? String{
            if channelId != String(HippoConfig.shared.getCurrentChannelId() ?? -1){
                return
            }
        }else if let channelId = dict["channel_id"] as? Int{
            if channelId != HippoConfig.shared.getCurrentChannelId(){
                return
            }
        }

        
        if let status = dict["status"] as? Int{
            switch status {
            case 1:
                ///*Deleted Message*/
                if dict["last_sent_by_id"] as? Int == currentUserId(){
                    message.message = HippoStrings.you + " " + HippoStrings.deleteMessage
                }else{
                    message.message = (dict["last_sent_by_full_name"] as? String ?? "") + " " + HippoStrings.deleteMessage
                }
                message.messageState = MessageState.MessageDeleted
            case 2:
                ///*Edited Message*/
                message.message = dict["edited_message"] as? String ?? ""
                message.messageState = MessageState.MessageEdited
            
            default:
                break
            }
            
            let messageReference = findAnyReferenceOf(message: message)
            
            if message.isSentByMe(), let refernece = messageReference {
                refernece.status = .sent
            }
            if let oldMessage = messageReference {
                let result = updateReferenceMessage(oldMessage: oldMessage, newMessage: message)
                if result {
                    return
                }
            }
        }
    }
    
    
    func channelRefreshed(dict: [String: Any]) {
        //ChannelId should be same as current channelId
        guard let channelId = Int.parse(values: dict, key: "channel_id"), id == channelId else {
            return
        }
        let closetheChat = dict["close_the_chat"] as? Int
        if closetheChat == 1{
            delegate?.closeChatActionFromRefreshChannel()
        }
        
        
        let rawSendingReplyDisabled = (dict["disable_reply"] as? Int) ?? 0
        let isSendingDisabled = rawSendingReplyDisabled == 1 ? true : false
        if isSendingDisabled {
            chatDetail?.disableReply = isSendingDisabled
            chatDetail?.allowAudioCall = !isSendingDisabled
            chatDetail?.allowVideoCall = !isSendingDisabled
        }
        
        if HippoConfig.shared.appUserType == .customer {
            chatDetail?.channelImageUrl = dict["channel_image_url"] as? String ?? chatDetail?.channelImageUrl
            chatDetail?.channelName = dict["label"] as? String
            delegate?.channelDataRefreshed()
        }
        
        let shouldShowToCustomer = Bool.parse(key: "is_customer_allowed_to_initiate_video_call", json: dict, defaultValue: false)
        guard let allUsers = dict["all_users"] as? [[String: Any]], !allUsers.isEmpty else {
            return
        }
        let users = User.parseArray(list: allUsers)
        guard let (_, _) = User.find(userId: currentUserId(), from: users), (shouldShowToCustomer || HippoConfig.shared.appUserType == .agent), let chatDetail = self.chatDetail else {
            return
        }
        chatDetail.allowAudioCall = Bool.parse(key: "allow_audio_call", json: dict) ?? chatDetail.allowAudioCall
        chatDetail.allowVideoCall = Bool.parse(key: "allow_video_call", json: dict) ?? chatDetail.allowVideoCall
        chatDetail.updatePeerData(users: users)
        
        if isSendingDisabled {
            chatDetail.allowAudioCall = !isSendingDisabled
            chatDetail.allowVideoCall = !isSendingDisabled
        }

        chatDetail.assignedAgentID = users.first?.userID ?? chatDetail.assignedAgentID
        chatDetail.assignedAgentName = users.first?.fullName ?? chatDetail.assignedAgentName
        if let vc = getLastVisibleController() as? HippoConversationViewController{
            vc.storeResponse?.restrictPersonalInfo = dict["restrict_personal_info_sharing"] as? Bool ?? false
        }
        
        delegate?.channelDataRefreshed()
    }
    
    
    func messageReceived(message: HippoMessage) {
        if let notificationType = message.notification, notificationType.rejectOnActive {
            HippoConfig.shared.log.debug("notification reject \(notificationType)", level: .custom)
            return
        }
        
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
        let messageReference = findAnyReferenceOf(message: message)
        
        if message.isSentByMe(), let refernece = messageReference {
            refernece.status = .sent
        }
        if let oldMessage = messageReference {
            let result = updateReferenceMessage(oldMessage: oldMessage, newMessage: message)
            if result {
                return
            }
        }
        appendMessageIfRequired(message: message)
        delegate?.newMessageReceived(newMessage: message)
    }
    
    //This function  return the value so the tableView should reload
    func updateReferenceMessage(oldMessage: HippoMessage, newMessage: HippoMessage) -> Bool {
        switch newMessage.type {
        case .consent:
            if let oldActionMessage = oldMessage as? HippoActionMessage, let newActionMessage = newMessage as? HippoActionMessage {
                oldActionMessage.updateObject(with: newActionMessage)
            }
        case .feedback, .leadForm:
            oldMessage.updateObject(with: newMessage)
            delegate?.channelDataRefreshed()
        case .paymentCard:
//            oldMessage.cards = newMessage.cards
//            oldMessage.selectedCardId = newMessage.selectedCardId
//            oldMessage.fallbackText = newMessage.fallbackText
//            oldMessage.selectedCard = newMessage.selectedCard
//            return false
            
            oldMessage.cards = newMessage.cards
            oldMessage.selectedCard = newMessage.selectedCard
            oldMessage.fallbackText = newMessage.fallbackText
            if HippoConfig.shared.appUserType == .agent {
                if (oldMessage.selectedCardId ?? "") == (newMessage.selectedCardId ?? "") {
                    return true
                }
            }
            oldMessage.selectedCardId = newMessage.selectedCardId
            return false
        case .normal:
            if newMessage.notification == NotificationType.messageModified{
                oldMessage.updateMessageForEditDelete(with: newMessage)
                delegate?.channelDataRefreshed()
            }
        default:
            break
        }
        return true
    }
    
    func findAnyReferenceOf(message: HippoMessage) -> HippoMessage? {
        let muid = message.messageUniqueID
        let messageID = message.messageId
        
        return getMessageWith(muid: muid) ?? getMessageWith(messageId: messageID)
    }
    func getMessageWith(messageId: Int?) -> HippoMessage? {
        guard let parsedMessageId = messageId, parsedMessageId > 0 else {
            return nil
        }
        let index = messages.firstIndex(where: { (mes) -> Bool in
            return mes.messageId == parsedMessageId
        })
        return index == nil ? nil : messages[index!]
    }
    func getMessageWith(muid: String?) -> HippoMessage? {
        guard let parsedMuid = muid else {
            return nil
        }
        if let index = messageHashMap[parsedMuid], index > 0, messages.count > index, messages[index].messageUniqueID == muid {
            return messages[index]
        }
        let index = messages.firstIndex(where: { (mes) -> Bool in
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
            SocketClient.shared.send(messageDict: message.getJsonToSendToFaye(), toChannelID: id.description, completion: {_ in completion?()})
            return
        }
        if isSendingDisabled && !(message.type == .feedback){
            print("----sending is disabled")
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
        case .leadForm:
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
        SocketClient.shared.unsubscribeSocketChannel(fromChannelId: id.description)
    }
    func send(dict: [String: Any], completion: @escaping  (Bool, NSError?) -> Void) {
        var json = dict
        json["channel_id"] = id.description
        
        SocketClient.shared.send(messageDict: json, toChannelID: id.description) { (result) in
            completion(result.isSuccess, result.error as NSError?)
        }
    }
    func send(publishable: FuguPublishable, completion: @escaping  (Bool, NSError?) -> Void) {
        var json = publishable.getJsonToSendToFaye()
        json["channel_id"] = id.description
        
        SocketClient.shared.send(messageDict: json, toChannelID: id.description) { (response) in
            completion(response.isSuccess, response.error as NSError?)
        }
        
//        FayeConnection.shared.send(messageDict: json, toChannelID: id.description) { (result) in
//            completion(result.success, result.error?.error as NSError?)
//        }
    }
    
    func isSubscribed() -> Bool {
        return SocketClient.shared.isChannelSubscribed(channel: id.description)
    }
    
    func isConnected() -> Bool {
        return isSubscribed() && SocketClient.shared.isConnected() && FuguNetworkHandler.shared.isNetworkConnected
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
    
    func deinitObservers(){
        NotificationCenter.default.removeObserver(self)
        unSubscribe()
        saveMessagesInCache()
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
    func messageSendingFailed(message: HippoMessage, result: SocketClient.EventAckResponse) {
        guard let _ = result.error else {
            return
        }
        message.wasMessageSendingFailed = true
        let showErrorMessage = result.error?.localizedDescription == "" ? false : true
        let messageToShow: String? = showErrorMessage ? result.error?.localizedDescription : nil
        delegate?.cancelSendingMessage(message: message, errorMessage: messageToShow, errorCode: result.error)
    }
    
}
