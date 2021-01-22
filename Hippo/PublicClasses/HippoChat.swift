//
//  HippoChat.swift
//  HippoChat
//
//  Created by Vishal on 16/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

public typealias HippoGeneralCompletion = ((_ success: Bool,_ error: Error?) -> Void)

struct TokenManager {
    static var deviceToken: String {
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKeys.normalToken)
        }
        get {
            return UserDefaults.standard.value(forKey: StoreKeys.normalToken) as? String ?? ""
        }
    }
    static var voipToken: String {
           set {
               UserDefaults.standard.set(newValue, forKey: StoreKeys.voipToken)
           }
           get {
               return UserDefaults.standard.value(forKey: StoreKeys.voipToken) as? String ?? ""
           }
       }
}
extension TokenManager {
    struct StoreKeys {
        static let voipToken = "HIPPO_VoIP_TOKEN"
        static let normalToken = "HIPPO_NORMAL_TOKEN"
    }
}

public class HippoChat {
    
    public static var isSingleChatApp: Bool {
        get {
            return HippoProperty.current.singleChatApp
        }
        set {
            HippoProperty.current.singleChatApp = newValue
        }
    }
    
    public static func setUser(_ user: HippoUserDetail) {
        HippoConfig.shared.updateUserDetail(userDetail: user)
    }
    
    public static func set(botGroupID: Int) {
        HippoConfig.setBotGroupID(id: botGroupID)
    }
    
    public static func setCredential(appSecretKey: String, appType: String) {
        HippoConfig.shared.setCredential(withAppSecretKey: appSecretKey, appType: appType)
    }
    
    public static func setNewConversatonButton(enable: Bool) {
        HippoProperty.setNewConversationButton(enable: enable)
    }
    
    public static func setNewConversationButtonTags(tags: [String]) {
        HippoProperty.setNewConversationButtonTags(tags: tags)
    }
    
    public static func shouldRestrictMimeType(allow: Bool) {
        HippoProperty.shouldRestrictMimeType(allow: allow)
    }
    
}

extension HippoChat {
    public static func openGeneralChat(on viewController: UIViewController, detail: GeneralChat, completion: HippoGeneralCompletion?) {
        HippoConfig.shared.openChatByTransactionId(on: viewController, data: detail, completion: completion)
    }
    
    public static func openConversationWithHome(on viewController: UIViewController? = nil, withLabelId labelId: Int?, animation: Bool = true) {
        HippoProperty.setOpenLabelIdOnHome(label: labelId)
        HippoConfig.shared.checker.presentChatsViewController()
    }
}
