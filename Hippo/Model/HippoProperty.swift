//
//  HippoProperty.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import Foundation

class HippoProperty: NSObject {
    static var current = HippoProperty()
    
    //Inital Form collector info
    var forms: [FormData] = []
    var formCollectorTitle: String = ""
    var botGroupId: Int = -1
    var singleChatApp: Bool = false
    var paymentPlanType : [Int] = [PaymentPlanType.agentPlan.rawValue]
    private(set) var newConversationButtonTags: [String] = []
    private(set) var enableNewConversationButton: Bool = false
    private(set) var newConverstationButtonTitle: String? = HippoConfig.shared.strings.newConversation
    private(set) var currentBtnText: String? = HippoStrings.ongoing
    private(set) var pastBtnText: String? = HippoStrings.past
    private(set) var pleaseSelectOptionText: String? = "Please select an option"
    private(set) var newconversationBotGroupId: String? = nil

    private(set) var openLabelIdOnHome: Int?
    private(set) var restrictMimeType: Bool = false
    
    var skipBot: Bool?
    var skipBotReason: String?
    
    
    //Properties
    var ticketCustomAttributes: [String: Any]?
    var showMessageSourceIcon: Bool = false
    private(set) var isPaymentRequestEnabled: Bool = false    
    
    func updatePaymentRequestStatus(enable: Bool) {
        isPaymentRequestEnabled = enable
    }
    
    class func setBotGroupID(id: Int) {
        current.botGroupId = id
    }
    
    class func setPaymentPlanType(type : [Int]){
        current.paymentPlanType = type
    }
 
    func shouldSendBotGroupId() -> Bool {
        return botGroupId > 0
    }
    
    class func setNewConversationButtonTags(tags: [String]) {
        current.newConversationButtonTags = tags
    }
    class func setNewConversationButton(enable: Bool) {
        current.enableNewConversationButton = enable
    }
    
    class func setNewConversationButtonTitle(title: String, currentText: String?, pastText: String?, pleaseSelectOption: String?) {
        current.newConverstationButtonTitle = title
        current.currentBtnText = currentText
        current.pastBtnText = pastText
        current.pleaseSelectOptionText = pleaseSelectOption
    }
    
    class func setNewConversationBotGroupId(botGroupId: String?) {
        current.newconversationBotGroupId = botGroupId
    }
    class func setOpenLabelIdOnHome(label: Int?) {
        current.openLabelIdOnHome = label
    }
    
    class func shouldRestrictMimeType(allow: Bool){
        current.restrictMimeType = allow
    }
    
}



