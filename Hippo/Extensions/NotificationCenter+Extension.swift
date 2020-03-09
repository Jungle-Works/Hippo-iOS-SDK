//
//  NotificationCenter+Extension.swift
//  SDKDemo1
//
//  Created by Vishal on 20/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let myChatDataUpdated = Notification.Name("HippoMyChatDataUpdated")
    static let allChatDataUpdated = Notification.Name("HippoAllChatDataUpdated")
    static let allAndMyChatDataUpdated = Notification.Name("HippoAllChatAndMyChatDataUpdated")
    static let agentLoginDataUpated = Notification.Name("HipoAgentLoginDataUpdated")
    static let userChannelChanged = Notification.Name("userChannelChanged")
    static let ConversationScreenDisappear = Notification.Name.init("ConversationScreenDisappear")
    static let putUserSuccess = Notification.Name.init("HippoPutUserSuccess")
    static let putUserFailure = Notification.Name.init("HippoPutUserFailure")

}
