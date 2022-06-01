//
//  FilterManager.swift
//  Fugu
//
//  Created by Vishal on 31/05/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit



class FilterManager: NSObject {
    
    static var shared = FilterManager()
    static let paginationLimit = 10
    static let initalStart = 0
  
    var selectedChatStatus = [ChatStatus.open.rawValue]
    var selectedChatType = [Int]()
    var selectedLabelId = [Int]()
    var selectedChannelId = [Int]()
    var selectedAgentId = [Int]()
    
    var chatStatusArray = [labelWithId]()
    var chatTypeArray = [labelWithId]()
    var labelArray = [TagDetail]()
    var channelArray = [ChannelDetail]()

    var peopleArray = [SearchCustomerData]()
    var customChannelArray = [ChannelDetail]()
    var dateList = [DateFilterInfo]()
    var selectedDate: DateFilterInfo?
    
    override init() {
        chatTypeArray.removeAll()
        chatStatusArray.removeAll()
        labelArray.removeAll()
        channelArray.removeAll()
        peopleArray.removeAll()
        customChannelArray.removeAll()
        dateList.removeAll()
        
//        for each in tagList {
//            each.isSelected = false
//        }
//        for each in channelList {
//            each.isSelected = false
//        }
        
        labelArray = Business.shared.tags.clone()
        channelArray = Business.shared.channels.clone()
        
        selectedChatStatus = [ChatStatus.open.rawValue]
        selectedChatType = [Int]()
        selectedLabelId = [Int]()
        selectedChannelId = [Int]()
        
        chatStatusArray.append(labelWithId(label: HippoStrings.openChat , id: 1, isSelected: true))
        chatStatusArray.append(labelWithId(label: HippoStrings.closeChats, id: 2))
        
        dateList = DateFilterInfo.initalDate()
        
        BussinessProperty.current.isFilterApplied = false
    }
    
    func setChatArray(for type: ConversationType) {
        chatTypeArray.removeAll()
        switch type {
        case .allChat:
            chatTypeArray.append(labelWithId(label: "Unassigned", id: 2))
        default:
            chatTypeArray.append(labelWithId(label: "Unassigned", id: 2))
            chatTypeArray.append(labelWithId(label: "My chats", id: 1))
            chatTypeArray.append(labelWithId(label: "Tagged", id: 3))
        }
    }
    
    func resetData(convoType: ConversationType) {
        AgentConversationManager.selectedCustomerObject = nil
        FilterManager.shared = FilterManager()
        FilterManager.shared.setChatArray(for: convoType)
        BussinessProperty.current.isFilterApplied = false
    }
    
    
    class func searchPeople(with searchString: String, isLoadMore: Bool, searchOperator: String, isCustomAttr: Bool, searchKey: String, convoType: ConversationType, callback: @escaping((_ isSuccess: Bool, _ isPaginationRequired: Bool) -> Void)) {
     
        guard searchString.count > 2 else {
            callback(false, false)
            return
        }
        
        guard let agentInfo = HippoConfig.shared.agentDetail else {
            callback(false, false)
            return
        }
        
        var params: [String: Any] = ["access_token": agentInfo.fuguToken,
                                     "search_text": searchString,
                                     "channel_start": FilterManager.initalStart.toString(),
                                     "channel_end": FilterManager.paginationLimit.toString(),
                                     "user_start": FilterManager.initalStart.toString(),
                                     "user_end": FilterManager.paginationLimit.toString(),
                                     "is_my_chat": convoType == .myChat ? 1 : 0,
                                     "search_operator": searchOperator,
                                     "search_flow_type": 1,
                                     "search_filter": searchKey,
                                     "is_custom_attribute": isCustomAttr.intValue()
        ]
        
