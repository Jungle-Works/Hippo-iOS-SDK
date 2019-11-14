//
//  HippoTheme.swift
//  Hippo
//
//  Created by Vishal on 20/11/18.
//

import UIKit

@objc public class HippoTheme: NSObject {
    
    public class func defaultTheme() -> HippoTheme { return HippoTheme() }
    
    var chatBoxCornerRadius: CGFloat = 5
    
    var shouldEnableDisplayUserImage: Bool = true
    
    open var backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)
    open var infoIconTintColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    open var headerBackgroundColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    open var headerTextColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
    open var headerText = "Support"
    open var directChatHeader = "Conversation List"
    open var broadcastHeader = "Broadcast Message"
    open var broadcastHistoryHeader = "Broadcast Message history"
    
    open var audioCallIcon: UIImage? = UIImage(named: "audioCallIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var videoCallIcon: UIImage? = UIImage(named: "tiny-video-symbol", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var missedCallMessageColor: UIColor = UIColor.red
    
    open var headerTextFont: UIFont? = UIFont.boldSystemFont(ofSize: 18.0)
    open var actionableMessageHeaderTextFont: UIFont? = UIFont.boldSystemFont(ofSize: 16.0)
    open var actionableMessagePriceBoldFont: UIFont? = UIFont.boldSystemFont(ofSize: 15.0)
    open var actionableMessageDescriptionFont: UIFont? = UIFont.boldSystemFont(ofSize: 13.0)
    open var actionableMessageButtonFont: UIFont? = UIFont.boldSystemFont(ofSize: 16.0)
    
    open var leftBarButtonImage: UIImage? = UIImage(named: "whiteBackButton", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var leftBarButtonFont: UIFont? = UIFont.systemFont(ofSize: 13.0)
    open var leftBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var leftBarButtonText = String()
    
    open var forwardIcon: UIImage? = UIImage(named: "forword_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var forwordIconTintColor = UIColor.black
    
    open var homeBarButtonImage: UIImage? = UIImage(named: "home-bubble", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var homeBarButtonFont: UIFont? = UIFont.systemFont(ofSize: 13.0)
    open var homeBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var homeBarButtonText = String()
    
    open var broadcastBarButtonImage: UIImage? = UIImage(named: "broadcastIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var broadcastBarButtonFont: UIFont? = UIFont.systemFont(ofSize: 13.0)
    open var broadcastBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var broadcastBarButtonText = String()
    
    open var conversationTitleColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var conversationLastMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var sendBtnIcon: UIImage? = UIImage(named: "sendMessageIcon", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var sendBtnIconTintColor: UIColor?
    
    open var addButtonIcon: UIImage? = UIImage(named: "addButtonIcon", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var addBtnTintColor: UIColor?
    
    open var actionButtonIcon: UIImage? = UIImage(named: "optionIcons", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var actionButtonIconTintColor: UIColor?
    
    
    open var readMessageTick: UIImage? = UIImage(named: "readMsgTick", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var readMessageTintColor: UIColor?
    
    open var unreadMessageTick: UIImage? = UIImage(named: "unreadMsgTick", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var unreadMessageTintColor: UIColor?
    
    open var unsentMessageIcon: UIImage? = UIImage(named: "unsent_watch_icon", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var unsentMessageTintColor: UIColor?
    
    open var dateTimeTextColor = UIColor.black40
    open var dateTimeFontSize: UIFont? = UIFont.systemFont(ofSize: 12.0)
    
    open var senderNameColor = UIColor.black40
    open var senderNameFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    open var itmDescriptionNameFont: UIFont? = UIFont.systemFont(ofSize: 14.0)
    open var incomingMsgColor = UIColor.black
    open var incomingMsgFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    open var incomingChatBoxColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
    open var incomingMsgDateTextColor = UIColor.black40
    
    open var privateNoteMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var privateNoteMsgFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    open var privateNoteChatBoxColor = UIColor(red: 255/255, green: 255/255, blue: 217/255, alpha: 1)
    open var privateNoteMsgDateTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1)
    
    open var processingGreenColor = UIColor(red: 108/255, green: 198/255, blue: 77/255, alpha: 1)
    
    open var actionableMessageButtonColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
    open var actionableMessageButtonHighlightedColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 0.8)
    
    open var outgoingMsgColor = UIColor.black
    open var outgoingChatBoxColor = UIColor(red: 233/255, green: 239/255, blue: 253/255, alpha: 1)
    open var outgoingMsgDateTextColor = UIColor.black40
    
    open var botTextAndBorderColor = UIColor.black
    
    open var chatBoxBorderWidth = CGFloat(0.5)
    open var chatBoxBorderColor = #colorLiteral(red: 0.862745098, green: 0.8784313725, blue: 0.9019607843, alpha: 1)
    
    open var inOutChatTextFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    
    open var timeTextColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var typingTextFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    open var typingTextColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var chatbackgroundImage: UIImage?
    
    open var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 17)
    open var titleTextColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    open var descriptionFont: UIFont = UIFont.systemFont(ofSize: 14.0)
    open var descriptionTextColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).withAlphaComponent(0.6)
    
    open var pricingFont: UIFont = UIFont.boldSystemFont(ofSize: 17)
    open var pricingTextColor: UIColor? = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    //MARK: Theme for broadCast
    open var broadcastTitleFont: UIFont? = UIFont.systemFont(ofSize: 15.0)
    open var broadcastTitleColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    open var broadcastTitleInfoFont: UIFont? = UIFont.systemFont(ofSize: 10.0)
    open var broadcastTitleInfoColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    open var checkBoxActive = UIImage(named: "checkbox_active_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var checkBoxInActive = UIImage(named: "checkbox_inactive_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var radioActive = UIImage(named: "radio_button_active", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var radioInActive = UIImage(named: "radio_button_deactive", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    
    /// MARK: Theme For Support
    
    open var supportTheme = SupportTheme()
    
    
    //MARK: Icons
    open var placeHolderImage = UIImage(named: "placeholderImg", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var csvIcon = UIImage(named: "csv", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var pdfIcon = UIImage(named: "pdf", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var docIcon = UIImage(named: "doc", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var downloadIcon = UIImage(named: "downloadIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var reloadIcon = UIImage(named: "reload", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var txtIcon = UIImage(named: "txt", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var pptIcon = UIImage(named: "ppt", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var defaultDocIcon = UIImage(named: "defaultDoc", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var playIcon = UIImage(named: "playIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var pauseIcon = UIImage(named: "pauseIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var excelIcon = UIImage(named: "excel", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var audioIcon = UIImage(named: "AudioIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var uploadIcon = UIImage(named: "uploadIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var chatReOpenIcon = UIImage(named: "reopen_conversation_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var chatCloseIcon = UIImage(named: "close_conversation_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var chatAssignIcon = UIImage(named: "assigned_conversation_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    
    
    open var radioImageActive: UIImage? = UIImage(named: "radio_button_active", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
     open var radioImageInActive: UIImage? = UIImage(named: "radio_button_deactive", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    open var openChatIcon =  UIImage(named: "newChat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var cancelIcon =  UIImage(named: "cancel_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    //Private icons
    var facebookSourceIcon = UIImage(named: "facebookIcon", in: FuguFlowManager.bundle, compatibleWith: nil)
    var emailSourceIcon = UIImage(named: "emailIntegrationIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var smsSourceIcon = UIImage(named: "smsIntegrationIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    open var sourceIconColor: UIColor = UIColor(red: 34/255, green: 150/255, blue: 255/255, alpha: 1)
}
