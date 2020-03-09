//
//  MessageUIAttributes.swift
//  Fugu
//
//  Created by Vishal on 09/07/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

struct MessageUIAttributes {
    private(set) var senderName: String = ""
    private(set) var isSelfMessage: Bool = false
    
    private(set) var nameHeight: CGFloat = 0
    private(set) var messageHeight: CGFloat = 0
    private(set) var messageWithNameHeight: CGFloat = 0
    private(set) var attributedMessageString = NSMutableAttributedString()
    private(set) var senderNameAttributedString = NSMutableAttributedString()
    private(set) var timeHeight: CGFloat = 30
    
    private(set) var isShowingImage: Bool = false
    
    private(set) var messageWithName = NSMutableAttributedString()
    
    init(message: String, senderName: String, isSelfMessage: Bool, isShowingImage: Bool = false) {
        
        self.isShowingImage = isShowingImage
        self.isSelfMessage = isSelfMessage
        self.senderName = senderName
        
        //        let temp = message.replacingOccurrences(of: "\n", with: "<br>")
        //        var attributedMessageString = temp.stringFromHtml()
        
        var attributedMessageString = NSMutableAttributedString.init(string: message)
        
        attributedMessageString = getAttributedStringWithThemeFont(aString: attributedMessageString)
        
        senderNameAttributedString = getSenderNameInThemeFont(appendWithString: "")
        
        self.timeHeight = heightOfConstraintsInNormalMessageCell()
        self.nameHeight = getHeightForName()
        self.messageHeight = heightOf(attributedString: attributedMessageString)
        self.attributedMessageString = attributedMessageString
       

        senderNameAttributedString = getSenderNameInThemeFont(appendWithString: "")
        messageWithName = senderNameAttributedString
        senderNameAttributedString.append(self.attributedMessageString)
        
        messageWithNameHeight = heightOf(attributedString: senderNameAttributedString)
    }
    func heightOfConstraintsInNormalMessageCell() -> CGFloat {
        return (2 + 2.5 + 3.5 + 12 + 7 + 4)
    }
    
    private func heightOf(attributedString: NSMutableAttributedString) -> CGFloat {
        var availableWidthSpace = windowScreenWidth - CGFloat(60 + 10) - CGFloat(10 + 5)
        availableWidthSpace -= isShowingImage ? 35 : 0
       
        let availableBoxSize = CGSize(width: availableWidthSpace, height: CGFloat.greatestFiniteMagnitude)
        
        let size = attributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size
//        if !attributedString.string.isEmpty {
//          print("==\(availableWidthSpace)-\(size)--\(attributedString)")
//        }
        return size.height
    }
    
    private func getHeightForName() -> CGFloat {
        return heightOf(attributedString: senderNameAttributedString)
    }
    
    private func getSenderNameInThemeFont(appendWithString: String = "") -> NSMutableAttributedString {
        let firstStringStyle = NSMutableParagraphStyle()
        firstStringStyle.alignment = .left
        
        let nameString = NSMutableAttributedString(string: self.senderName + appendWithString)
        
        if isSelfMessage {
            let font = HippoConfig.shared.theme.senderNameFont
            
            nameString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.senderNameColor, range: NSMakeRange(0, nameString.string.length()))
            nameString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, nameString.string.length()))
            nameString.addAttribute(NSAttributedString.Key.paragraphStyle, value: firstStringStyle, range: NSMakeRange(0, nameString.string.length()))
            return nameString
        } else {
            let font = HippoConfig.shared.theme.senderNameFont
            nameString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.senderNameColor, range: NSMakeRange(0, nameString.string.length()))
            nameString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, nameString.string.length()))
            nameString.addAttribute(NSAttributedString.Key.paragraphStyle, value: firstStringStyle, range: NSMakeRange(0, nameString.string.length()))
            return nameString
        }
        
        
    }
    
    private func getAttributedStringWithThemeFont(aString: NSMutableAttributedString) -> NSMutableAttributedString {
        
        let range = NSRange.init(location: 0, length: aString.length)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        if isSelfMessage {
            let font = HippoConfig.shared.theme.inOutChatTextFont
            aString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            //            aString.addAttribute(NSAttributedStringKey.foregroundColor, value: HippoConfig.shared.theme.senderMessageColor, range: range)
            aString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
            return aString
        } else {
            let font = HippoConfig.shared.theme.incomingMsgFont
            aString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.incomingMsgColor, range: range)
            aString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
            return aString
        }
    }
    
}
