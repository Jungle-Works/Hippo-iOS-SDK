//
//  FuguChannel.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 20/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

struct FuguChannelCreationResult {
   let isSuccessful: Bool
   let error: Error?
   let channel: FuguChannel?
    let isChannelAvailableLocallay: Bool
 }

protocol FuguChannelDelegate: class {
   func newMessageReceived(message: FuguMessage)
}

//TODO: - Subscribe Fail-safe -> subscribe channel again if it is disconnected
class FuguChannel {
   
   typealias FuguChannelCreationHandler = (_ result: FuguChannelCreationResult) -> Void
   typealias FuguChannelHandler = (_ success: Bool, _ error: Error?) -> Void
   
   let id: Int
   weak var delegate: FuguChannelDelegate?
   var messages = [FuguMessage]()
   
   //TODO: - Auto Subscription Logic
   // MARK: - Intializer
   init(id: Int) {
      self.id = id
      subscribe()
      addObserverIfAppIsKilled()
      loadCachedMessages()
   }
   
   func addObserverIfAppIsKilled() {
      NotificationCenter.default.addObserver(self, selector: #selector(FuguChannel.saveMessagesInCache), name: .UIApplicationWillTerminate, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(FuguChannel.saveMessagesInCache), name: .UIApplicationWillResignActive, object: nil)
   }
   
   // MARK: - Create New Channel/Conversation
   static var hashmapTransactionIdToChannelID = [String: Int]()
   
   class func get(withLabelId labelId: String, completion: @escaping FuguChannelCreationHandler) {
      
      let params = getParamsToStartConversation(WithLabelId: labelId)
      createNewConversationWith(params: params, completion: completion)
   }
   
    class func get(withFuguChatAttributes attributes: FuguNewChatAttributes, completion: @escaping FuguChannelCreationHandler) {
        let params = getParamsToStartConversation(fuguAttributes: attributes)
        if attributes.isInAppChat {
            createNewConversationWith(params: params, completion: completion)
            return
        }
        
        if let transactionID = attributes.transactionId, FuguNewChatAttributes.isValidTransactionID(id: transactionID),
            let channelID = hashmapTransactionIdToChannelID[transactionID] {
            
            let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
            let result = FuguChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: true)
            completion(result)
            return
        }
        createNewConversationWith(params: params, completion: completion)

    }
   
   class func createNewConversationWith(params: [String: Any], completion: @escaping FuguChannelCreationHandler) {
      
      HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CREATE_CONVERSATION.rawValue) { (response, error, _, statusCode) in
         guard let responseDict = response as? [String: Any],
            let data = responseDict["data"] as? [String: Any],
            let channelID = data["channel_id"] as? Int else {
               
                let result = FuguChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false)
               completion(result)
               return
         }
         
         let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
        let result = FuguChannelCreationResult(isSuccessful: true, error: nil, channel: channel, isChannelAvailableLocallay: false)
         if let transactionID = params["transaction_id"] as? String {
            hashmapTransactionIdToChannelID[transactionID] = channelID
         }
         completion(result)
      }
   }
    class func createNewConversationForTicket(params: [String: Any], completion: @escaping FuguChannelCreationHandler) {
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CREATE_TICKET.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any], let _ = responseDict["data"] else {
                    let result = FuguChannelCreationResult(isSuccessful: false, error: error, channel: nil, isChannelAvailableLocallay: false)
                    completion(result)
                    return
            }
            
            let result = FuguChannelCreationResult(isSuccessful: true, error: nil, channel: nil, isChannelAvailableLocallay: false)
            completion(result)
        }
    }
class func getParamsToStartConversation(WithLabelId labelId: String? = nil, fuguAttributes: FuguNewChatAttributes? = nil) -> [String: Any] {
      var params = [String: Any]()
      params["app_secret_key"] = HippoConfig.shared.appSecretKey
      params["en_user_id"] = HippoConfig.shared.userDetail?.fuguEnUserID ?? -1
      
      if let unwrappedLabelId = labelId {
         params["label_id"] = unwrappedLabelId
      }
      
