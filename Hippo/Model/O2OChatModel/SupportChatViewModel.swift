//
//  SupportChatViewModel.swift
//  Hippo
//
//  Created by Arohi Sharma on 16/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

class SupportChatViewModel{
    
    //MARK:- Variables
    var conversationList = [AgentConversation]()
    var getListing : Bool?{
        didSet{
            getSupportChatListing()
        }
    }
    var page = 1
    var limit = 20
    var isRefreshing : Bool = false
    var isLoading = false
    var isLoadMoreRequired = true
    
    //MARK:- Clousers
    var responseRecieved : (()->())?
    var startLoading : ((Bool)->())?
    var endRefreshClausre:(()->())?
    
    
    private func getSupportChatListing(){
        page = conversationList.count == 0 ? 1 : conversationList.count
        if isRefreshing {
            page = 1
        }else{
            if !isLoading{
               self.startLoading?(true)
            }
        }
        
        let params = generateGetO2OSupportParams()
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.getAgentSupportChannelListing.rawValue) { (responseObject, error, tag, statusCode) in
            if self.isRefreshing {
                self.endRefreshClausre?()
            }else{
                if !self.isLoading{
                    self.startLoading?(false)
                }
            }
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                self.responseRecieved?()
                return
            }
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            
            if self.isRefreshing && self.page == 1{
                self.conversationList.removeAll()
            }
            
            if let response = responseObject as? [String : Any], let data = response["data"] as? [String : Any], let conversationList = data["conversation_list"] as? [[String : Any]]{
                
                for each in conversationList {
                    let object = AgentConversation(json: each)
                    object.channel_type = channelType.SUPPORT_CHAT_CHANNEL.rawValue
                    self.conversationList.append(object)
                }
                
                if conversationList.count < self.limit{
                    self.isLoadMoreRequired = false
                } else {
                    self.isLoadMoreRequired = true
                }
                
                self.responseRecieved?()
            }
        }
    }
    
    
    private func generateGetO2OSupportParams() -> [String : Any]{
        var params = [String : Any]()
        params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        params["page_offset"] = page
        params["row_count"] = limit
        if HippoConfig.shared.supportChatFilter != nil{
            
            let selectedFilterStatus = HippoConfig.shared.supportChatFilter?.filter{$0.type == .type}.map{$0.value?.filter{$0.isSelected == true} ?? [SupportFilterValues]()}.first?.first ?? SupportFilterValues()
            switch (selectedFilterStatus.value){
            case HippoStrings.myChatsOnly:
                params["fetch_my_chats_only"] = true
            case HippoStrings.unassignedChats:
                 params["fetch_unassigned_chats"] = true
            case HippoStrings.mySupportChats:
                params["fetch_my_support_chats"] = true
            default:
                print("default")
                break
            }
        
            let openChatStatus = HippoConfig.shared.supportChatFilter?.filter{$0.type == .status}.map{$0.value?.filter{$0.value == HippoStrings.openChat} ?? [SupportFilterValues]()}.first?.first?.isSelected
            let closeChatStatus = HippoConfig.shared.supportChatFilter?.filter{$0.type == .status}.map{$0.value?.filter{$0.value == HippoStrings.closedChat} ?? [SupportFilterValues]()}.first?.first?.isSelected
            
            var channelStatusArr = [Int]()
            if openChatStatus ?? false{
                channelStatusArr.append(ChatStatus.open.rawValue)
            }
            if closeChatStatus ?? false{
                channelStatusArr.append(ChatStatus.close.rawValue)
            }
            
            if channelStatusArr.count == 0{
                channelStatusArr.append(ChatStatus.open.rawValue)
            }
            
            params["channel_status"] = channelStatusArr
            
        }
        return params
    }
}

