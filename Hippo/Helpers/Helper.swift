//
//  Helper.swift
//  Hippo
//
//  Created by Vishal on 06/03/19.
//

import Foundation


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
        let isAboveMessageIsFromSameUser: Bool = (chatMessageObject.aboveMessageUserId == chatMessageObject.senderId && chatMessageObject.type != .consent && chatMessageObject.aboveMessageType != .consent) && chatMessageObject.aboveMessageType != .assignAgent
        let messageString = chatMessageObject.message
        let userNameString = isAboveMessageIsFromSameUser ? "" : chatMessageObject.senderFullName
        let middleString = isAboveMessageIsFromSameUser ? "" : "\n"
        
        return attributedStringForLabel(userNameString, secondString: middleString + messageString, thirdString: "", colorOfFirstString: HippoConfig.shared.theme.senderNameColor, colorOfSecondString: HippoConfig.shared.theme.incomingMsgColor, colorOfThirdString: UIColor.black.withAlphaComponent(0.5), fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString:  HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.systemFont(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
    }
}
