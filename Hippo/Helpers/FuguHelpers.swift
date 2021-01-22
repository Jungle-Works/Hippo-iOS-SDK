//
//  Helpers.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import AVFoundation

let FUGU_USER_ID = "fuguUserId"
let Fugu_AppSecret_Key = "fugu_app_secret_key"
let Fugu_en_user_id = "fuguEnUserId"
let Hippo_User_Channel_Id = "userChannelId"
let Fugu_groupCallData = "groupCallData"
let phoneNumberRegex = "1?W*([2-9][0-8][0-9])W*([2-9][0-9]{2})W*([0-9]{4})(se?x?t?(d*))?"

extension UInt {
    func toString() -> String {
        return "\(self)"
    }
    
    static func parse(values: [String :Any], key: String) -> UInt? {
        if let rawKey = values[key] as? Int {
            return UInt(rawKey)
        } else if let rawKey = values[key] as? String, let parsedKey = UInt(rawKey) {
            return parsedKey
        } else if let rawKey = values[key] as? UInt {
            return rawKey
        }
        return nil
    }
}

extension Int {
    static func parse(values: [String :Any], key: String) -> Int? {
        if let rawKey = values[key] as? Int {
            return rawKey
        } else if let rawKey = values[key] as? String, let parsedKey = Int(rawKey) {
            return parsedKey
        }
        return nil
    }
}

extension Bool {
    static func parse(key: String, json: [String: Any], defaultValue: Bool = false) -> Bool {
        if let raw = json[key] as? Int {
            return raw == 1
        } else if let raw = json[key] as? Bool {
            return raw
        } else if let raw = json[key] as? String {
            return raw == "1"
        }
        return defaultValue
    }
    static func parse(key: String, json: [String: Any]) -> Bool? {
        if let raw = json[key] as? Int {
            return raw == 1
        } else if let raw = json[key] as? Bool {
            return raw
        } else if let raw = json[key] as? String {
            return raw == "1"
        }
        return nil
    }
    
    func intValue() -> Int {
        return self ? 1 : 0
    }
}


struct UserDefaultkeys {
    static let agentData = "Hippo_Agent_data_login"
    static let videoCallStatus = "Hippo_is_video_call_enabled"
    static let audioCallStatus = "Hippo_is_audio_call_enabled"
    static let encodeToHtmlEntities = "Hippo_encode_to_html_entities"
    static let maxFileUploadSize = "Max_file_upload_size"
    static let unsupportedMessageString = "unsupported_message"
    static let TicketsKey = "HippoDefaultKey"
    static let currentFAQVersion = "HippoCurrentFAQVersion"
    static let countryInfo = "HippoCountryInfo"
    static let botImageUrl = "HippoBotImageUrl"
    static let hideCallIconOnNavigationForCustomer = "HippoHideCallIconOnNavigationForCustomer"
    static let multiChannelLabelMapping = "Hippo_Multiple_channel_Label_Mapping"
    static let isAskPaymentAllowed = "is_ask_payment_allowed"
    static let onlineStatus = "online_status"
    static let filterApplied = "filterApplied"
    static let hideAllChat = "hideAllChat"
    static let hideO2OChat = "hideO2OChat"
}

var FUGU_SCREEN_WIDTH: CGFloat {
    return UIScreen.main.bounds.width
}
var FUGU_SCREEN_HEIGHT: CGFloat {
    return UIScreen.main.bounds.height
}
var windowScreenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

var windowScreenHeight: CGFloat {
    return UIScreen.main.bounds.height
}
var safeAreaHeight: CGFloat {
    return UIApplication.shared.statusBarFrame.height
}
var isModuleRunning: Bool {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return true
    }
    return bundleIdentifier != "com.socomo.Fugu"
}
var material:[String] = [
    "e57373",
    "f06292",
    "ba68c8",
    "9575cd",
    "7986cb",
    "64b5f6",
    "4fc3f7",
    "4dd0e1",
    "4db6ac",
    "81c784",
    "aed581",
    "ff8a65",
    "d4e157",
    "ffd54f",
    "ffb74d",
    "a1887f",
    "90a4ae"
]

func getColor(char: String) -> Int {
    let val = char.unicodeScalars.first?.value ?? 0
    let index = Int(val) % material.count
    return index
}


