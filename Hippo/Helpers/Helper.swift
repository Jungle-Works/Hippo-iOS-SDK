//
//  Helper.swift
//  Hippo
//
//  Created by Vishal on 06/03/19.
//

import UIKit

let kFontFirstStr = "<a color='#627de3' contenteditable='false' data-id='197'>"
let kFontLastStr = "</a>"

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
//    let isAboveMessageIsFromSameUser: Bool = (chatMessageObject.aboveMessageUserId == chatMessageObject.senderId && chatMessageObject.type != .consent && chatMessageObject.aboveMessageType != .consent) && chatMessageObject.aboveMessageType != .assignAgent
    let isAboveMessageIsFromSameUser: Bool = (chatMessageObject.aboveMessageUserId == chatMessageObject.senderId && chatMessageObject.type != .consent && chatMessageObject.aboveMessageType != .consent) && chatMessageObject.aboveMessageType != .assignAgent && chatMessageObject.belowMessageType != .card
    let messageString = chatMessageObject.message
//    let userNameString = isAboveMessageIsFromSameUser ? "" : chatMessageObject.senderFullName
//    let middleString = isAboveMessageIsFromSameUser ? "" : "\n"

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


//    return attributedStringForLabel(userNameString, secondString: middleString + messageString, thirdString: "", colorOfFirstString: nameColor, colorOfSecondString: messageColor, colorOfThirdString: timeColor, fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString: HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.systemFont(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
        return attributedStringForLabel("", secondString: messageString, thirdString: "", colorOfFirstString: nameColor, colorOfSecondString: messageColor, colorOfThirdString: timeColor, fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString:  HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.regular(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
    }
}
class CustomLoader{
    
     static let shared = CustomLoader()
    lazy var loader = UIImageView()
    //lazy var loaderView = UIView()
    private var backgroundView = UIView()
    
    
    func showLoader(message: String = "Please wait" , _ viewController : UIViewController) {
        if let viewController = viewController as? UIViewController{
            if viewController.view.subviews.contains(loader)
            {
                self.hideGifLoader(viewController)
            }
        }
        backgroundView.frame = viewController.view.frame
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.4
        
        loader.isHidden = false
        //loaderView.isHidden = false
        backgroundView.isHidden = false
        
        //loaderView.frame = (CGRect(x: self.backgroundView.frame.size.width/2 - 40 , y: self.backgroundView.frame.size.height/2 - 40 , width: 80, height: 80))
        //loaderView.backgroundColor = UIColor.black
        //loaderView.layer.cornerRadius = 10
        //loader.center = loaderView.center
        loader = UIImageView(frame: CGRect(x: self.backgroundView.frame.size.width/2 - 40 , y: self.backgroundView.frame.size.height/2 - 40 , width: 80, height: 80))
        loader.image = UIImage.gifImageWithName("loader")
        loader.isHidden = false
        //loaderView.addSubview(loader)
       
        
        if let viewController = viewController as? UIViewController{
            viewController.view.addSubview(backgroundView)
            viewController.view.addSubview(loader)
        }
        
    }
    
    func hideGifLoader(_ viewController : UIViewController) {
        backgroundView.isHidden = true
        loader.isHidden = true
        //loaderView.isHidden = true
        backgroundView.removeFromSuperview()
        loader.removeFromSuperview()
       // loaderView.removeFromSuperview()
    }
    
}
