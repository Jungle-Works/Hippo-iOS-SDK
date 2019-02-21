//
//  FuguAppFlow.swift
//  Fugu
//
//  Created by clickpass on 7/11/17.
//

import UIKit

class FuguFlowManager: NSObject {
    
    public static var shared = FuguFlowManager()
      
    class var bundle: Bundle? {
        let podBundle = Bundle(for: AllConversationsViewController.self)
        
        guard let bundleURL = podBundle.url(forResource: "Hippo", withExtension: "bundle"), let fetchBundle = Bundle(url: bundleURL) else {
            return nil
        }
        return fetchBundle
    }
    
    
    fileprivate let storyboard = UIStoryboard(name: "FuguUnique", bundle: bundle)
   
   
   // MARK: - Navigation Methods
   func presentCustomerConversations(animation: Bool = true) {
      guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguCustomerNavigationController") as? UINavigationController else {
         return
      }
      let visibleController = getLastVisibleController()
    
      visibleController?.present(navigationController, animated: animation, completion: nil)
   }
    
    func presentNLevelViewController(animation: Bool = true) {
        self.openFAQScreen(animation: animation)
    }
    func openFAQScreen(animation: Bool) {
        guard let vc = NLevelViewController.get(with: [HippoSupportList](), title: HippoSupportList.FAQName) else {
            return
        }
        let visibleController = getLastVisibleController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.setTheme()
        vc.isFirstLevel = true
        visibleController?.present(navVC, animated: animation, completion: nil)
    }
    
    func presentBroadcastController(animation: Bool = true) {
        let visibleController = getLastVisibleController()
        guard let navVC = BroadCastViewController.getNavigation() else {
            return
        }
        visibleController?.present(navVC, animated: animation, completion: nil)
        
    }
    
    
    func openDirectConversationHome() {
        guard HippoConfig.shared.appUserType == .agent else {
            return
        }
        guard let nav = AgentDirectViewController.get() else {
            return
        }
        let visibleController = getLastVisibleController()
        visibleController?.present(nav, animated: true, completion: nil)
        
    }
    func openChatViewController(labelId: Int) {
        
        let conversationViewController = ConversationsViewController.getWith(labelId: labelId.description)
        let visibleController = getLastVisibleController()
        //TODO: - Try to hit getByLabelId hit before presenting controller
        let navVC = UINavigationController(rootViewController: conversationViewController)
        navVC.setNavigationBarHidden(true, animated: false)

        conversationViewController.createConversationOnStart = true
        visibleController?.present(navVC, animated: false, completion: nil)
    }
   
    func showFuguChat(_ chat: FuguNewChatAttributes, createConversationOnStart: Bool = false) {
        let visibleViewController = getLastVisibleController()
        let convVC = ConversationsViewController.getWith(chatAttributes: chat)
        let navVC = UINavigationController(rootViewController: convVC)
        navVC.setNavigationBarHidden(true, animated: false)
        convVC.createConversationOnStart = createConversationOnStart
        visibleViewController?.present(navVC, animated: false, completion: nil)
    }
   
    func presentAgentConversations() {
        guard HippoConfig.shared.appUserType == .agent else {
            return
        }
        guard let nav = AgentHomeViewController.get() else {
            return
        }
        let visibleController = getLastVisibleController()
        visibleController?.present(nav, animated: true, completion: nil)
    }
   

    func toShowInAppNotification(userInfo: [String: Any]) -> Bool {
        if validateFuguCredential() == false {
            return false
        }
        
        if let muid = userInfo["muid"] as? String {
            if HippoConfig.shared.muidList.contains(muid) {
                return false
            }
            HippoConfig.shared.muidList.append(muid)
        }
        
        updatePushCount(pushInfo: userInfo)
        if let keys = userInfo["user_unique_key"] as? [String] {
            UnreadCount.increaseUnreadCounts(for: keys)
        }
        pushTotalUnreadCount()
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            return showNotificationForAgent(with: userInfo)
        case .customer:
            break
        }
        let visibleController: UIViewController? = getLastVisibleController()
        
        if let lastVisibleCtrl = visibleController as? AllConversationsViewController {
            lastVisibleCtrl.updateChannelsWithrespectToPush(pushInfo: userInfo)
            if UIApplication.shared.applicationState == .inactive {
                HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
                return false
            }
            return true
        }
        return updateConversationVcForPush(userInfo: userInfo)
    }
    
    func presentFormCollector(forms: [FormData], animated: Bool = true) {
        let vc = HippoDataCollectorController.get(forms: forms)
        let visibleController = getLastVisibleController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.setTheme()
        visibleController?.present(navVC, animated: animated, completion: nil)
    }
    private func showNotificationForAgent(with userInfo: [String: Any]) -> Bool {
        let currentChannelId = currentAgentChannelID()
        let recievedId = userInfo["channel_id"] as? Int ?? userInfo["label_id"] as? Int ?? -1
        
        guard currentChannelId != -1, recievedId > 0 else {
            return true
        }
        if UIApplication.shared.applicationState == .inactive {
            HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
            return false
        }
        
        if currentChannelId != recievedId {
            return true
        }
        return false
    }
    
    
    private func currentAgentChannelID() -> Int {
        let visibleController: UIViewController? = getLastVisibleController()
        
        guard let vc = visibleController as? AgentConversationViewController, vc.channel != nil else {
            return -1
        }
        return vc.channel.id
    }
    
   private func updateConversationVcForPush(userInfo: [String: Any]) -> Bool {
      
      let visibleController = getLastVisibleController()
      
      if let conversationVC = visibleController as? ConversationsViewController {
        
        let recievedId = userInfo["channel_id"] as? Int ??  -1
        let recievedLabelId = userInfo["label_id"] as? Int ?? -1
        
        var isPresent = false
        
        if let id = conversationVC.channel?.id, id > 0 {
            isPresent = conversationVC.channel?.id != recievedId
        } else {
            isPresent = conversationVC.labelId != recievedLabelId
        }
        
        
        updatePushCount(pushInfo: userInfo)
        
         if let navVC = conversationVC.navigationController, isPresent {
            let existingViewControllers = navVC.viewControllers
            for existingController in existingViewControllers {
               if let lastVisibleCtrl = existingController as? AllConversationsViewController {
                  lastVisibleCtrl.updateChannelsWithrespectToPush(pushInfo: userInfo)
                  break
               }
            }
         }
         
         if UIApplication.shared.applicationState == .inactive {
            HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
            return false
         }
         return isPresent
      }
      if UIApplication.shared.applicationState == .inactive {
         HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
         return false
      }
      
      return true
   }
   
}
