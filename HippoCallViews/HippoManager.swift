//
//  HippoManager.swift
//  Hippo
//
//  Created by Vishal on 11/11/18.
//  Copyright © 2018 clicklabs. All rights reserved.
//

import Hippo

#if canImport(IQKeyboardManager)
import IQKeyboardManager
#endif

#if canImport(HippoCallClient)
import HippoCallClient
#endif

/**
 This class is Created to have a singleton instance of delegate handler.
 This is example class anyone can use it or can create there own.
 
 To get it working set "HippoConfig.shared.setHippoDelegate(delegate: HippoManager.shared)" :
 
 1. application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool in appDelegate
 2. pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) where you have declared PKPushRegistryDelegate
 **/


class HippoManager: HippoDelegate {


    static let shared = HippoManager()

    func hippoUnreadCount(_ totalCount: Int) {
        /**
         Write your code to set total unread count of logged in user
         **/

    }

    func hippoUserUnreadCount(_ usersCount: [String : Int]) {
        /**
         Write your code to set unread count of indiviual user list you have given in "getUnreadCount"
         **/
    }

    func hippoDeinit() {
        #if canImport(IQKeyboardManager)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().isEnabled = true
        #endif
    }

    func hippoDidLoad() {
        /**
         Here hippo Screen appears, Perform action you want to do on screen aperring
         Example: Disable Any keyboard manger you are using.
         **/
        #if canImport(IQKeyboardManager)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        #endif
    }
    func hippoMessageRecievedWith(response: [String : Any], viewController: UIViewController) {
        /**
         This delegate is for the Button action on message,
         example : Payment, webview, or any other screen
         **/
    }
    //This delegate will only work if you add 'Hippo/Call' in pod file
    #if canImport(HippoCallClient)
    func loadCallPresenterView(request: CallPresenterRequest) -> CallPresenter? {
        /**
         This function is called when some one call Or app user wants to call,
         Change this function as per your requirements.

         Note:  nil means no screen will be presented and videoCall/Audio call will not work
         **/

        switch request.callType {
        case .video:
            let videoView = VideoCallView.loadVideoCallView()
            return videoView
        case .audio:
            if #available(iOS 10.0, *) {
                let audioCallPresenter = AudioCallPresenter.shared
                audioCallPresenter.setWith(callUUID: request.uuid, isDialedByUser: request.isDialedByUser)
                return audioCallPresenter
            }
        }
        return nil
    }
    #endif
}
