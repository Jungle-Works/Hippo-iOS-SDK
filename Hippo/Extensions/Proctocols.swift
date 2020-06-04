//
//  Proctocols.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit

#if canImport(HippoCallClient)
 import HippoCallClient
#endif


/*
 For counting the number of cases on enum
 */
protocol CaseCountable { }

extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    
    static var count: Int {
        var count = 0
        while Self(rawValue: count) != nil { count+=1 }
        return count
    }
    
    static var allValues: [Self] {
        return (0..<count).compactMap({ Self(rawValue: $0) })
    }
    
}


public protocol HippoDelegate: class {
    func hippoUnreadCount(_ totalCount: Int)
    func hippoUserUnreadCount(_ usersCount: [String: Int])    
    func hippoDeinit()
    func hippoDidLoad()
    func hippoMessageRecievedWith(response: [String: Any], viewController: UIViewController)
    func promotionMessageRecievedWith(response: [String: Any], viewController: UIViewController)
    func deepLinkClicked(response : [String : Any])
    func hippoUserLogOut()
    func startLoading(message: String?)
    func stopLoading()
    func hippoAgentTotalUnreadCount(_ totalCount: Int)
    func hippoAgentTotalChannelsUnreadCount(_ totalCount: Int)    
    func sendDataIfChatIsAssignedToSelfAgent(_ dic : [String : Any])
    func sendp2pUnreadCount(unreadCount : Int, channelId : Int)
    func chatListButtonAction()
    
    
    #if canImport(HippoCallClient)
     func loadCallPresenterView(request: CallPresenterRequest) -> CallPresenter?
    #endif
}

extension HippoDelegate {
    
    func sendp2pUnreadCount(unreadCount : Int, channelId : Int){
        
    }
    func hippoUnreadCount(_ totalCount: Int) {
        
    }
    func hippoUserUnreadCount(_ usersCount: [String: Int]) {
        
    }
    
    func hippoDeinit() {
        
    }
    func hippoDidLoad() {
        
    }
    
    func hippoMessageRecievedWith(response: [String: Any], viewController: UIViewController) {
        
    }
    
    func promotionMessageRecievedWith(response: [String: Any], viewController: UIViewController) {
        
    }
}

protocol RetryMessageUploadingDelegate: class {
    func retryUploadFor(message: HippoMessage)
    func cancelImageUploadFor(message: HippoMessage)
}

protocol DocumentTableViewCellDelegate: class {
    func performActionAccordingToStatusOf(message: HippoMessage, inCell cell: DocumentTableViewCell)
}

protocol VideoTableViewCellDelegate: class {
    func downloadFileIn(message: HippoMessage)
    func openFileIn(message: HippoMessage)
}
