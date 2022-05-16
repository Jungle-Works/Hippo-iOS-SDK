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
//    var savedReplies: [CannedReply] = []
//    var tags: [TagDetail] = []
//    var channels: [ChannelDetail] = []
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
//        if let tagList = data["tags"] as? [[String: Any]] {
//            self.tags = TagDetail.parseTagDetail(data: tagList)
//        }
//        if let channelList = data["channel_filter"] as? [[String: Any]] {
//            self.channels = ChannelDetail.parselist(jsonList: channelList)
//        }
////        CacheManager.storeTags(tags: tags)
////        CacheManager.storeChannelDetails(tags: channels)
    }
    
    func restoreAllSavedInfo() {
        agents = CacheManager.getStoredAgents()
//        savedReplies = CacheManager.getStoredCannedReply()
    }
    
    func clearData() {
        self.agents.removeAll()
//        self.expiryInfo = nil
//        self.savedReplies.removeAll()
//        self.properties = BusinessProperty(loginData: [:])
//
//        self.tags.removeAll()
//        self.channels.removeAll()
//        self.versionInfo = nil
//        self.constants = BusinessConstants()
    }
}
