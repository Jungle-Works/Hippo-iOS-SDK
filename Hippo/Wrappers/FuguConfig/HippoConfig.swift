//
//  HippoConfig.swift
//  SDKDemo1
//
//  Created by Vishal on 01/11/18.
//

import Foundation
import UIKit

#if canImport(HippoCallClient)
  import HippoCallClient
#endif

public protocol HippoMessageRecievedDelegate: class {
    func hippoMessageRecievedWith(response: [String: Any], viewController: UIViewController)
}

enum AppUserType {
    case agent
    case customer
}


struct SERVERS {
    static let liveUrl = "https://api.fuguchat.com/"
    static let liveFaye = "https://api.fuguchat.com:3002/faye"
    
    static let betaUrl = "https://hippo-api-dev.fuguchat.com:3004/"
    static let betaFaye = "https://hippo-api-dev.fuguchat.com:3004/faye"
    
    static let devUrl = "https://hippo-api-dev.fuguchat.com:3011/"
    static let devFaye = "https://hippo-api-dev.fuguchat.com:3012/faye"
}

@objcMembers public class HippoConfig : NSObject {
    
    public static let shared = HippoConfig()
    
    public typealias commonHippoCallback = ((_ success: Bool, _ error: Error?) -> ())
    // MARK: - Properties
    internal var log = CoreLogger(formatter: Formatter.defaultFormat, theme: nil, minLevels: [.all])
    internal var muidList: [String] = []
    internal var pushArray = [PushInfo]()
    
    internal var checker: HippoChecker = HippoChecker()
    
    private(set)  open var isBroadcastEnabled: Bool = false
    open weak var messageDelegate: HippoMessageRecievedDelegate?
    internal weak var delegate: HippoDelegate?
//    internal var deviceToken = ""
//    internal var voipToken = ""
    internal var ticketDetails = HippoTicketAtrributes(categoryName: "")
    internal var theme = HippoTheme.defaultTheme()
    internal var userDetail: HippoUserDetail?
    internal var agentDetail: AgentDetail?
    internal var strings = HippoStrings()
    
    open var isPaymentRequestEnabled: Bool {
        return HippoProperty.current.isPaymentRequestEnabled
    }
    
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
    
    
    
    internal var appUserType = AppUserType.customer
    internal var resellerToken = ""
    internal var referenceId = -1
    internal var appType: String?
    internal var credentialType = FuguCredentialType.defaultType
    
    internal var baseUrl = SERVERS.liveUrl
    internal var fayeBaseURLString: String = SERVERS.liveFaye
    
    open var unreadCount: ((_ totalUnread: Int) -> ())?
    open var usersUnreadCount: ((_ userUnreadCount: [String: Int]) -> ())?
    open var HippoDismissed: ((_ isDismissed: Bool) -> ())?
    
    internal let powererdByColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
    internal let FuguColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    internal let poweredByFont: UIFont = UIFont.systemFont(ofSize: 10.0)
    internal let FuguStringFont: UIFont = UIFont.systemFont(ofSize: 10.0)
    
    
    public let navigationTitleTextAlignMent: NSTextAlignment? = .center
    
    // MARK: - Intialization
    private override init() {
        super.init()
        
        TookanHelper.getCountryCode()
        HippoObservers.shared.enable = true
        FuguNetworkHandler.shared.fuguConnectionChangesStartNotifier()
        CallManager.shared.initCallClientIfPresent()
    }
    
    
    internal func setAgentStoredData() {
        guard let storedData = AgentDetail.agentLoginData else {
            return
        }
        HippoConfig.shared.appUserType = .agent
        HippoConfig.shared.agentDetail = AgentDetail(dict: storedData)
        
        if !HippoConfig.shared.agentDetail!.fuguToken.isEmpty {
            HippoConfig.shared.appUserType = .agent
        }
    }
    
    public func setHippoDelegate(delegate: HippoDelegate?) {
        self.delegate = delegate
    }
    
    @available(*, deprecated, renamed: "setCustomisedHippoTheme", message: "This class will no longer be available, To Continue migrate to setCustomisedHippoTheme")
    public func setCustomisedFuguTheme(theme: HippoTheme) {
        self.theme = theme
    }
    
