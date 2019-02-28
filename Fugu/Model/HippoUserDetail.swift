//
//  HippoUserDetail.swift
//  Fugu
//
//  Created by Gagandeep Arora on 31/08/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

typealias HippoUserDetailCallback = (_ success: Bool, _ error: Error?) -> Void

@objc public class HippoUserDetail: NSObject {
   
   // MARK: - Properties
    var fullName: String?
    var email: String?
    var phoneNumber: String?
    var userUniqueKey: String?
    var addressAttribute: HippoAttributes?
    var customAttributes: [String: Any]?
    var isJugnooUser: Bool = false
    
   fileprivate(set) var fuguUserID: Int? {
      get {
         return UserDefaults.standard.value(forKey: FUGU_USER_ID) as? Int
      }
      set {
         UserDefaults.standard.set(newValue, forKey: FUGU_USER_ID)
      }
   }
   
   fileprivate(set) var fuguEnUserID: String? {
      get {
         return UserDefaults.standard.value(forKey: Fugu_en_user_id) as? String
      }
      set {
         UserDefaults.standard.set(newValue, forKey: Fugu_en_user_id)
      }
   }
   
   // MARK: - Intializer
    override init() {}
    
    public init(fullName: String, email: String, phoneNumber: String, userUniqueKey: String, addressAttribute: HippoAttributes? = nil, customAttributes: [String: Any]? = nil, isJugnooUser: Bool = false) {
        super.init()
        
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.userUniqueKey = userUniqueKey
        self.addressAttribute = addressAttribute ?? HippoAttributes()
        self.customAttributes = customAttributes
        self.isJugnooUser = isJugnooUser
    }
   
   // MARK: - Helpers
    func toJson() -> [String: Any] {
        var params: [String: Any] = [
         "device_id": UIDevice.current.identifierForVendor?.uuidString ?? 0,
         "device_type" : Device_Type_iOS
      ]
        
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
      
      if let applicationType = HippoConfig.shared.appType,
         applicationType.isEmpty == false {
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
        
        if let addressInfo = addressAttribute?.toJSON() { params["attributes"] = addressInfo }
        
        if customAttributes != nil {
         params["custom_attributes"] = customAttributes!
      }
        
        if HippoConfig.shared.deviceToken.isEmpty == false { params["device_token"] = HippoConfig.shared.deviceToken }
        
        var deviceDetails = [String: Any]()
        deviceDetails["ios_operating_system"] = "IOS"
        deviceDetails["ios_model"] = UIDevice.current.model
        deviceDetails["ios_manufacturer"] = "APPLE"
        deviceDetails["ios_os_version"] = UIDevice.current.systemVersion
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: deviceDetails, options: .prettyPrinted)
            
            var service = (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! ) as String
            service = service.replacingOccurrences(of: "\n", with: "")
            service = service.replacingOccurrences(of: "\\", with: "")
            
            params["device_details"] = service
        } catch let error as NSError {
            print(error.description)
        }
        return params
    }
   
   
   // MARK: - Type Methods
   class func getUserDetailsAndConversation(completion: HippoUserDetailCallback? = nil) {
      var endPointName = FuguEndPoints.API_PUT_USER_DETAILS.rawValue
      
      if HippoConfig.shared.credentialType == .reseller {
         endPointName = FuguEndPoints.API_Reseller_Put_User.rawValue
      }
      
      let params: [String: Any]
      do {
         params = try getParamsToGetHippoUserDetails()
      } catch {
         completion?(false, error)
         return
      }
      
      
      HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: endPointName) { (responseObject, error, tag, statusCode) in
         
         guard let response = (responseObject as? [String: Any]),
            statusCode == STATUS_CODE_SUCCESS,
            let data = response["data"] as? [String: Any] else {
               completion?(false, (error ?? APIErrors.statusCodeNotFound))
               return
         }
         
         userDetailData = data
          
        
         if let appSecretKey = userDetailData["app_secret_key"] as? String {
            HippoConfig.shared.appSecretKey = appSecretKey
         }
         
         if let userId = userDetailData["user_id"] as? Int {
            HippoConfig.shared.userDetail?.fuguUserID = userId
         }
         
         if let enUserId = userDetailData["en_user_id"] as? String {
            HippoConfig.shared.userDetail?.fuguEnUserID = enUserId
         }
        var isFaqEnabled = false
        if let is_faq_enabled = userDetailData["is_faq_enabled"] as? Bool {
            isFaqEnabled = is_faq_enabled
        }
        if let in_app_support_panel_version = userDetailData["in_app_support_panel_version"] as? Int, in_app_support_panel_version > HippoSupportList.currentFAQVersion, isFaqEnabled {
            HippoSupportList.getListForBusiness(completion: { (success, list) in
                if success {
                    HippoSupportList.currentFAQVersion = in_app_support_panel_version
                }
            })
        }
         if let botChannelsArray = userDetailData["conversations"] as? [[String: Any]] {
            FuguDefaults.set(value: botChannelsArray, forKey: DefaultName.conversationData.rawValue)
         }
         _ = checkUnreadChatCount()
         
         completion?(true, nil)
      }
   }
   
   private class func getParamsToGetHippoUserDetails() throws -> [String: Any] {
      guard let params = HippoConfig.shared.userDetail?.toJson() else {
         throw FuguUserIntializationError.invalidUserUniqueKey
      }
      
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
      
      return params
   }
   class func logoutFromHippo(completion: ((Bool) -> Void)? = nil) {
        if HippoConfig.shared.appSecretKey.isEmpty || HippoConfig.shared.userDetail == nil {
            clearData()
          completion?(false)
            return
            
        }
        var params: [String: Any] = [
            "app_secret_key": HippoConfig.shared.appSecretKey
        ]
        
      if let savedUserId = HippoConfig.shared.userDetail?.fuguUserID {
            params["user_id"] = savedUserId
        }
    
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_CLEAR_USER_DATA_LOGOUT.rawValue) { (responseObject, error, tag, statusCode) in

         clearData()
         let tempStatusCode = statusCode ?? 0
         let success = (200 <= tempStatusCode) && (300 > tempStatusCode)
         completion?(success)
        }
    }
    
    private class func clearData() {
        
        //HippoConfig.shared.deviceToken = ""
        HippoConfig.shared.appSecretKey = ""
        HippoConfig.shared.resellerToken = ""
        HippoConfig.shared.referenceId = -1
        HippoConfig.shared.appType = nil
        HippoConfig.shared.userDetail = nil
        userDetailData = [String: Any]()
        FuguChannelPersistancyManager.shared.clearChannels()
        FuguChannel.hashmapTransactionIdToChannelID = [:]
        
        HippoSupportList.FAQData = [:]
        HippoSupportList.currentFAQVersion = 0
        
        FuguDefaults.removeObject(forKey: DefaultName.conversationData.rawValue)
        FuguDefaults.removeAllPersistingData()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: FUGU_USER_ID)
        defaults.removeObject(forKey: Fugu_en_user_id)
        defaults.synchronize()
    }
}
