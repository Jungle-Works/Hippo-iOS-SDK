//
//  ChatInfoManager.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 16/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class ChatInfoManager: NSObject {
    struct UpdateChannelTagRequest {
        let tags: [TagDetail]
        let channelId: Int
        let enableLoader: Bool
    }
    
    static let sharedInstance = ChatInfoManager()
    
    func getAllTags(showLoader: Bool, sortList: Bool, exsitingTagsArray: [TagDetail], handler: @escaping (([TagDetail]?) -> ())) {
        
        guard HippoConfig.shared.appUserType == .agent, let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            handler(nil)
            return
        }
        
        let dict: [String: Any] = ["access_token": agent.fuguToken,
                                   "device_type": Device_Type_iOS,
                                   "app_version": fuguAppVersion]
        
        HippoConfig.shared.log.debug("API_Get tags.....\(dict)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: showLoader, para: dict, extendedUrl: AgentEndPoints.getAllTags.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                  let statusCode = responseDict["statusCode"] as? Int, statusCode == 200, let data = responseDict["data"] as? [String: Any], let tags = data["tags"] as? [[String: Any]] else {
                      HippoConfig.shared.log.debug("API_Gettags ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                      handler(nil)
                      return
                  }
            let tagsArray = TagDetail.parseTagDetailWithSelected(data: tags, sortList: sortList, existingTagsArray: exsitingTagsArray)
            handler(tagsArray)
        }
    }
    
    func createNewTag(showLoader: Bool, param: [String: Any], handler: @escaping ((TagDetail?) -> ())) {
        guard HippoConfig.shared.appUserType == .agent, let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            handler(nil)
            return
        }
        
        var params: [String : Any] = ["access_token": agent.fuguToken,
                                      "device_type": Device_Type_iOS,
                                      "app_version": fuguAppVersion]
        
        for (key, value) in param {
            params[key] = value
        }
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: showLoader, para: params, extendedUrl: AgentEndPoints.createTags.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any],
                  let statusCode = responseDict["statusCode"] as? Int, statusCode == 200, let data = responseDict["data"] as? [String: Any], let rawTag = data["tag"] as? [String: Any] else {
                      HippoConfig.shared.log.debug("API_Gettags ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                      handler(nil)
                      return
                  }
            let tag = TagDetail(json: rawTag)
            handler(tag)
        }
    }
    
    
    func useCreatedTag(showLoader: Bool, param: [String: Any], handler: @escaping ((TagDetail?) -> Void)) {
        
        guard HippoConfig.shared.appUserType == .agent, let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            handler(nil)
            return
        }
        
        var params: [String : Any] = ["access_token": agent.fuguToken,
                                      "device_type": Device_Type_iOS,
                                      "app_version": fuguAppVersion]
        for (key, value) in param {
            params[key] = value
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: showLoader, para: params, extendedUrl: AgentEndPoints.assignTags.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any],
                  let statusCode = responseDict["statusCode"] as? Int, statusCode == 200, let data = responseDict["data"] as? [String: Any], let rawTag = data["tag"] as? [String: Any] else {
                      HippoConfig.shared.log.debug("API_Gettags ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                      handler(nil)
                      return
                  }
            let tag = TagDetail(json: rawTag)
            handler(tag)
        }
    }
    
    func updateChannelTags(request: UpdateChannelTagRequest, handler: @escaping ((_ success: Bool) -> ())) {
        guard HippoConfig.shared.appUserType == .agent, let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            handler(false)
            return
        }
        
        var params: [String : Any] = ["access_token": agent.fuguToken,
                                      "channel_id": request.channelId]
        var tagIds: [[String: Any]] = []
        
        for each in request.tags {
            guard let id = each.tagId else {
                continue
            }
            let tag: [String: Any] = ["tag_id": id,
                                      "status": each.isSelected.intValue()]
            tagIds.append(tag)
        }
        if !tagIds.isEmpty {
            params["tagIds"] = tagIds
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.assignTagsV2.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any],
                  let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                      HippoConfig.shared.log.debug("API_Gettags ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                      handler(false)
                      return
                  }
            handler(true)
        }
    }
}
