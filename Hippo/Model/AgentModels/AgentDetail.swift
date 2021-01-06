//
//  AgentDetail.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

public enum HippoError: LocalizedError {
    case general
    case networkError
    case callClientNotFound
    case invalidInputData
    case invalidEmail
    case notAllowedForAgent
    case invalidAppSecretKey
    case updateUserDetail
    case threwError(message: String)
    case ChannelIdNotFound
    
    public var errorDescription: String? {
        switch self {
        case .threwError(message: let errorMessage):
            return errorMessage
        case .invalidEmail:
            return HippoConfig.shared.strings.invalidEmail
        case .invalidInputData:
            return HippoConfig.shared.strings.inputDataIsInvalid
        case .notAllowedForAgent:
            return HippoConfig.shared.strings.notAllowedForAgent
        case .callClientNotFound:
            return HippoConfig.shared.strings.callClientNotFound
        case .updateUserDetail:
            return HippoStrings.somethingWentWrong
        case .invalidAppSecretKey:
            return "Invalid appsecret key"
        case .networkError:
            return HippoStrings.noNetworkConnection
        case .ChannelIdNotFound:
            return "Channel id is empty"
        default:
            return HippoStrings.somethingWentWrong
        }
    }
}

enum AgentStatus: String , CaseIterable{
    case available = "AVAILABLE"
    case offline = "OFFLINE"
    case away = "AWAY"
}

struct ResponseResult {
    let isSuccessful: Bool
    let error: Error?
    let response : NSDictionary? = NSDictionary()
}

class AgentDetail: NSObject {
    
    static let defaultAppType = "99"
    
    var isForking: Bool = false
    
    var id: Int = -1
    var enUserId: String = ""
    var fullName: String = ""
    var fuguToken = ""
    var userName = ""
    var appSecrectKey = ""
    var businessUniqueName = ""
    var userChannel = ""
    var email = ""
    var businessId = -1
    var businessName = ""
    var number = ""
    var userImage: String?
    var languageCode : String?
//    var status = AgentStatus.offline
    var agentUserType = AgentUserType.agent
    
    var oAuthToken = ""
    var authTokenInitManager = ""
    var app_type = AgentDetail.defaultAppType
    var customAttributes: [String: Any]? = nil
    var businessCurrency : [BuisnessCurrency]?
    
