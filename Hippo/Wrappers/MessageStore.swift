//
//  MessageStore.swift
//  SDKDemo1
//
//  Created by Vishal on 30/08/18.
//

import Foundation



struct RequestIdenfier {
    static let getMessagesIdentifier = "HIPPO_GET_MESSAGES_IDENTIFIER"
    static let getMyConversationIdentfier = "HIPPO_GET_MY_CONVERSATION_IDENTIFIER"
    static let getAllConversationIdentfier = "HIPPO_GET_ALL_CONVERSATION_IDENTIFIER"
    static let geto2oChatConversationIdentfier = "HIPPO_o2oCHAT_IDENTIFIER"
    static let authLoginIdentifier = "HIPPO_AUTH_LOGIN_IDENTIFIER"
    static let agentLoginIdentifier = "HIPPO_AGENT_LOGIN1_IDENTIFIER"
    static let getCountrycode = "tookanGetCountrycode"
    static let putUser = "Hippo_Put_User"
}

class MessageStore {
    typealias ChannelMessagesCallBack = ((_ result: ChannelMessagesResult?, _ error: GetMessagesError?) -> ())
    static var isInProgress: Bool = false
    //TODO: Refactor pagination logic
    static var iOSPageLimit = 100
    
    
    struct GetMessagesError {
        var requestType: Int = 0
        var isCreateConversationRequired: Bool = false
        
        init(json: [String :Any]) {
            requestType = json["type"] as? Int ?? 0
            isCreateConversationRequired = requestType == 1
        }
        
        static var defaultError: GetMessagesError {
            return GetMessagesError(json: [:])
        }
    }
    
    struct messageRequest {
        var pageStart: Int
        var showLoader: Bool
        var pageEnd: Int?
        var channelId: Int = -1
        var labelId: Int = -1
        let id: String = UUID().uuidString
    }
    
    struct ChannelMessagesResult {
        var isSuccessFull: Bool = false
        var chatDetail: ChatDetail?
        var isMoreDataToLoad = false
        var newMessages = [HippoMessage]()
        var userSubscribedValue = UserSubscriptionStatus.notSubscribed
        var tags: [TagDetail]?
        var isSendingDisabled: Bool = false
        var newMessageHashmap: [String: Int] = [:]
        var channelName: String = ""
        
        var channelID: Int = -1
        var labelID: Int = -1
        var botGroupID: Int?
        var requestType: Int = 0
        
        var isBotInProgress: Bool = false
        var restrictPersonalInfo : Bool = false
        var createNewChannel : Bool?
    }
    
    
    
    class func getMessages(requestParam: messageRequest, ignoreIfInProgress: Bool = false, completion: @escaping ChannelMessagesCallBack) {
        
        if ignoreIfInProgress, isInProgress {
            handleGetMessageError(response: nil, completion: completion)
            return
        }
        guard let params = createParamForGetMessages(requestParam: requestParam) else {
            handleGetMessageError(response: nil, completion: completion)
            return
        }
        HippoConfig.shared.log.trace(params, level: .request)
        isInProgress = true
        
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.getMessagesIdentifier + "\(requestParam.channelId)",para: params, extendedUrl: FuguEndPoints.API_GET_MESSAGES.rawValue) { (responseObject, error, tag, statusCode) in
       
            isInProgress = false
            let rawStatusCode = statusCode ?? -1
            
            switch rawStatusCode {
            case STATUS_CODE_SUCCESS:
                guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any] else {
                    handleGetMessageError(response: nil, completion: completion)
                    return
                }
                handleGetMessagesCompletion(for: requestParam, data: data, completion: completion)
            default:
                HippoConfig.shared.log.error(error?.localizedDescription ?? "", level: .error )
                if error?.localizedDescription == "cancelled"{
                    return
                }
                
                if error?.localizedDescription ?? "" == "Access Denied"{
                    
                }
                handleGetMessageError(response: nil, completion: completion)
            }
        }
        
    }
    
    class func getMessagesByLabelID(requestParam: messageRequest, ignoreIfInProgress: Bool = false, completion: @escaping ChannelMessagesCallBack) {
        
        if ignoreIfInProgress, isInProgress {
            handleGetMessageError(response: nil, completion: completion)
            return
        }
        
        guard let params = createParamForGetMessages(requestParam: requestParam) else {
            handleGetMessageError(response: nil, completion: completion)
            return
        }
        HippoConfig.shared.log.trace(params, level: .request)
        isInProgress = true
        
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.getMessagesIdentifier ,para: params, extendedUrl: FuguEndPoints.API_GET_MESSAGES_BASED_ON_LABEL.rawValue) { (responseObject, error, tag, statusCode) in
            
            isInProgress = false
            let rawStatusCode = statusCode ?? -1
            
            switch rawStatusCode {
            case STATUS_CODE_SUCCESS:
                guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any] else {
                    handleGetMessageError(response: nil, completion: completion)
                    return
                }
                handleGetMessagesCompletion(for: requestParam, data: data, completion: completion)
            case 406:
                handleGetMessageError(response: responseObject, completion: completion)
                break
            default:
                HippoConfig.shared.log.error(error?.localizedDescription ?? "", level: .error)
                handleGetMessageError(response: nil, completion: completion)
            }
        }
        
    }
    
    private class func createParamForGetMessages(requestParam: messageRequest) -> [String: Any]? {
        var params: [String : Any] = ["page_start": requestParam.pageStart]
        
        
        if requestParam.channelId > 0 {
            params["channel_id"] = requestParam.channelId
        } else {
            params["label_id"] = requestParam.labelId
        }
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            guard let token = HippoConfig.shared.agentDetail?.fuguToken else {
                return nil
            }
            params["access_token"] = token
            params["en_user_id"] = HippoConfig.shared.agentDetail?.enUserId ?? ""
        case .customer:
            guard !HippoConfig.shared.appSecretKey.isEmpty else {
                return nil
            }
            guard let enUserID = HippoUserDetail.fuguEnUserID else {
                return nil
            }
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
            params["en_user_id"] = enUserID
            
            if HippoProperty.current.singleChatApp {
                params["multi_channel_label_mapping_app"] = 1
            }
        }
        
        let endPage = requestParam.pageEnd == nil ? requestParam.pageStart + iOSPageLimit : requestParam.pageEnd!
        params["page_end"] = endPage
        
        
