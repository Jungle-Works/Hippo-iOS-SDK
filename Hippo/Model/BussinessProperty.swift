//
//  BussinessProperty.swift
//  Hippo
//
//  Created by Vishal on 01/08/19.
//

import Foundation


class BussinessProperty: NSObject {
    static let current = BussinessProperty()
    var currencyArr : [BuisnessCurrency]?
    
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
                return "This message doesn't support in your current app."
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