func convertDateTimeToUTC(date: Date? = nil) -> String {
    let formatterUTC = DateFormatter()
    formatterUTC.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatterUTC.timeZone = TimeZone(secondsFromGMT: 0)
    
    return formatterUTC.string(from: date ?? Date())
}


func attributedStringForLabel(_ firstString: String, secondString: String, thirdString: String, colorOfFirstString: UIColor, colorOfSecondString: UIColor, colorOfThirdString: UIColor, fontOfFirstString: UIFont?, fontOfSecondString: UIFont?, fontOfThirdString: UIFont, textAlighnment: NSTextAlignment, dateAlignment: NSTextAlignment) -> NSMutableAttributedString {
    
    let combinedString = "\(firstString)\(secondString)\(thirdString)" as NSString
    
    let rangeOfFirstString = combinedString.range(of: firstString)
    let rangeOfSecondString = combinedString.range(of: secondString)
    let rangeOfThirdString = combinedString.range(of: thirdString)
    
    let firstStringStyle = NSMutableParagraphStyle()
    firstStringStyle.alignment = textAlighnment
    
    let thirdStringStyle = NSMutableParagraphStyle()
    thirdStringStyle.alignment = dateAlignment
    
    let attributedTitle = NSMutableAttributedString(string: combinedString as String)
    
    #if swift(>=4.0)
    
    attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: colorOfFirstString, range: rangeOfFirstString)
    if let sendeNameFont = fontOfFirstString {
        attributedTitle.addAttribute(NSAttributedString.Key.font, value: sendeNameFont, range: rangeOfFirstString)
    }
    
    attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: firstStringStyle, range: rangeOfFirstString)
    
    attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: colorOfSecondString, range: rangeOfSecondString)
    
    if let incomingMsgFont = fontOfSecondString {
        attributedTitle.addAttribute(NSAttributedString.Key.font, value: incomingMsgFont, range: rangeOfSecondString)
    }
    
    attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: firstStringStyle, range: rangeOfSecondString)
    
    attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: colorOfThirdString, range: rangeOfThirdString)
    
    attributedTitle.addAttribute(NSAttributedString.Key.font, value: fontOfThirdString, range: rangeOfThirdString)
    attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: thirdStringStyle, range: rangeOfThirdString)
    
    #else
    attributedTitle.addAttribute(NSForegroundColorAttributeName, value: colorOfFirstString, range: rangeOfFirstString)
    if let sendeNameFont = fontOfFirstString {
        attributedTitle.addAttribute(NSFontAttributeName, value: sendeNameFont, range: rangeOfFirstString)
    }
    
    attributedTitle.addAttribute(NSParagraphStyleAttributeName, value: firstStringStyle, range: rangeOfFirstString)
    
    attributedTitle.addAttribute(NSForegroundColorAttributeName, value: colorOfSecondString, range: rangeOfSecondString)
    
    if let incomingMsgFont = fontOfSecondString {
        attributedTitle.addAttribute(NSFontAttributeName, value: incomingMsgFont, range: rangeOfSecondString)
    }
    
    attributedTitle.addAttribute(NSParagraphStyleAttributeName, value: firstStringStyle, range: rangeOfSecondString)
    
    attributedTitle.addAttribute(NSForegroundColorAttributeName, value: colorOfThirdString, range: rangeOfThirdString)
    
    attributedTitle.addAttribute(NSFontAttributeName, value: fontOfThirdString, range: rangeOfThirdString)
    attributedTitle.addAttribute(NSParagraphStyleAttributeName, value: thirdStringStyle, range: rangeOfThirdString)
    
    #endif
    return attributedTitle
}

