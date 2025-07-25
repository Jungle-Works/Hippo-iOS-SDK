//
//  FuguUserDetail.swift
//  Fugu
//
//  Created by Gagandeep Arora on 31/08/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
//import Demo_3002

typealias FuguUserDetailCallback = (_ success: Bool, _ error: Error?) -> Void



class User: NSObject {
    var enUserID: String = ""
    var userID: Int
    var fullName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var userType: UserType = .customer
    var image: String?
    
    
    init?(dict: [String: Any]) {
        guard let rawUserId = Int.parse(values: dict, key: "user_id") else {
            return nil
        }
        self.userID = rawUserId
        self.fullName = dict["full_name"] as? String ?? ""
        self.image = dict["user_image"] as? String
    }
    init(name: String, imageURL: String?, userId: Int) {
        self.fullName = name
        self.image = imageURL
        self.userID = userId
    }
    
    func toJson() -> [String: Any] {
        var json: [String: Any] = ["full_name": self.fullName]
        
        if userID > 0 {
            json["user_id"] = userID
        }
        
        if let parsedURL = image {
            json["user_image"] = parsedURL
        }
        
        return json
    }
    
    class func parseArray(list: [[String: Any]]) -> [User] {
        var users: [User] = []
        
        for each in list {
            guard let user = User(dict: each) else {
                continue
            }
            users.append(user)
        }
        return users
    }
    class func find(userId: Int, from list: [User]) -> (User, Int)? {
        let userIndex = list.firstIndex { (u) -> Bool in
            return u.userID == userId
        }
        guard let parsedUserIndex = userIndex else {
            return nil
        }
        return (list[parsedUserIndex], parsedUserIndex)
    }
    
}

public class UserTag: NSObject {
    var tagName: String? = nil
    var teamId: Int? = nil
    var tag_id: Int? = -1
    
    public init(tagName: String? = nil, teamId: Int? = nil) {
        self.tagName = tagName
        self.teamId = teamId
    }
    
    
    init(json: [String: Any]) {
        self.tagName = json["tag_name"] as? String
        self.tag_id = json["tag_id"] as? Int ?? -1
    }
}

@objc public class HippoUserDetail: NSObject {
    
    // MARK: - Properties
    var fullName: String?
    var email: String?
    var phoneNumber: String?
    var userUniqueKey: String?
    var callingType:Int?
    public var nCallingType = 2
    var addressAttribute: HippoAttributes?
    var customAttributes: [String: Any]?
    var userTags: [UserTag] = []
    var customRequest: [String: Any] = [:]
    var userImage: URL?
    var selectedlanguage : String?
    var userChannel: String?
    var listener : SocketListner?
    var userIdenficationSecret : String?
    var fetchAnnouncementsUnreadCount: Bool?
    var callAudioTypeorNot : String?
    var redirectToWhatsapp: Bool = false
    
    static var shouldGetPaymentGateways : Bool = true
    
