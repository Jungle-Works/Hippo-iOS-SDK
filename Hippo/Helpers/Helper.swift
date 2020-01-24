//
//  Helper.swift
//  Hippo
//
//  Created by Vishal on 06/03/19.
//

import UIKit

class Helper {
    class func formatNumber(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        
        let str = numberFormatter.string(from: NSNumber.init(floatLiteral: number))
        
        return str ?? "\(number)"
    }
    
    class func getIncomingAttributedStringWithLastUserCheck(chatMessageObject: HippoMessage) -> NSMutableAttributedString {
        let isAboveMessageIsFromSameUser: Bool = (chatMessageObject.aboveMessageUserId == chatMessageObject.senderId && chatMessageObject.type != .consent && chatMessageObject.aboveMessageType != .consent) && chatMessageObject.aboveMessageType != .assignAgent && chatMessageObject.belowMessageType != .card
        let messageString = chatMessageObject.message
       // let userNameString = isAboveMessageIsFromSameUser ? "" : chatMessageObject.senderFullName
       // let middleString = isAboveMessageIsFromSameUser ? "" : "\n"
        
        let isSelfMessage = chatMessageObject.isSelfMessage(for: chatMessageObject.chatType)
        let theme = HippoConfig.shared.theme
        let messageColor: UIColor
        let timeColor: UIColor
        let nameColor: UIColor
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            messageColor = isSelfMessage ? theme.outgoingMsgColor : theme.incomingMsgColor
            timeColor = isSelfMessage ? theme.outgoingMsgDateTextColor : theme.incomingMsgDateTextColor
            nameColor = isSelfMessage ? theme.senderNameColor : theme.senderNameColor
            
        default:
            messageColor = isSelfMessage ? theme.outgoingMsgColor : theme.incomingMsgColor
            timeColor = isSelfMessage ? theme.outgoingMsgDateTextColor : theme.incomingMsgDateTextColor
            nameColor = isSelfMessage ? theme.senderNameColor : theme.senderNameColor
        }
        
        
        return attributedStringForLabel("", secondString: messageString, thirdString: "", colorOfFirstString: nameColor, colorOfSecondString: messageColor, colorOfThirdString: timeColor, fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString:  HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.systemFont(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
    }
}