//        print("=====> Param \(params)")
        return params
    }
    
    
    private class func handleGetMessagesCompletion(for requestParam: messageRequest, data: [String: Any], completion: @escaping ChannelMessagesCallBack) {
        var result = ChannelMessagesResult()
        
        result.isSuccessFull = true
        result.chatDetail = ChatDetail(json: data)
        
        let rawMessages = data["messages"] as? [[String: Any]] ?? []
        
        HippoConfig.shared.log.trace(data, level: .response)
        let (newMessages, newHashmap) = HippoMessage.getArrayFrom(json: rawMessages, chatType: result.chatDetail?.chatType)
        result.newMessageHashmap = newHashmap
        result.newMessages = newMessages
        
        //Checking subscribtion status
        if let on_subscribe = data["on_subscribe"] as? Int {
            result.userSubscribedValue = UserSubscriptionStatus(rawValue: on_subscribe) ?? UserSubscriptionStatus.notSubscribed
        }
        //Checking for pagination
        if requestParam.pageEnd == nil {
            result.isMoreDataToLoad = rawMessages.count - iOSPageLimit - 1 == 0
        } else {
            result.isMoreDataToLoad = newMessages.count != 0
        }
        //Getting tags from data
        if let _tags = data["tags"] as? [[String :Any]] {
            result.tags = TagDetail.parseTagDetail(data: _tags)
        }
    
     
        //Checking sending Status
        if let _disableSending = data["disable_reply"] as? Bool {
            result.isSendingDisabled = _disableSending
        }
        
        if let _isBotInProgress = data["is_bot_in_progress"] as? Bool {
            result.isBotInProgress = _isBotInProgress
        }
        
        result.channelID = data["channel_id"] as? Int ?? -1
        result.labelID = data["label_id"] as? Int ?? -1
        result.botGroupID = Int.parse(values: data, key: "bot_group_id")
        result.requestType = data["type"] as? Int ?? 0
        
        //if default channel
        
        if result.channelID < 0, let otherLanguageDic = rawMessages.first?["channel_other_lang_data"] as? [String : Any]{
            if result.botGroupID ?? 0 <= 0{
                result.newMessages.first?.message = otherLanguageDic["channel_message"] as? String ?? ""
            }
            result.channelName = otherLanguageDic["channel_name"] as? String ?? ""
            //channel name
        }else if let channelName = data["label"] as? String {
            result.channelName = channelName
        } else if let fullName = data["full_name"] as? String, fullName.count > 0 {
            result.channelName = fullName
        }
        
        //
        if let isPersonalInfoRestricted = data["restrict_personal_info_sharing"] as? Bool{
            result.restrictPersonalInfo = isPersonalInfoRestricted
        }
        if let createChannel = data["create_new_channel"] as? Bool{
            result.createNewChannel = createChannel
        }
        
        //Sending
        completion(result, nil)
    }
    private class func handleGetMessageError(response: Any?, completion: @escaping ChannelMessagesCallBack) {
        guard let rawReponse = response as? [String : Any] else {
            completion(nil, GetMessagesError.defaultError)
            return
        }
        let error = GetMessagesError(json: rawReponse)
        completion(nil, error)
    }
    
    
}