    public func setCustomisedHippoTheme(theme: HippoTheme) {
        self.theme = theme
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
    public func startOneToOneChat(otherUserEmail: String, completion: @escaping commonHippoCallback) {
        let email = otherUserEmail.trimWhiteSpacesAndNewLine()
        guard email.isValidEmail() else {
            completion(false, HippoError.invalidEmail)
            return
        }
        HippoChecker.checkForAgentIntialization { (success, error) in
            guard success else {
                completion(false, error)
                return
            }
            guard let attributes = AgentDirectChatAttributes(otherUserEmail: email) else {
                completion(false, HippoError.general)
                return
            }
            FuguFlowManager.shared.pushAgentConversationViewController(chatAttributes: attributes)
        }
        
    }
    
    
    public func updateUserDetail(userDetail: HippoUserDetail) {
        self.userDetail = userDetail
        self.appUserType = .customer
        AgentDetail.agentLoginData = nil
        HippoUserDetail.getUserDetailsAndConversation()
    }
    
    public func enableBroadcast() {
        isBroadcastEnabled = true
    }
    public func disableBroadcast() {
        isBroadcastEnabled = false
    }
    
    public class func enablePaymentRequest() {
        HippoProperty.current.updatePaymentRequestStatus(enable: true)
    }
    public class func disablePaymentRequest() {
        HippoProperty.current.updatePaymentRequestStatus(enable: false)
    }
    
    
    public func initManager(agentToken: String, app_type: String, customAttributes: [String: Any]? = nil) {
        let detail = AgentDetail(oAuthToken: agentToken.trimWhiteSpacesAndNewLine(), appType: app_type, customAttributes: customAttributes)
        detail.isForking = true
        self.appUserType = .agent
        self.agentDetail = detail
        AgentConversationManager.updateAgentChannel()
    }
    
    /********
     Key for customAttributes:
     
     bundle_ios_id: String =  bundle id for your app,
     role: Int =  user role example = 01, 02, 03 ...,
     app_name: String =  app name you want to create on Hippo,
     device_type: Int = your device type on your system.
     *******/
    
    public func initManager(authToken: String, app_type: String, customAttributes: [String: Any]? = nil) {
        let detail = AgentDetail(oAuthToken: authToken.trimWhiteSpacesAndNewLine(), appType: app_type, customAttributes: customAttributes)
        self.appUserType = .agent
        self.agentDetail = detail
        AgentConversationManager.updateAgentChannel()
    }
    // MARK: - Open Chat UI Methods
    public func presentChatsViewController() {
        AgentDetail.setAgentStoredData()
        checker.presentChatsViewController()
    }
    class public func showChats(on viewController: UIViewController) {
        AgentDetail.setAgentStoredData()
        HippoConfig.shared.checker.presentChatsViewController(on: viewController)
    }
    
    public func initiateBroadcast(displayName: String = "") {
        guard appUserType == .agent, isBroadcastEnabled else {
            return
        }
        let name = displayName.isEmpty ? HippoConfig.shared.strings.displayNameForCustomers : displayName
        HippoConfig.shared.strings.displayNameForCustomers = name
        FuguFlowManager.shared.presentBroadcastController()
    }
    public func openChatScreen(on viewController: UIViewController? = nil, withLabelId labelId: Int, hideBackButton: Bool = false, animation: Bool = true) {
        guard appUserType == .customer else {
            return
        }
        if let vc = viewController {
            FuguFlowManager.shared.openChatViewController(on: vc, labelId: labelId, hideBackButton: hideBackButton, animation: animation)
        } else {
            FuguFlowManager.shared.openChatViewController(labelId: labelId)
        }
    }
    
    public func setRideTime(estimatedTimeInSec: UInt) {
       let detail = RideDetail(estimatedTime: estimatedTimeInSec)
       RideDetail.current = detail
    }
    
    public func endRide() {
        RideDetail.current = nil
        
        RideDetail.sendRideEndStatus { (success, error) in
            
            if let errorMessage = error?.localizedDescription {
                self.log.error("Hippo SDK ride status cannot be updated on server for error:  \(errorMessage)", level: .error)
            }
        }
        
    }
    
    public func openChatScreen(withTransactionId transactionId: String, tags: [String]? = nil, channelName: String, message: String = "", userUniqueKey: String? = nil, isInAppMessage: Bool = false, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        guard appUserType == .customer else {
            return
        }
        
        // TODO: - check for userUniqueKey and add save user data in cache
        let uniqueKey = userUniqueKey ?? self.userDetail?.userUniqueKey
        
        checkForIntialization { (success, error) in
            guard success else {
                completion(success, error)
                return
            }
            
            var fuguChat = FuguNewChatAttributes(transactionId: transactionId, userUniqueKey: uniqueKey, otherUniqueKey: nil, tags: tags, channelName: channelName, preMessage: message)
            fuguChat.isInAppChat = isInAppMessage
            FuguFlowManager.shared.showFuguChat(fuguChat)
            completion(true, nil)
        }
        
    }
    public func openConversationFor(otherUserUniqueKey: String, channelTitle: String? = nil, transactionId: String? = nil) {
        guard HippoConfig.shared.appUserType == .agent else {
            return
        }
        AgentConversationManager.searchUserUniqueKeys.removeAll()
        AgentConversationManager.searchUserUniqueKeys = [otherUserUniqueKey]
        
        if let tempTransactionID = transactionId, !tempTransactionID.isEmpty {
            AgentConversationManager.transactionID = tempTransactionID.trimWhiteSpacesAndNewLine()
            FuguFlowManager.shared.openDirectAgentConversation(channelTitle: channelTitle)
        } else {
            FuguFlowManager.shared.openDirectConversationHome()
        }
    }
    
    public func getUnreadCountFor(with userUniqueKeys: [String]) {
        UnreadCount.userUniqueKeyList = userUniqueKeys
        AgentConversationManager.getUserUnreadCount()
    }
    public func clearHostNotification() {
        HippoNotification.removeHostNotification()
    }
    public func getUnreadCountFor(userUniqueKey: String) -> Int {
        guard !UnreadCount.unreadCountList.isEmpty else {
            AgentConversationManager.getUserUnreadCount()
            return 0
        }
        
        
        let obj = UnreadCount.unreadCountList[userUniqueKey]
        return obj == nil ? 0 : obj!.count
    }
    
    public func openChatByTransactionId(on viewController: UIViewController? = nil, data: GeneralChat, completion: ((_ success: Bool, _ error: Error?) -> Void)? ) {
        guard appUserType == .customer else {
            return
        }
        
        checkForIntialization { (success, error) in
            guard success else {
                completion?(success, error)
                return
            }
            var fuguChat = FuguNewChatAttributes(transactionId: data.uniqueChatId, userUniqueKey: data.userUniqueId, otherUniqueKey: nil, tags: data.tags, channelName: data.channelName, preMessage: "", groupingTag: data.groupingTags)
            fuguChat.hideBackButton = data.hideBackButton
            if let vc = viewController {
                FuguFlowManager.shared.showFuguChat(on: vc, chat: fuguChat, createConversationOnStart: true)
            } else {
                FuguFlowManager.shared.showFuguChat(fuguChat, createConversationOnStart: true)
            }
            completion?(true, nil)
        }
    }
    
    
    public func showPeerChatWith(data: PeerToPeerChat, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard appUserType == .customer else {
            return
        }
        
        checkForIntialization { (success, error) in
            guard success else {
                completion(success, error)
                return
            }
            let fuguChat = FuguNewChatAttributes(transactionId: data.uniqueChatId ?? "", userUniqueKey: data.userUniqueId, otherUniqueKey: data.idsOfPeers, tags: nil, channelName: data.channelName, preMessage: "")
            FuguFlowManager.shared.showFuguChat(fuguChat, createConversationOnStart: true)
            completion(true, nil)
        }
        
    }
    public func fetchUnreadCountFor(request: PeerToPeerChat, completion: @escaping P2PUnreadCountCompletion) {
        UnreadCount.fetchP2PUnreadCount(request: request, callback: completion)
    }
    
    public func openChatWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        switch appUserType {
        case .agent:
            openCustomerConversationWith(channelId: channelId, completion: completion)
        case .customer:
            openAgentConversationWith(channelId: channelId, completion: completion)
        }
    }
    public func startCall(data: PeerToPeerChat, callType: CallType, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            completion(false, HippoError.networkError)
            return
        }
        guard CallManager.shared.isCallClientAvailable() else {
            log.error(HippoError.callClientNotFound.localizedDescription, level: .error)
            completion(false, HippoError.callClientNotFound)
            return
        }
        guard appUserType == .customer else {
            completion(false, HippoError.threwError(message: "Not Allowed For Hippo Agent"))
            return
        }
        guard ((BussinessProperty.current.isVideoCallEnabled && callType == .video) || (BussinessProperty.current.isAudioCallEnabled && callType == .audio)) else {
            completion(false, HippoError.threwError(message: strings.videoCallDisabledFromHippo))
            return
        }
        
