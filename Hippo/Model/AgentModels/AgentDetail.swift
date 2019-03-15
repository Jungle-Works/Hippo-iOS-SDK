//
//  AgentDetail.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

enum HippoError: LocalizedError {
    case general
    case networkError
    case callClientNotFound
    case invalidInputData
    case invalidEmail
    case notAllowedForAgent
    case threwError(message: String)
    
    var errorDescription: String? {
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
        case .networkError:
            return HippoConfig.shared.strings.noNetworkConnection
        default:
            return HippoConfig.shared.strings.somethingWentWrong
        }
    }
}

enum AgentStatus: String {
    case available = "AVAILABLE"
    case offline = "OFFLINE"
    case away = "AWAY"
}

struct ResponseResult {
    let isSuccessful: Bool
    let error: Error?
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
    
    var status = AgentStatus.offline
    
    var oAuthToken = ""
    var app_type = AgentDetail.defaultAppType
    var customAttributes: [String: Any]? = nil
    
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
        number = dict["phone_number"] as? String ?? ""
        
        if let online_status = dict["online_status"] as? String, let status = AgentStatus.init(rawValue: online_status) {
            self.status = status
        }
        if let auth_token = dict["auth_token"] as? String {
            oAuthToken = auth_token
        }
        if let type = dict["app_type"] as? String {
            app_type = type
        }
        if let custom_attributes = dict["self_custom_attributes"] as? [String : Any] {
            self.customAttributes = custom_attributes
        }
    }
    
    
    
    init(oAuthToken: String, appType: String, customAttributes: [String: Any]?) {
        self.oAuthToken = oAuthToken
        self.customAttributes = customAttributes
        let type = appType.trimWhiteSpacesAndNewLine()
        self.app_type = type.isEmpty ? AgentDetail.defaultAppType : type
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
        dict["online_status"] = status.rawValue
        
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
                HippoUserDetail.clearAllData()
                AgentConversationManager.errorMessage = error?.localizedDescription
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
                print("Login errror: \(error?.localizedDescription ?? "Something went wrong")")
                postLoginUpdated()
                HippoUserDetail.clearAllData()
                AgentConversationManager.errorMessage = error?.localizedDescription ?? "Something went wrong"
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
            
            HippoConfig.shared.isVideoCallEnabled = Bool.parse(key: "is_video_call_enabled", json: data)
            HippoConfig.shared.isAudioCallEnabled = Bool.parse(key: "is_audio_call_enabled", json: data)
            HippoConfig.shared.unsupportedMessageString = data["unsupported_message"] as? String ?? ""
            HippoConfig.shared.maxUploadLimitForBusiness = data["max_file_size"] as? UInt ?? 10
            
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
            return
        }
        let params = getParamsForLogout()
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.logout.rawValue) { (responseObject, error, tag, statusCode) in
            
            HippoUserDetail.clearAllData()
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
        params["access_token"] = agentDetail.fuguToken
        params["device_type"] = Device_Type_iOS
        params["device_id"]  =  UIDevice.current.identifierForVendor?.uuidString ?? 0
        params["device_details"] = getDeviceDetails()
        params["app_type"]  = agentDetail.app_type
        
        if let attributes = HippoConfig.shared.agentDetail?.customAttributes {
            params["custom_attributes"]  = attributes
        }
        if !HippoConfig.shared.deviceToken.isEmpty {
            params["device_token"] = HippoConfig.shared.deviceToken
        }
        if !HippoConfig.shared.voipToken.isEmpty {
            params["voip_token"] = HippoConfig.shared.voipToken
        }
        params["app_version_code"] = "\(versionCode)"
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
