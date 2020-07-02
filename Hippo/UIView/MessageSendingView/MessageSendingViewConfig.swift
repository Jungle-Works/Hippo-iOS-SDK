//
//  MessageSendingViewConfig.swift
//  HippoAgent
//
//  Created by Vishal on 06/06/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation
//import SZMentionsSwift

struct MentionAttribute: AttributeContainer {
    var name: NSAttributedString.Key
    var value: Any
}


struct MessageSendingViewConfig {
    var isMentionEnabled: Bool = true
    var isReplyEnabled: Bool = true
    var shouldShowBottomBar: Bool = true
    var mode: MessageTextViewMode = .newMessage
    var bottomBarHeight: CGFloat = 50
    var editMessage: HippoMessage?
    var indexPath: IndexPath?
    var chatType: ChatType?
   
    var hideMessageBox: Bool = false
    
    var allowedMentionForPrivate: [String] = ["@"]
    
    var normalMessagePlaceHolder: String = HippoStrings.messagePlaceHolderText
    var privateMessagePlaceHolder: String = HippoStrings.privateMessagePlaceHolder
    
    var normalMessagePlaceHolderWithoutCannedMessage: String = HippoStrings.messagePlaceHolderText
    
    var isActionButtonEnabled: Bool = false
    var actionButtonMessage: String = HippoStrings.takeOver
    var actionButtonHeightConstant: CGFloat = 50
    var actionButtonTopBottomPadding: CGFloat = 5
    
    
    var mentionAttributes: [MentionAttribute] = [
        MentionAttribute(
            name: .foregroundColor,
            value: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)//UIColor.themeColor
        ),
        MentionAttribute(
            name: .font,
            value: UIFont.regular(ofSize: 14)//UIFont.regularMontserrat(withSize: 14)
        ),
        MentionAttribute(
            name: .backgroundColor,
            value: UIColor.clear
        ),
    ]
    var defaultAttributes: [MentionAttribute] = [
        MentionAttribute(
            name: .foregroundColor,
            value: UIColor.black
        ),
        MentionAttribute(
            name: .font,
            value: UIFont.regular(ofSize: 14)//UIFont.regularMontserrat(withSize: 14)
        ),
        MentionAttribute(
            name: .backgroundColor,
            value: UIColor.clear
        ),
    ]
    
    
    enum MessageTextViewMode {
        case newMessage
        case editMessage
    }

    func showBottomBar() -> Bool {
        return shouldShowBottomBar && mode == .newMessage
    }
    
    func getActionButtonHeight() -> CGFloat {
        let height: CGFloat = actionButtonHeightConstant + (2 * actionButtonTopBottomPadding)
        return isActionButtonEnabled ? height : 0
    }
    
    func shouldHideBottonButtons() -> Bool {
        switch chatType {
        case .o2o?:
            return true
        default:
            return  false
        }
    }
    
    func createDefaultAttributeds(for privateMessage: Bool) -> [MentionAttribute] {
        var defaultAttributes: [MentionAttribute] = [
            MentionAttribute(
                name: .font,
                value: UIFont.regular(ofSize: 14)//UIFont.regularMontserrat(withSize: 14)
            ),
            MentionAttribute(
                name: .backgroundColor,
                value: UIColor.clear
            ),
        ]
        let color = UIColor.black//privateMessage ? HippoTheme.theme.chatBox.privateMessageTheme.placeholderColor : HippoTheme.theme.chatBox.outgoingMessageTheme.text
        let foregroundColor = MentionAttribute(name: .foregroundColor, value: color)
        
        defaultAttributes.append(foregroundColor)
        
        return defaultAttributes
    }
}
