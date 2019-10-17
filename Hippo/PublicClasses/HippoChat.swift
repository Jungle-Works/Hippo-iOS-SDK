//
//  HippoChat.swift
//  HippoChat
//
//  Created by Vishal on 16/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

public typealias HippoGeneralCompletion = ((_ success: Bool,_ error: Error?) -> Void)

public class HippoChat {
    
    public static func setUser(_ user: HippoUserDetail) {
        HippoConfig.shared.updateUserDetail(userDetail: user)
    }
    
    public static func set(botGroupID: Int) {
        HippoConfig.setBotGroupID(id: botGroupID)
    }
    
    public static func setCredential(appSecretKey: String, appType: String) {
        HippoConfig.shared.setCredential(withAppSecretKey: appSecretKey, appType: appType)
    }
    
}

extension HippoChat {
    public static func openGeneralChat(on viewController: UIViewController, detail: GeneralChat, completion: HippoGeneralCompletion?) {
        HippoConfig.shared.openChatByTransactionId(on: viewController, data: detail, completion: completion)
    }
}
