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
//        guard let bundleURL = podBundle.url(forResource: "HippoChat", withExtension: "bundle"), let fetchBundle = Bundle(url: bundleURL) else {
            return podBundle
        }
        return fetchBundle
    }
    
    
    fileprivate let storyboard = UIStoryboard(name: "FuguUnique", bundle: bundle)
   
    //MARK: AgentNavigation methods
    func pushAgentConversationViewController(channelId: Int, channelName: String, channelType : channelType? = .DEFAULT) {
        let conVC = AgentConversationViewController.getWith(channelID: channelId, channelName: channelName)
        let navVc = UINavigationController(rootViewController: conVC)
        navVc.setTheme()
        navVc.modalPresentationStyle = .fullScreen
        getLastVisibleController()?.present(navVc, animated: true, completion: nil)
    }
    
    func pushAgentConversationViewController(chatAttributes: AgentDirectChatAttributes) {
        let conVC = AgentConversationViewController.getWith(chatAttributes: chatAttributes)
        let navVc = UINavigationController(rootViewController: conVC)
        navVc.setTheme()
        navVc.modalPresentationStyle = .fullScreen
        getLastVisibleController()?.present(navVc, animated: true, completion: nil)
    }
    
    
   // MARK: - Navigation Methods
   func presentCustomerConversations(animation: Bool = true) {
      guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguCustomerNavigationController") as? UINavigationController else {
         return
      }
      let visibleController = getLastVisibleController()
      navigationController.modalPresentationStyle = .fullScreen
      visibleController?.present(navigationController, animated: animation, completion: nil)
   }
    func presentCustomerConversations(on viewController: UIViewController, animation: Bool = true) {
       guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguCustomerNavigationController") as? UINavigationController, let topVC = navigationController.topViewController else {
          return
       }
//       let visibleController = getLastVisibleController()
     
        viewController.navigationController?.pushViewController(topVC, animated: animation)
//       visibleController?.present(navigationController, animated: animation, completion: nil)
    }
    
    func presentPromotionalpushController(animation: Bool = true) {
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguPromotionalNavigationController") as? UINavigationController else {
            return
        }
        let visibleController = getLastVisibleController()
        guard ((visibleController as? PromotionsViewController) == nil) else {
            return
        }
        navigationController.modalPresentationStyle = .fullScreen
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
        navVC.modalPresentationStyle = .fullScreen
        visibleController?.present(navVC, animated: animation, completion: nil)
    }
    
    func presentBroadcastController(animation: Bool = true) {
        let visibleController = getLastVisibleController()
        guard let navVC = BroadCastViewController.getNavigation() else {
            return
        }
        navVC.modalPresentationStyle = .fullScreen
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
        nav.modalPresentationStyle = .fullScreen
        visibleController?.present(nav, animated: true, completion: nil)
    }
    
    
    
    func openDirectAgentConversation(channelTitle: String?) {
        guard HippoConfig.shared.appUserType == .agent else {
            return
        }
        guard !AgentConversationManager.searchUserUniqueKeys.isEmpty, let transactionId = AgentConversationManager.transactionID else {
            return
        }
        let attributes = AgentDirectChatAttributes(otherUserUniqueKey: AgentConversationManager.searchUserUniqueKeys[0], channelName: channelTitle, transactionID: transactionId.trimWhiteSpacesAndNewLine())
        let vc = AgentConversationViewController.getWith(chatAttributes: attributes)
        vc.isSingleChat = true
        
        let naVC = UINavigationController(rootViewController: vc)
        let visibleController = getLastVisibleController()
        naVC.modalPresentationStyle = .fullScreen
        visibleController?.present(naVC, animated: true, completion: nil)
    }
    func openChatViewController(labelId: Int) {
        
        let conversationViewController = ConversationsViewController.getWith(labelId: labelId.description)
        let visibleController = getLastVisibleController()
        //TODO: - Try to hit getByLabelId hit before presenting controller
        let navVC = UINavigationController(rootViewController: conversationViewController)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .fullScreen
        conversationViewController.createConversationOnStart = true
        visibleController?.present(navVC, animated: false, completion: nil)
    }
    func openChatViewControllerTempFunc(labelId: Int) {
        
        let conversationViewController = ConversationsViewController.getWith(labelId: labelId.description)
        let visibleController = getLastVisibleController()
        //TODO: - Try to hit getByLabelId hit before presenting controller
        let navVC = UINavigationController(rootViewController: conversationViewController)
        navVC.setNavigationBarHidden(true, animated: false)
        
        conversationViewController.createConversationOnStart = true
        navVC.modalPresentationStyle = .fullScreen
        visibleController?.present(navVC, animated: true, completion: nil)
        
    }
    
    func openChatViewController(on viewController: UIViewController, labelId: Int, hideBackButton: Bool, animation: Bool) {
        
        let conversationViewController = ConversationsViewController.getWith(labelId: labelId.description)
//        let visibleController = getLastVisibleController()
        //TODO: - Try to hit getByLabelId hit before presenting controller
//        let navVC = UINavigationController(rootViewController: conversationViewController)
//        navVC.setNavigationBarHidden(true, animated: false)

        conversationViewController.createConversationOnStart = false
            conversationViewController.hideBackButton = hideBackButton
        viewController.navigationController?.pushViewController(conversationViewController, animated: animation)
//        visibleController?.present(navVC, animated: false, completion: nil)
    }
   
    func showFuguChat(_ chat: FuguNewChatAttributes, createConversationOnStart: Bool = false) {
        let visibleViewController = getLastVisibleController()
        let convVC = ConversationsViewController.getWith(chatAttributes: chat)
        let navVC = UINavigationController(rootViewController: convVC)
        navVC.setNavigationBarHidden(true, animated: false)
        convVC.createConversationOnStart = createConversationOnStart
        navVC.modalPresentationStyle = .fullScreen
        visibleViewController?.present(navVC, animated: false, completion: nil)
    }
    func showFuguChat(on viewController: UIViewController, chat: FuguNewChatAttributes, createConversationOnStart: Bool = false) {
//        let visibleViewController = getLastVisibleController()
        let convVC = ConversationsViewController.getWith(chatAttributes: chat)
//        let navVC = UINavigationController(rootViewController: convVC)
//        navVC.setNavigationBarHidden(true, animated: false)
        convVC.createConversationOnStart = createConversationOnStart
//        visibleViewController?.present(navVC, animated: false, completion: nil)
        viewController.navigationController?.pushViewController(convVC, animated: true)
    }
    
    func consultNowButtonClicked(consultNowInfoDict: [String: Any]){
        
//        var fuguNewChatAttributes = FuguNewChatAttributes(transactionId: "", userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: HippoProperty.current.newConversationButtonTags, channelName: nil, preMessage: "", groupingTag: nil)
        var transactionId = ""
        if let id = consultNowInfoDict["transactionId"] as? Int {
            transactionId = "\(id)"
        }else if let id = consultNowInfoDict["transactionId"] as? String{
            transactionId = id
        }
          
        var fuguNewChatAttributes = FuguNewChatAttributes(transactionId: transactionId, userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: HippoProperty.current.newConversationButtonTags, channelName: nil, preMessage: "", groupingTag: nil)
        print("bodID******* \(HippoProperty.current.newconversationBotGroupId ?? "")")
        print("bodID*******FuguAppFlow")
//        fuguNewChatAttributes.botGroupId = HippoProperty.current.newconversationBotGroupId//"72"//
        if let botID = HippoProperty.current.newconversationBotGroupId, botID != ""{
            fuguNewChatAttributes.botGroupId = botID
        }
        let visibleViewController = getLastVisibleController()
        let convVC = ConversationsViewController.getWith(chatAttributes: fuguNewChatAttributes)
        let navVC = UINavigationController(rootViewController: convVC)
        navVC.setNavigationBarHidden(true, animated: false)
        convVC.createConversationOnStart = true
        convVC.consultNowInfoDict = consultNowInfoDict
        convVC.isComingFromConsultNowButton = true
        navVC.modalPresentationStyle = .fullScreen
        visibleViewController?.present(navVC, animated: false, completion: nil)
        
    }
    
