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
    private(set) var newConversationButtonTags: [String] = []
    private(set) var enableNewConversationButton: Bool = false
    private(set) var newconversationBotGroupId: String? = nil

    private(set) var openLabelIdOnHome: Int?

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
    
    func shouldSendBotGroupId() -> Bool {
        return botGroupId > 0
    }
    
    class func setNewConversationButtonTags(tags: [String]) {
        current.newConversationButtonTags = tags
    }
    class func setNewConversationButton(enable: Bool) {
        current.enableNewConversationButton = enable
    }
    
    class func setNewConversationBotGroupId(botGroupId: String?) {
        current.newconversationBotGroupId = botGroupId
    }
    class func setOpenLabelIdOnHome(label: Int?) {
        current.openLabelIdOnHome = label
    }
}



