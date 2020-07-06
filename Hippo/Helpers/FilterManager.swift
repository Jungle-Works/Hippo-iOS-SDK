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
//    var selectedChatType = [Int]()
//    var selectedLabelId = [Int]()
//    var selectedChannelId = [Int]()
//    var selectedAgentId = [Int]()
    
    var chatStatusArray = [labelWithId]()
//    var chatTypeArray = [labelWithId]()
//    var labelArray = [TagDetail]()
//    var channelArray = [ChannelDetail]()
//
//    var peopleArray = [SearchCustomerData]()
//    var customChannelArray = [ChannelDetail]()
//    var dateList = [DateFilterInfo]()
//    var selectedDate: DateFilterInfo?
    
    override init() {
//        chatTypeArray.removeAll()
        chatStatusArray.removeAll()
//        labelArray.removeAll()
//        channelArray.removeAll()
//        peopleArray.removeAll()
//        customChannelArray.removeAll()
//        dateList.removeAll()
        
//        for each in tagList {
//            each.isSelected = false
//        }
//        for each in channelList {
//            each.isSelected = false
//        }
        
//        labelArray = Business.shared.tags.clone()
//        channelArray = Business.shared.channels.clone()
        
        selectedChatStatus = [ChatStatus.open.rawValue]
//        selectedChatType = [Int]()
//        selectedLabelId = [Int]()
//        selectedChannelId = [Int]()
        
        chatStatusArray.append(labelWithId(label: HippoStrings.openChat , id: 1, isSelected: true))
        chatStatusArray.append(labelWithId(label: HippoStrings.closeChat, id: 2))
//        chatStatusArray.append(labelWithId(label: "Open chats", id: 1))
//        chatStatusArray.append(labelWithId(label: "Closed chats", id: 2))
        
//        dateList = DateFilterInfo.initalDate()
        
        BussinessProperty.current.isFilterApplied = false
        
    }
    
//    private func setChatArray(for type: CurrentScreen) {
//        switch type {
//        case .allChat:
//            chatTypeArray.append(labelWithId(label: "Unassigned", id: 2))
//        default:
//            chatTypeArray.append(labelWithId(label: "Unassigned", id: 2))
//            chatTypeArray.append(labelWithId(label: "My chats", id: 1))
//            chatTypeArray.append(labelWithId(label: "Tagged", id: 3))
//        }
//    }
    func resetData() {
//        ConversationManager.sharedInstance.selectedCustomerObject = nil
        FilterManager.shared = FilterManager()
//        FilterManager.shared.setChatArray(for: LeftSideMenuPresenter.shared.currentScreenActive)
        BussinessProperty.current.isFilterApplied = false        
    }
    
    
//    class func searchPeople(with searchString: String, isLoadMore: Bool, callback: @escaping((_ isSuccess: Bool, _ isPaginationRequired: Bool) -> Void)) {
//        if isConnectedToInternet == false {
//            showAlert(lastVisibleController, title: nil, message: Messages.NoInternetMessage, actionComplete: nil)
//            callback(false, false)
//            return
//        }
//        guard searchString.count > 2 else {
//            callback(false, false)
//            return
//        }
//
//        guard let accessToken = PersonInfo.getAccessToken() else {
//            callback(false, false)
//            return
//        }
//
//        var params: [String: Any] = ["access_token": accessToken,
//                                     "search_text": searchString,
//                                     "channel_start": FilterManager.initalStart.toString(),
//                                     "channel_end": FilterManager.paginationLimit.toString(),
//                                     "user_start": FilterManager.initalStart.toString(),
//                                     "user_end": FilterManager.paginationLimit.toString(),
//                                     "is_my_chat": LeftSideMenuPresenter.shared.currentScreenActive == .myChat ? 1 : 0]
//
//        if isLoadMore {
//            params["user_start"] = FilterManager.shared.peopleArray.count.toString()
//        }
//
//        HTTPRequest(path: EndPoints.search, parameters: params, encoding: .json)
//        .config(isIndicatorEnable: false, isAlertEnable: false, isNetworkAlertEnable: false)
//            .handler { (response) in
//                guard response.isSuccess, let value = response.value as? [String: Any], let data = value["data"] as? [String: Any], let users = data["users"] as? [[String: Any]] else {
//                    callback(false, false)
//                    return
//                }
//                var usersArray = [SearchCustomerData]()
//
//                for each in users {
//                    if let obj = SearchCustomerData(JSON: each) {
//                        usersArray.append(obj)
//                    }
//                }
//                if isLoadMore {
//                    FilterManager.shared.peopleArray.append(contentsOf: usersArray)
//                } else {
//                    FilterManager.shared.peopleArray = usersArray
//                }
//                let totalUserCount = data["total_users"] as? Int ?? FilterManager.shared.peopleArray.count
//
//                let isPaginationRequired = FilterManager.shared.peopleArray.count < totalUserCount
//                callback(true, isPaginationRequired)
//        }
//    }
//    class func searchChannel(with searchString: String, isLoadMore: Bool, callback: @escaping((_ isSuccess: Bool, _ isPaginationRequired: Bool) -> Void)) {
//        if isConnectedToInternet == false {
//            showAlert(lastVisibleController, title: nil, message: Messages.NoInternetMessage, actionComplete: nil)
//            callback(false, false)
//            return
//        }
//        guard searchString.count > 2 else {
//            callback(false, false)
//            return
//        }
//        guard let accessToken = PersonInfo.getAccessToken() else {
//            callback(false, false)
//            return
//        }
//
//        var params: [String: Any] = ["access_token": accessToken,
//                                     "search_text": searchString,
//                                     "channel_start": FilterManager.initalStart.toString(),
//                                     "channel_end": FilterManager.paginationLimit.toString(),
//                                     "user_start": FilterManager.initalStart.toString(),
//                                     "user_end": FilterManager.paginationLimit.toString(),
//                                     "is_my_chat": LeftSideMenuPresenter.shared.currentScreenActive == .myChat ? 1 : 0]
//
//        if isLoadMore {
//            params["channel_start"] = FilterManager.shared.customChannelArray.count.toString()
//        }
//
//        HTTPRequest(path: EndPoints.search, parameters: params, encoding: .json)
//            .config(isIndicatorEnable: false, isAlertEnable: false, isNetworkAlertEnable: false)
//            .handler { (response) in
//                guard response.isSuccess, let value = response.value as? [String: Any], let data = value["data"] as? [String: Any], let channels = data["channels"] as? [[String: Any]] else {
//                    callback(false, false)
//                    return
//                }
//                var channelArray = [ChannelDetail]()
//
//                for each in channels {
//                    if let obj = ChannelDetail(JSON: each) {
//                        obj.isDefaultChannel = false
//                        channelArray.append(obj)
//                    }
//                }
//                if isLoadMore {
//                    FilterManager.shared.customChannelArray.append(contentsOf: channelArray)
//                } else {
//                    FilterManager.shared.customChannelArray = channelArray
//                }
//                let totalUserCount = data["total_channels"] as? Int ?? FilterManager.shared.customChannelArray.count
//                let isPaginationRequired = FilterManager.shared.customChannelArray.count < totalUserCount
//                callback(true, isPaginationRequired)
//        }
//    }
    
    class func shouldDisplayOptionFor(option: FilterOptionSection) -> Bool {
//        switch option {
//        case .agents:
//            return LeftSideMenuPresenter.shared.currentScreenActive  == .allChat
//        case .channels, .chatType, .date, .labels, .people, .status:
//            return true
//        }
        return true
    }
    
}