//    func presentPromotionalpushController(animation: Bool = true) {
//
//        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguPromotionalNavigationController") as? UINavigationController else {
//            return
//        }
//        let visibleController = getLastVisibleController()
//        navigationController.modalPresentationStyle = .fullScreen
//        visibleController?.present(navigationController, animated: animation, completion: nil)
//
//    }
   
    func presentAgentConversations() {
        guard HippoConfig.shared.appUserType == .agent else {
            return
        }
        guard let nav = AgentHomeViewController.get() else {
            return
        }
        let visibleController = getLastVisibleController()
        nav.modalPresentationStyle = .fullScreen
        visibleController?.present(nav, animated: true, completion: nil)
    }
   
    func presentPrePaymentController(_ url : String, _ channelId : Int){
        guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let config = WebViewConfig(url: urlString, title: HippoStrings.payment) else { return }
        let vc = PrePaymentViewController.getNewInstance(config: config)
        vc.isComingForPayment = true
        let navVC = UINavigationController(rootViewController: vc)
        navVC.setNavigationBarHidden(true, animated: false)
        let visibleController = getLastVisibleController()
        navVC.modalPresentationStyle = .fullScreen
        vc.isPrePayment = true
        vc.channelId = channelId
        vc.isPaymentCancelled = {(sucess) in
            HippoConfig.shared.HippoPrePaymentCancelled?()
        }
        vc.isPaymentSuccess = {(status) in
            HippoConfig.shared.HippoPrePaymentSuccessful?(status)
        }
        
        visibleController?.present(navVC, animated: true, completion: nil)  
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
        
        if getLastVisibleController() is PromotionsViewController{
            return false
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
               // HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
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
        navVC.modalPresentationStyle = .fullScreen
        visibleController?.present(navVC, animated: animated, completion: nil)
    }
    private func showNotificationForAgent(with userInfo: [String: Any]) -> Bool {
        let currentChannelId = currentAgentChannelID()
        let recievedId = userInfo["channel_id"] as? Int ?? userInfo["label_id"] as? Int ?? -1
        
        guard currentChannelId != -1, recievedId > 0 else {
            return true
        }
        if UIApplication.shared.applicationState == .inactive {
           // HippoConfig.shared.handleRemoteNotification(userInfo: userInfo)
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
            return false
         }
         return isPresent
      }
      
      return true
   }
   
}