func attributedStringForLabelForTwoStrings(_ firstString: String, secondString: String, colorOfFirstString: UIColor, colorOfSecondString: UIColor, fontOfFirstString: UIFont, fontOfSecondString: UIFont, textAlighnment: NSTextAlignment, dateAlignment: NSTextAlignment) -> NSMutableAttributedString {
    let combinedString = "\(firstString)\(secondString)" as NSString
    
    let rangeOfFirstString = combinedString.range(of: firstString)
    let rangeOfSecondString = combinedString.range(of: secondString)
    
    let firstStringStyle = NSMutableParagraphStyle()
    firstStringStyle.alignment = textAlighnment
    
    let thirdStringStyle = NSMutableParagraphStyle()
    thirdStringStyle.alignment = dateAlignment
    
    let attributedTitle = NSMutableAttributedString(string: combinedString as String)
    
    
    #if swift(>=4.0)
    
    attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: colorOfFirstString, range: rangeOfFirstString)
    attributedTitle.addAttribute(NSAttributedString.Key.font, value: fontOfFirstString, range: rangeOfFirstString)
    attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: firstStringStyle, range: rangeOfFirstString)
    
    attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: colorOfSecondString, range: rangeOfSecondString)
    attributedTitle.addAttribute(NSAttributedString.Key.font, value: fontOfSecondString, range: rangeOfSecondString)
    attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: firstStringStyle, range: rangeOfSecondString)
    
    #else
    attributedTitle.addAttribute(NSForegroundColorAttributeName, value: colorOfFirstString, range: rangeOfFirstString)
    attributedTitle.addAttribute(NSFontAttributeName, value: fontOfFirstString, range: rangeOfFirstString)
    attributedTitle.addAttribute(NSParagraphStyleAttributeName, value: firstStringStyle, range: rangeOfFirstString)
    
    attributedTitle.addAttribute(NSForegroundColorAttributeName, value: colorOfSecondString, range: rangeOfSecondString)
    attributedTitle.addAttribute(NSFontAttributeName, value: fontOfSecondString, range: rangeOfSecondString)
    attributedTitle.addAttribute(NSParagraphStyleAttributeName, value: firstStringStyle, range: rangeOfSecondString)
    
    #endif
    return attributedTitle
}

func changeDateToParticularFormat(_ dateTobeConverted: Date, dateFormat: String, showInFormat: Bool) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    
    if !showInFormat {
        let comparisonResult = Calendar.current.compare(dateTobeConverted, to: Date(), toGranularity: .day)
        switch comparisonResult {
        case .orderedSame:
            return HippoStrings.today
        default:
            let calendar = NSCalendar.current
            let dateOfMsg = calendar.startOfDay(for: dateTobeConverted)
            let currentDate = calendar.startOfDay(for: Date())
            let dateDifference = calendar.dateComponents([.day], from: dateOfMsg, to: currentDate).day
            if dateDifference == 1 { return HippoStrings.yesterday }
            return formatter.string(from: dateTobeConverted)
        }
    }
    return formatter.string(from: dateTobeConverted)
}

//func connectedToNetwork() -> Bool {
//   return reachability.connection != .none
//}

func fuguDelay(_ withDuration: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + withDuration) {
        completion()
    }
}

func isSubscribed(userChannelId: String) -> Bool {
    return SocketClient.shared.isChannelSubscribed(channel: userChannelId)
}

func unSubscribe(userChannelId: String) {
    SocketClient.shared.unsubscribeSocketChannel(fromChannelId: userChannelId)
}

func subscribeCustomerUserChannel(userChannelId: String) {
    SocketClient.shared.subscribeSocketChannel(channel: userChannelId)
    HippoConfig.shared.userDetail?.listener?.startListening(event: SocketEvent.SERVER_PUSH.rawValue, callback: { (data) in
        if let messageDict = data as? [String : Any]{
           
            if (messageDict["channel"] as? String)?.replacingOccurrences(of: "/", with: "") != userChannelId{
                return
            }
            
            HippoConfig.shared.log.trace("UserChannel:: --->\(messageDict)", level: .socket)
            
            if let messageType = messageDict["message_type"] as? Int, messageType == MessageType.call.rawValue {
                if let channel_id = messageDict["channel_id"] as? Int{ //isSubscribed(userChannelId: "\(channel_id)") == false {
                    
                    let channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channel_id)
                    if versionCode < 350{//call for old version
                        channel.signalReceivedFromPeer?(messageDict)
                    }
                    CallManager.shared.voipNotificationRecieved(payloadDict: messageDict)
                }
            }else if let messageType = messageDict["message_type"] as? Int, messageType == MessageType.groupCall.rawValue{
                CallManager.shared.voipNotificationRecievedForGroupCall(payloadDict: messageDict)
            }
            
            if let notificationType = messageDict["notification_type"] as? Int{
                if notificationType == NotificationType.message.rawValue && messageDict["channel_id"] as? Int != HippoConfig.shared.getCurrentChannelId(){
                    if let channelId = messageDict["channel_id"] as? Int, let otherUserUniqueKey = ((messageDict["user_unique_keys"] as? [String])?.filter{$0 != HippoConfig.shared.userDetail?.userUniqueKey}.first){
                        let transactionId = P2PUnreadData.shared.getTransactionId(with: channelId)
                        if let data = P2PUnreadData.shared.getData(with: transactionId) , data.id == (transactionId + "-" + otherUserUniqueKey) {
                            let unreadCount = (data.count ?? 0) + 1
                            P2PUnreadData.shared.updateChannelId(transactionId: transactionId, channelId: channelId, count: unreadCount,muid: messageDict["muid"] as? String ,otherUserUniqueKey: otherUserUniqueKey)
                        }
                    }
                }
            }
        }
    })
}