        if isLoadMore {
            params["user_start"] = FilterManager.shared.peopleArray.count.toString()
        }
        
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.searchPeople, para: params, extendedUrl: AgentEndPoints.search.rawValue) { responseObject, error, extendedUrl, statusCode in
            if let _ = error {
                callback(false, false)
            } else {
                if let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], let users = data["users"] as? [[String: Any]] {
                    var usersArray = [SearchCustomerData]()
                    
                    for each in users {
                        let obj = SearchCustomerData(dict: each)
                        usersArray.append(obj)
                    }
                    if isLoadMore {
                        FilterManager.shared.peopleArray.append(contentsOf: usersArray)
                    } else {
                        FilterManager.shared.peopleArray = usersArray
                    }
                    let totalUserCount = data["total_users"] as? Int ?? FilterManager.shared.peopleArray.count
                    
                    let isPaginationRequired = FilterManager.shared.peopleArray.count < totalUserCount
                    callback(true, isPaginationRequired)
                }
            }
        }
    }
    
    class func searchChannel(with searchString: String, isLoadMore: Bool, convoType: ConversationType, callback: @escaping((_ isSuccess: Bool, _ isPaginationRequired: Bool) -> Void)) {
        guard searchString.count > 2 else {
            callback(false, false)
            return
        }
        guard let agentInfo = HippoConfig.shared.agentDetail else {
            callback(false, false)
            return
        }
        
        var params: [String: Any] = ["access_token": agentInfo.fuguToken,
                                     "search_text": searchString,
                                     "channel_start": FilterManager.initalStart.toString(),
                                     "channel_end": FilterManager.paginationLimit.toString(),
                                     "user_start": FilterManager.initalStart.toString(),
                                     "user_end": FilterManager.paginationLimit.toString(),
                                     "is_my_chat": convoType == .myChat ? 1 : 0]
        
        if isLoadMore {
            params["channel_start"] = FilterManager.shared.customChannelArray.count.toString()
        }
        
         HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.searchPeople, para: params, extendedUrl: AgentEndPoints.search.rawValue) { responseObject, error, extendedUrl, statusCode in
             if let _ = error {
                 callback(false, false)
             } else {
                 if let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], let channels = data["channels"] as? [[String: Any]] {
                     var channelArray = [ChannelDetail]()
                     
                     for each in channels {
                         if let obj = ChannelDetail(json: each) {
                             obj.isDefaultChannel = false
                             channelArray.append(obj)
                         }
                     }
                     if isLoadMore {
                         FilterManager.shared.customChannelArray.append(contentsOf: channelArray)
                     } else {
                         FilterManager.shared.customChannelArray = channelArray
                     }
                     let totalUserCount = data["total_channels"] as? Int ?? FilterManager.shared.customChannelArray.count
                     let isPaginationRequired = FilterManager.shared.customChannelArray.count < totalUserCount
                     callback(true, isPaginationRequired)
                 }
             }
         }
    }
    
    class func shouldDisplayOptionFor(option: FilterOptionSection, convoType: ConversationType) -> Bool {
        switch option {
        case .agents:
            return convoType == .allChat
        case .channels, .chatType, .date, .labels, .people, .status:
            return true
        }
    }
    
    class func getCustomAttr(callback: @escaping ((_ isSuccess: Bool, _ attributes: [SearchCustomAttr]?) -> Void)){
        let params = getParamsForCustomAttributes()
        
        HTTPClient.shared.makeSingletonConnectionWith(method: .GET, enCodingType: .url, identifier: RequestIdenfier.customAttributes, para: params, extendedUrl: AgentEndPoints.customAttributes.rawValue) { responseObject, error, extendedUrl, statusCode in
            if let _ = error {
                callback(false, nil)
            } else {
                if let response = responseObject as? [String: Any], let data = response["data"] as? [[String: Any]] {
                    var attributeArray: [SearchCustomAttr] = []
                    
                    for attribute in data{
                        if let keyName = attribute["key_name"] as? String, let predicate = attribute["predicate_name"] as? String{
                            let attr = SearchCustomAttr(keyName: keyName, predicateName: predicate, isCustomKey: true)
                            attributeArray.append(attr)
                        }
                    }
                    
                    callback(true, attributeArray)
                    print(data, attributeArray)
                }
            }
        }
    }
    
    class func getParamsForCustomAttributes() -> [String: Any]{
        guard let agentInfo = HippoConfig.shared.agentDetail else {
            return [:]
        }
        
        let params: [String: Any] = [
            "access_token": agentInfo.fuguToken
        ]
        
        return params
    }
}

extension Int {
    func toString() -> String {
        return "\(self)"
    }
}