    static var agentLoginData: [String: Any]? {
        get {
            return UserDefaults.standard.value(forKey: UserDefaultkeys.agentData) as? [String: Any]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.agentData)
        }
    }
    
    init(dict: [String: Any]) {
        super.init()
        
        id = dict["user_id"] as? Int ?? -1
        enUserId = dict["en_user_id"] as? String ?? ""
        fullName = dict["full_name"] as? String ?? ""
        fuguToken = dict["access_token"] as? String ?? ""
        userName = dict["user_name"] as? String ?? ""
        appSecrectKey = dict["app_secret_key"] as? String ?? ""
        businessUniqueName = dict["business_unique_name"] as? String ?? ""
        userChannel = dict["user_channel"] as? String ?? ""
        email = dict["email"] as? String ?? ""
        businessId = dict["business_id"] as? Int ?? -1
        businessName = dict["business_name"] as? String ?? ""
        if let buisnessLanguageArr = dict["business_languages"] as? [[String : Any]]{
            BussinessProperty.current.buisnessLanguageArr = BuisnessLanguage().getLanguageData(buisnessLanguageArr)
        }
        number = dict["phone_number"] as? String ?? ""
        userImage = dict["user_image"] as? String
        languageCode = dict["lang_code"] as? String
        
        if (languageCode?.trimWhiteSpacesAndNewLine() ?? "") != ""{
            for (index,_) in (BussinessProperty.current.buisnessLanguageArr ?? [BuisnessLanguage]()).enumerated(){
                if BussinessProperty.current.buisnessLanguageArr?[index].lang_code == languageCode{
                    BussinessProperty.current.buisnessLanguageArr?[index].is_default = true
                }else{
                    BussinessProperty.current.buisnessLanguageArr?[index].is_default = false
                }
            }
        }
        
      
//        if let online_status = dict["online_status"] as? String, let status = AgentStatus.init(rawValue: online_status) {
//            self.status = status
//        }
//        if HippoConfig.shared.agentDetail?.status == AgentStatus.offline{
//            if let online_status = dict["online_status"] as? String, let status = AgentStatus.init(rawValue: online_status) {
//                self.status = status
//            }
//        }else{
//            self.status = HippoConfig.shared.agentDetail?.status ?? AgentStatus.offline
//        }
        
        if let auth_token = dict["auth_token"] as? String {
            oAuthToken = auth_token
        }
        if let type = dict["app_type"] as? String {
            app_type = type
        }
        if let custom_attributes = dict["self_custom_attributes"] as? [String : Any] {
            self.customAttributes = custom_attributes
        }
        if let agent_type = dict["agent_type"] as? Int, let agentType = AgentUserType.init(rawValue: agent_type){
            self.agentUserType = agentType
        }
        
    }
       
    init(oAuthToken: String, appType: String, customAttributes: [String: Any]?, userId : Int? = nil) {
        self.oAuthToken = oAuthToken
        self.customAttributes = customAttributes
        let type = appType.trimWhiteSpacesAndNewLine()
        self.app_type = type.isEmpty ? AgentDetail.defaultAppType : type
        self.authTokenInitManager = oAuthToken
        self.id = userId ?? -1
    }
    
    func toJson() -> [String: Any] {
        var dict = [String: Any]()
        dict["auth_token"] = oAuthToken.isEmpty ? fuguToken : oAuthToken
        dict["user_id"] = id
        dict["en_user_id"] = enUserId
        dict["full_name"] = fullName
        dict["access_token"] = fuguToken
        dict["user_name"] = userName
        dict["app_secret_key"] = appSecrectKey
        dict["business_unique_name"] = businessUniqueName
        dict["user_channel"] = userChannel
        dict["email"] = email
        dict["business_id"] = businessId
        dict["business_name"] = businessName
        dict["phone_number"]  = number
//        dict["online_status"] = status.rawValue
        dict["agent_type"] = agentUserType.rawValue
        dict["user_image"] = userImage
        dict["app_type"] = app_type
        if customAttributes != nil {
         dict["self_custom_attributes"] = customAttributes!
        }
        
        return dict
    }
    class func setAgentStoredData() {
        guard let storedData = AgentDetail.agentLoginData else {
            return
        }
        HippoConfig.shared.appUserType = .agent
        HippoConfig.shared.agentDetail = AgentDetail(dict: storedData)
        
        if !HippoConfig.shared.agentDetail!.fuguToken.isEmpty {
            HippoConfig.shared.appUserType = .agent
        }
    }
}

//MARK: API's
extension AgentDetail {
    class func loginViaAuth(completion: @escaping (_ result: ResponseResult) -> Void) {
        guard HippoConfig.shared.appUserType == .agent, let agentDetail = HippoConfig.shared.agentDetail else {
            let result = ResponseResult(isSuccessful: false, error: HippoError.general)
            completion(result)
            return
        }
        let params = getParamsForAuthLogin()
        let endpoint: String
        
