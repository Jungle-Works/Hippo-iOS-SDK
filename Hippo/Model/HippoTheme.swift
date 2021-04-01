//
//  HippoTheme.swift
//  Hippo
//
//  Created by Vishal on 20/11/18.
//

import UIKit

public struct HippoLabelTheme {
    public let textColor: UIColor
    public let textFont: UIFont?
    
    public init(textColor: UIColor, textFont: UIFont?) {
        self.textFont = textFont
        self.textColor = textColor
    }
    
}

public struct ConversationListTheme {
    public var titleTheme: HippoLabelTheme
    public var lastMessageTheme: HippoLabelTheme
    public var timeTheme: HippoLabelTheme
    
    static func normalTheme() -> ConversationListTheme {
        let titleTheme: HippoLabelTheme = HippoLabelTheme(textColor: .black, textFont: UIFont.bold(ofSize: 15))
        let lastMessageTheme: HippoLabelTheme = HippoLabelTheme(textColor: UIColor(red: 152/255 , green: 173/255, blue: 176/255, alpha: 1.0), textFont: UIFont.regular(ofSize: 14.0))
        let timeTheme: HippoLabelTheme = HippoLabelTheme(textColor: UIColor(red: 152/255 , green: 173/255, blue: 176/255, alpha: 1.0), textFont: UIFont.regular(ofSize: 12.0))
        return ConversationListTheme(titleTheme: titleTheme, lastMessageTheme: lastMessageTheme, timeTheme: timeTheme)
    }
    
    static func unReadTheme() -> ConversationListTheme {
        let titleTheme: HippoLabelTheme = HippoLabelTheme(textColor: .black, textFont: UIFont.bold(ofSize: 15.0))
        let lastMessageTheme: HippoLabelTheme = HippoLabelTheme(textColor: UIColor(red: 74/255 , green: 74/255, blue: 74/255, alpha: 1.0), textFont: UIFont.regular(ofSize: 14.0))
        let timeTheme: HippoLabelTheme = HippoLabelTheme(textColor: UIColor(red: 74/255 , green: 74/255, blue: 74/255, alpha: 1.0), textFont: UIFont.regular(ofSize: 12.0))
        
        return ConversationListTheme(titleTheme: titleTheme, lastMessageTheme: lastMessageTheme, timeTheme: timeTheme)
    }
}

@objc public class HippoTheme: NSObject {
    
    public class func defaultTheme(fontRegular : String = "", fontBold : String = "") -> HippoTheme {
         HippoFont.boldFont = fontBold
         HippoFont.regularFont = fontRegular
        return HippoTheme()
    }
    
