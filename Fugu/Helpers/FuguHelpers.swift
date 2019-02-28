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

var FUGU_SCREEN_WIDTH: CGFloat {
    return UIScreen.main.bounds.width
}
var FUGU_SCREEN_HEIGHT: CGFloat {
    return UIScreen.main.bounds.height
}

var isModuleRunning: Bool {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
      return true
   }
    return bundleIdentifier != "com.socomo.Fugu"
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
    
    attributedTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: colorOfFirstString, range: rangeOfFirstString)
    if let sendeNameFont = fontOfFirstString {
        attributedTitle.addAttribute(NSAttributedStringKey.font, value: sendeNameFont, range: rangeOfFirstString)
    }
    
    attributedTitle.addAttribute(NSAttributedStringKey.paragraphStyle, value: firstStringStyle, range: rangeOfFirstString)
    
    attributedTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: colorOfSecondString, range: rangeOfSecondString)
    
    if let incomingMsgFont = fontOfSecondString {
        attributedTitle.addAttribute(NSAttributedStringKey.font, value: incomingMsgFont, range: rangeOfSecondString)
    }
    
    attributedTitle.addAttribute(NSAttributedStringKey.paragraphStyle, value: firstStringStyle, range: rangeOfSecondString)
    
    attributedTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: colorOfThirdString, range: rangeOfThirdString)
    
    attributedTitle.addAttribute(NSAttributedStringKey.font, value: fontOfThirdString, range: rangeOfThirdString)
    attributedTitle.addAttribute(NSAttributedStringKey.paragraphStyle, value: thirdStringStyle, range: rangeOfThirdString)
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
    
    attributedTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: colorOfFirstString, range: rangeOfFirstString)
    attributedTitle.addAttribute(NSAttributedStringKey.font, value: fontOfFirstString, range: rangeOfFirstString)
    attributedTitle.addAttribute(NSAttributedStringKey.paragraphStyle, value: firstStringStyle, range: rangeOfFirstString)
    
    attributedTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: colorOfSecondString, range: rangeOfSecondString)
    attributedTitle.addAttribute(NSAttributedStringKey.font, value: fontOfSecondString, range: rangeOfSecondString)
    attributedTitle.addAttribute(NSAttributedStringKey.paragraphStyle, value: firstStringStyle, range: rangeOfSecondString)
    
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
            return "Today"
        default:
            let calendar = NSCalendar.current
            let dateOfMsg = calendar.startOfDay(for: dateTobeConverted)
            let currentDate = calendar.startOfDay(for: Date())
            let dateDifference = calendar.dateComponents([.day], from: dateOfMsg, to: currentDate).day
            if dateDifference == 1 { return "Yesterday" }
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

func checkUnreadChatCount() -> Int {
    var chatCounter = 0
    if let chatCachedArray = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] {
        for conversationInfo in chatCachedArray {
            if let conversationCounter = conversationInfo["unread_count"] as? Int {
                chatCounter += conversationCounter
            }
        }
    }
    if HippoConfig.shared.unreadCount != nil {
      HippoConfig.shared.unreadCount!(chatCounter)
   }
    return chatCounter
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



func updateDeviceToken(deviceToken: Data) {
    let tokenData = NSData(data: deviceToken)
    let trimEnds = tokenData.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
    let pushToken = trimEnds.replacingOccurrences(of: " ", with: "")
    
    if pushToken.isEmpty == false {
        HippoConfig.shared.deviceToken = pushToken
        HippoUserDetail.getUserDetailsAndConversation()
    }
}

func validateFuguRemoteNotification(withUserInfo userInfo: [String: Any]) -> Bool {
    if let pushSource = userInfo["push_source"] as? String,
        pushSource == "FUGU" {
        return true
    }
    return false
}
func showAlertWith(message: String, action: (() -> Void)?) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
        action?()
    })
    alert.addAction(dismissAction)
    getLastVisibleController()?.present(alert, animated: true, completion: nil)
}
func validateHippoCredential() -> Bool {
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






