//
//  AgentConversationManager.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

struct ServerResponse {
    var statusCode: Int?
    var responseObj: Any?
    var tag: String?
    var error: Error?
}

struct AgentGetConversationFromServerResult {
    let isSuccessful: Bool
    let error: Error?
    let conversations: [AgentConversation]?
}



struct GetConversationRequestParam {
    let pageStart: Int
    let pageEnd: Int?
    let showLoader: Bool
    let type: RequestType
    let identifier: String
    
    static var allChatDefaultRequest: GetConversationRequestParam {
        return GetConversationRequestParam(pageStart: 1, pageEnd: nil, showLoader: false, type: .allChat, identifier: String.generateUniqueId())
    }
    static var myChatDefaultRequest: GetConversationRequestParam {
        return GetConversationRequestParam(pageStart: 1, pageEnd: nil, showLoader: false, type: .myChat, identifier: String.generateUniqueId())
    }
    static var searchUserDefaultRequest: GetConversationRequestParam {
        return GetConversationRequestParam(pageStart: 1, pageEnd: nil, showLoader: false, type: .searchUser, identifier: String.generateUniqueId())
    }
    
    var apiRequestIdentifier: String {
        switch type {
        case .allChat:
            return RequestIdenfier.getAllConversationIdentfier
        case .myChat:
            return RequestIdenfier.getMyConversationIdentfier
        case .searchUser:
            return RequestIdenfier.getAllConversationIdentfier
        }
    }
    enum RequestType {
        case myChat
        case allChat
        case searchUser
        
        
        init(conversationType: ConversationType) {
            switch conversationType{
            case .allChat:
                self = .allChat
            case .myChat:
                self = .myChat
            }
        }
    }
    
}
class AgentConversationManager {
    
    static var searchUserUniqueKeys: [String] = []
    static var transactionID: String? = nil
    
    //MARK: Static variables
    static var isUnreadCountInProgress = false
    static var isAllChatInProgress = false
    static var isMyChatInProgress = false
    static var isLoginInProgess = false
    static let maxPageSize = 30
    
    static var allChatHttpRequest: URLSessionDataTask?
    static var myChatHttpRequest: URLSessionDataTask?
    
    
    static var errorMessage: String?
    
    class func updateAgentChannel() {
        isLoginInProgess = true
        AgentDetail.loginViaAuth {(result) in
            isLoginInProgess = false
            guard result.isSuccessful else {
                return
            }
            getUserUnreadCount()
            getAllData()
        }
    }
    class func getAllData() {
        
        getUserUnreadCount()
        