    var chatBoxCornerRadius: CGFloat = 5
    var shouldEnableDisplayUserImage: Bool = true
    open var gradientTopColor =  #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)//UIColor(red: 109/255, green: 212/255, blue: 0/255, alpha: 1)//UIColor(red: 77/255, green: 124/255, blue: 254/255, alpha: 1)//
    open var gradientBottomColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)//UIColor(red: 57/255, green: 58/255, blue: 238/255, alpha: 1)
    open var gradientBackgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)//UIColor(red: 77/255, green: 124/255, blue: 254/200, alpha: 0.05)

    open var unreadMessageColor = UIColor(red: 82/255 , green: 82/255, blue: 82/255, alpha: 1.0)
    open var backgroundColor = UIColor.white //#colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 1, alpha: 1)
    open var infoIconTintColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    open var headerBackgroundColor = UIColor.white
    open var headerTextColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)//UIColor.black
  
    
    open var unreadCountColor : UIColor = UIColor(red: 244/255, green: 64/255, blue: 67/255, alpha: 1.0)//UIColor(red: 91/255, green: 159/255, blue: 13/255, alpha: 1.0)
    open var themeColor: UIColor = UIColor(red: 91/255, green: 159/255, blue: 13/255, alpha: 1.0)//.white//UIColor(red: 109/255, green: 212/255, blue: 0/255, alpha: 1)//
    
    open var themeTextcolor: UIColor = .black//.white//UIColor(red: 109/255, green: 212/255, blue: 0/255, alpha: 1)//
    
    open var starRatingColor: UIColor = UIColor.yellow
    
    open var darkThemeTextColor = UIColor.white
    open var lightThemeTextColor = UIColor.black
    
    open var conversationListNormalTheme: ConversationListTheme = ConversationListTheme.normalTheme()
    open var conversationListUnreadTheme: ConversationListTheme = ConversationListTheme.unReadTheme()
    open var informationIcon: UIImage? = UIImage(named: "dots", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var audioCallIcon: UIImage? = UIImage(named: "call", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var videoCallIcon: UIImage? = UIImage(named: "video", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

    open var noChatImage : UIImage? = UIImage(named: "noChats", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var noPrescription : UIImage? = UIImage(named: "emptyprescription", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var paymentIcon: UIImage? = UIImage(named: "makePayment", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var AddFileIcon: UIImage? = UIImage(named: "AddFile", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var editIcon: UIImage? = UIImage(named: "edit", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var eyeIcon: UIImage? = UIImage(named: "eye", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//    open var paymentIcon: UIImage? = UIImage(named: "makePayment", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var botIcon: UIImage? = UIImage(named: "bot", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
//    open var botIcon: UIImage? = UIImage(named: "bot", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var alphabetSymbolIcon: UIImage? = UIImage(named: "alphabet_symbol_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
//    open var alphabetSymbolIcon: UIImage? = UIImage(named: "alphabet_symbol_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var privateInternalNotesIcon: UIImage? = UIImage(named: "private+message_icon_chat_box", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var deleteIcon: UIImage? = UIImage(named: "delete", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var eFormIcon: UIImage? = UIImage(named: "eform", in: FuguFlowManager.bundle, compatibleWith: nil)
    
    
//    open var privateInternalNotesIcon: UIImage? = UIImage(named: "private+message_icon_chat_box", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    open var missedCallMessageColor: UIColor = UIColor.red
    
//    open var headerTextFont: UIFont? = UIFont.boldregular(ofSize: 18.0)

    
    open var headerTextFont: UIFont? = UIFont.bold(ofSize: 17.0)
    open var actionableMessageHeaderTextFont: UIFont? = UIFont.bold(ofSize: 16.0)
    open var actionableMessagePriceBoldFont: UIFont? = UIFont.bold(ofSize: 15.0)
    open var actionableMessageDescriptionFont: UIFont? = UIFont.bold(ofSize: 13.0)
    open var actionableMessageButtonFont: UIFont? = UIFont.bold(ofSize: 16.0)
    open var leftBarButtonImage: UIImage? = UIImage(named: "whiteBackButton", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var leftBarButtonArrowImage: UIImage? = UIImage(named: "whiteBackButton", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var closeChatImage: UIImage? = UIImage(named: "closeRed", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

    open var leftBarButtonFont: UIFont? = UIFont.regular(ofSize: 13.0)
    open var leftBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var leftBarButtonText = String()
    
    open var forwardIcon: UIImage? = UIImage(named: "forword_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var forwordIconTintColor = UIColor.black
    
    open var homeBarButtonImage: UIImage? = UIImage(named: "home-bubble", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var homeBarButtonFont: UIFont? = UIFont.regular(ofSize: 13.0)
    open var homeBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var homeBarButtonText = String()
    
    open var broadcastBarButtonFont: UIFont? = UIFont.regular(ofSize: 13.0)
    open var broadcastBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var broadcastBarButtonText = String()
    
//    open var filterBarButtonImage: UIImage? = UIImage(named: "filter_button_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var filterSelectedBarButtonImage: UIImage? = UIImage(named: "filter_button_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var filterUnselectedBarButtonImage: UIImage? = UIImage(named: "filter_button_icon_unselected", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var filterBarButtonFont: UIFont? = UIFont.regular(ofSize: 13.0)
    open var filterBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var filterBarButtonText = String()
    
    open var crossBarButtonImage: UIImage? = UIImage(named: "cancel_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var crossBarButtonFont: UIFont? = UIFont.regular(ofSize: 13.0)
    open var crossBarButtonTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    open var crossBarButtonText = String()
    
    open var conversationTitleColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var conversationLastMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var sendBtnIcon: UIImage? = UIImage(named: "send", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    
    open var sendBtnIconTintColor: UIColor?
    
    open var messageTextViewTintColor = UIColor(red: 11/255, green: 106/255, blue: 255/255, alpha: 1)
    
    open var addButtonIcon: UIImage? = UIImage(named: "add", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

//    open var moreOptionsButtonIcon: UIImage? = UIImage(named: "moreOptions", in: FuguFlowManager.bundle, compatibleWith: nil)
        open var moreOptionsButtonIcon: UIImage? = UIImage(named: "moreOptions", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var moreOptionsBtnTintColor: UIColor?
    open var moreOptionsIconsTintColor = UIColor.black
    open var moreOptionsTitlesTintColor = UIColor.black
    open var addBtnTintColor: UIColor?
    
    open var actionButtonIcon: UIImage? = UIImage(named: "optionIcons", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var actionButtonIconTintColor: UIColor?
    
    open var readTintColor = UIColor(red: 0/255, green: 221/255, blue: 182/255, alpha: 1)//UIColor(red: 109/255, green: 212/255, blue: 0/255, alpha: 1)//
    open var unreadTintColor = UIColor.gray
    
    open var readMessageTick: UIImage? = UIImage(named: "readMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)//UIImage(named: "readMsgTick", in: FuguFlowManager.bundle, compatibleWith: nil)//
    open var readMessageTintColor: UIColor? //= UIColor(red: 0/255, green: 221/255, blue: 182/255, alpha: 1)//UIColor(red: 109/255, green: 212/255, blue: 0/255, alpha: 1)//
    
    open var unreadMessageTick: UIImage? = UIImage(named: "unreadMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)//UIImage(named: "unreadMsgTick", in: FuguFlowManager.bundle, compatibleWith: nil)//
    open var unreadMessageTintColor: UIColor? //= UIColor.gray
    
    open var unsentMessageIcon: UIImage? = UIImage(named: "unsent_watch_icon", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var unsentMessageTintColor: UIColor?
    
    open var dateTimeTextColor = UIColor.black40
    open var dateTimeFontSize: UIFont? = UIFont.regular(ofSize: 11.0)
    open var applePlaceHolderColor = UIColor(red: 0/255, green: 0/255, blue: 0.0980392/255, alpha: 0.22)
    open var senderNameColor = UIColor.black40//UIColor.black
    open var senderNameFont: UIFont = UIFont.regular(ofSize: 16.0)
    open var itmDescriptionNameFont: UIFont? = UIFont.regular(ofSize: 14.0)
    open var incomingMsgColor = UIColor.black//UIColor.white//
    open var incomingMsgFont: UIFont = UIFont.regular(ofSize: 16.0)
    open var incomingChatBoxColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
    open var incomingMsgDateTextColor = UIColor.black40//UIColor.white//
    
    open var searchBarBackgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
    
    open var missedCallColor = UIColor(red: 237/255, green: 73/255, blue: 124/255, alpha: 1)
    open var callAgainColor = UIColor(red: 59/255, green: 213/255, blue: 178/255, alpha: 1)
    
    open var privateNoteMsgColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    open var privateNoteMsgFont: UIFont? = UIFont.regular(ofSize: 15.0)
    open var privateNoteChatBoxColor = UIColor(red: 255/255, green: 255/255, blue: 217/255, alpha: 1)
    open var privateNoteMsgDateTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5568627451, alpha: 1)
    
    open var processingGreenColor = UIColor(red: 108/255, green: 198/255, blue: 77/255, alpha: 1)
    
    open var actionableMessageButtonColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
    open var actionableMessageButtonHighlightedColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 0.8)
    
    open var outgoingMsgColor = UIColor.black
    open var outgoingChatBoxColor = UIColor(red: 242/255, green: 245/255, blue: 248/255, alpha: 1)//UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
    open var outgoingMsgDateTextColor = UIColor.black40
    
    open var botTextAndBorderColor = UIColor.black
    
    open var chatBoxBorderWidth = CGFloat(0.5)
    open var chatBoxBorderColor = #colorLiteral(red: 0.862745098, green: 0.8784313725, blue: 0.9019607843, alpha: 1)
    var promotionBackgroundColor = UIColor(red: 244/255, green: 245/255, blue: 246/255, alpha: 1)
    open var multiselectUnselectedButtonColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
    open var multiselectSelectedButtonColor = UIColor(red: 232/255, green: 236/255, blue: 252/255, alpha:1)
    
    open var inOutChatTextFont: UIFont = UIFont.regular(ofSize: 16.0)
    
    open var timeTextColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var typingTextFont: UIFont? = UIFont(name:  HippoFont.regularFont, size: 15.0) ?? UIFont.regular(ofSize: 15.0)
    open var typingTextColor = #colorLiteral(red: 0.1725490196, green: 0.137254902, blue: 0.2, alpha: 1)
    
    open var newConversationButtonFont: UIFont? = UIFont(name:  HippoFont.boldFont, size: 18.0)

    open var chatbackgroundImage: UIImage?
    
    open var titleFont: UIFont = UIFont.bold(ofSize: 18.0)//UIFont(name:  HippoFont.boldFont, size: 17.0) ?? UIFont.boldregular(ofSize: 17.0)
    open var promotionTitle : UIFont = UIFont.bold(ofSize: 15.0)
    
    open var titleTextColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    open var descriptionFont: UIFont = UIFont.regular(ofSize: 14.0)
    open var descriptionTextColor = UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1.0)//#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).withAlphaComponent(0.6)
    open var pricingFont: UIFont = UIFont.regular(ofSize: 14.0)//UIFont(name:  HippoFont.boldFont, size: 17) ?? UIFont.boldregular(ofSize: 17)
    open var pricingTextColor: UIColor? = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    open var multiSelectButtonFont: UIFont = UIFont.regular(ofSize: 15.0)
    open var multiSelectTextColor: UIColor? = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    //MARK: Theme for broadCast
    open var broadcastTitleFont: UIFont? = UIFont.regular(ofSize: 15.0)
    open var broadcastTitleColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    open var broadcastTitleInfoFont: UIFont? = UIFont.regular(ofSize: 10.0)
    open var broadcastTitleInfoColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    

    open var checkBoxActive = UIImage(named: "checkbox_active_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var checkBoxActiveTintColor = UIColor.black
//    open var checkBoxInActive = UIImage(named: "checkbox_inactive_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var checkBoxInActive = UIImage(named: "checkbox_inactive_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var checkBoxInActiveTintColor = UIColor.white
    
    open var titleColorOfFilterResetButton = UIColor.white
    open var backgroundColorOfFilterResetButton = UIColor.black
    
    open var titleColorOfFilterApplyButton = UIColor.white
    open var backgroundColorOfFilterApplyButton = UIColor.black
    
    open var radioActive = UIImage(named: "radio_button_active", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var radioInActive = UIImage(named: "radio_button_deactive", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    
    open var infoIcon: UIImage?
    
    /// MARK: Theme For Support
    
    open var supportTheme = SupportTheme()
    
    
    //MARK: Icons
    open var placeHolderImage = UIImage(named: "placeholderImg", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var userPlaceHolderImage = UIImage(named: "user_placeholder_icon", in: FuguFlowManager.bundle, compatibleWith: nil)
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
    open var chatReOpenIconWithTemplateMode = UIImage(named: "reopen_conversation_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var chatCloseIcon = UIImage(named: "cancel_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    open var chatAssignIcon = UIImage(named: "assigned_conversation_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    
    
    open var radioImageActive: UIImage? = UIImage(named: "radio_button_active", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
     open var radioImageInActive: UIImage? = UIImage(named: "radio_button_deactive", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    open var openChatIcon =  UIImage(named: "newChat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var cancelIcon =  UIImage(named: "cancel_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    open var availableStatusIcon =  UIImage(named: "available_status_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var awayStatusIcon =  UIImage(named: "away_status_icon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    //Private icons
    var facebookSourceIcon = UIImage(named: "facebookIcon", in: FuguFlowManager.bundle, compatibleWith: nil)
    var emailSourceIcon = UIImage(named: "emailIntegrationIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var smsSourceIcon = UIImage(named: "smsIntegrationIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
     var whatsappIcon = UIImage(named: "whatsapp", in: FuguFlowManager.bundle, compatibleWith: nil)
    
    
    open var sourceIconColor: UIColor = UIColor(red: 34/255, green: 150/255, blue: 255/255, alpha: 1)
    
    //
    
    open var ratingFullStar = UIImage(named: "starWithShadow", in: FuguFlowManager.bundle, compatibleWith: nil)
    open var ratingEmptyStar = UIImage(named: "emptyStar", in: FuguFlowManager.bundle, compatibleWith: nil)
    
    open var ratingLabelFont: UIFont? = UIFont(name: "HelveticaNeue-Bold", size: 15)
    open var ratingLabelTextFontColor: UIColor = .black
    
    open var profileNameFont: UIFont? = UIFont(name: "HelveticaNeue-Bold", size: 18)
    open var profileNameTextColor: UIColor = .black
    
    open var profileFieldTitleFont: UIFont? =  UIFont(name: "HelveticaNeue-Medium", size: 18)
    open var profileFieldTitleColor: UIColor = .black
    
    open var profileFieldValueFont: UIFont? =  UIFont(name: "HelveticaNeue-Medium", size: 16)
    open var prfoileFieldValueColor: UIColor? = .lightText
    
    open var profileBackgroundColor: UIColor? = UIColor.veryLightBlue
    
    open var logoutButtonIcon: UIImage?
    open var logoutButtonTintColor: UIColor?
//    open var logoutButtonTintColor: UIColor = .black
    
    open var notificationButtonIcon: UIImage?
    open var notificationButtonTintColor: UIColor?
    
    open var securePaymentIcon: UIImage? = UIImage(named: "securePayment", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    open var securePaymentTintColor: UIColor?
    open var secureTextFont: UIFont = UIFont.regular(ofSize: 10)
    open var shouldShowBtnOnChatList : Bool = true
    
    //MARK:- Open Strings Parent app can set
    
    open var headerText = "My Recent Consultations"
    open var directChatHeader = "Conversation List"
    open var broadcastHeader = "Broadcast Message"
    open var broadcastHistoryHeader = "Broadcast Message history"
    open var promotionsAnnouncementsHeaderText = "Announcements"
    open var takeOverButtonText : String?
    open var myChatBtnText : String?
    open var allChatBtnText : String?
    open var messagePlaceHolderText : String?
    open var noOpenAndcloseChatError : String?
    open var noChatUnderCatagoryError : String?
    open var chatListRetryBtnText : String?
}


extension UIFont {
    open class func regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name:  HippoFont.regularFont , size: size) ?? UIFont.systemFont(ofSize: size)
    }
    open class func bold(ofSize size: CGFloat) -> UIFont{
        return UIFont(name:  HippoFont.boldFont , size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}
