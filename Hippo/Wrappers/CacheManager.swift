//
//  CacheManager.swift
//  Fugu
//
//  Created by Vishal on 20/08/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class CacheManager {
    
//    //MARK: Tags
//    class func storeTags(tags: [TagDetail]) {
//        let list = tags.getJsonToStore()
//        HippoConfig.folder.set(value: list, forKey: HippoDefaultKeys.tagsList)
//    }
//
//    class func getStoredTagDetail() -> [TagDetail] {
//        var tags: [TagDetail] = []
//
//        guard let json = HippoConfig.folder.object(forKey: HippoDefaultKeys.tagsList) as? [[String: Any]] else {
//            return tags
//        }
//        tags = TagDetail.parseTagDetail(data: json)
//        return tags
//    }
//
//    //MARK: Channel Details
//    class func storeChannelDetails(tags: [ChannelDetail]) {
//        let list = tags.getJsonToStore()
//        HippoConfig.folder.set(value: list, forKey: HippoDefaultKeys.channelDetails)
//    }
//
//    class func getStoredChannelDetail() -> [ChannelDetail] {
//        var channels: [ChannelDetail] = []
//
//        guard let json = HippoConfig.folder.object(forKey: HippoDefaultKeys.channelDetails) as? [[String: Any]] else {
//            return channels
//        }
//        channels = ChannelDetail.parselist(jsonList: json)
//        return channels
//    }
    
    //MARK: Agents
    class func storeAgents(agents: [Agent]) {
//        let list: [[String: Any]] = Agent.getJsonToStore(agents: agents)
        let list = Agent.getJsonToStore(agents: agents)
        FuguDefaults.set(value: list, forKey: DefaultKey.AgentsList)
    }
    class func getStoredAgents() -> [Agent] {
        var agents = [Agent]()
        guard let json = FuguDefaults.object(forKey: DefaultKey.AgentsList) as? [[String: Any]] else {
            return agents
        }
        agents = Agent.getArrayfrom(jsonArray: json)
        return agents
    }
    
//    //MARK: Saved or Canned replies
//    class func storeCannedReply(replies: [CannedReply]) {
//        let list: [[String: Any]] = CannedReply.getJsonToStore(replies: replies)
//        HippoConfig.folder.set(value: list, forKey: HippoDefaultKeys.CannedReplyList)
//    }
//
//    class func getStoredCannedReply() -> [CannedReply] {
//        var replies = [CannedReply]()
//
//        guard let json = HippoConfig.folder.object(forKey: HippoDefaultKeys.CannedReplyList) as? [[String: Any]] else {
//            return replies
//        }
//
//        replies = CannedReply.getArrayfrom(jsonArray: json)
//        return replies
//
//    }
//
//    //MARK: Storing login and personalData
//    class func storeLoginData(json: [String: Any]) {
//        HippoConfig.folder.set(value: json, forKey: HippoDefaultKeys.LoginData)
//    }
//    class func getStoredLoginData() -> [String: Any] {
//        guard let json = HippoConfig.folder.object(forKey: HippoDefaultKeys.LoginData) as? [String: Any] else {
//            return [:]
//        }
//        return json
//    }
//
//    //MARK: Storing Server App Config
//    class func storeServerAppConfig(json: [String: Any]) {
//        HippoConfig.folder.set(value: json, forKey: HippoDefaultKeys.appServerConfig)
//    }
//    class func getServerAppConfig() -> [String: Any] {
//        guard let json = HippoConfig.folder.object(forKey: HippoDefaultKeys.appServerConfig) as? [String: Any] else {
//            return [:]
//        }
//        return json
//    }
    
}