        checkForIntialization { (success, error) in
            guard success else {
                completion(success, error)
                return
            }
            self.findChannelAndStartCall(data: data, callType: callType, completion: completion)
        }
    }
    private func findChannelAndStartCall(data: PeerToPeerChat, callType: CallType, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let uuid: String = String.uuid()
        let peer = User(name: data.peerName, imageURL: data.otherUserImage?.absoluteString, userId: -222)
        CallManager.shared.startConnection(peerUser: peer, muid: uuid, callType: callType, completion: { success in })
        
        let attributes = FuguNewChatAttributes(transactionId: data.uniqueChatId ?? "", userUniqueKey: data.userUniqueId, otherUniqueKey: data.idsOfPeers, tags: nil, channelName: data.channelName, preMessage: "", groupingTag: nil)
        
        HippoChannel.get(withFuguChatAttributes: attributes, completion: {(result) in
            guard result.isSuccessful, let channel = result.channel else {
                CallManager.shared.hungupCall()
                completion(false, HippoError.threwError(message: "Something went wrong while creating channel."))
                return
            }
            let call = CallData.init(peerData: peer, callType: callType, muid: uuid, signallingClient: channel)
            
            CallManager.shared.startCall(call: call, completion: { (success) in
                if !success {
                    CallManager.shared.hungupCall()
                }
                completion(true, nil)
            })
        })
        completion(true, nil)
    }
    internal func openCustomerConversationWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
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
    internal func openAgentConversationWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        completion(false, HippoError.notAllowedForAgent)
