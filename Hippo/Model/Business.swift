//
//  Business.swift
//  HippoAgent
//
//  Created by Vishal on 18/06/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class Business {
    static let shared = Business()
    
    var agents: [Agent] = []
    var savedReplies: [CannedReply] = []
    var tags: [TagDetail] = []
    var channels: [ChannelDetail] = []
//
//    var properties = BusinessProperty(loginData: [:])
//    var expiryInfo: ExpiryInfo?
//    var versionInfo: VersionInfo?
//    var constants = BusinessConstants()
    
    
    func updateDataFromLogin(data: [String: Any]) {
//        self.properties = BusinessProperty(loginData: data)
//
//        if let expiryInfo = data["expiry_info"] as? [String: Any] {
//           self.expiryInfo = ExpiryInfo(json: expiryInfo)
//        }
//
//        if let rawVersion = data["version"] as? [String: Any], !rawVersion.isEmpty {
//            self.versionInfo = VersionInfo(json: rawVersion)
//        }
        if let tagList = data["tags"] as? [[String: Any]] {
            self.tags = TagDetail.parseTagDetail(data: tagList)
        }
        if let channelList = data["channel_filter"] as? [[String: Any]] {
            self.channels = ChannelDetail.parselist(jsonList: channelList)
        }
        
        if CacheManager.getStoredChannelDetail().isEmpty{
            self.getChannelIds()
        }else{
            self.channels = CacheManager.getStoredChannelDetail()
        }
        
////        CacheManager.storeTags(tags: tags)
////        CacheManager.storeChannelDetails(tags: channels)
        if CacheManager.getStoredTagDetail().isEmpty{
              ChatInfoManager.sharedInstance.getAllTags(showLoader: false, sortList: true, exsitingTagsArray: [TagDetail]()) { (result) in
                guard let tags = result else {
                    return
                }
                self.tags = tags
                CacheManager.storeTags(tags: tags)
            }
        }else{
            self.tags = CacheManager.getStoredTagDetail()
        }
    }
    
    func restoreAllSavedInfo() {
        let agents = CacheManager.getStoredAgents()
        if agents.isEmpty{
            AgentConversationManager.getAgentsList { [weak self] result in
                self?.agents = CacheManager.getStoredAgents()
            }
        }else{
            self.agents = agents
        }
        
        savedReplies = CacheManager.getStoredCannedReply()
    }
    
    func clearData() {
        self.agents.removeAll()
//        self.expiryInfo = nil
        self.savedReplies.removeAll()
//        self.properties = BusinessProperty(loginData: [:])
//
//        self.tags.removeAll()
        self.channels.removeAll()
//        self.versionInfo = nil
//        self.constants = BusinessConstants()
    }
    
    func getChannelIds() {
        guard let agent = HippoConfig.shared.agentDetail else {
            return
        }
         
        let params: [String : Any] = ["access_token": agent.fuguToken,
                                      "business_id": agent.businessId]
         
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.getAllChannelIdentfier, para: params, extendedUrl: AgentEndPoints.getChannelIds.rawValue) { [weak self] responseObject, error, extendedUrl, statusCode in
            if let response = responseObject as? [String: Any], let kData = response["data"] as? [String: Any], let channels = kData["channels"] as? [[String : Any]], let weakSelf = self {
                weakSelf.channels = ChannelDetail.parselist(jsonList: channels)
                CacheManager.storeChannelDetails(tags: weakSelf.channels)
            }
        }
    }
}
