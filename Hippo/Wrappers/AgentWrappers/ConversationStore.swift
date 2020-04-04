//
//  ConversationPersistancyManager.swift
//  SDKDemo1
//
//  Created by Vishal on 19/09/18.
//

import Foundation


class ConversationStore {
    static let shared = ConversationStore()
    
    var myChats = [AgentConversation]()
    var allChats = [AgentConversation]()
    var activeDirectChats = [AgentConversation]()
    var isMoreMyChatToLoad = false
    var isMoreAllChatToLoad = false
    
    var channelUnreadHashMap: [Int: AgentConversation] = [:]
    
    
    func clearData() {
        myChats.removeAll()
        allChats.removeAll()
        activeDirectChats.removeAll()
        isMoreMyChatToLoad = false
        isMoreAllChatToLoad = false
        channelUnreadHashMap.removeAll()
    }
    
    func storeConversationToCache() {
        var myChatsJson = [[String: Any]]()
        var allChatsJson = [[String: Any]]()
        
        for each in myChats {
            let json = each.getJsonToStore()
            myChatsJson.append(json)
        }
        for each in allChats {
            let json = each.getJsonToStore()
            allChatsJson.append(json)
        }
        FuguDefaults.set(value: myChatsJson, forKey: DefaultKey.myChatConversations)
        FuguDefaults.set(value: allChatsJson, forKey: DefaultKey.allChatConversations)
    }
    
    func fetchAllCachedConversation() {
        loadCacheForMyChat()
        loadCacheForAllChat()
    }
    
    func loadCacheForMyChat() {
        guard let myChatsJson = FuguDefaults.object(forKey: DefaultKey.myChatConversations) as? [[String: Any]] else {
            return
        }
        self.myChats = AgentConversation.getConversationArray(jsonArray: myChatsJson)
    }
    
    func loadCacheForAllChat() {
        guard let allChatsJson = FuguDefaults.object(forKey: DefaultKey.allChatConversations) as? [[String: Any]] else {
            return
        }
         self.allChats = AgentConversation.getConversationArray(jsonArray: allChatsJson)
    }
}


class ConversationStoreManager {
    
    private let store = ConversationStore.shared
    
    func readAllNotificationFor(channelID: Int) {
        let myChatIndex = AgentConversation.getIndex(in: store.myChats, for: channelID)
        let allChatIndex = AgentConversation.getIndex(in: store.allChats, for: channelID)
        
        if myChatIndex != nil {
            let conversation = store.myChats[myChatIndex!]
            conversation.unreadCount = 0
        }
        if allChatIndex != nil {
            let conversation = store.allChats[allChatIndex!]
            conversation.unreadCount = 0
        }
        
        resetForChannel(channelId: channelID)
        pushTotalUnreadCount()
    }
    
    func refreshChannelUnreadHashMap() {
        for each in store.allChats where each.channel_id != nil {
            let channelId = each.channel_id ?? -1
            store.channelUnreadHashMap[channelId] = each
        }
    }
    
    func updateUnreadCountHashMap(channelId: Int) {
        guard let index = AgentConversation.getIndex(in: store.allChats, for: channelId), index < store.allChats.count else {
            return
        }
        store.channelUnreadHashMap[channelId] = store.allChats[index]
    }
    
}
