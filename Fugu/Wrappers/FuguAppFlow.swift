//
//  FuguAppFlow.swift
//  Fugu
//
//  Created by clickpass on 7/11/17.
//

import UIKit

class HippoFlowManager: NSObject {
    
    public static var shared = HippoFlowManager()
      
    class var bundle: Bundle? {
        let podBundle = Bundle(for: AllConversationsViewController.self)
        
        guard let bundleURL = podBundle.url(forResource: "Hippo", withExtension: "bundle"), let fetchBundle = Bundle(url: bundleURL) else {
            return nil
        }
        return fetchBundle
    }
    
    
    fileprivate let storyboard = UIStoryboard(name: "FuguUnique", bundle: bundle)
   
   
   // MARK: - Navigation Methods
   func presentAllChatsViewController(animation: Bool = true) {
      guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguNavigationController") as? UINavigationController else {
         return
      }
      let visibleController = getLastVisibleController()
      
      navigationController.modalPresentationStyle = .overCurrentContext
      
      visibleController?.present(navigationController, animated: animation, completion: nil)
   }
    
    func presentAllChatsViewController(_ animation: Bool = true, labelId: Int, fuguNav: UINavigationController?) {
        
        guard let nav = storyboard.instantiateViewController(withIdentifier: "FuguNavigationController") as? UINavigationController else {
            return
        }
        
        var navigationController = nav
        
        if let alreadyPresentedInstance = fuguNav {
            navigationController = alreadyPresentedInstance
        }
        
        let visibleController = getLastVisibleController()
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.viewControllers.append(ConversationsViewController.getWith(channelID: labelId, channelName: ""))
        visibleController?.present(navigationController, animated: animation, completion: nil)
    }
    
    func presentConversationsViewController(_ animation: Bool = true, labelId: Int, fuguNav: UINavigationController?) {
        
        guard let nav = storyboard.instantiateViewController(withIdentifier: "FuguNavigationController") as? UINavigationController else {
            return
        }
        
        var navigationController = nav
        
        if let alreadyPresentedInstance = fuguNav {
            navigationController = alreadyPresentedInstance
        }
        
        let visibleController = getLastVisibleController()
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.viewControllers[0] = (ConversationsViewController.getWith(channelID: labelId, channelName: ""))
        visibleController?.present(navigationController, animated: animation, completion: nil)
    }
    
    func presentNLevelViewController(animation: Bool = true) {
        
//        if HippoConfig.shared.userDetail?.fuguUserID == nil {
//            HippoUserDetail.getUserDetailsAndConversation(completion: { [weak self] (success, error) in
                self.openFAQScreen(animation: animation)
//            })
//        }
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
   func openChatViewController(labelId: Int) {
      
     let conversationViewController = ConversationsViewController.getWith(labelId: labelId.description)
         let visibleController = getLastVisibleController()
         //TODO: - Try to hit getByLabelId hit before presenting controller
      visibleController?.present(conversationViewController, animated: false, completion: nil)
   }
   
   func showFuguChat(_ chat: FuguNewChatAttributes) {
      let visibleViewController = getLastVisibleController()
      let convVC = ConversationsViewController.getWith(chatAttributes: chat)
      visibleViewController?.present(convVC, animated: false, completion: nil)
   }
   
   
   // MARK: - Push Handling
//   private func updateChannelData() {
//      guard let showAllConversationVC = controllersInStack.first as? AllConversationsViewController else {
//         return
//      }
//      if let conversationVC = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController {
//         guard let pushChannelId = HippoConfig.shared.pushInfo["channel_id"] as? Int, let pushMessage = HippoConfig.shared.pushInfo["new_message"] as? String else {
//            return
//         }
//         if let tempChatCachedArray = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] {
//
//            var chatCachedArray = tempChatCachedArray
//            for channel in 0 ..< chatCachedArray.count {
//               let channelObj = chatCachedArray[channel]
//               guard let channelId = channelObj["channel_id"] as? Int else {
//                  return
//               }
//               if channelId == pushChannelId {
//                  var updatedChannelObj = channelObj
//                  updatedChannelObj["message"] = pushMessage
//                  updatedChannelObj["unread_count"] = 0
//                  if let dateTime = HippoConfig.shared.pushInfo["date_time"] as? String, dateTime.characters.count > 0 {
//                     updatedChannelObj["date_time"] = dateTime
//                  }
//
//                  updatedChannelObj["label"] = (HippoConfig.shared.pushInfo["label"] as? String) ?? ""
//
//                  chatCachedArray[channel] = updatedChannelObj
//                  FuguDefaults.set(value: chatCachedArray, forKey: DefaultName.conversationData.rawValue)
//                  _ = checkUnreadChatCount()
//                  conversationVC.delegate = showAllConversationVC
//                  break
//               }
//            }
//         }
//
//         conversationVC.channel = FuguChannel(id: pushChannelId.description)
//         HippoConfig.shared.pushInfo = [:]
//         controllersInStack.append(conversationVC)
//      }
//   }
   

    func toShowInAppNotification(userInfo: [String: Any]) -> Bool {
        if validateHippoCredential() == false {
            return false
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

    
   private func updateConversationVcForPush(userInfo: [String: Any]) -> Bool {
      
      let visibleController = getLastVisibleController()
      
      if let conversationVC = visibleController as? ConversationsViewController {
         
         if let navVC = conversationVC.navigationController {
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
         
         if let channelId = userInfo["channel_id"] as? Int {
            return conversationVC.channel?.id != channelId
         } else {
            return false
         }
      }
      if UIApplication.shared.applicationState == .inactive {
         HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
         return false
      }
      
      return true
   }
   
}