func subscribeMarkConversation(){
    var markConversationChannel = ""
    if currentUserType() == .customer{
        markConversationChannel = HippoConfig.shared.appSecretKey + "/" + "markConversation"
    }else{
        markConversationChannel = (HippoConfig.shared.agentDetail?.appSecrectKey ?? "") + "/" + "markConversation"
    }
    
    guard !isSubscribed(userChannelId: markConversationChannel) else {
        return
    }
    
//    SocketClient.shared.subscribedChannel(channelId: markConversationChannel, completion: { (success) in
//    }) {  (messageDict) in
//        print(messageDict)
//        if let notificationType = messageDict["notification_type"] as? Int, notificationType == 12{
//            if let status = messageDict["status"] as? String{
//                if status != "2"{
//                    return
//                }
//            }else if let status = messageDict["status"] as? Int{
//                if status != 2{
//                    return
//                }
//            }
//            for controller in getLastVisibleController()?.navigationController?.viewControllers ?? [UIViewController](){
//                if controller is AllConversationsViewController{
//                    (controller as? AllConversationsViewController)?.closeChat(messageDict["channel_id"] as? Int ?? -1)
//                    return
//                }
//            }
//
//            if currentUserType() == .agent{
//                if let channelId = messageDict["channel_id"] as? Int{
//                   removeChannelForUnreadCount(channelId)
//                }
//            }
//        }
//    }
    
}




func removeChannelForUnreadCount(_ channelId : Int){
    if var channelList = FuguDefaults.object(forKey: DefaultName.agentTotalUnreadHashMap.rawValue) as? [String : Any], let totalUnreadCount = UserDefaults.standard.value(forKey: DefaultName.agentUnreadCount.rawValue) as? Int{
       //find if the channel exists in list
        if let channelUnreadCount = channelList["\(channelId)"] as? Int{
            let newUnreadCount = totalUnreadCount - channelUnreadCount
            HippoConfig.shared.sendAgentUnreadCount(newUnreadCount)
            channelList.removeValue(forKey: "\(channelId)")
            HippoConfig.shared.sendAgentChannelsUnreadCount(channelList.count)
            FuguDefaults.set(value: channelList, forKey: DefaultName.agentTotalUnreadHashMap.rawValue)
            UserDefaults.standard.set(newUnreadCount, forKey: DefaultName.agentUnreadCount.rawValue)
        }
    }
}



func calculateTotalAgentUnreadCount(_ channelId : Int, _ unreadCount : Int){
    if var channelList = FuguDefaults.object(forKey: DefaultName.agentTotalUnreadHashMap.rawValue) as? [String : Any], var totalUnreadCount = UserDefaults.standard.value(forKey: DefaultName.agentUnreadCount.rawValue) as? Int{
       //find if the channel exists in list
        if let channelUnreadCount = channelList["\(channelId)"] as? Int{
            let newUnreadCount = channelUnreadCount + 1
            channelList["\(channelId)"] = newUnreadCount
           // set value in hash
            FuguDefaults.set(value: channelList, forKey: DefaultName.agentTotalUnreadHashMap.rawValue)
            //set total unread
            totalUnreadCount = totalUnreadCount + 1
            UserDefaults.standard.set(totalUnreadCount, forKey: DefaultName.agentUnreadCount.rawValue)
            //send delegate
            HippoConfig.shared.sendAgentUnreadCount(totalUnreadCount)
            HippoConfig.shared.sendAgentChannelsUnreadCount(channelList.count)
        }else{
            // if channel id doesnot exist in list
            channelList["\(channelId)"] = 1
            FuguDefaults.set(value: channelList, forKey: DefaultName.agentTotalUnreadHashMap.rawValue)
            
            totalUnreadCount = totalUnreadCount + 1
            UserDefaults.standard.set(totalUnreadCount, forKey: DefaultName.agentUnreadCount.rawValue)
            //send delegate
            HippoConfig.shared.sendAgentUnreadCount(totalUnreadCount)
            HippoConfig.shared.sendAgentChannelsUnreadCount(channelList.count)
        }
    }
}