//        HippoChecker.checkForAgentIntialization { (success, error) in
//            guard success else {
//                completion(false, error)
//                return
//            }
//
//            let conVC = AgentConversationViewController.getWith(channelID: channelId, channelName: "Channel")
//            let lastVC = getLastVisibleController()
//            lastVC?.present(conVC, animated: true, completion: nil)
//        }
    }
    
    internal func validateLogin(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        switch HippoConfig.shared.appUserType {
        case .customer:
            checkForIntialization(completion: completion)
        case .agent:
            HippoChecker.checkForAgentIntialization(completion: completion)
        }
        
    }
    
    func checkForIntialization(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        if let fuguUserId = HippoUserDetail.fuguUserID, fuguUserId > 0 {
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
            baseUrl = SERVERS.devUrl
            fayeBaseURLString = SERVERS.devFaye
        case .beta:
            baseUrl = SERVERS.betaUrl
            fayeBaseURLString = SERVERS.betaFaye
        case .live:
            baseUrl = SERVERS.liveUrl
            fayeBaseURLString = SERVERS.liveFaye
        }
        FayeConnection.shared.enviromentSwitchedWith(urlString: fayeBaseURLString)
    }
    
    
    @available(*, deprecated, renamed: "clearHippoUserData", message: "This Function is renamed to clearHippoUserData")
    public func clearFuguUserData(completion: ((Bool) -> Void)? = nil) {
        clearHippoUserData(completion: completion)
    }
    
    public func clearHippoUserData(completion: ((Bool) -> Void)? = nil) {
        setAgentStoredData()
        switch appUserType {
        case .agent:
            AgentDetail.LogoutAgent(completion: completion)
        case .customer:
            HippoUserDetail.logoutFromFugu(completion: completion)
        }
    }
    
    public static func setBotGroupID(id: Int) {
        guard  id >= 0  else {
            HippoConfig.shared.log.error("Bot Id Should be greater then zero!!!!", level: .error)
            return
        }
        HippoProperty.setBotGroupID(id: id)
    }
    
    // MARK: - Push Notification
    public func registerVoipDeviceToken(deviceData: Data) {
        guard let token = parseDeviceToken(deviceToken: deviceData) else {
            return
        }
        TokenManager.voipToken = token
        updateDeviceToken(deviceToken: token)
    }
    
    public func registerDeviceToken(deviceToken: Data) {
        guard let token = parseDeviceToken(deviceToken: deviceToken) else {
            return
        }
        TokenManager.deviceToken = token
        updateDeviceToken(deviceToken: token)
    }
    
    public func isHippoNotification(withUserInfo userInfo: [String: Any]) -> Bool {
        if let pushSource = userInfo["push_source"] as? String, (pushSource == "FUGU" || pushSource == "HIPPO") {
            return true
        }
        return false
    }
    public func setStrings(stringsObject: HippoStrings) {
        HippoConfig.shared.strings = stringsObject
    }
    public func showNotification(userInfo: [String: Any]) -> Bool {
        let notificationType = Int.parse(values: userInfo, key: "notification_type") ?? -1
        
        if notificationType == NotificationType.call.rawValue && UIApplication.shared.applicationState != .inactive {
            return false
        }
        
        if HippoConfig.shared.isHippoNotification(withUserInfo: userInfo) {
            return FuguFlowManager.shared.toShowInAppNotification(userInfo: userInfo)
        }
        return false
    }
    
    public func handleVoipNotification(payload: [AnyHashable: Any]) {
        guard let json = payload as? [String: Any] else {
            return
        }
        handleVoipNotification(payloadDict: json)
    }
    public func handleVoipNotification(payloadDict: [String: Any]) {
        CallManager.shared.voipNotificationRecieved(payloadDict: payloadDict)
    }
    
    public func handleRemoteNotification(userInfo: [String: Any]) {
        setAgentStoredData()
        if validateFuguCredential() == false {
            return
        }
        if HippoConfig.shared.isHippoNotification(withUserInfo: userInfo) == false {
            return
        }
        //Check to append all muid of push list
        if let muid = userInfo["muid"] as? String, !HippoConfig.shared.muidList.contains(muid) {
            HippoConfig.shared.muidList.append(muid)
        }
        updateStoredUnreadCountFor(with: userInfo)
        resetForChannel(pushInfo: userInfo)
        pushTotalUnreadCount()
        if let id = userInfo["channelId"], let channelId = Int("\(id)"){
            HippoNotification.removeAllnotificationFor(channelId: channelId)
        }
        //        UIApplication.shared.clearNotificationCenter()
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            handleAgentNotification(userInfo: userInfo)
        case .customer:
            handleCustomerNotification(userInfo: userInfo)
        }
    }
    func handleAgentNotification(userInfo: [String: Any]) {
        let visibleController = getLastVisibleController()
        let channelId = (userInfo["channel_id"] as? Int) ?? -1
        let channelName = (userInfo["label"] as? String) ?? ""
        
        let rawSendingReplyDisabled = (userInfo["disable_reply"] as? Int) ?? 0
        let isSendingDisabled = rawSendingReplyDisabled == 1 ? true : false
        
        guard channelId > 0 else {
            HippoConfig.shared.presentChatsViewController()
            return
        }
        
        if let conVC = visibleController as? AgentConversationViewController {
            if channelId != conVC.channel?.id, channelId > 0 {
                conVC.channel?.delegate = nil
                conVC.channel = AgentChannelPersistancyManager.shared.getChannelBy(id: channelId)
                conVC.messagesGroupedByDate = []
                conVC.populateTableViewWithChannelData()
                conVC.label = channelName
                conVC.navigationItem.title = channelName
                if isSendingDisabled {
                    conVC.disableSendingReply()
                }
                
                conVC.getMessagesBasedOnChannel(fromMessage: 1, pageEnd: nil, completion: {(_) in
                    conVC.enableSendingNewMessages()
                })
                
            }
            return
        }
        
        if let _ = visibleController as? AgentHomeViewController {
            if channelId > 0 {
                FuguFlowManager.shared.pushAgentConversationViewController(channelId: channelId, channelName: channelName)
            }
            return
        }
        
        HippoChecker.checkForAgentIntialization { (success, error) in
            guard success else {
                return
            }
            FuguFlowManager.shared.pushAgentConversationViewController(channelId: channelId, channelName: channelName)
        }
    }
    
    func handleNotificationForChatInfoScreen(with info: [String: Any], lastController: UIViewController) {
        
        
    }
    func handleCustomerNotification(userInfo: [String: Any]) {
        let visibleController = getLastVisibleController()
        
        let channelId = (userInfo["channel_id"] as? Int) ?? -1
        let channelName = (userInfo["label"] as? String) ?? ""
        let labelId = (userInfo["label_id"] as? Int) ?? -1
        
        let rawSendingReplyDisabled = (userInfo["disable_reply"] as? Int) ?? 0
        let isSendingDisabled = rawSendingReplyDisabled == 1 ? true : false
        
        if let conVC = visibleController as? ConversationsViewController {
            if channelId != conVC.channel?.id, channelId > 0 {
                let existingChannelID = conVC.channel?.id ?? -1
                conVC.clearUnreadCountForChannel(id: existingChannelID)
                conVC.channel?.delegate = nil
                conVC.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
                conVC.messagesGroupedByDate = []
                conVC.populateTableViewWithChannelData()
                conVC.label = channelName
                conVC.navigationTitleLabel?.text = channelName
                if isSendingDisabled {
                    conVC.disableSendingReply()
                }
                conVC.getMessagesBasedOnChannel(fromMessage: 1, pageEnd: nil, completion: {(_) in
                    conVC.enableSendingNewMessages()
                })
            } else if labelId > 0 {
                conVC.channel?.delegate = nil
                conVC.messagesGroupedByDate = []
                conVC.tableViewChat.reloadData()
                conVC.label = channelName
                conVC.labelId = labelId
                conVC.navigationTitleLabel?.text = channelName
                if isSendingDisabled {
                    conVC.disableSendingReply()
                }
                conVC.fetchMessagesFrom1stPage()
            }
            return
        }
        
        if let allConVC = visibleController as? AllConversationsViewController {
            if channelId > 0 {
                let conVC = ConversationsViewController.getWith(channelID: channelId, channelName: channelName)
                conVC.delegate = allConVC
                allConVC.navigationController?.pushViewController(conVC, animated: true)
            } else if labelId > 0 {
                let conVC = ConversationsViewController.getWith(labelId: "\(labelId)")
                conVC.delegate = allConVC
                allConVC.navigationController?.pushViewController(conVC, animated: true)
            }
            
            return
        }
        
        guard channelId > 0 || labelId > 0 else {
            HippoConfig.shared.presentChatsViewController()
            return
        }
        
        checkForIntialization { (success, error) in
            guard success else {
                return
            }
            
            if channelId > 0 {
                let conVC = ConversationsViewController.getWith(channelID: channelId, channelName: channelName)
                let navVC = UINavigationController(rootViewController: conVC)
                navVC.isNavigationBarHidden = true
                visibleController?.present(navVC, animated: true, completion: nil)
            } else if labelId > 0 {
                let conVC = ConversationsViewController.getWith(labelId: "\(labelId)")
                let navVC = UINavigationController(rootViewController: conVC)
                navVC.isNavigationBarHidden = true
                visibleController?.present(navVC, animated: true, completion: nil)
            }
        }
    }
}


