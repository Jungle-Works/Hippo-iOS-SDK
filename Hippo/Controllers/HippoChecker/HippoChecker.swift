//
//  HippoChecker.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import Foundation


class HippoChecker {
    
    enum HippoCheckerRequest {
        case presentChat
    }
    
    
    var config: HippoConfig {
        return HippoConfig.shared
    }
    
    var request: HippoCheckerRequest?
    
    
    
    func presentChatsViewController() {
        AgentDetail.setAgentStoredData()
        switch config.appUserType {
        case .customer:
            FuguFlowManager.shared.presentCustomerConversations()
        case .agent:
            FuguFlowManager.shared.presentAgentConversations()
        }
    }
    
    
    func shouldCollectDataFromUser() -> Bool {
        let form = HippoProperty.current.forms
        guard !form.isEmpty else {
            return false
        }
        return true
    }
    
}
extension HippoChecker {
    
}
