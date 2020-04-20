//
//  HippoNotification.swift
//  Fugu
//
//  Created by Vishal on 11/09/18.
//

import Foundation
import UIKit
import UserNotifications

class HippoNotification {
    static var channelIdentifierHashmap: [Int: [String]] = [:]
    static var otherIdentifiers: [String] = []
    
    static func clearAllNotificationCenter() {
        DispatchQueue.main.async {
            UIApplication.shared.cancelAllLocalNotifications()
            UIApplication.shared.applicationIconBadgeNumber = 1
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    class func getAllIdentifiersFor(category: String) -> [String] {
        var identifiers = [String]()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications {(notifications) in
                for notification in notifications {
                    let content = notification.request.content
                    if content.categoryIdentifier == category, !notification.request.identifier.isEmpty {
                        identifiers.append(notification.request.identifier)
                    }
                }
            }
        } else {
            HippoNotification.clearAllNotificationCenter()
        }
        return identifiers
    }
    
    
//    class func getMessagesForNotificationBar(completion: @escaping ((_ messages: [HippoMessage]) -> Void)) {
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().getDeliveredNotifications {(notifications) in
//                var messages: [HippoMessage] = []
//                var channelHashMap: [Int: [String]] = [:]
//                for notification in notifications {
//                    guard let messageDict = notification.request.content.userInfo as? [String: Any], let conversation = AgentConversation(json: messageDict), let message = conversation.messageObject, let channelId = message.channelId else {
//                        continue
//                    }
//                    var currentIdentifier: [String] = channelHashMap[channelId] ?? []
//                    let identifier = notification.request.identifier
//                    if !currentIdentifier.contains(identifier) {
//                        currentIdentifier.append(identifier)
//                        channelHashMap[channelId] = currentIdentifier
//                    }
//                    messages.append(message)
//                }
//                HippoNotification.channelIdentifierHashmap = channelHashMap
//                completion(messages)
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//    }
    
    class func refreshHashMap() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications {(notifications) in
                
                guard notifications.count > 0 else {
                    HippoNotification.clearAllNotificationCenter()
                    return
                }
                
                var channelHashMap: [Int: [String]] = [:]
                for notification in notifications {
                    let identifier = notification.request.identifier
                    
                    guard let messageDict = notification.request.content.userInfo as? [String: Any] else {
                        otherIdentifiers.append(identifier)
                        continue
                    }
                    let conversation = AgentConversation(json: messageDict)
                    guard let channelId = conversation.channel_id else {
                        otherIdentifiers.append(identifier)
                        continue
                    }
                    
                    var currentIdentifier: [String] = channelHashMap[channelId] ?? []
                    
                    
                    if !currentIdentifier.contains(identifier) {
                        currentIdentifier.append(identifier)
                        channelHashMap[channelId] = currentIdentifier
                    }
                }
                HippoNotification.channelIdentifierHashmap = channelHashMap
            }
        } else {
           HippoNotification.clearAllNotificationCenter()
        }
    }
    
    class func removeHostNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: otherIdentifiers)
        } else {
            HippoNotification.clearAllNotificationCenter()
        }
        otherIdentifiers.removeAll()
    }
    class func removeAllnotificationFor(channelId: Int) {
       
        guard let identifiers = channelIdentifierHashmap[channelId], !identifiers.isEmpty else {
            return
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        } else {
            HippoNotification.clearAllNotificationCenter()
        }
        channelIdentifierHashmap[channelId] = []
    }
    
//    @available(iOS 10.0, *)
//    class func newNotificationArrived(with notification: UNNotification) {
//        guard let info = notification.request.content.userInfo as? [String: Any], let conversation = AgentConversation(JSON: info), let message = conversation.messageObject, let channelId = message.channelId else {
//            return
//        }
//        let identifier = notification.request.identifier
//        var currentIdentifiers: [String] = channelIdentifierHashmap[channelId] ?? []
//
//        if !currentIdentifiers.contains(identifier) {
//            currentIdentifiers.append(identifier)
//            channelIdentifierHashmap[channelId] = currentIdentifiers
//        }
//    }

}




class HippoObservers {
    static let shared = HippoObservers()
    var enable = true
    
    init() {
       registerApplicationObservers()
    }
    func registerApplicationObservers() {
        let center = NotificationCenter.default
        
        #if swift(>=4.2)
        center.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didFinishLaunchingNotification, object: nil)
        center.addObserver(self, selector: #selector(appEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        center.addObserver(self, selector: #selector(appEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        #else
        center.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        center.addObserver(self, selector: #selector(appEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        center.addObserver(self, selector: #selector(appEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        #endif
        
    }
    @objc func appBecomeActive() {
        HippoNotification.refreshHashMap()
    }
    @objc func appEnterBackground() {
        
    }
    @objc func appEnterForeground() {
        HippoNotification.refreshHashMap()
    }
}
