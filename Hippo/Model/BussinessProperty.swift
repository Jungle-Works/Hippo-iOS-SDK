//
//  BussinessProperty.swift
//  Hippo
//
//  Created by Vishal on 01/08/19.
//

import Foundation
import UIKit

class BussinessProperty: NSObject {
    static let current = BussinessProperty()
    var currencyArr : [BuisnessCurrency]?
    var buisnessLanguageArr : [BuisnessLanguage]?
    var shouldHideCustomerData : Bool?
    var editDeleteExpiryTime : CGFloat? // in minutes from backend
    var id : Int?
    
    var hideAllChat: Bool? {
         get {
             
             guard let hideAllChat = UserDefaults.standard.value(forKey: UserDefaultkeys.hideAllChat) as? Bool else {
                 return nil
             }
             return hideAllChat
         }
         set {
             UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.hideAllChat)
         }
     }
    
    var hideo2oChat: Bool? {
         get {
             
             guard let hideo2oChat = UserDefaults.standard.value(forKey: UserDefaultkeys.hideO2OChat) as? Bool else {
                 return nil
             }
             return hideo2oChat
         }
         set {
             UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.hideO2OChat)
         }
     }
    
    
    var botImageUrl: String? {
        get {
            
            guard let botImageUrl = UserDefaults.standard.value(forKey: UserDefaultkeys.botImageUrl) as? String else {
                return nil
            }
            return botImageUrl
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.botImageUrl)
        }
    }
    
    var isVideoCallEnabled: Bool {
        get {
            guard CallManager.shared.isCallClientAvailable() else {
                return false
            }
            
            guard let videoCallStatus = UserDefaults.standard.value(forKey: UserDefaultkeys.videoCallStatus) as? Bool else {
                return false
            }
            return videoCallStatus
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.videoCallStatus)
        }
    }
    var encodeToHTMLEntities: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: UserDefaultkeys.encodeToHtmlEntities) as? Bool else {
                return false
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.encodeToHtmlEntities)
        }
    }
    var isAudioCallEnabled: Bool {
        get {
            guard CallManager.shared.isCallClientAvailable() else {
                return false
            }
            guard let videoCallStatus = UserDefaults.standard.value(forKey: UserDefaultkeys.audioCallStatus) as? Bool else {
                return false
            }
            return videoCallStatus
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.audioCallStatus)
        }
    }

    var hideCallIconOnNavigationForCustomer: Bool {
        get {
            guard let status = UserDefaults.standard.value(forKey: UserDefaultkeys.hideCallIconOnNavigationForCustomer) as? Bool else {
                return false
            }
            return status
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.hideCallIconOnNavigationForCustomer)
        }
    }
    var multiChannelLabelMapping: Bool {
        get {
            guard let status = UserDefaults.standard.value(forKey: UserDefaultkeys.multiChannelLabelMapping) as? Bool else {
                return false
            }
            return status
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.multiChannelLabelMapping)
        }
    }
    var maxUploadLimitForBusiness: UInt {
        get {
            guard let value = UserDefaults.standard.value(forKey: UserDefaultkeys.maxFileUploadSize) as? UInt else {
                return 10
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.maxFileUploadSize)
        }
    }
    
    var unsupportedMessageString: String {
        get {
            guard let unsupportedMessageString = UserDefaults.standard.value(forKey: UserDefaultkeys.unsupportedMessageString) as? String, !unsupportedMessageString.isEmpty else {
                return HippoStrings.unknownMessage
            }
            return unsupportedMessageString
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.unsupportedMessageString)
        }
    }
    
    var isAskPaymentAllowed: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: UserDefaultkeys.isAskPaymentAllowed) as? Bool else {
                return false
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.isAskPaymentAllowed)
        }
    }
    
    var agentStatusForToggle: String {
        get {
            guard let value = UserDefaults.standard.value(forKey: UserDefaultkeys.onlineStatus) as? String else {
                return AgentStatus.offline.rawValue
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.onlineStatus)
        }
    }
    
    var isFilterApplied: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: UserDefaultkeys.filterApplied) as? Bool else {
                return false
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.filterApplied)
        }
    }
    
    var eFormEnabled : Bool?
    
    func updateData(loginData: [String: Any]) {
        let userDetailData = loginData
        
       isVideoCallEnabled = Bool.parse(key: "is_video_call_enabled", json: userDetailData)
       isAudioCallEnabled = Bool.parse(key: "is_audio_call_enabled", json: userDetailData, defaultValue: false)
       encodeToHTMLEntities = Bool.parse(key: "encode_to_html_entites", json: userDetailData)
       botImageUrl = String.parse(values: userDetailData, key: "bot_image_url")

       unsupportedMessageString = userDetailData["unsupported_message"] as? String ?? ""
       maxUploadLimitForBusiness = userDetailData["max_file_size"] as? UInt ?? 10
        
        hideCallIconOnNavigationForCustomer = Bool.parse(key: "hide_direct_call_button", json: userDetailData)
        multiChannelLabelMapping = Bool.parse(key: "multi_channel_label_mapping", json: userDetailData) ?? false
        buisnessLanguageArr = BuisnessLanguage().getLanguageData(loginData["business_languages"] as? [[String : Any]] ?? [[String : Any]]())
    }
}

struct BuisnessCurrency{
    var currency : String?
    var currencySymbol : String?
    
    init() {
        
    }
    
    func getBuisnessCurrency(_ dic : [String : Any]) -> BuisnessCurrency{
        var this = BuisnessCurrency()
        this.currency = dic["currency"] as? String
        this.currencySymbol = dic["currency_symbol"] as? String
        return this
    }
    
    func getCurrenyData(_ arrCurrency : [[String : Any]]) -> [BuisnessCurrency]{
        var buisnessCurrency = [BuisnessCurrency]()
        for data in arrCurrency{
            buisnessCurrency.append(BuisnessCurrency().getBuisnessCurrency(data))
        }
        return buisnessCurrency
    }
    
}

struct BuisnessLanguage : Decodable{
    
    var business_id : Int?
    var is_default : Bool?
    var lang_code : String?
    var lang_id : Int?
    
    func getBuisnessLanguage(_ dic : [String : Any]) -> BuisnessLanguage{
        var this = BuisnessLanguage()
        this.business_id = dic["business_id"] as? Int
        this.is_default = dic["is_default"] as? Bool
        this.lang_code = dic["lang_code"] as? String
        this.lang_id = dic["lang_id"] as? Int
        return this
    }
    
    func getLanguageData(_ arrLanguage : [[String : Any]]) -> [BuisnessLanguage]{
        var buisnessLanguage = [BuisnessLanguage]()
        for data in arrLanguage{
            buisnessLanguage.append(BuisnessLanguage().getBuisnessLanguage(data))
        }
        return buisnessLanguage
    }
}