        if agentDetail.isForking {
            endpoint = AgentEndPoints.getAgentLoginInfo.rawValue
        } else {
            endpoint = AgentEndPoints.loginViaAuthToken.rawValue
        }
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: endpoint) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], unwrappedStatusCode == STATUS_CODE_SUCCESS else {
                let result = ResponseResult(isSuccessful: false, error: error)
                postLoginUpdated()
                AgentConversationManager.errorMessage = error?.localizedDescription
                showAlertWith(message: error?.localizedDescription ?? "", action: nil)
                print(error.debugDescription)
                completion(result)
                return
            }
            let authToken = HippoConfig.shared.agentDetail?.oAuthToken
            let app_type = HippoConfig.shared.agentDetail?.app_type ?? AgentDetail.defaultAppType
            let attributes = HippoConfig.shared.agentDetail?.customAttributes
            let isForking = HippoConfig.shared.agentDetail?.isForking ?? false
            
            let detail = AgentDetail(dict: data)
            detail.oAuthToken = authToken ?? detail.fuguToken
            detail.app_type = app_type
            detail.customAttributes = attributes
            detail.isForking = isForking
            
            HippoConfig.shared.agentDetail = detail
            loginAgentViaToken(completion: completion)
        }
        
    }
    
    class func loginAgentViaToken(completion: @escaping (_ result: ResponseResult) -> Void) {
        guard HippoConfig.shared.appUserType == .agent && HippoConfig.shared.agentDetail != nil else {
            let result = ResponseResult(isSuccessful: false, error: HippoError.general)
            completion(result)
            return
        }
        let params = getParamsForLogin()
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.loginViaToken.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any], unwrappedStatusCode == STATUS_CODE_SUCCESS else {
                let result = ResponseResult(isSuccessful: false, error: error)
                print("Login errror: \(error?.localizedDescription ?? HippoStrings.somethingWentWrong)")
                postLoginUpdated()
               // HippoUserDetail.clearAllData()
                AgentConversationManager.errorMessage = error?.localizedDescription ?? HippoStrings.somethingWentWrong
                completion(result)
                return
            }
            let authToken = HippoConfig.shared.agentDetail?.oAuthToken
            let app_type = HippoConfig.shared.agentDetail?.app_type ?? AgentDetail.defaultAppType
            let attributes = HippoConfig.shared.agentDetail?.customAttributes
            
            let detail = AgentDetail(dict: data)
            detail.oAuthToken = authToken ?? detail.fuguToken
            detail.app_type = app_type
            detail.customAttributes = attributes
            HippoConfig.shared.agentDetail = detail
            
            if let online_status = data["online_status"] as? String, let status = AgentStatus.init(rawValue: online_status) {
                BussinessProperty.current.agentStatusForToggle = status.rawValue
            }
            
          
            BussinessProperty.current.isVideoCallEnabled = Bool.parse(key: "is_video_call_enabled", json: data)
            BussinessProperty.current.isAudioCallEnabled = Bool.parse(key: "is_audio_call_enabled", json: data)
            
            if let businessProperty = data["business_property"] as? [String: Any] {
                BussinessProperty.current.editDeleteExpiryTime = CGFloat(Int.parse(values: businessProperty, key: "edit_delete_message_duration") ?? 0)
            
                BussinessProperty.current.encodeToHTMLEntities = Bool.parse(key: "encode_to_html_entites", json: businessProperty)
                
                BussinessProperty.current.isAskPaymentAllowed = Bool.parse(key: "is_ask_payment_allowed", json: businessProperty)
                
                BussinessProperty.current.hideAllChat = Bool.parse(key: "hide_all_chat_tab", json: businessProperty)
                
                BussinessProperty.current.shouldHideCustomerData = Bool.parse(key: "hide_customer_data", json: businessProperty)
                
                BussinessProperty.current.hideo2oChat = !(Bool.parse(key: "o2o_in_dashboard_enabled", json: businessProperty))
                
                BussinessProperty.current.eFormEnabled = (Bool.parse(key: "is_eform_enabled", json: businessProperty))
                
                BussinessProperty.current.currencyArr = BuisnessCurrency().getCurrenyData(businessProperty["business_currency"] as? [[String : Any]] ?? [[String : Any]]())
                HippoConfig.shared.jitsiUrl = businessProperty["jitsi_url"] as? String
            }
            
            BussinessProperty.current.unsupportedMessageString = data["unsupported_message"] as? String ?? ""
            BussinessProperty.current.maxUploadLimitForBusiness = data["max_file_size"] as? UInt ?? 10
            
            AgentDetail.agentLoginData = detail.toJson()
            
            fuguDelay(3, completion: {
                AgentUserChannel.reIntializeIfRequired()
            })
            
            let result = ResponseResult(isSuccessful: true, error: HippoError.general)
            AgentConversationManager.errorMessage = nil
            postLoginUpdated()
            completion(result)
        }
    }
    private static func postLoginUpdated() {
        NotificationCenter.default.post(name: .agentLoginDataUpated, object: self)
    }
    
    class func LogoutAgent(completion: ((Bool) -> Void)? = nil) {
        guard HippoConfig.shared.appUserType == .agent && HippoConfig.shared.agentDetail != nil else {
            HippoUserDetail.clearAllData()
            completion?(true)
            return
        }
        let params = getParamsForLogout()
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.logout.rawValue) { (responseObject, error, tag, statusCode) in
            
            HippoUserDetail.clearAllData()
            HippoConfig.shared.delegate?.hippoUserLogOut()
            let tempStatusCode = statusCode ?? 0
            let success = (200 <= tempStatusCode) && (300 > tempStatusCode)
            completion?(success)
            
        }
    }
}


