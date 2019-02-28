//
//  HippoConfig.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/16/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit

public protocol HippoMessageRecievedDelegate {
    func fuguMessageRecievedWith(response: [String: Any], viewController: UIViewController)
    func backFromFugu(viewController: UIViewController)
}

@objc public class HippoConfig : NSObject {
  @objc public static let shared = HippoConfig()

   // MARK: - Properties

   public var delegate: HippoMessageRecievedDelegate?
    
    internal var deviceToken = ""
    internal var ticketDetails = HippoTicketAtrributes(categoryName: "")
    internal var theme = HippoTheme.defaultTheme()
    internal var userDetail: HippoUserDetail?
    
    internal var allConversationTypes = [[String: Any]]()
   
   internal var appSecretKey: String {
      get {
         guard let appSecretKey = UserDefaults.standard.value(forKey: Fugu_AppSecret_Key) as? String else {
            return ""
         }
         return appSecretKey
      }
      set {
         UserDefaults.standard.set(newValue, forKey: Fugu_AppSecret_Key)
      }
   }



    internal var resellerToken = ""
    internal var referenceId = -1
    internal var appType: String?
    internal var credentialType = FuguCredentialType.defaultType

    internal var baseUrl = "https://api.fuguchat.com/"
    internal var fayeBaseURLString: String = "https://api.fuguchat.com:3002/faye"

    internal var unreadCount: ((_ totalUnread: Int) -> ())?

    internal let powererdByColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
    internal let HippoColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    internal let poweredByFont: UIFont = UIFont.systemFont(ofSize: 10.0)
    internal let HippoStringFont: UIFont = UIFont.boldSystemFont(ofSize: 12)
  
    internal var showNewChatBtn = true
    
    open let navigationTitleTextAlignMent: NSTextAlignment? = .center


//    var pushInfo = [String: Any]()
   
   // MARK: - Intialization
    private override init() {
        super.init()
        FuguNetworkHandler.shared.fuguConnectionChangesStartNotifier()
    }
  
  public func showCreateChatBtn(_ value: Bool) {
    showNewChatBtn = value
  }
   
   public func setCustomisedHippoTheme(theme: HippoTheme) {
      self.theme = theme
   }
    public func setAllConversationTypes(withTypes types: [[String: Any]]) {
        self.allConversationTypes = types
    }
   public func setCredential(withAppSecretKey appSecretKey: String, appType: String? = nil) {
      self.credentialType = FuguCredentialType.defaultType
      self.appSecretKey = appSecretKey
      self.appType = appType
   }
   
   public func setCredential(withToken token: String, referenceId: Int, appType: String) {
      self.credentialType = FuguCredentialType.reseller
      
      self.resellerToken = token
      self.referenceId = referenceId
      self.appType = appType
   }
   
   public func updateUserDetail(userDetail: HippoUserDetail) {
      self.userDetail = userDetail
      HippoUserDetail.getUserDetailsAndConversation()
   }
   
   // MARK: - Open Chat UI Methods
    public func presentChatsViewController() {
        HippoFlowManager.shared.presentAllChatsViewController()
    }
    public func showTicketSupport(with param: HippoTicketAtrributes) {
        let temp = param
        temp.FAQName = param.FAQName.trimWhiteSpacesAndNewLine()
        self.ticketDetails = param
        HippoFlowManager.shared.presentNLevelViewController()
    }
    
    public func presentChatsViewController(_ animation: Bool = true, labelId: Int, fuguNav: UINavigationController?) {
        HippoFlowManager.shared.presentAllChatsViewController(animation, labelId: labelId, fuguNav: fuguNav)
    }
    
    public func presentConversationViewController(_ animation: Bool = true, labelId: Int, fuguNav: UINavigationController?) {
        HippoFlowManager.shared.presentConversationsViewController(animation, labelId: labelId, fuguNav: fuguNav)
    }
    
    public func openChatScreen(withLabelId labelId: Int) {
        HippoFlowManager.shared.openChatViewController(labelId: labelId)
    }
   