func pushTotalUnreadCount() {
    var chatCounter = 0
    
    switch HippoConfig.shared.appUserType {
    case .agent:
        let allChats = ConversationStore.shared.allChats
        for each in allChats {
            if let unreadCount = each.unreadCount  {
                chatCounter += unreadCount
            }
        }
    case .customer:
        if let chatCachedArray = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] {
            for conversationInfo in chatCachedArray {
                if let conversationCounter = conversationInfo["unread_count"] as? Int {
                    chatCounter += conversationCounter
                }
            }
        }
    }
    
    chatCounter += getPushUnreadCount()
    HippoConfig.shared.sendUnreadCount(chatCounter)
    
//    if let allConversationVC = getLastVisibleController() as? AllConversationsViewController{
//        let totalNotifyCount = chatCounter
//        if totalNotifyCount > 0{
//            if let tabItems = allConversationVC.tabBarController?.tabBar.items {
//                // In this case we want to modify the badge number of the third tab:
//                let tabItem = tabItems[0]
//                tabItem.badgeValue = "\(totalNotifyCount)"
//                //tabItem.badgeValue = nil
//                //UserDefaults.standard.set(totalNotifyCount, forKey: "totalNotify")
//            }
//        }else{
//            if let tabItems = allConversationVC.tabBarController?.tabBar.items {
//                // In this case we want to modify the badge number of the third tab:
//                let tabItem = tabItems[0]
//                tabItem.badgeValue = nil
//            }
//        }
//    }
    
}

func updateStoredUnreadCountFor(with userInfo: [String: Any]) {
    let recievedChannelId = userInfo["channel_id"] as? Int ?? -1
    let recievedLabelId = userInfo["label_id"] as? Int ?? -1
    
    guard recievedChannelId > 0, recievedLabelId > 0 else {
        return
    }
    
    switch HippoConfig.shared.appUserType {
    case .agent:
        let allChats = ConversationStore.shared.allChats
        for (index, each) in allChats.enumerated() {
            let id = each.channel_id ?? -1
            let labelId = each.labelId ?? -1
            
            var isLabelIdPresent = false
            var isChannelIdPresent = false
            
            if id == recievedChannelId {
                isChannelIdPresent = true
            }
            if labelId == recievedLabelId {
                isLabelIdPresent = true
            }
            
            if recievedChannelId < 1 {
                isChannelIdPresent = false
            }
            if recievedLabelId < 1 {
                isLabelIdPresent = false
            }
            guard isLabelIdPresent || isChannelIdPresent else {
                continue
            }
            let obj = each
            obj.unreadCount = 0
            ConversationStore.shared.allChats[index] = obj
            return
        }
    case .customer:
        guard var chatCachedArray = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] else {
            return
        }
        
        let rawIndex = getIndexOf(objects: chatCachedArray, with: recievedChannelId, with: recievedLabelId)
        if let index = rawIndex {
            var obj = chatCachedArray[index]
            obj["unread_count"] = 0
            chatCachedArray[index] = obj
            FuguDefaults.set(value: chatCachedArray, forKey: DefaultName.conversationData.rawValue)
        }
    }
    
}


func getIndexOf(objects: [[String: Any]], with channelId: Int, with labelId: Int) -> Int? {
    guard channelId > 0 || labelId > 0 else {
        return nil
    }
    
    for (index, each) in objects.enumerated() {
        let id = each["channel_id"] as? Int ?? -1
        let currentLabelId = each["label_id"] as? Int ?? -1
        
        var isLabelIdPresent = false
        var isChannelIdPresent = false
        
        if id == channelId {
            isChannelIdPresent = true
        }
        if currentLabelId == labelId {
            isLabelIdPresent = true
        }
        
        if channelId < 1 {
            isChannelIdPresent = false
        }
        if labelId < 1 {
            isLabelIdPresent = false
        }
        
        guard isLabelIdPresent || isChannelIdPresent else {
            continue
        }
        return index
    }
    return nil
}