    class var HippoUserChannelId: String? {
        get {
            return UserDefaults.standard.value(forKey: Hippo_User_Channel_Id) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Hippo_User_Channel_Id)
        }
    }
    
    
    class var fuguUserID: Int? {
        get {
            return UserDefaults.standard.value(forKey: FUGU_USER_ID) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: FUGU_USER_ID)
        }
    }
    
    class var callingType: Int? {
        get {
            return UserDefaults.standard.value(forKey: calling_Type) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: calling_Type)
        }
    }
    
    
    //    class var fullName: String? {
    //        get {
    //            return UserDefaults.standard.value(forKey: full_name) as? String
    //        }
    //        set {
    //            UserDefaults.standard.set(newValue, forKey: full_name)
    //        }
    //    }
    
    class var NotificationNotAllowedAlert: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: NotificationDisabledAlert)
        }
        get {
            return UserDefaults.standard.value(forKey: NotificationDisabledAlert) as? Bool ?? false
        }
    }
    
    class var fuguEnUserID: String? {
        get {
            return UserDefaults.standard.value(forKey: Fugu_en_user_id) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Fugu_en_user_id)
        }
    }
    
    static func isValidDetails() -> Bool {
        let appSecretKey = HippoConfig.shared.appSecretKey
        let enUserID = fuguEnUserID?.trimWhiteSpacesAndNewLine() ?? ""
        
        return !appSecretKey.isEmpty && !enUserID.isEmpty
    }
    
    // MARK: - Intializer
    override init() {}
    
    public init(fullName: String, email: String, phoneNumber: String, userUniqueKey: String, addressAttribute: HippoAttributes? = nil, customAttributes: [String: Any]? = nil, userTags: [UserTag]? = nil, userImage: String? = nil, userIdenficationSecret: String? = nil, selectedlanguage : String? = nil, getPaymentGateways: Bool = true, fetchAnnouncementsUnreadCount: Bool = false, redirectToWhatsapp: Bool = false) {
        super.init()
        self.userIdenficationSecret = userIdenficationSecret
        self.fullName = fullName.trimWhiteSpacesAndNewLine()
        self.email = email.trimWhiteSpacesAndNewLine()
        self.phoneNumber = phoneNumber.trimWhiteSpacesAndNewLine()
        self.userUniqueKey = userUniqueKey.trimWhiteSpacesAndNewLine()
        self.addressAttribute = addressAttribute ?? HippoAttributes()
        self.customAttributes = customAttributes
        self.fetchAnnouncementsUnreadCount = fetchAnnouncementsUnreadCount
        self.redirectToWhatsapp = redirectToWhatsapp
        self.userTags = userTags ?? []
        
        if let parsedUserImage = userImage?.trimWhiteSpacesAndNewLine(), let url = URL(string: parsedUserImage) {
            self.userImage = url
        }
        
        self.selectedlanguage = selectedlanguage
        self.listener = HippoConfig.shared.listener
        HippoUserDetail.shouldGetPaymentGateways = getPaymentGateways
        UserDefaults.standard.set(selectedlanguage, forKey: DefaultName.selectedLanguage.rawValue)
    }
    
    func getUserTagsJSON() -> [[String: Any]] {
        var object = [[String: Any]]()
        
        for each in self.userTags {
            var temp = [String: Any]()
            if each.tagName == nil && each.teamId == nil {
                continue
            }
            if let id = each.teamId, id > 0 {
                temp["reseller_team_id"] = id
            }
            if let tagName = each.tagName, !tagName.trimWhiteSpacesAndNewLine().isEmpty {
                temp["tag_name"] = tagName
            }
            if temp["tag_name"] == nil && temp["reseller_team_id"] == nil {
                continue
            }
            object.append(temp)
        }
        return object
    }
    func getUserTagNameArray() -> [String] {
        var object = [String]()
        
        for each in self.userTags {
            if each.tagName == nil {
                continue
            }
            if let tagName = each.tagName, !tagName.trimWhiteSpacesAndNewLine().isEmpty {
                object.append(tagName)
            }
        }
        return object
    }
    
    // MARK: - Helpers
    func toJson() -> [String: Any] {
        var params: [String: Any] = [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? 0,
            "device_type" : Device_Type_iOS
        ]
        
        if let userIdenficationSecret = userIdenficationSecret, userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false{
            params["user_identification_secret"] = userIdenficationSecret
        }
        
        switch HippoConfig.shared.credentialType {
        case FuguCredentialType.reseller:
            if HippoConfig.shared.resellerToken.isEmpty == false &&
                HippoConfig.shared.referenceId > 0 {
                params["reseller_token"] = HippoConfig.shared.resellerToken
                params["reference_id"] = HippoConfig.shared.referenceId
            }
            
        case FuguCredentialType.defaultType:
            if HippoConfig.shared.appSecretKey.isEmpty == false {
                params["app_secret_key"] = HippoConfig.shared.appSecretKey
            }
        }
        
        if let applicationType = HippoConfig.shared.appType, applicationType.isEmpty == false {
            params["app_type"] = applicationType
        }
        
        let userName = self.fullName ?? ""
        if userName.isEmpty == false { params["full_name"] = userName }
        
        let userEmail = self.email ?? ""
        if userEmail.isEmpty == false { params["email"] = userEmail }
        
        let userPhoneNumber = self.phoneNumber ?? ""
        if userPhoneNumber.isEmpty == false { params["phone_number"] = userPhoneNumber }
        
        let userUniqueKey = self.userUniqueKey ?? ""
        if userUniqueKey.isEmpty == false {
            params["user_unique_key"] = userUniqueKey
        }
        
        //        callingType = Int(Int.parse(values: callingType, key: "calling_type") ?? 0)
        params["grouping_tags"] = getUserTagsJSON()
        if let addressInfo = addressAttribute?.toJSON() {
            params["attributes"] = addressInfo
        }
        var attributes = customAttributes ?? [:]
        if let countryInfo = TookanHelper.countryInfo {
            attributes["country_info"] = countryInfo
        }
        if !attributes.isEmpty {
            params["custom_attributes"] = attributes
        }
        
        if TokenManager.deviceToken.isEmpty == false {
            params["device_token"] = TokenManager.deviceToken
        } else if let token = UserDefaults.standard.value(forKey: TokenManager.StoreKeys.normalToken) as? String, token.isEmpty == false {
            TokenManager.deviceToken = token
            params["device_token"] = TokenManager.deviceToken
        }
        print("TokenManager.deviceToken:", TokenManager.deviceToken)
        
        if TokenManager.voipToken.isEmpty == false {
            params["voip_token"] = TokenManager.voipToken
        } else if let token = UserDefaults.standard.value(forKey: TokenManager.StoreKeys.voipToken) as? String, token.isEmpty == false {
            TokenManager.voipToken = token
            params["voip_token"] = TokenManager.voipToken
        }
        
        if let image = userImage {
            params["user_image"] = image.absoluteString
        }
        
        if let fetchAnnouncementsUnreadCount = fetchAnnouncementsUnreadCount, fetchAnnouncementsUnreadCount {
            params["fetch_announcements_unread_count"] = 1
        }
        
        params["device_details"] = AgentDetail.getDeviceDetails()
        params["fetch_business_lang"] = 1
        params += customRequest
        return params
    }
    
    
    // MARK: - Type Methods
    class func getUserDetailsAndConversation(isOpenedFromPush: Bool = false, completion: FuguUserDetailCallback? = nil) {
        
        if isOpenedFromPush, let userDetailData = FuguDefaults.object(forKey: DefaultName.putUserData.rawValue) as? [String: Any]{
            self.handlePutUserResponse(userDetailData: userDetailData, completion: completion)
            return
        }
        var endPointName = FuguEndPoints.API_PUT_USER_DETAILS.rawValue
        
        if HippoConfig.shared.credentialType == .reseller {
            endPointName = FuguEndPoints.API_Reseller_Put_User.rawValue
        }
        
        let params: [String: Any]
        do {
            params = try getParamsToGetFuguUserDetails()
        } catch {
            completion?(false, error)
            return
        }
        
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: RequestIdenfier.putUser, para: params, extendedUrl: endPointName) { (responseObject, error, tag, statusCode) in
            
            guard let response = (responseObject as? [String: Any]), statusCode == STATUS_CODE_SUCCESS, let data = response["data"] as? [String: Any] else {
                HippoConfig.shared.log.error("PutUserError: \(error.debugDescription)", level: .error)
                if statusCode == 400 {
                    if let message = (responseObject as? [String: Any])?["message"] as? String {
                        HippoConfig.shared.sendSecurityError(message: message)
                    }
                }
                
                NotificationCenter.default.post(name: .putUserFailure, object:self)
                completion?(false, (error ?? APIErrors.statusCodeNotFound))
                return
            }
            HippoConfig.shared.log.trace("PutUserData: \(data)", level: .response)
            if userDetailData.isEmpty && HippoNotification.containsNotification(){
                let allConversationObj = AllConversationsViewController()
                allConversationObj.getAllConversations()
            }
            userDetailData = data
            FuguDefaults.set(value: userDetailData, forKey: DefaultName.putUserData.rawValue)
            self.handlePutUserResponse(userDetailData: userDetailData, completion: completion)
        }
    }
    
    class func handlePutUserResponse(userDetailData: [String : Any],completion: FuguUserDetailCallback? = nil) {
        if let jitsiUrl = userDetailData["jitsi_url"] as? String{
            HippoConfig.shared.jitsiUrl = jitsiUrl
        }
        
        if let tags = userDetailData["grouping_tags"] as? [[String: Any]] {
            HippoConfig.shared.userDetail?.userTags.removeAll()
            for each in tags {
                HippoConfig.shared.userDetail?.userTags.append(UserTag(json: each))
            }
        }
        
        if let serverTime = userDetailData["updateAt"] as? Int {
            let difference = serverTime - Int(NSDate().timeIntervalSince1970 * 1000)
            HippoConfig.shared.serverTimeDifference = difference
        }
        
        if let deviceKey = userDetailData["device_key"] as? String {
            HippoConfig.shared.deviceKey = deviceKey
            SocketClient.shared.connect()
        }
        
        if let appSecretKey = userDetailData["app_secret_key"] as? String {
            HippoConfig.shared.appSecretKey = appSecretKey
            subscribeMarkConversation()
        }
        
        if let whatsappConfig = userDetailData["whatsapp_widget_config"] as? [String: Any], let whatsappEnabled = whatsappConfig["whatsappEnabled"] as? Int, whatsappEnabled == 1{
            let title = whatsappConfig["title"] as? String ?? ""
            let subTitle = whatsappConfig["subTitle"] as? String ?? ""
            let defaultMessage = whatsappConfig["defaultMessage"] as? String ?? ""
            let defaultUserReply = whatsappConfig["defaultUserReply"] as? String ?? ""
            let whatsappContactNumber = whatsappConfig["whatsappContactNumber"] as? String ?? ""
            let whatsappEnabledForAll = whatsappConfig["whatsappEnabledForAll"] as? Int ?? 0
            HippoConfig.shared.whatsappWidgetConfig = WhatsappWidgetConfig(defaultMessage: defaultMessage, title: title, subTitle: subTitle, defaultUserReply: defaultUserReply, whatsappContactNumber: whatsappContactNumber, whatsappEnabledForAll: whatsappEnabledForAll)
        }
        
        
        BussinessProperty.current.isCallInviteEnabled = Bool.parse(key: "is_call_invite_enabled", json: userDetailData)
        
        if let automationEnabled = Int.parse(values: userDetailData, key: "is_automation_client"){
            BussinessProperty.current.isAutomationEnabled = automationEnabled
        }else{
            BussinessProperty.current.isAutomationEnabled = 0
        }
        
        BussinessProperty.current.editDeleteExpiryTime = CGFloat(Int.parse(values: userDetailData, key: "edit_delete_message_duration") ?? 0)
        
        if let userId = userDetailData["user_id"] as? Int {
            HippoUserDetail.fuguUserID = userId
        }
        
        if let callingType = userDetailData["calling_type"] as? String{
            HippoUserDetail.callingType = Int(callingType)
        }
        
        if let enUserId = userDetailData["en_user_id"] as? String {
            HippoUserDetail.fuguEnUserID = enUserId
        }
        BussinessProperty.current.id = userDetailData["business_id"] as? Int
        
        if let rawUserChannel = userDetailData["user_channel"] as? String {
            HippoUserDetail.HippoUserChannelId = rawUserChannel
            subscribeCustomerUserChannel(userChannelId: rawUserChannel)
        }
        
        if let rawEmail = userDetailData["email"] as? String {
            HippoConfig.shared.userDetail?.email = rawEmail
        }
        
        if let customer_initial_form_info = userDetailData["customer_initial_form_info"] as? [String: Any] {
            HippoProperty.current.forms = FormData.getFormDataList(from: customer_initial_form_info)
            HippoProperty.current.formCollectorTitle = customer_initial_form_info["page_title"] as? String ?? HippoStrings.support.capitalized
        } else {
            HippoProperty.current.forms = []
        }
        
        HippoProperty.current.showMessageSourceIcon = Bool.parse(key: "show_message_source", json: userDetailData, defaultValue: false)
        
        var isFaqEnabled = false
        if let is_faq_enabled = userDetailData["is_faq_enabled"] as? Bool {
            isFaqEnabled = is_faq_enabled
        }
        HippoConfig.shared.log.trace("User Login Data\(userDetailData)", level: .response)
        
        if let cusstomerBotID = String.parse(values: userDetailData, key: "customer_conversation_bot_id") {
            HippoProperty.setNewConversationBotGroupId(botGroupId: cusstomerBotID)
        }
        
        BussinessProperty.current.updateData(loginData: userDetailData)
        
        
        if let in_app_support_panel_version = userDetailData["in_app_support_panel_version"] as? Int, in_app_support_panel_version > HippoSupportList.currentFAQVersion, isFaqEnabled {
            HippoSupportList.getListForBusiness(completion: { (success, list) in
                if success {
                    HippoSupportList.currentFAQVersion = in_app_support_panel_version
                }
            })
        }
        
        resetPushCount()
        
        if let lastVisibleController = getLastVisibleController() as? ConversationsViewController, let channelId = lastVisibleController.channel?.id {
            lastVisibleController.clearUnreadCountForChannel(id: channelId)
        } else {
            pushTotalUnreadCount()
        }
        NotificationCenter.default.post(name: .putUserSuccess, object:self)
        
        let isAskPaymentAllowed = Bool.parse(key: "is_ask_payment_allowed", json: userDetailData, defaultValue: false)
        if isAskPaymentAllowed == true && self.shouldGetPaymentGateways{
            
            self.getPaymentGateway() { (success) in
                //guard success == true else { return }
            }
        }
        let announcementCount = userDetailData["unread_channels"] as? [Int] ?? [Int]()
        let arr = announcementCount.map{String($0)}
        if !(HippoConfig.shared.isOpenedFromPush ?? false){
            HippoConfig.shared.announcementUnreadCount?(announcementCount.count)
            UserDefaults.standard.set(arr, forKey: DefaultName.announcementUnreadCount.rawValue)
        }
        
        if HippoConfig.shared.isPopUpCalledBeforeCaching == true, let btnOneCallback = HippoConfig.shared.popupCallbacksCache?.first, let btnTwoCallback = HippoConfig.shared.popupCallbacksCache?.last, let screenToShowPopUpOn = HippoConfig.shared.screenToShowPopUpOn{
            HippoConfig.shared.presentPromotionalPopUp(on: screenToShowPopUpOn, onButtonOneClick: btnOneCallback, onButtonTwoClick: btnTwoCallback)
            HippoConfig.shared.isPopUpCalledBeforeCaching = false
        }
        
        completion?(true, nil)
        
    }
    
    
    
    class func getPaymentGateway(completion: @escaping (Bool) -> Void) {
        let params = getParamsForPaymentGateway()
        getPaymentGateway(params: params, completion: completion)
    }
    
    private class func getPaymentGateway(params: [String: Any],  completion: @escaping (Bool) -> Void) {
        HippoConfig.shared.log.debug("API_GetPaymentGateway.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.getPaymentGateway.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any],
                  let statusCode = responseDict["statusCode"] as? Int, let data = responseDict["data"] as? [String: Any], let addedPaymentGateways = data["added_payment_gateways"] as? [[String: Any]], statusCode == 200 else {
                HippoConfig.shared.log.debug("API_API_GetPaymentGateway ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                completion(false)
                return
            }
            //            let addedPaymentGatewaysArr = PaymentGateway.parse(addedPaymentGateways: addedPaymentGateways)
            FuguDefaults.set(value: addedPaymentGateways, forKey: DefaultName.addedPaymentGatewaysData.rawValue)
            completion(true)
        }
    }
    
    private class func getParamsForPaymentGateway() -> [String: Any] {
        var params = [String: Any]()
        params["app_secret_key"] = HippoConfig.shared.appSecretKey
        params["app_version"] = fuguAppVersion
        params["device_type"] = Device_Type_iOS
        params["source_type"] = SourceType.SDK.rawValue
        params["app_version_code"] = versionCode
        params["get_enabled_gateways"] = 1
//        params["is_sdk_flow"] = 1
        params["offering"] = HippoConfig.shared.offering
        if let enUserID = HippoUserDetail.fuguEnUserID{
            params["en_user_id"] = enUserID
        }
        
        if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
            if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                params["user_identification_secret"] = userIdenficationSecret
            }
        }
        
        return params
    }
    
    private class func getParamsToGetFuguUserDetails() throws -> [String: Any] {
        guard var params = HippoConfig.shared.userDetail?.toJson() else {
            throw FuguUserIntializationError.invalidUserUniqueKey
        }
        params["offering"] = HippoConfig.shared.offering
        //        params["en_user_id"] = HippoUserDetail.fuguEnUserID
        
        switch HippoConfig.shared.credentialType {
        case FuguCredentialType.reseller:
            if params["reseller_token"] == nil {
                throw FuguUserIntializationError.invalidResellerToken
            }
            
            if params["reference_id"] == nil {
                throw FuguUserIntializationError.invalidResellerToken
            }
        default:
            if params["app_secret_key"] == nil {
                throw FuguUserIntializationError.invalidAppSecretKey
            }
        }
        params["app_version_code"] = versionCode
        params["source"] = HippoSDKSource
        
        //        if HippoProperty.current.singleChatApp {
        ////            params["neglect_conversations"] = true
        //        }
        
        params["fetch_whatsapp_config"] = 1
        params["neglect_conversations"] = true
        
        return params
    }
    
    class func hitStatsAPi(pushContent: [String: Any]?, sendSessionTym: Bool = false, linkClicked: String? = nil, channelId: Int? = nil, actionType: Int? = nil) {
        
        if sendSessionTym && HippoConfig.shared.sessionStartTime == nil{
            return
        }
        
        let params = getParamsForStats(from: pushContent, sendSessionTym: sendSessionTym, linkClicked: linkClicked, channelId: channelId, actionType: actionType)
        print(params, FuguEndPoints.statsUpdate.rawValue)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.statsUpdate.rawValue) { (response, error, _, statusCode) in
            print(response)
            if let responseDict = response as? [String: Any],
               let statusCode = responseDict["statusCode"] as? Int,
               let data = responseDict["data"] as? [String: Any], statusCode == 200 {
                if sendSessionTym{
                    HippoConfig.shared.sessionStartTime = nil
                    HippoConfig.shared.tempChannelId = nil
                }
                print(data)
            }else {
                HippoConfig.shared.log.debug((error, statusCode), level: .error)
            }
        }
    }
    
    private class func getParamsForStats(from data: [String: Any]?, sendSessionTym: Bool = false, linkClicked: String? = nil, channelId: Int? = nil, actionType: Int? = nil) -> [String: Any] {
        var params = [String: Any]()
        
        params["en_user_id"] = currentEnUserId()
        params["channel_id"] = sendSessionTym ? HippoConfig.shared.tempChannelId : channelId
        
        if currentUserType() == .agent{
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }else{
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }
        
        if sendSessionTym{
            let sessionTym = Int(Date().timeIntervalSince(HippoConfig.shared.sessionStartTime ?? Date()))
            HippoConfig.shared.log.debug(("session tym ----->>>>>>>>", sessionTym, "\n channel id - \(HippoConfig.shared.tempChannelId ?? 0)"), level: .info)
            params["ctr_session_time"] = "\(sessionTym)"
           
        }else{
            if linkClicked != nil{
                if actionType != 2{
                    let date = "\(Date())"
                    params["open_links"] = [["time": date, "link": linkClicked ?? ""]]
                }
                params["is_clicked"] = 1
            }else{
                let timestampInSeconds = Int(Date().timeIntervalSince1970)
                params["ctr_session_time"] = "\(timestampInSeconds)"
                params["is_delivered"] = 1
                params["channel_id"] = channelId
            }
           
        }
        
        return params
    }
    
    class func getPromotionalPopUpData(completion: @escaping (PromotionalPopUpData?, [String: Any]?) -> Void){
        let params = getParamsForPromotionalPopUp()
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.promotionalPopUp.rawValue, callback: { (response, error, _, statusCode) in
            if let responseDict = response as? [String: Any],
               let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 {
                completion(decodeJson(from: response as Any), responseDict)
            }else {
                completion(nil, nil)
            }
        })
    }
    
    private class func getParamsForPromotionalPopUp() -> [String: Any]{
        var params: [String : Any] = [
            "en_user_id" : currentEnUserId(),
            "start_offset" : 0,
            "end_offset" : 10
        ]
        
        if currentUserType() == .agent{
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }else{
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }
        
        return params
    }
    
    private class func decodeJson(from data: Any) -> PromotionalPopUpData? {
        
        let decoder = JSONDecoder()
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        do {
            let people = try decoder.decode(PromotionalPopUpData.self, from: jsonData ?? Data())
            return people
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    class func clearAgentData() {
        HippoConfig.shared.agentDetail = nil
        AgentConversationManager.errorMessage = nil
        AgentChannelPersistancyManager.shared.clearChannels()
        HippoChannel.hashmapTransactionIdToChannelID = [:]
        FuguDefaults.removeObject(forKey: "hashmapTransactionIdToChannelID")
        
        AgentDetail.agentLoginData = nil
        UnreadCount.clearAllStoredUnreadCount()
        AgentConversationManager.searchUserUniqueKeys.removeAll()
        AgentConversationManager.transactionID = nil
        ConversationStore.shared.clearData()
        AgentUserChannel.shared = nil
    }
    
    class func clearAllData(completion: ((Bool) -> Void)? = nil) {
        
        FuguDefaults.removeAllPersistingData()
        //        if FayeConnection.shared.isConnected{
        //            FayeConnection.shared.disconnectFaye()
        //        }
        //Clear agent data
        clearAgentData()
        
        //unSubscribe(userChannelId: HippoUserDetail.HippoUserChannelId ?? "")
        HippoConfig.shared.groupCallData.removeAll()
        HippoProperty.current = HippoProperty()
        BussinessProperty.current.isAutomationEnabled = nil
        
        //FuguConfig.shared.deviceToken = ""
        HippoConfig.shared.appSecretKey = ""
        HippoConfig.shared.resellerToken = ""
        HippoConfig.shared.referenceId = -1
        HippoConfig.shared.appType = nil
        HippoConfig.shared.userDetail = nil
        HippoConfig.shared.muidList = []
        
        HippoConfig.shared.whatsappWidgetConfig = nil
        HippoConfig.shared.isOpenedFromPush = nil
        HippoConfig.shared.sessionStartTime = nil
        HippoConfig.shared.tempChannelId = nil
        HippoConfig.shared.botButtonActionCallBack = nil
        HippoConfig.shared.newChatCallback = nil
        resetPushCount()
        
        userDetailData = [String: Any]()
        FuguChannelPersistancyManager.shared.clearChannels()
        HippoChannel.hashmapTransactionIdToChannelID = [:]
        FuguDefaults.removeObject(forKey: "hashmapTransactionIdToChannelID")
        
        FuguDefaults.removeObject(forKey: DefaultKey.myChatConversations)
        FuguDefaults.removeObject(forKey: DefaultKey.allChatConversations)
        FuguDefaults.removeObject(forKey: DefaultKey.allChatConversations)
        
        FuguDefaults.removeObject(forKey: DefaultName.conversationData.rawValue)
        FuguDefaults.removeObject(forKey: DefaultName.appointmentData.rawValue)
        FuguDefaults.removeObject(forKey: DefaultName.addedPaymentGatewaysData.rawValue)
        
        FuguDefaults.removeAllPersistingData()
        
        CallManager.shared.hungupCall()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Hippo_User_Channel_Id)
        defaults.removeObject(forKey: FUGU_USER_ID)
        defaults.removeObject(forKey: Fugu_en_user_id)
        defaults.synchronize()
        completion?(true)
    }
    
    class func logoutFromFugu(completion: ((Bool) -> Void)? = nil) {
        if HippoConfig.shared.appSecretKey.isEmpty {
            completion?(false)
            return
            
        }
        var params: [String: Any] = [
            "app_secret_key": HippoConfig.shared.appSecretKey,
            "offering" : HippoConfig.shared.offering,
            "device_type" : Device_Type_iOS
        ]
        
        if let savedUserId = HippoUserDetail.fuguEnUserID {
            params["en_user_id"] = savedUserId
        }
        
        if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
            if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                params["user_identification_secret"] = userIdenficationSecret
            }
        }
        let deviceToken = TokenManager.deviceToken
        let voipToken = TokenManager.voipToken
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CLEAR_USER_DATA_LOGOUT.rawValue) { (responseObject, error, tag, statusCode) in
            if currentUserType() == .customer{
                unSubscribe(userChannelId: HippoUserDetail.HippoUserChannelId ?? "")
            }else{
                unSubscribe(userChannelId: HippoConfig.shared.agentDetail?.userChannel ?? "")
            }
            clearAllData(completion: completion)
            TokenManager.deviceToken = deviceToken
            TokenManager.voipToken = voipToken
            unSubscribe(userChannelId: HippoConfig.shared.appSecretKey + "/" + "markConversation")
            //            let tempStatusCode = statusCode ?? 0
            //            let success = (200 <= tempStatusCode) && (300 > tempStatusCode)
            //            completion?(success)
        }
    }
}






