//
//  BussinessProperty.swift
//  Hippo
//
//  Created by Vishal on 01/08/19.
//

import Foundation


class BussinessProperty: NSObject {
    static let current = BussinessProperty()
    
    
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
}