//MARK: Ticket System Methods
public extension HippoConfig {
    
    /// Opens Ticket Support.
    ///
    /// - Parameter param: HippoTicketAttributes Object.
    func showTicketSupport(with param: HippoTicketAtrributes) {
        guard appUserType == .customer else {
            return
        }
        let temp = param
        temp.FAQName = param.FAQName.trimWhiteSpacesAndNewLine()
        self.ticketDetails = param
        FuguFlowManager.shared.presentNLevelViewController()
    }
}

extension HippoConfig {
    func sendUnreadCount(_ totalCount: Int) {
        HippoConfig.shared.unreadCount?(totalCount)
        HippoConfig.shared.delegate?.hippoUnreadCount(totalCount)
    }
    func notifyUserUnreadCount(_ usersCount: [String: Int]) {
        HippoConfig.shared.usersUnreadCount?(usersCount)
        HippoConfig.shared.delegate?.hippoUserUnreadCount(usersCount)
    }
    func notifiyDeinit() {
        HippoConfig.shared.HippoDismissed?(true)
        HippoConfig.shared.delegate?.hippoDeinit()
    }
    func notifyDidLoad() {
        HippoConfig.shared.HippoDismissed?(false)
        HippoConfig.shared.delegate?.hippoDidLoad()
    }
    
    func broadCastMessage(dict: [String: Any], contoller: UIViewController) {
        HippoConfig.shared.messageDelegate?.hippoMessageRecievedWith(response: dict, viewController: contoller)
        HippoConfig.shared.delegate?.hippoMessageRecievedWith(response: dict, viewController: contoller)
    }
    
    #if canImport(HippoCallClient)
    func notifyCallRequest(_ request: CallPresenterRequest) -> CallPresenter? {
        if HippoConfig.shared.delegate == nil {
           HippoConfig.shared.log.error("To Enable video/Audio CALL, SET  HippoConfig.shared.setHippoDelegate(delegate: HippoDelegate)", level: .error)
        }
        return HippoConfig.shared.delegate?.loadCallPresenterView(request: request)
    }
    #endif
}
