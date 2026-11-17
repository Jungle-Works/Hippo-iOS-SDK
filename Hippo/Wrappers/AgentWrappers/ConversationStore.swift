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
    var p2pChats = [AgentConversation]()
    var supportChats = [AgentConversation]()
    var activeDirectChats = [AgentConversation]()
    var isMoreMyChatToLoad = false
    var isMoreAllChatToLoad = false
    var isMorep2pChatToLoad = false
    var isMoreSupportChatToLoad = false
    
    var channelUnreadHashMap: [Int: AgentConversation] = [:]
    
    func conversations(for type: ConversationType) -> [AgentConversation] {
        switch type {
        case .myChat:
            return myChats
        case .allChat:
            return allChats
        case .p2pChat:
            return p2pChats
        case .supportChat:
            return supportChats
        case .historyChat:
            return []
        }
    }
    
    func isMoreToLoad(for type: ConversationType) -> Bool {
        switch type {
        case .myChat:
            return isMoreMyChatToLoad
        case .allChat:
            return isMoreAllChatToLoad
        case .p2pChat:
            return isMorep2pChatToLoad
        case .supportChat:
            return isMoreSupportChatToLoad
        case .historyChat:
            return false
        }
    }
    
    func clearData() {
        myChats.removeAll()
        allChats.removeAll()
        p2pChats.removeAll()
        supportChats.removeAll()
        activeDirectChats.removeAll()
        isMoreMyChatToLoad = false
        isMoreAllChatToLoad = false
        isMorep2pChatToLoad = false
        isMoreSupportChatToLoad = false
        channelUnreadHashMap.removeAll()
    }
    
    func storeConversationToCache() {
        func json(of conversations: [AgentConversation]) -> [[String: Any]] {
            return conversations.map { $0.getJsonToStore() }
        }
        
        FuguDefaults.set(value: json(of: myChats), forKey: DefaultKey.myChatConversations)
        FuguDefaults.set(value: json(of: allChats), forKey: DefaultKey.allChatConversations)
        FuguDefaults.set(value: json(of: p2pChats), forKey: DefaultKey.p2pChatConversations)
        FuguDefaults.set(value: json(of: supportChats), forKey: DefaultKey.supportChatConversations)
    }
    
    func fetchAllCachedConversation() {
        loadCacheForMyChat()
        loadCacheForAllChat()
        loadCacheForP2PChat()
        loadCacheForSupportChat()
    }
    
    private func cachedConversations(forKey key: String) -> [AgentConversation]? {
        guard let json = FuguDefaults.object(forKey: key) as? [[String: Any]] else {
            return nil
        }
        return AgentConversation.getConversationArray(jsonArray: json)
    }
    
    func loadCacheForMyChat() {
        guard let cached = cachedConversations(forKey: DefaultKey.myChatConversations) else {
            return
        }
        self.myChats = cached
    }
    
    func loadCacheForAllChat() {
        guard let cached = cachedConversations(forKey: DefaultKey.allChatConversations) else {
            return
        }
        self.allChats = cached
    }
    
    func loadCacheForP2PChat() {
        guard let cached = cachedConversations(forKey: DefaultKey.p2pChatConversations) else {
            return
        }
        self.p2pChats = cached
    }
    
    func loadCacheForSupportChat() {
        guard let cached = cachedConversations(forKey: DefaultKey.supportChatConversations) else {
            return
        }
        // Support rows always carry the support channel type; the cache round-trip
        // must not lose it or AgentHomeConversationCell renders them as normal chats.
        cached.forEach { $0.channel_type = channelType.SUPPORT_CHAT_CHANNEL.rawValue }
        self.supportChats = cached
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