    public func openChatScreen(withTransactionId transactionId: String, tags: [String]? = nil, channelName: String, message: String = "", userUniqueKey: String? = nil, isInAppMessage: Bool = false, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
      
      // TODO: - check for userUniqueKey and add save user data in cache
      let uniqueKey = userUniqueKey ?? self.userDetail?.userUniqueKey
      
       checkForIntialization { (success, error) in
         guard success else {
            completion(success, error)
            return
         }
         
        var fuguChat = FuguNewChatAttributes(transactionId: transactionId, userUniqueKey: uniqueKey, otherUniqueKey: nil, tags: tags, channelName: channelName, preMessage: message)
         fuguChat.isInAppChat = isInAppMessage
         let convVC = ConversationsViewController.getWith(chatAttributes: fuguChat)
         getLastVisibleController()?.present(convVC, animated: true, completion: nil)
         completion(true, nil)
      }

    }
    
   
   public func showPeerChatWith(data: PeerToPeerChat, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
      checkForIntialization { (success, error) in
         guard success else {
            completion(success, error)
            return
         }
         let fuguChat = FuguNewChatAttributes(transactionId: data.uniqueChatId ?? "", userUniqueKey: data.userUniqueId, otherUniqueKey: data.idsOfPeers, tags: nil, channelName: data.channelName, preMessage: "")
         HippoFlowManager.shared.showFuguChat(fuguChat)
         completion(true, nil)
      }

   }
   
   public func openChatWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
      checkForIntialization { (success, error) in
         guard success else {
            completion(false, error)
            return
         }
         
         let conVC = ConversationsViewController.getWith(channelID: channelId, channelName: "Group Chat")
         let lastVC = getLastVisibleController()
         lastVC?.present(conVC, animated: true, completion: nil)
      }
   }
   
   func checkForIntialization(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
      
      if let fuguUserId = userDetail?.fuguUserID, fuguUserId > 0 {
         completion(true, nil)
         return
      }
      
      HippoUserDetail.getUserDetailsAndConversation(completion: { (success, error) in
         completion(success, error)
      })
   }
   
   // MARK: - Helpers
   public func switchEnvironment(_ envType: HippoEnvironment) {
      switch envType {
      case .dev:
        baseUrl = "https://hippo-api-dev.fuguchat.com:3011/" //https://beta-api.fuguchat.com/"
        fayeBaseURLString = "https://hippo-api-dev.fuguchat.com:3012/faye"

      default:
         baseUrl = "https://api.fuguchat.com/" /*Live*/
         fayeBaseURLString = "https://api.fuguchat.com:3002/faye"
      }
      FayeConnection.shared.enviromentSwitchedWith(urlString: fayeBaseURLString)
   }
   
   public func clearHippoUserData(completion: ((Bool) -> Void)? = nil) {
      HippoUserDetail.logoutFromHippo(completion: completion)
   }
   
   // MARK: - Push Notification
   
  @objc public func registerDeviceToken(deviceToken: Data) {
      updateDeviceToken(deviceToken: deviceToken)
   }
   
 @objc  public func isHippoNotification(userInfo: [String: Any]) -> Bool {
      if validateFuguRemoteNotification(withUserInfo: userInfo) {
         return HippoFlowManager.shared.toShowInAppNotification(userInfo: userInfo)
      }
      return false
   }
   
 @objc  public func handleRemoteNotification(userInfo: [String: Any]) {
      if validateHippoCredential() == false {
         return
      }
      if validateFuguRemoteNotification(withUserInfo: userInfo) == false {
         return
      }
      
      let visibleController = getLastVisibleController()
    
      UIApplication.shared.clearNotificationCenter()
      
      let channelId = (userInfo["channel_id"] as? Int) ?? -1
      let channelName = (userInfo["label"] as? String) ?? ""
      
      if let conVC = visibleController as? ConversationsViewController {
         if channelId != conVC.channel?.id, channelId > 0 {
            conVC.channel?.delegate = nil
            conVC.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
            conVC.messagesGroupedByDate = []
            conVC.populateTableViewWithChannelData()
            conVC.label = channelName
            conVC.navigationTitleLabel?.text = channelName
            conVC.getMessagesBasedOnChannel(fromMessage: 1, completion: {
               conVC.enableSendingNewMessages()
            })
            
         }
         return
      }
      
      if let allConVC = visibleController as? AllConversationsViewController {
         if channelId > 0 {
            let conVC = ConversationsViewController.getWith(channelID: channelId, channelName: channelName)
            conVC.delegate = allConVC
            allConVC.navigationController?.pushViewController(conVC, animated: true)
         }
         
         return
      }
      
      guard channelId > 0 else {
         HippoConfig.shared.presentChatsViewController()
         return
      }
      
      checkForIntialization { (success, error) in
         guard success else {
            return
         }
         
         let conVC = ConversationsViewController.getWith(channelID: channelId, channelName: channelName)
         visibleController?.present(conVC, animated: true, completion: nil)
      }
      
//      NSLog("PUSH DATA ----->>>>> \(userInfo)")

   }

}