//MARK: Params
extension AgentDetail {
    static func getDeviceDetails() -> String {
        var deviceDetails = [String: Any]()
        deviceDetails["os"] = "IOS"
        deviceDetails["model"] = UIDevice.current.model
        deviceDetails["manufacturer"] = "APPLE"
        deviceDetails["os_version"] = UIDevice.current.systemVersion
        deviceDetails["app_version_code"] = versionCode
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: deviceDetails, options: .prettyPrinted)
            
            var service = (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! ) as String
            service = service.replacingOccurrences(of: "\n", with: "")
            service = service.replacingOccurrences(of: "\\", with: "")
            
            return service
        } catch let error as NSError {
            print(error.description)
        }
        return ""
    }
    
    internal static func getParamsForLogout() -> [String: Any] {
        guard let agentDetail = HippoConfig.shared.agentDetail else {
            return [:]
        }
        var params = [String: Any]()
        params["access_token"] = agentDetail.fuguToken
        params["device_type"] = Device_Type_iOS
        params["device_id"]  =  UIDevice.current.identifierForVendor?.uuidString ?? 0
        
//        params["device_details"] = getDeviceDetails()
        params["source_type"] = 1
        
        return params
    }
    
    internal static func getParamsForLogin() -> [String: Any] {
        guard let agentDetail = HippoConfig.shared.agentDetail else {
            return [:]
        }
        var params = [String: Any]()
        params["ignore_agent_status"] = 1
        params["access_token"] = agentDetail.fuguToken
        params["device_type"] = Device_Type_iOS
        params["device_id"]  =  UIDevice.current.identifierForVendor?.uuidString ?? 0
        params["device_details"] = getDeviceDetails()
        params["app_type"]  = agentDetail.app_type
        
        if let attributes = HippoConfig.shared.agentDetail?.customAttributes {
            params["custom_attributes"]  = attributes
        }
        if !TokenManager.deviceToken.isEmpty {
            params["device_token"] = TokenManager.deviceToken
        }
        if !TokenManager.voipToken.isEmpty {
            params["voip_token"] = TokenManager.voipToken
        }
        params["app_version_code"] = "\(versionCode)"
        
        params["fetch_business_lang"] = 1
        params["fetch_tags"] = 0
        return params
    }
    internal static func getParamsForAuthLogin() -> [String: Any] {
        guard let agentDetail = HippoConfig.shared.agentDetail else {
            return [:]
        }
        var params = [String: Any]()
        
        if agentDetail.isForking {
            params["agent_secret_key"] = agentDetail.oAuthToken
        } else {
            params["auth_token"] = agentDetail.oAuthToken
        }
        params["fetch_tags"] = 0
        return params
    }
}
//MARK: Class variables
extension AgentDetail {
    class var id: Int {
        get {
            guard let _agentID = HippoConfig.shared.agentDetail?.id else { return -1 }
            return Int(_agentID)
        }
    }
}
