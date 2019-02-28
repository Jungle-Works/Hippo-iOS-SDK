//
//  FuguTheme.swift
//  Fugu
//
//  Created by Gagandeep Arora on 28/08/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

@objc public class HippoTheme: NSObject {
    public class func defaultTheme() -> HippoTheme { return HippoTheme() }
    
    open var backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)
    
    open var headerBackgroundColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    open var unReadMessageCounterColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    open var headerTextColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
    open var headerText = "Support"
   
    open var headerTextFont: UIFont? = UIFont.boldSystemFont(ofSize: 18.0)
    open var actionableMessageHeaderTextFont: UIFont? = UIFont.boldSystemFont(ofSize: 16.0)
    open var actionableMessagePriceBoldFont: UIFont? = UIFont.boldSystemFont(ofSize: 15.0)
    open var actionableMessageDescriptionFont: UIFont? = UIFont.boldSystemFont(ofSize: 13.0)
    open var actionableMessageButtonFont: UIFont? = UIFont.boldSystemFont(ofSize: 16.0)
    
    open var conversationTypeTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 14.0)
    open var leftBarButtonImage: UIImage? = UIImage(named: "whiteBackButton", in: HippoFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var leftBarButtonFont: UIFont? = UIFont.systemFont(ofSize: 13.0)
    open var leftBarButtonText = String()
    
    open var conversationTitleColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var conversationLastMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var sendBtnIcon: UIImage? = UIImage(named: "sendMessageIcon", in: HippoFlowManager.bundle, compatibleWith: nil)
    open var sendBtnIconTintColor: UIColor?
    
    open var addButtonIcon: UIImage? = UIImage(named: "addButtonIcon", in: HippoFlowManager.bundle, compatibleWith: nil)
    open var addBtnTintColor: UIColor?
    
    open var readMessageTick: UIImage? = UIImage(named: "readMsgTick", in: HippoFlowManager.bundle, compatibleWith: nil)
    open var readMessageTintColor: UIColor?
    
    open var unreadMessageTick: UIImage? = UIImage(named: "unreadMsgTick", in: HippoFlowManager.bundle, compatibleWith: nil)
    open var unreadMessageTintColor: UIColor?
    
    open var unsentMessageIcon: UIImage? = UIImage(named: "unsent_watch_icon", in: HippoFlowManager.bundle, compatibleWith: nil)
    open var unsentMessageTintColor: UIColor?
    
    open var dateTimeTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1)
    open var dateTimeFontSize: UIFont? = UIFont.systemFont(ofSize: 12.0)
    
    open var senderNameColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1)
    open var senderNameFont: UIFont? = UIFont.systemFont(ofSize: 12.0)
    open var itmDescriptionNameFont: UIFont? = UIFont.systemFont(ofSize: 14.0)
    open var incomingMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var incomingMsgFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    open var incomingChatBoxColor = #colorLiteral(red: 0.9098039216, green: 0.9176470588, blue: 0.9882352941, alpha: 1)
    open var incomingMsgDateTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1)
    
    open var actionableMessageButtonColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
    open var actionableMessageButtonHighlightedColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 0.8)
    
    open var outgoingMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var outgoingChatBoxColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var outgoingMsgDateTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1)
    
    open var chatBoxBorderWidth = CGFloat(0.5)
    open var chatBoxBorderColor = #colorLiteral(red: 0.862745098, green: 0.8784313725, blue: 0.9019607843, alpha: 1)
    
    open var inOutChatTextFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    
    open var timeTextColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var typingTextFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    open var typingTextColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var searchBarFont: UIFont? = UIFont.systemFont(ofSize: 15.0)//UIFont.init(name: FONT_MONTSERRAT_REGULAR, size: 12.0)
    open var buttonBarBackgroundColor: UIColor = .white
    open var buttonBarMinimumInteritemSpacing: CGFloat = 0
    open var selectedBarBackgroundColor: UIColor = .white
    open var selectedBarHeight:CGFloat = CGFloat(3.0)
    open var buttonBarItemBackgroundColor: UIColor = .white
    open var buttonBarSelectedItemFont: UIFont = UIFont.boldSystemFont(ofSize: 14.0)
    open var buttonBarSelectedTitleColor: UIColor = .black
    open var buttonBarItemTitleColor: UIColor = .black
    open var buttonBarItemFont: UIFont = UIFont.systemFont(ofSize: 14.0)
    open var buttonBarItemLeftRightMargin: CGFloat = 7.5
    open var buttonBarColor: UIColor = UIColor.init(red: 253/255, green: 121/255, blue: 69/255, alpha: 1.0)
    
    open var sendMoneyButtonColor: UIColor = UIColor.init(red: 255/255, green: 118/255, blue: 80/255, alpha: 1.0)
    open var sendMoneyButtonFont: UIFont? = UIFont.systemFont(ofSize: 14.0)
    open var jugnooAccessToken = ""
    open var checkPaymentStatusBaseURL = ""
    open var EmptyViewLabelTextColor: UIColor = UIColor.init(red: 96/255, green: 93/255, blue: 105/255, alpha: 1.0)
    open var EmptyViewLabelTextFont: UIFont = UIFont.boldSystemFont(ofSize: 20.0)
    
    
    /// MARK: Theme For Support
    
    open var supportTheme = SupportTheme()
}


public struct SupportTheme {
    var supportListHeadingFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    var supportListHeadingColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    
    var supportDescSubHeadingFont: UIFont? = UIFont.boldSystemFont(ofSize: 17)
    var supportDescSubHeadingColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    var supportDescriptionFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    var supportDescriptionColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    var supportButtonTitleFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    var supportButtonTitleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    var supportButtonThemeColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    
    public init() {
        
    }
}