func sendUserUnreadCount() {
    guard HippoConfig.shared.appUserType == .agent else {
        return
    }
    let json = UnreadCount.getJsonToSend()
    HippoConfig.shared.notifyUserUnreadCount(json)
}

func getPushUnreadCount() -> Int {
    var count = 0
    for each in HippoConfig.shared.pushArray {
        count += each.count
    }
    return count
}

func rotateCameraImageToProperOrientation(imageSource: UIImage, maxResolution: CGFloat = 1024) -> UIImage {
    
    let imgRef = imageSource.cgImage
    
    let width = CGFloat(imgRef!.width)
    let height = CGFloat(imgRef!.height)
    
    var bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
    var scaleRatio: CGFloat = 1
    
    if width > maxResolution || height > maxResolution {
        
        scaleRatio = min(maxResolution / bounds.size.width, maxResolution / bounds.size.height)
        bounds.size.height *= scaleRatio
        bounds.size.width *= scaleRatio
    }
    
    var transform = CGAffineTransform.identity
    let orient = imageSource.imageOrientation
    let imageSize = CGSize(width: imgRef!.width, height: imgRef!.height)
    
    switch imageSource.imageOrientation {
        
    case .up :
        transform = CGAffineTransform.identity
        
    case .upMirrored :
        
        transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
        transform = transform.scaledBy(x: -1.0, y: 1.0)
        
    case .down :
        
        transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
        transform = transform.rotated(by: CGFloat(Double.pi))
        
    case .downMirrored :
        
        transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
        transform = transform.scaledBy(x: 1.0, y: -1.0)
        
    case .left :
        
        let storedHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = storedHeight
        
        transform = transform.rotated(by: 3.0 * CGFloat(Double.pi) / 2.0)
        
        
    case .leftMirrored :
        
        let storedHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = storedHeight;
        transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
        transform = transform.scaledBy(x: -1.0, y: 1.0)
        transform = transform.rotated(by: 3.0 * CGFloat(Double.pi) / 2.0)
        
    case .right :
        
        let storedHeight = bounds.size.height
        
        bounds.size.height = bounds.size.width
        bounds.size.width = storedHeight
        transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
        transform = transform.rotated(by: CGFloat(Double.pi) / 2.0)
        
    case .rightMirrored :
        
        let storedHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = storedHeight
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        transform = transform.rotated(by: CGFloat(Double.pi) / 2.0)
        
    }
    
    UIGraphicsBeginImageContext(bounds.size)
    let context = UIGraphicsGetCurrentContext()
    
    
    if orient == .right || orient == .left {
        
        context!.scaleBy(x: -scaleRatio, y: scaleRatio)
        context!.translateBy(x: -height, y: 0)
        
    } else {
        
        context!.scaleBy(x: scaleRatio, y: -scaleRatio)
        context!.translateBy(x: 0, y: -height)
        
    }
    
    context?.concatenate(transform)
    
    context?.draw(imgRef!, in: CGRect.init(x: 0, y: 0, width: width, height: height))
    
    let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imageCopy!
}

func updatePushCount(pushInfo: [String: Any]) {
    guard let channelId = pushInfo["channel_id"] as? Int else {
        return
    }
    guard channelId > 0 else {
        return
    }
    let index = HippoConfig.shared.pushArray.firstIndex { (p) -> Bool in
        return p.channelId == channelId
    }
    var newObj = PushInfo(json: pushInfo)
    guard index != nil else {
        newObj.count = 1
        HippoConfig.shared.pushArray.append(newObj)
        return
    }
    let oldObj = HippoConfig.shared.pushArray[index!]
    if let newMuid = newObj.muid, let oldMuid = oldObj.muid, newMuid == oldMuid {
        return
    }
    HippoConfig.shared.pushArray[index!].count += 1
    HippoConfig.shared.pushArray[index!].muid = newObj.muid
}
func resetForChannel(pushInfo: [String: Any]) {
    guard let channelId = pushInfo["channel_id"] as? Int else {
        return
    }
    resetForChannel(channelId: channelId)
}