      if let attributeParams = fuguAttributes?.getParamsToStartNewChat() {
         params += attributeParams
      }
      return params
   }
   
   
   // MARK: - Messages
   private func loadCachedMessages() {
      let sentMessages = getSentCachedMessages()
      let unsentMessages = getUnsentCachedMessages()
      
      messages = sentMessages + unsentMessages
   }
   
   private func getUnsentCachedMessages() -> [FuguMessage] {
      let cacheOfAllChannels = FuguDefaults.object(forKey: DefaultName.unsentMessagesData.rawValue) as? [String: Any]
      let thisChannelCache = getChannelMessageCacheFrom(allChannelCache: cacheOfAllChannels)
      
      let messages = FuguMessage.getArrayFrom(json: thisChannelCache)
      return messages
   }
   
   private func getSentCachedMessages() -> [FuguMessage] {
      let cachedOfAllChannels = FuguDefaults.object(forKey: DefaultName.sentMessagesData.rawValue) as? [String: Any]
      let thisChannelCache = getChannelMessageCacheFrom(allChannelCache: cachedOfAllChannels)
      
      let messages = FuguMessage.getArrayFrom(json: thisChannelCache)
      return messages
   }
   
   private func getChannelMessageCacheFrom(allChannelCache: [String: Any]?) -> [[String: Any]] {
      let thisChannelCache = allChannelCache?[id.description] as? [[String: Any]] ?? []
      return thisChannelCache
   }
   
   @objc fileprivate func saveMessagesInCache() {
      var arrayOfSentMessages = [[String: Any]]()
      var arrayOfUnsentMessages = [[String: Any]]()
      
      for message in messages {
         if message.status == .none {
            message.wasMessageSendingFailed = true
            let messageDict = message.getDictToSaveInCache()
            arrayOfUnsentMessages.append(messageDict)
         } else {
            let messageDict = message.getDictToSaveInCache()
            arrayOfSentMessages.append(messageDict)
         }
      }
      
      //TODO: - Refactor this
      
      var sentMessageObject = (FuguDefaults.object(forKey: DefaultName.sentMessagesData.rawValue) as? [String: Any]) ?? [String: Any]()
      var unsentMessageObject = FuguDefaults.object(forKey: DefaultName.unsentMessagesData.rawValue) as? [String: Any] ?? [String: Any]()
      
      sentMessageObject[id.description] = arrayOfSentMessages
      unsentMessageObject[id.description] = arrayOfUnsentMessages
      
      FuguDefaults.set(value: sentMessageObject, forKey: DefaultName.sentMessagesData.rawValue)
      FuguDefaults.set(value: unsentMessageObject, forKey: DefaultName.unsentMessagesData.rawValue)
   }
   
   
   func isMessageSentByMe(senderId: Int) -> Bool {
      let currentUserId = HippoConfig.shared.userDetail?.fuguUserID ?? -1
      return currentUserId == senderId
   }
   
   fileprivate func updateAllMessagesStatusToRead() {
      for message in messages {
         if message.status != .none {
            message.status = .read
         }
      }
   }
   
   
   // MARK: - Methods
   func send(message: FuguMessage, completion: @escaping () -> Void) {
      
      guard HippoConnection.isNetworkConnected else {
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
      
      FayeConnection.shared.send(messageDict: messageDict, toChannelID: id.description) { (success) in
         if success {
            message.status = ReadUnReadStatus.sent
         }
         message.wasMessageSendingFailed = !success
         message.creationDateTime = Date()
         completion()
      }
   }
   
   @objc fileprivate func subscribe(completion: FuguChannelHandler? = nil) {
      FayeConnection.shared.subscribeTo(channelId: id.description, completion: { (success) in
         completion?(success, nil)
      }) { [weak self] (messageDict) in
         guard let message = FuguMessage(dict: messageDict), self != nil else {
            return
         }
         
         if !message.isANotification() &&  !self!.isMessageSentByMe(senderId: message.senderId) {
            self?.messages.append(message)
         }
        
         if message.isANotification() && self!.canChangeStatusOfMessagesToReadAllIf(messageReceived: message) {
            self?.updateAllMessagesStatusToRead()
         }
         
         self?.delegate?.newMessageReceived(message: message)
      }
   }
   
   fileprivate func unSubscribe(completion: FuguChannelHandler? = nil) {
      FayeConnection.shared.unsubscribe(fromChannelId: id.description, completion: { (success, error) in
         completion?(success, error)
      })
   }
   
   func isSubscribed() -> Bool {
      return FayeConnection.shared.isChannelSubscribed(channelID: id.description)
   }
   
   func canChangeStatusOfMessagesToReadAllIf(messageReceived: FuguMessage) -> Bool {
      return (messageReceived.typingStatus == .startTyping || messageReceived.notification == NotificationType.read_all) && !isMessageSentByMe(senderId: messageReceived.senderId)
   }
   
   // MARK: - Deintializer
   deinit {
      NotificationCenter.default.removeObserver(self)
      unSubscribe()
      saveMessagesInCache()
      print("Channel with \(id) Deintialized")
   }
   
}

