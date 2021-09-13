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
    
    static var o2oDefaultRequest: GetConversationRequestParam {
        return GetConversationRequestParam(pageStart: 1, pageEnd: nil, showLoader: false, type: .o2oChat, identifier: String.generateUniqueId())
    }
    
    
    var apiRequestIdentifier: String {
        switch type {
        case .allChat:
            return RequestIdenfier.getAllConversationIdentfier
        case .myChat:
            return RequestIdenfier.getMyConversationIdentfier
        case .searchUser:
            return RequestIdenfier.getAllConversationIdentfier
        case .o2oChat:
            return RequestIdenfier.geto2oChatConversationIdentfier
        }
    }
    enum RequestType {
        case myChat
        case allChat
        case searchUser
        case o2oChat
        
        
        init(conversationType: ConversationType) {
            switch conversationType{
            case .allChat:
                self = .allChat
            case .myChat:
                self = .myChat
            case .o2oChat:
                self = .o2oChat
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
    static var iso2oChatInProgress = false
    static let maxPageSize = 20//30
    
    static var allChatHttpRequest: URLSessionDataTask?
    static var myChatHttpRequest: URLSessionDataTask?
    
    
    static var errorMessage: String?
    
    class func updateAgentChannel(completion: @escaping HippoResponseRecieved) {
        isLoginInProgess = true
        AgentDetail.loginViaAuth {(result) in
            isLoginInProgess = false
            guard result.isSuccessful else {
                completion(result.error as? HippoError ?? HippoError.general, nil)
                return
            }
            completion(nil, nil)
         
        }
    }
    
    class func getAllData() {
     
        if !isMyChatInProgress {
            isMyChatInProgress = true
            getConversations(with: .myChatDefaultRequest) { (result) in
                isMyChatInProgress = false
                NotificationCenter.default.post(name: .myChatDataUpdated, object:self)
            }
        }
        if !isAllChatInProgress {
            guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
                return
            }
            if agent.agentUserType != .admin && (BussinessProperty.current.hideAllChat ?? false){
                
            }else{
                isAllChatInProgress = true
                getConversations(with: .allChatDefaultRequest) { (result) in
                    isAllChatInProgress = false
                    NotificationCenter.default.post(name: .allChatDataUpdated, object:self)
                }
            }
        }
        
        if !iso2oChatInProgress{
            if BussinessProperty.current.hideo2oChat ?? false{
                return
            }
            
            iso2oChatInProgress = true
            
            getConversations(with: .o2oDefaultRequest) { (result) in
                iso2oChatInProgress = false
                
            }
        }
        
    }

    class func getBotsAction(userId: Int, channelId: Int, handler: @escaping (([BotAction]) -> Void)) {
        guard let agent = HippoConfig.shared.agentDetail else {
            return
        }
        let params: [String: Any] = ["access_token": agent.fuguToken,
                                     "user_id": userId,
                                     "channel_id": "\(channelId)"]
        print(params)
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.getAllConversationIdentfier, para: params, extendedUrl: AgentEndPoints.getBotActions.rawValue) { (response, error, tag, statusCode) in
            print(response)
            if let _ = error {
                handler([BotAction]())
            } else {
                if let response = response as? [String: Any], let data = response["data"] as? [[String: Any]] {
                    var actionsArray = [BotAction]()
                    for action in data {
                        actionsArray.append(BotAction(dict: action))
                    }
                    handler(actionsArray)
                }
            }

        }
    }


//    class func agentStatusUpdate(newStatus: AgentStatus) {
    class func agentStatusUpdate(newStatus: AgentStatus, completion: @escaping ((_ result: Bool) -> Void)) {
         guard HippoConfig.shared.appUserType == .agent else {
            completion(false)
            return
         }
         guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            completion(false)
            return
         }
         let param: [String: Any] = [
                "access_token": agent.fuguToken,
                "en_user_id": agent.enUserId,
                "business_id": agent.businessId,
                "device_type": Device_Type_iOS,
                "online_status": newStatus.rawValue,
                "lang_code" : getCurrentLanguageLocale()
             ]
        print(param)

        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.getAllConversationIdentfier,para: param, extendedUrl: AgentEndPoints.agentStatus.rawValue) { (response, error, tag, statusCode) in
            if let _ = error {
                completion(false)
                return
            }
            print("newStatus: ",newStatus)
//            HippoConfig.shared.agentDetail?.status = newStatus
            BussinessProperty.current.agentStatusForToggle = newStatus.rawValue
            completion(true)
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
        
//        guard let params = getParamsToGetConversation(with: request) else {
//            completion(AgentGetConversationFromServerResult(isSuccessful: false, error: HippoError.general, conversations: nil))
//            return
//        }
        guard let params = paramsForGetConversation(with: request) else {
            completion(AgentGetConversationFromServerResult(isSuccessful: false, error: HippoError.general, conversations: nil))
            return
        }
        
        print("Conversation Param: \(params)")
        
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
        
//        var isMoreToLoad = false
//
//        if request.pageEnd == nil {
//            isMoreToLoad = conversations.count - maxPageSize - 1 == 0
//        } else {
//            isMoreToLoad = conversations.count != 0
//        }
        var isMoreToLoad = false
        if conversations.count < maxPageSize{
            isMoreToLoad = false
        }else{
            isMoreToLoad = true
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
        case .o2oChat:
            iso2oChatInProgress = false
            ConversationStore.shared.isMoreo2oChatToLoad = isMoreToLoad
            if request.pageStart == 1 {
                ConversationStore.shared.o2oChats = conversations
            } else {
                ConversationStore.shared.o2oChats.append(contentsOf: conversations)
            }
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
    
//    func assignChatToMe(channel: HippoChannel?, completion: ((_ success: Bool) -> ())?) {
    class func assignChatToMe(channelID: Int, completion: @escaping ((_ result: Bool) -> Void)) {
        guard let accessToken = HippoConfig.shared.agentDetail?.fuguToken else {
            completion(false)
            return
        }
        let userId = currentUserId()
        let params: [String : Any] = ["access_token": accessToken,
                                      "channel_id": channelID,
                                      "user_id": userId]
        
        HippoConfig.shared.log.debug("API_AssignAgent.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.assignAgent.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    HippoConfig.shared.log.debug("API_AssignAgent ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    completion(false)
                    return
            }
            completion(true)
        }
    }
    
//    func getAgentsList(showLoader: Bool = false, completion: @escaping AgentCallBack) {
    class func getAgentsList(showLoader: Bool = false, completion: @escaping ((_ result: Bool) -> Void)) {
        
        guard let accessToken = HippoConfig.shared.agentDetail?.fuguToken, let bussinessId = HippoConfig.shared.agentDetail?.businessId else {
//            completion(nil)
            completion(false)
            return
        }

        let params: [String : Any] = ["access_token": accessToken,
                                      "business_id": bussinessId]
        
        HippoConfig.shared.log.debug("API_GetAgents.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getAgents.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200, let data = responseDict["data"] as? [String: Any], let rawAgents = data["agents"] as? [[String: Any]] else {
                    HippoConfig.shared.log.debug("API_GetAgents ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    completion(false)
                    return
            }
            let agents = Agent.getArrayfrom(jsonArray: rawAgents)
            Business.shared.agents = agents
            CacheManager.storeAgents(agents: agents)
//            NotificationCenter.default.post(.init(name: .AgentRefreshed))
//            completion(agents)
            completion(true)
        }
        
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
    
    
//    fileprivate static func getParamsToGetConversation(with request: GetConversationRequestParam) -> [String: Any]? {
//        guard HippoConfig.shared.appUserType == .agent else {
//            return nil
//        }
//        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
//            return nil
//        }
////        var params: [String: Any] = ["status": [1],
////                                     "access_token": agent.fuguToken,
////                                     "en_user_id": agent.enUserId,
////                                     "device_type": "2"]
//        var statusArr = [Int]()
//        for i in 0..<FilterManager.shared.chatStatusArray.count{
//            if FilterManager.shared.chatStatusArray[i].isSelected == true{
//                statusArr.append(i+1)
//            }
//        }
//        if statusArr == []{
//            statusArr.append(1)
//        }
////        print("qqqqqqqqqq",statusArr)
//
//        var params: [String: Any] = ["status": statusArr,
//                                     "access_token": agent.fuguToken,
//                                     "en_user_id": agent.enUserId,
//                                     "device_type": "2"]
//
//        params["page_start"] = request.pageStart
//        params["page_end"] = request.pageEnd == nil ? request.pageStart + maxPageSize : request.pageEnd!
//
//        switch request.type {
//        case .allChat:
//            params["type"] = [10]
//        case .myChat:
//            params["type"] = [0]
//        case .searchUser:
//            params["type"] = [0, 3]
//        }
//
//        return params
//    }
    
    
    fileprivate static func generateDefaultParam(with request: GetConversationRequestParam) -> [String: Any]? {
        guard HippoConfig.shared.appUserType == .agent else {
            return nil
        }
        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            return nil
        }
        var dict: [String: Any] = ["access_token": agent.fuguToken,
                                   "device_type": Device_Type_iOS,
                                   "app_version": fuguAppVersion]
        

        dict["page_offset"] = request.pageStart
        if let pageEnd = request.pageEnd{
            let startPage = request.pageStart
            if pageEnd > startPage  {
                dict["row_count"] =  pageEnd - startPage + 1
            }
        } else {
            dict["row_count"] = maxPageSize
        }
        
        return dict
    }
    fileprivate static func paramsForGetConversation(with request: GetConversationRequestParam) -> [String: Any]? {
        guard var dict = generateDefaultParam(with: request) else {
            return nil
        }
        dict["channel_status"] = FilterManager.shared.selectedChatStatus
        
        
//        if let search_user_id = ConversationManager.sharedInstance.selectedCustomerObject?.user_id {
//            dict["search_user_id"] = search_user_id
//        }
//        if !FilterManager.shared.selectedAgentId.isEmpty {
//            dict["agent_ids"] = FilterManager.shared.selectedAgentId
//        }
//        if !FilterManager.shared.selectedLabelId.isEmpty {
//            dict["label_list"] = FilterManager.shared.selectedLabelId
//        }
//        if !FilterManager.shared.selectedChannelId.isEmpty {
//            dict["default_channels"] = FilterManager.shared.selectedChannelId
//        }
//        if ConversationManager.sharedInstance.selectedChannelId != -1 {
//            dict["search_custom_label"] = ConversationManager.sharedInstance.selectedChannelId
//        }
//        if let appendChannelID = ConversationManager.sharedInstance.appendChannelID  {
//            dict["append_channel_id"] = appendChannelID
//        }
//
//        if let start_date = FilterManager.shared.selectedDate?.getStartDateString() {
//            dict["start_date"] = start_date
//        }
//        if let end_date = FilterManager.shared.selectedDate?.getEndDateString() {
//            dict["end_date"] = end_date
//        }
        
//        dict.appendDictionary(other: parsedChatTypes())
        dict.appendDictionary(other: parsedChatTypes(request: request))
        
        return dict
    }
//    func parsedChatTypes() -> [String: Any] {
    fileprivate static func parsedChatTypes(request: GetConversationRequestParam) -> [String: Any] {
        var chatJson = [String: Any]()
        switch request.type {
        case .allChat:
            chatJson["fetch_all_chats"] = true
        case .myChat:
            chatJson["fetch_my_chats"] = true
        case .searchUser:
            print("searchUser")
        case .o2oChat:
            chatJson["fetch_o2o_chats"] = true
        }
        
        return chatJson
    }
    
    fileprivate static func getParamsForSearchUser() -> [String: Any]? {
//        guard let conversationParam = getParamsToGetConversation(with: GetConversationRequestParam.searchUserDefaultRequest) else {
//            return nil
//        }
        guard let conversationParam = paramsForGetConversation(with: GetConversationRequestParam.searchUserDefaultRequest) else {
                   return nil
               }
        
        var params: [String: Any] = conversationParam
        params["search_user_unique_key"] = searchUserUniqueKeys
        params["fetch_all_chats"] = true
        return params
    }
}

extension Dictionary {
    
    //Append Dictionary
    mutating func appendDictionary(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    static func += <K, V> ( left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left.updateValue(v, forKey: k)
        }
    }
    
}