func resetForChannel(channelId: Int) {
    let index = HippoConfig.shared.pushArray.firstIndex { (p) -> Bool in
        return p.channelId == channelId
    }
    
    guard index != nil else {
        return
    }
    HippoConfig.shared.pushArray.remove(at: index!)
    
}
func resetPushCount() {
    HippoConfig.shared.pushArray = []
}

func getLastVisibleController(ofParent parent: UIViewController? = nil) -> UIViewController? {
    if let vc = parent {
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return getLastVisibleController(ofParent: selected)
        } else if let nav = vc as? UINavigationController, let top = nav.topViewController {
            return getLastVisibleController(ofParent: top)
        } else if let presented = vc.presentedViewController {
            return getLastVisibleController(ofParent: presented)
        } else {
            return vc
        }
    } else {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            return getLastVisibleController(ofParent: rootVC)
        } else {
            return nil
        }
    }
}

func parseDeviceToken(deviceToken: Data) -> String? {
    let tokenData = NSData(data: deviceToken)
    let trimEnds = tokenData.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
    let pushToken: String = trimEnds.replacingOccurrences(of: " ", with: "")
    
    if pushToken.isEmpty || pushToken.contains("{")  {
        return deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    }
    return pushToken
}

func updateDeviceToken(deviceToken: String) {
    switch HippoConfig.shared.appUserType {
    case .agent:
        AgentConversationManager.updateAgentChannel{ (error,response) in
        }
    case .customer:
        HippoUserDetail.getUserDetailsAndConversation()
    }
}


func validateCustomerData() -> Bool {
    switch HippoConfig.shared.credentialType {
    case FuguCredentialType.reseller:
        if HippoConfig.shared.resellerToken.isEmpty || HippoConfig.shared.referenceId < 0 {
            return false
        }
    default:
        if HippoConfig.shared.appSecretKey.isEmpty {
            return false
        }
    }
    return true
}

func validateAgentData() -> Bool {
    guard HippoConfig.shared.agentDetail != nil, !HippoConfig.shared.agentDetail!.fuguToken.isEmpty else {
        return false
    }
    return true
}
func validateFuguCredential() -> Bool {
    switch HippoConfig.shared.appUserType {
    case .agent:
        return validateAgentData()
    case .customer:
        return validateCustomerData()
    }
}

func getCurrentLanguageLocale() -> String {
    if UserDefaults.standard.value(forKey: DefaultName.selectedLanguage.rawValue) as? String == ""{
        return "en"
    }else{
        return UserDefaults.standard.value(forKey: DefaultName.selectedLanguage.rawValue) as? String ?? "en"
    }
}


func showAlertWith(message: String, action: (() -> Void)?) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: HippoStrings.ok, style: .default, handler: { _ in
        action?()
    })
    alert.addAction(dismissAction)
    getLastVisibleController()?.present(alert, animated: true, completion: nil)
}


func currentUserId() -> Int {
    switch HippoConfig.shared.appUserType {
    case .agent:
        return HippoConfig.shared.agentDetail?.id ?? -1
    case .customer:
        return HippoUserDetail.fuguUserID ?? -1
    }
}

func currentUserImage() -> String? {
    switch HippoConfig.shared.appUserType {
    case .agent:
        return HippoConfig.shared.agentDetail?.userImage
    case .customer:
        return HippoConfig.shared.userDetail?.userImage?.absoluteString
    }
}

func currentEnUserId() -> String {
    switch HippoConfig.shared.appUserType {
    case .agent:
        return HippoConfig.shared.agentDetail?.enUserId ?? ""
    case .customer:
        return HippoUserDetail.fuguEnUserID ?? ""
    }
}

func currentUserName() -> String {
    switch HippoConfig.shared.appUserType {
    case .agent:
        return HippoConfig.shared.agentDetail?.fullName ?? HippoStrings.agent
    case .customer:
        return HippoConfig.shared.userDetail?.fullName ?? HippoStrings.visitor
    }
}

func currentUserType() -> UserType {
    switch HippoConfig.shared.appUserType {
    case .agent:
        return UserType.agent
    case .customer:
        return UserType.customer
    }
}