        if !isMyChatInProgress {
            isMyChatInProgress = true
            getConversations(with: .myChatDefaultRequest) { (result) in
                isMyChatInProgress = false
                NotificationCenter.default.post(name: .myChatDataUpdated, object:self)
            }
        }
        if !isAllChatInProgress {
            isAllChatInProgress = true
            getConversations(with: .allChatDefaultRequest) { (result) in
                isAllChatInProgress = false
                NotificationCenter.default.post(name: .allChatDataUpdated, object:self)
            }
        }
        
    }
    class func agentStatusUpdate(newStatus: AgentStatus) {
        guard HippoConfig.shared.appUserType == .agent else {
             return
         }
         guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
             return
         }
         let param: [String: Any] = [
                "access_token": agent.fuguToken,
                "en_user_id": agent.enUserId,
                "business_id": agent.businessId,
                "device_type": Device_Type_iOS,
                "online_status": newStatus.rawValue,
             ]
        print(param)

        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.getAllConversationIdentfier,para: param, extendedUrl: AgentEndPoints.agentStatus.rawValue) { (response, error, tag, statusCode) in
            if let _ = error {
                return
            }
            HippoConfig.shared.agentDetail?.status = newStatus
        }
    }

    class func getUserUnreadCount() {
        guard !isUnreadCountInProgress && !isLoginInProgess else {
            return
        }
        isUnreadCountInProgress = true
        UnreadCount.getUnreadCount(completion: { (result) in
            isUnreadCountInProgress = false
        })
        
    }
    class func getConversations(with request: GetConversationRequestParam, completion: @escaping ((_ result: AgentGetConversationFromServerResult) -> ())) {
        
        guard let params = getParamsToGetConversation(with: request) else {
            completion(AgentGetConversationFromServerResult(isSuccessful: false, error: HippoError.general, conversations: nil))
            return
        }
        
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: request.apiRequestIdentifier, para: params, extendedUrl: AgentEndPoints.getConversation.rawValue) { (responseObject, error, tag, statusCode) in
            
            
            let response = ServerResponse(statusCode: statusCode, responseObj: responseObject, tag: tag, error: error)
            let result = parseGetConversationData(result: response)
            
            guard result.isSuccessful else {
                completion(result)
                return
            }
            handleGetConversationSuccess(request: request, result: result, completion: completion)
        }
        
    }
    
    class func handleGetConversationSuccess(request: GetConversationRequestParam, result: AgentGetConversationFromServerResult, completion: @escaping ((_ result: AgentGetConversationFromServerResult) -> ())) {
        
        
        guard let conversations = result.conversations else {
            completion(result)
            return
        }
        
        var isMoreToLoad = false
        
        if request.pageEnd == nil {
            isMoreToLoad = conversations.count - maxPageSize - 1 == 0
        } else {
            isMoreToLoad = conversations.count != 0
        }
        
        switch request.type {
        case .allChat:
            isAllChatInProgress = false
            ConversationStore.shared.isMoreAllChatToLoad = isMoreToLoad
            
            if request.pageStart == 1 {
                UnreadCount.clearAllStoredUnreadCount()
                ConversationStore.shared.allChats = conversations
            } else {
                ConversationStore.shared.allChats.append(contentsOf: conversations)
            }

        case .myChat:
            isMyChatInProgress = false
            ConversationStore.shared.isMoreMyChatToLoad = isMoreToLoad
    
            if request.pageStart == 1 {
                UnreadCount.clearAllStoredUnreadCount()
                ConversationStore.shared.myChats = conversations
            } else {
                ConversationStore.shared.myChats.append(contentsOf: conversations)
            }
        case .searchUser:
            break
        }
        resetPushCount()
        pushTotalUnreadCount()
        AgentConversationManager.errorMessage = nil
        completion(result)
    }
    
    class func isAnyApiOnGoing() -> Bool {
        return isConversationApiOnGoing() || isLoginInProgess
    }
    class func isConversationApiOnGoing() -> Bool {
        return isMyChatInProgress || isAllChatInProgress
    }
    
    class func getConversationForSearchUser(completion: @escaping ((_ result: AgentGetConversationFromServerResult) -> Void)) {
        guard HippoConfig.shared.appUserType == .agent, HippoConfig.shared.agentDetail != nil else {
            let result = AgentGetConversationFromServerResult(isSuccessful: false, error: HippoError.general, conversations: nil)
            completion(result)
            return
        }
        
        
        guard let params = getParamsForSearchUser() else {
            let result = AgentGetConversationFromServerResult(isSuccessful: false, error: HippoError.general, conversations: nil)
            completion(result)
            return
        }
        HippoConfig.shared.log.trace("getConversationForSearchUser param: ", params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getConversation.rawValue) { (responseObject, error, tag, statusCode) in
            let response = ServerResponse(statusCode: statusCode, responseObj: responseObject, tag: tag, error: error)
            let result = parseGetConversationData(result: response)
            
            guard result.isSuccessful else {
                completion(result)
                return
            }
            completion(result)
        }
        
    }
    class func updateChannelStatus(for channelID: Int, newStatus: Int, completion: @escaping ((_ result: ResponseResult) -> Void)) {
        guard HippoConfig.shared.appUserType == .agent, HippoConfig.shared.agentDetail != nil else {
            let result = ResponseResult(isSuccessful: false, error: HippoError.general)
            completion(result)
            return
        }
        let params = getParamsForCloseConversation(with: channelID, newStatus: newStatus)
       
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.markConversation.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS  else {
                let result = ResponseResult(isSuccessful: false, error: error)
                completion(result)
                return
            }
            let result = ResponseResult(isSuccessful: true, error: error)
            completion(result)
        }
    }
    
    class func parseGetConversationData(result: ServerResponse) -> AgentGetConversationFromServerResult {
        
        guard let unwrappedStatusCode = result.statusCode, let response = result.responseObj as? [String: Any], let data = response["data"] as? [String: Any], unwrappedStatusCode == STATUS_CODE_SUCCESS, let conversation_list = data["conversation_list"] as? [[String: Any]] else {
            let result = AgentGetConversationFromServerResult(isSuccessful: false, error: result.error, conversations: nil)
            AgentConversationManager.errorMessage = result.error?.localizedDescription
            HippoConfig.shared.log.error("Conversation error: ", result.error ?? "", level: .error)
            return result
        }
        HippoConfig.shared.log.trace("conversation_list \(conversation_list)", level: .response)
        let conversations = AgentConversation.getConversationArray(jsonArray: conversation_list)
        let result = AgentGetConversationFromServerResult(isSuccessful: true, error: nil, conversations: conversations)
        return result
    }
}



//MARK: Params objectssss
extension AgentConversationManager {
    fileprivate static func getParamsForCloseConversation(with channelId: Int, newStatus: Int) -> [String: Any] {
        
        guard let agent = HippoConfig.shared.agentDetail else {
            return [:]
        }
        
        let params: [String: Any] = ["access_token": agent.fuguToken,
                                     "channel_id": channelId,
                                     "en_user_id": agent.enUserId,
                                     "status": newStatus]
        return params
    }
    
    
    fileprivate static func getParamsToGetConversation(with request: GetConversationRequestParam) -> [String: Any]? {
        guard HippoConfig.shared.appUserType == .agent else {
            return nil
        }
        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            return nil
        }
        var params: [String: Any] = ["status": [1],
                                     "access_token": agent.fuguToken,
                                     "en_user_id": agent.enUserId,
                                     "device_type": "2"]
        
        params["page_start"] = request.pageStart
        params["page_end"] = request.pageEnd == nil ? request.pageStart + maxPageSize : request.pageEnd!
        
        switch request.type {
        case .allChat:
            params["type"] = [10]
        case .myChat:
            params["type"] = [0]
        case .searchUser:
            params["type"] = [0, 3]
        }
        
        return params
    }
    fileprivate static func getParamsForSearchUser() -> [String: Any]? {
        guard let conversationParam = getParamsToGetConversation(with: GetConversationRequestParam.searchUserDefaultRequest) else {
            return nil
        }
        
        var params: [String: Any] = conversationParam
        params["search_user_unique_key"] = searchUserUniqueKeys
        
        return params
    }
}
