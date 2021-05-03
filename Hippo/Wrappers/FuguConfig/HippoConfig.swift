//
//  HippoConfig.swift
//  SDKDemo1
//
//  Created by Vishal on 01/11/18.
//

import Foundation
import UIKit
import AVFoundation
#if canImport(HippoCallClient)
  import HippoCallClient
 
#endif

#if canImport(JitsiMeet)
import JitsiMeet
#endif

public protocol HippoMessageRecievedDelegate: class {
    func hippoMessageRecievedWith(response: [String: Any], viewController: UIViewController)
}

enum AppUserType {
    case agent
    case customer
}

enum AgentUserType: Int {
    case agent = 11
    case admin = 13
}

struct SERVERS {

static let liveUrl = "https://api.hippochat.io/"
static let liveFaye = "https://socketv2.hippochat.io/faye"

static let betaUrl = "https://beta-live-api.fuguchat.com:3001/"
static let betaFaye = "https://beta-live-api.fuguchat.com:3001/faye"

static let devUrl = "https://hippo-api-dev.fuguchat.com:3004/"
static let devFaye = "https://hippo-api-dev.fuguchat.com:3004/faye"


}

struct BotAction {
    var botId = Int()
    var botName = String()
    var message = String()
    var messageType = MessageType.none
    var contentValues = [[String: Any]]()
    var rawDict = [String: Any]()
    var values = [Any]()

    init(dict: [String: Any]) {
        if let value = dict["bot_id"] as? Int {
            self.botId = value
        }

        if let value = dict["bot_name"] as? String {
            self.botName = value
        }

        if let value = dict["message"] as? String {
            self.message = value
        }

        if let message_type = dict["message_type"] as? Int, let messageType = MessageType(rawValue: message_type) {
            self.messageType = messageType
        }

        if let contentValues = dict["content_value"] as? [[String: Any]] {
            self.contentValues = contentValues
        }

        if let values = dict["values"] as? [Any] {
            self.values = values
        }

        self.rawDict = dict


    }
}

@objcMembers public class HippoConfig : NSObject {
    
    public static var shared = HippoConfig()
    
    public typealias commonHippoCallback = ((_ success: Bool, _ error: Error?) -> ())
    // MARK: - Properties
    internal var log = CoreLogger(formatter: Formatter.defaultFormat, theme: nil, minLevels: [.all])
    internal var muidList: [String] = []
    internal var pushArray = [PushInfo]()
    internal var checker: HippoChecker = HippoChecker()
    private(set)  open var isBroadcastEnabled: Bool = false
    open weak var messageDelegate: HippoMessageRecievedDelegate?
    internal weak var delegate: HippoDelegate?
    internal var deviceToken = ""
    internal var voipToken = ""
    internal var ticketDetails = HippoTicketAtrributes(categoryName: "")
    internal var theme = HippoTheme.defaultTheme()
    internal var userDetail: HippoUserDetail?
    internal var jitsiUrl : String?
    internal var jitsiOngoingCall : Bool?
    internal var agentDetail: AgentDetail?
    public var strings = HippoStrings()
    private(set)  open var newConversationButtonBorderWidth: Float = 0.0

    private(set)  open var isSuggestionNeeded = false
    private(set)  open var maxSuggestionCount = 10
    private(set)  open var questions = [String: Int]()//Dictionary<String, Int>()
    private(set)  open var suggestions = [Int: String]()//Dictionary<Int, String>()
    private(set)  open var mapping = [Int: [Int]]()//Dictionary<Int, Array<Int>>()
    
    private(set)  open var hasChannelTabs = true//false
    
    open var isPaymentRequestEnabled: Bool {
        return HippoProperty.current.isPaymentRequestEnabled
    }
    internal var groupCallData: [String : Any] {
         get {
            guard let groupCallData = UserDefaults.standard.value(forKey: Fugu_groupCallData) as? [String : Any] else {
                 return [String : Any]()
             }
             return groupCallData
         }
         set {
             UserDefaults.standard.set(newValue, forKey: Fugu_groupCallData)
         }
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
    
    
    open var appName: String = ""
    internal var appUserType = AppUserType.customer
    internal var resellerToken = ""
    internal var referenceId = -1
    internal var appType: String?
    internal var credentialType = FuguCredentialType.defaultType
    var isSkipBot:Bool = false
    internal var baseUrl =      SERVERS.liveUrl     // SERVERS.betaUrl//
    internal var fayeBaseURLString: String =     SERVERS.liveFaye   // SERVERS.betaFaye//
    open var unreadCount: ((_ totalUnread: Int) -> ())?
    open var usersUnreadCount: ((_ userUnreadCount: [String: Int]) -> ())?
    open var HippoDismissed: ((_ isDismissed: Bool) -> ())?
    open var HippoPrePaymentCancelled: (()->())?
    open var HippoPrePaymentSuccessful: ((Bool)->())?
    public var HippoLanguageChanged : ((Error?)->())?
    public var HippoSessionStatus: ((GroupCallStatus)->())?
    public var announcementUnreadCount : ((Int)->())?

    var supportChatFilter : [SupportFilter]?

    public var hideTabbar : ((Bool)->())?
    
    internal let powererdByColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
    internal let FuguColor = #colorLiteral(red: 0.3843137255, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    internal let poweredByFont: UIFont = UIFont.regular(ofSize: 10.0)
    internal let FuguStringFont: UIFont = UIFont.regular(ofSize: 10.0)
    var socketsFailed : Bool?
    
    public let navigationTitleTextAlignMent: NSTextAlignment? = .center
    public var shouldOpenDefaultChannel = true
    public var shouldUseNewCalling : Bool?{
        didSet{
            versionCode = 350
        }
    }
    public var shouldUseNewCallingWithCallkit : Bool?{
        didSet{
            versionCode = 450
        }
    }
    
    internal let listener = SocketListner()
    ///turn its value true to show slow internet bar on chat screen
    public var shouldShowSlowInternetBar : Bool?
    
    var isOpenedFromPush : Bool?

    // MARK: - Intialization
    private override init() {
        super.init()
        
        TookanHelper.getCountryCode()
        HippoObservers.shared.enable = true
        FuguNetworkHandler.shared.fuguConnectionChangesStartNotifier()
        CallManager.shared.initCallClientIfPresent()
        
    }
    
    //MARK:- Function to pass Deep link Dic
    //Function is called on click of deep link form promotion view controller
    func getDeepLinkData(_ data : [String : Any]){
        HippoConfig.shared.delegate?.deepLinkClicked(response: data)
    }
    
    //Function to get current channel id
    public func getCurrentChannelId()->Int?{
        if currentUserType() == .customer{
            let topViewController = getLastVisibleController()
            //will return channel id if we have some active chat else return nil
            if topViewController is ConversationsViewController{
                return (topViewController as? ConversationsViewController)?.channelId
            }
        }else{
            let topViewController = getLastVisibleController()
            //will return channel id if we have some active chat else return nil
            if topViewController is AgentConversationViewController{
                return (topViewController as? AgentConversationViewController)?.channelId
            }
        }
        return nil
    }
    
    //Function to get current agent sdk channel id
    open func getCurrentAgentSdkChannelId()->Int?{
        let topViewController = getLastVisibleController()
        //will return channel id if we have some active chat else return nil
        if topViewController is AgentConversationViewController{
            return (topViewController as? AgentConversationViewController)?.channelId
        }
        return nil
    }
    
    public func callMissedFromUser(userInfo : [String : Any]){
        if userInfo["notification_type"] as? Int == NotificationType.call.rawValue{
            CallManager.shared.voipNotificationRecieved(payloadDict: userInfo)
        }
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
    
    public func setAppName(withAppName appName: String) {
        guard appName.isEmpty else {
            self.appName = appName
            return
        }
        guard let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String else {
            self.appName = ""
            return
        }
        self.appName = name
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
    
    func getAllStrings(){
        AllString.getAllStrings{(error,response) in
            self.HippoLanguageChanged?(error)
            if error == nil{
                if self.appUserType == .customer{
                    AllString.updateLanguageApi()
                }else{
                    let status = AgentStatus.allCases.filter{$0.rawValue == BussinessProperty.current.agentStatusForToggle}
                    AgentConversationManager.agentStatusUpdate(newStatus: status.first ?? .available, completion: {_ in })
                }
            }
        }
    }
    
    
    public static func setSkipBot(enable: Bool, reason: String) {
        HippoProperty.current.skipBot = enable
        HippoProperty.current.skipBotReason = reason
    }
    
    public func updateUserDetail(userDetail: HippoUserDetail) {
        self.userDetail = userDetail
        self.appUserType = .customer
        AgentDetail.agentLoginData = nil
        HippoUserDetail.getUserDetailsAndConversation { (status, error) in
            if (self.userDetail?.selectedlanguage ?? "") == ""{
               self.userDetail?.selectedlanguage = BussinessProperty.current.buisnessLanguageArr?.filter{$0.is_default == true}.first?.lang_code
            }
            self.setLanguage(self.userDetail?.selectedlanguage ?? "en")
        }
    }
    
    public func enableBroadcast() {
        isBroadcastEnabled = true
    }
    public func disableBroadcast() {
        isBroadcastEnabled = false
    }
    
//    public func showNewConversationButton() {
//        isNewConversationButtonHidden = false
//    }
//    public func hideNewConversationButton() {
//        isNewConversationButtonHidden = true
//    }
    
    public func refreshUnreadCount(){
        if socketsFailed ?? false && currentUserType() == .agent{
            UnreadCount.getAgentTotalUnreadCount { (result) in
            
            }
            if getLastVisibleController() is AgentHomeViewController{
              AgentConversationManager.getAllData()
            }
            socketsFailed = false
        }
    }
    
    public func isSuggestionNeeded(setValue: Bool) {
        isSuggestionNeeded = setValue
    }
    public func setMaxSuggestionCount(maxSuggestionCount: Int) {
        self.maxSuggestionCount = maxSuggestionCount
    }
    public func setSuggestionQuestionsData(questions: [String: Int]) {
        self.questions = questions
    }
    public func setSuggestionAnswersData(suggestions: [Int: String]) {
        self.suggestions = suggestions
    }
    public func setSuggestionMappingData(mapping: [Int: [Int]]) {
        self.mapping = mapping
    }
    
    public func hasChannelTabs(setValue: Bool) {
        hasChannelTabs = setValue
    }
//    public func setEmptyChannelListText(text: String) {
//        emptyChannelListText = text
//    }
    
    public func showNewConversationButtonBorderWithWidth(borderWidth:Float = 1.0) {
        newConversationButtonBorderWidth = borderWidth
    }
    public func hideNewConversationButtonBorder() {
        newConversationButtonBorderWidth = 0.0
    }
    
    public class func enablePaymentRequest() {
        HippoProperty.current.updatePaymentRequestStatus(enable: true)
    }
    public class func disablePaymentRequest() {
        HippoProperty.current.updatePaymentRequestStatus(enable: false)
    }
    
    public static func setTicketCustomAttributes(attributes: [String: Any]?)  {
        HippoProperty.current.ticketCustomAttributes = attributes
    }
    
    public func initManager(agentToken: String, app_type: String, customAttributes: [String: Any]? = nil,selectedLanguage : String? = nil, completion: @escaping HippoResponseRecieved) {
        let detail = AgentDetail(oAuthToken: agentToken.trimWhiteSpacesAndNewLine(), appType: app_type, customAttributes: customAttributes, userId: agentDetail?.id)
        detail.isForking = true
        self.appUserType = .agent
        self.agentDetail = detail
        AgentConversationManager.updateAgentChannel(completion: {(error,response) in
            if (selectedLanguage ?? "") == ""{ self.setLanguage(BussinessProperty.current.buisnessLanguageArr?.filter{$0.is_default == true}.first?.lang_code ?? "")
            }
            completion(error,response)
        })
    }
    
    /********
     Key for customAttributes:
     
     bundle_ios_id: String =  bundle id for your app,
     role: Int =  user role example = 01, 02, 03 ...,
     app_name: String =  app name you want to create on Hippo,
     device_type: Int = your device type on your system.
     *******/
    
    public func initManager(authToken: String, app_type: String, customAttributes: [String: Any]? = nil, selectedLanguage : String? = nil, completion: @escaping HippoResponseRecieved) {
        let detail = AgentDetail(oAuthToken: authToken.trimWhiteSpacesAndNewLine(), appType: app_type, customAttributes: customAttributes, userId: self.agentDetail?.id)
        self.appUserType = .agent
        self.agentDetail = detail
        AgentConversationManager.updateAgentChannel(completion: {(error,response) in
            if (selectedLanguage ?? "") == ""{ self.setLanguage(BussinessProperty.current.buisnessLanguageArr?.filter{$0.is_default == true}.first?.lang_code ?? "en")
                completion(error,response)
                return
            }
            self.setLanguage(selectedLanguage ?? "en")
            completion(error,response)
        })
    }
    // MARK: - Open Chat UI Methods
    public func presentChatsViewController() {
        AgentDetail.setAgentStoredData()
        checker.presentChatsViewController()
    }
    public func getAgentChatVC() -> UIViewController?{
         guard HippoConfig.shared.appUserType == .agent else {
             return nil
         }
         guard let nav = AgentHomeViewController.get() else {
             return nil
         }
         return nav.viewControllers.first
     }

    public func getCustomerChatVC() -> UINavigationController?{
        guard HippoConfig.shared.appUserType == .customer else {
            return nil
        }
        guard let navigationController = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle).instantiateViewController(withIdentifier: "FuguCustomerNavigationController") as? UINavigationController else {
            return nil
        }
        (navigationController.viewControllers.first as? AllConversationsViewController)?.shouldHideBackBtn = true
        
        return navigationController
    }
    
    
    
    func presentPrePaymentController(){
        
    }
    
    class public func showChats(on viewController: UIViewController) {
        AgentDetail.setAgentStoredData()
        HippoConfig.shared.checker.presentChatsViewController(on: viewController)
    }
    
    public func consultNowButtonClicked(consultNowInfoDict: [String: Any]){
        FuguFlowManager.shared.consultNowButtonClicked(consultNowInfoDict: consultNowInfoDict)
    }
    
    public func presentPromotionalPushController(){
        FuguFlowManager.shared.presentPromotionalpushController()
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
            //FuguFlowManager.shared.openChatViewController(labelId: labelId)
            FuguFlowManager.shared.openChatViewControllerTempFunc(labelId: labelId)
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
        
        if let tempTransactionID = transactionId, !tempTransactionID.isEmpty, !otherUserUniqueKey.isEmpty {
            AgentConversationManager.transactionID = tempTransactionID.trimWhiteSpacesAndNewLine()
            FuguFlowManager.shared.openDirectAgentConversation(channelTitle: channelTitle)
        } else {
            if let tempTransactionID = transactionId, !tempTransactionID.isEmpty {
                AgentConversationManager.transactionID = tempTransactionID.trimWhiteSpacesAndNewLine()
                FuguFlowManager.shared.openDirectAgentConversation(channelTitle: channelTitle)
            } else {
                FuguFlowManager.shared.openDirectConversationHome()
            }
        }
    }
    
    public func fetchAddedPaymentGatewaysData() -> [PaymentGateway]? {
        if let addedPaymentGatewaysData = FuguDefaults.object(forKey: DefaultName.addedPaymentGatewaysData.rawValue) as? [[String: Any]]{
            let addedPaymentGatewaysArr = PaymentGateway.parse(addedPaymentGateways: addedPaymentGatewaysData)
            return addedPaymentGatewaysArr
        }else{
            return nil
        }
    }
    
    public func openPrePayment(paymentGatewayId : Int, paymentType : Int?, prePaymentDic: [String : Any], completion: @escaping PrePaymentCompletion){
        PrePayment.callPrePaymentApi(paymentGatewayId: paymentGatewayId, paymentType : paymentType, prePaymentDic: prePaymentDic, completion: completion)
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
    
    public func getUnreadCountForAgent(){
        UnreadCount.getAgentTotalUnreadCount { (result) in
        
        }
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
    
    public func registerNewChannelId(_ transactionId: String, _ channelId : Int){
        if P2PUnreadData.shared.getData(with: transactionId) == nil{
            //P2PUnreadData.shared.updateChannelId(transactionId: transactionId, channelId: channelId, count: 1)
        }
    }
    
    public func openChatWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        switch appUserType {
        case .agent:
            openAgentConversationWith(channelId: channelId, completion: completion)
        case .customer:
            openCustomerConversationWith(channelId: channelId, completion: completion)
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
                completion(false, HippoError.threwError(message: HippoStrings.somethingWentWrong))
                return
            }
            let call = CallData.init(peerData: peer, callType: callType, muid: uuid, signallingClient: channel)
  
//            CallManager.shared.startCall(call: call, completion: { (success)  in
//                if !success {
//                    CallManager.shared.hungupCall()
//                }
//                completion(true, nil)
//            })
            CallManager.shared.startCall(call: call, completion: { (success,error)  in
                if !success {
                    CallManager.shared.hungupCall()
                }
                completion(true, nil)
            })
            
        })
        completion(true, nil)
    }
    public func startCallToAgent(data: PeerToPeerChat, agentEmail: String, callType: CallType, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
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
        
        guard agentEmail != "" else {
            completion(false, HippoError.threwError(message: "Agent email is required"))
            return
        }
        
        checkForIntialization { (success, error) in
            guard success else {
                completion(success, error)
                return
            }
            self.findChannelAndStartCallToAgent(data: data, agentEmail: agentEmail, callType: callType, completion: completion)
        }
    }
    private func findChannelAndStartCallToAgent(data: PeerToPeerChat, agentEmail: String, callType: CallType, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let uuid: String = String.uuid()
        let peer = User(name: data.peerName, imageURL: data.otherUserImage?.absoluteString, userId: -222)
        CallManager.shared.startConnection(peerUser: peer, muid: uuid, callType: callType, completion: { success in })
        let attributes = FuguNewChatAttributes(transactionId: data.uniqueChatId ?? "", userUniqueKey: nil, otherUniqueKey: [data.userUniqueId], tags: nil, channelName: data.channelName, preMessage: "", groupingTag: nil)
        HippoChannel.getToCallAgent(withFuguChatAttributes: attributes, agentEmail: agentEmail, completion: {(result) in
            guard result.isSuccessful, let channel = result.channel else {
                CallManager.shared.hungupCall()
                completion(false, HippoError.threwError(message: HippoStrings.somethingWentWrong))
                return
            }
            let call = CallData.init(peerData: peer, callType: callType, muid: uuid, signallingClient: channel)
  
//            CallManager.shared.startCall(call: call, completion: { (success)  in
//                if !success {
//                    CallManager.shared.hungupCall()
//                }
//                completion(true, nil)
//            })
            CallManager.shared.startCall(call: call, completion: { (success,error)  in
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
            lastVC?.modalPresentationStyle = .fullScreen
            lastVC?.present(conVC, animated: true, completion: nil)
        }
    }
    internal func openAgentConversationWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        HippoChecker.checkForAgentIntialization { (success, error) in
            guard success else {
                completion(false, error)
                return
            }

            let conVC = AgentConversationViewController.getWith(channelID: channelId, channelName: "")
            let lastVC = getLastVisibleController()
            let navVC = UINavigationController(rootViewController: conVC)
            navVC.setTheme()
            navVC.modalPresentationStyle = .fullScreen
            lastVC?.present(navVC, animated: true, completion: nil)
        }
    }
    public func openAgentChatWith(channelId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
            HippoChecker.checkForAgentIntialization { (success, error) in
                guard success else {
                    completion(false, error)
                    return
                }
                guard channelId > 0 else {
                    completion(false, HippoError.invalidInputData)
                    return
                }
                FuguFlowManager.shared.pushAgentConversationViewController(channelId: channelId, channelName: "")
            }
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
    
    //MARK:- Set Language
    
    public func setLanguage(_ code : String){
        if BussinessProperty.current.buisnessLanguageArr?.contains(where: {$0.lang_code == code}) ?? false{
            UserDefaults.standard.set(code, forKey: DefaultName.selectedLanguage.rawValue)
            getAllStrings()
        }else if BussinessProperty.current.buisnessLanguageArr?.contains(where: {$0.lang_code == code}) ?? false == false{
            let defaultLang = BussinessProperty.current.buisnessLanguageArr?.filter{$0.is_default == true}.first?.lang_code
            UserDefaults.standard.set(defaultLang, forKey: DefaultName.selectedLanguage.rawValue)
            getAllStrings()
        }
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
//        FayeConnection.shared.enviromentSwitchedWith(urlString: fayeBaseURLString)
        SocketClient.shared.connect()
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
//            print("customerLogout")
        }
    }
    
    public static func setBotGroupID(id: Int) {
        guard  id >= 0  else {
            HippoConfig.shared.log.error("Bot Id Should be greater then zero!!!!", level: .error)
            return
        }
        HippoProperty.setBotGroupID(id: id)
    }
    
    public func selectedPaymentPlanType(type: [Int]) {
        HippoProperty.setPaymentPlanType(type: type)
    }
    
    
    public func setNewConversationBotGroupId(botGroupId: String){
        HippoProperty.setNewConversationBotGroupId(botGroupId: botGroupId)
    }
    
    // MARK: - Push Notification
    public func registerVoipDeviceToken(deviceData: Data) {
        guard let token = parseDeviceToken(deviceToken: deviceData) else {
            return
        }
        guard TokenManager.voipToken != token else  {
            log.debug("rejected", level: .custom)
            return
        }
        TokenManager.voipToken = token
       // updateDeviceToken(deviceToken: token)
    }
    
    public func getDeviceTokenKey() -> String {
        return TokenManager.StoreKeys.normalToken
    }
    
    public func getVoipDeviceTokenKey() -> String {
        return TokenManager.StoreKeys.voipToken
    }
    
    public func registerDeviceToken(deviceToken: Data) {
        log.debug("registerDeviceToken:\(deviceToken)", level: .custom)
        guard let token = parseDeviceToken(deviceToken: deviceToken) else {
            //showAlertWith(message: "cannot parse tokan, error in parsing", action: nil)
            return
        }
        log.debug("registerDeviceToken parsing token:\(token)", level: .custom)
//        guard TokenManager.deviceToken != token else  {
//            log.debug("rejected", level: .custom)
//            return
//        }
        TokenManager.deviceToken = token
        log.debug("registerDeviceToken save token:\(TokenManager.deviceToken)", level: .custom)
        //updateDeviceToken(deviceToken: token)
        //showAlertWith(message: "Device Tokan saved", action: nil)
    }
    
    func checkForChannelSubscribe(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        if let hippoUserChannelId = HippoUserDetail.HippoUserChannelId {
            guard isSubscribed(userChannelId: hippoUserChannelId) else {
                subscribeCustomerUserChannel(userChannelId: hippoUserChannelId)
                completion(false, nil)
                return
            }
            completion(true, nil)
            return
        }
    }
    
    
    public func isHippoUserChannelSubscribe() -> Bool {
        var checkStatus = false
        self.checkForChannelSubscribe(completion: { (success, error) in
           checkStatus = success
        })
        
        return checkStatus
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
    
    public func managePromotionOrP2pCount(_ userInfo: [String:Any]){
        if userInfo["is_announcement_push"] as? Bool == true, let channel_id = userInfo["channel_id"] as? Int{
            if !(getLastVisibleController() is PromotionsViewController){
                if var channelArr = UserDefaults.standard.value(forKey: DefaultName.announcementUnreadCount.rawValue) as? [String]{
                    if !channelArr.contains(String(channel_id)){
                        channelArr.append(String(channel_id))
                    }
                    UserDefaults.standard.set(channelArr, forKey: DefaultName.announcementUnreadCount.rawValue)
                    HippoConfig.shared.announcementUnreadCount?(channelArr.count)
                }
            }else{
                let visibleController = getLastVisibleController()
                if let promotionVC = visibleController as? PromotionsViewController {
                    promotionVC.getDataOrUpdateAnnouncement([channel_id], isforReadMore: false)
                }
                HippoNotification.removeAllAnnouncementNotification()
            }
        }else{
            if let data = P2PUnreadData.shared.getData(with: userInfo["chat_transaction_id"] as? String ?? ""), let otherUserUniqueKey = ((userInfo["user_unique_key"] as? [String])?.filter{$0 != HippoConfig.shared.userDetail?.userUniqueKey}.first){
                if (data.channelId ?? -1) < 0, otherUserUniqueKey != ""{
                    let id = ((userInfo["chat_transaction_id"] as? String ?? "") + "-" + otherUserUniqueKey)
                    if data.id == id{
                       P2PUnreadData.shared.updateChannelId(transactionId: userInfo["chat_transaction_id"] as? String ?? "", channelId: userInfo["channel_id"] as? Int ?? -1, count: 1, muid: userInfo["muid"] as? String ?? "", otherUserUniqueKey: otherUserUniqueKey)
                        
                    }
                }else if (data.channelId ?? -1) < 0{
                    P2PUnreadData.shared.updateChannelId(transactionId: userInfo["chat_transaction_id"] as? String ?? "", channelId: userInfo["channel_id"] as? Int ?? -1, count: 1, muid: userInfo["muid"] as? String ?? "", otherUserUniqueKey: nil)
                }
            }
        }
    }
    public func showNotification(userInfo: [String: Any]) -> Bool {
        let notificationType = Int.parse(values: userInfo, key: "notification_type") ?? -1
        
        if notificationType == NotificationType.call.rawValue && UIApplication.shared.applicationState != .inactive {
            return false
        }
        
        if notificationType == NotificationType.call.rawValue && jitsiOngoingCall == true{
            return false
        }
        
        if HippoConfig.shared.isHippoNotification(withUserInfo: userInfo) {
            return FuguFlowManager.shared.toShowInAppNotification(userInfo: userInfo)
        }
        return false
    }
    

    public func handleVoipNotification(payload: [AnyHashable: Any], completion: @escaping () -> Void) {
        guard let json = payload as? [String: Any] else {
            return
        }
        
        //HippoNotification.showLocalNotificationForVoip(json)
        self.handleVoipNotification(payloadDict: json, completion: completion)
        
    }
        
    public func handleVoipNotification(payloadDict: [String: Any], completion: @escaping () -> Void) {
        
        if let messageType = payloadDict["message_type"] as? Int, messageType == MessageType.groupCall.rawValue{
            CallManager.shared.voipNotificationRecievedForGroupCall(payloadDict: payloadDict)
        }else if let messageType = payloadDict["message_type"] as? Int, messageType == MessageType.call.rawValue {
            CallManager.shared.voipNotificationRecieved(payloadDict: payloadDict)
        }
        reportIncomingCallOnCallKit(userInfo: payloadDict, completion: completion)
    }
    
    func reportIncomingCallOnCallKit(userInfo: [String : Any], completion: @escaping () -> Void){
        #if canImport(JitsiMeet)
        enableAudioSession()
        if let uuid = userInfo["muid"] as? String, let name = userInfo["last_sent_by_full_name"] as? String, let isVideo = userInfo["call_type"] as? String == "AUDIO" ? false : true{
            guard let UUID = UUID(uuidString: uuid) else {
                return
            }
            if JMCallKitProxy.hasActiveCallForUUID(uuid){
                completion()
                return
            }
            JMCallKitProxy.reportNewIncomingCall(UUID: UUID, handle: name, displayName: name, hasVideo: isVideo) { (error) in
                completion()
            }
        }
        #endif
      }
    
    func enableAudioSession(){
         do{
             try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.videoChat, options: .mixWithOthers)
             try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
             try AVAudioSession.sharedInstance().setActive(true)
         }catch {
             print ("\(#file) - \(#function) error: \(error.localizedDescription)")
         }
     }
    
    public func handleRemoteNotification(userInfo: [String: Any]) {
        setAgentStoredData()
        if validateFuguCredential() == false {
            return
        }
        if HippoConfig.shared.isHippoNotification(withUserInfo: userInfo) == false {
            return
        }
        
        if let announcementPush = userInfo["is_announcement_push"] as? Int, announcementPush == 1 {
            self.isOpenedFromPush = true
            self.handleAnnouncementsNotification(userInfo: userInfo)
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
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            handleAgentNotification(userInfo: userInfo)
        case .customer:
            handleCustomerNotification(userInfo: userInfo)
        }
    }
    
    
    func handleAnnouncementsNotification(userInfo: [String: Any]) {
            let visibleController = getLastVisibleController()
            if let _ = visibleController as? PromotionsViewController {
//                HippoNotification.promotionPushDic.removeAll()
//                if let promotion = PromotionCellDataModel(pushDic: userInfo){
//                    HippoNotification.promotionPushDic.append(promotion)
//                }
//                HippoNotification.getAllAnnouncementNotifications()
                //promotionsVC.callGetAnnouncementsApi()
                return
            }else{
//                checkForIntialization {[weak self] (success, error) in
//                    guard success else {
//                        return
//                    }
                    if let promotion = PromotionCellDataModel(pushDic: userInfo){
                        HippoNotification.promotionPushDic[promotion.channelID] = promotion
                        HippoNotification.getAllAnnouncementNotifications{[weak self]() in
                            DispatchQueue.main.async {
                                self?.presentPromotionalPushController()
                            }
                        }
                    }
  //                  return
 //               }
            }
        }
    
    
    func handleAgentNotification(userInfo: [String: Any]) {
        
        let visibleController = getLastVisibleController()
        let channelId = (userInfo["channel_id"] as? Int) ?? -1
        let channelName = (userInfo["label"] as? String) ?? ""
      //  let channel_Type = (userInfo["channel_type"] as? Int) ?? -1

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
        let channel_Type = (userInfo["channel_type"] as? Int) ?? -1
        
        let rawSendingReplyDisabled = (userInfo["disable_reply"] as? Int) ?? 0
        let isSendingDisabled = rawSendingReplyDisabled == 1 ? true : false
        
        if let conVC = visibleController as? ConversationsViewController {
            
            if channel_Type == channelType.BROADCAST_CHANNEL.rawValue {
                conVC.channel?.delegate = nil
                conVC.messagesGroupedByDate = []
                conVC.tableViewChat.reloadData()
                conVC.label = channelName
                conVC.labelId = labelId
                conVC.channel = nil
                conVC.fetchMessagesFrom1stPage()
            } else if channelId != conVC.channel?.id, channelId > 0 {
                let existingChannelID = conVC.channel?.id ?? -1
                conVC.clearUnreadCountForChannel(id: existingChannelID)
                conVC.channel?.delegate = nil
                conVC.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
                conVC.messagesGroupedByDate = []
                conVC.populateTableViewWithChannelData()
                conVC.label = channelName
//                conVC.navigationTitleLabel?.text = channelName
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
//                conVC.navigationTitleLabel?.text = channelName
                if isSendingDisabled {
                    conVC.disableSendingReply()
                }
                conVC.fetchMessagesFrom1stPage()
            }
            return
        }
        
        if let allConVC = visibleController as? AllConversationsViewController {
            
             if channel_Type == channelType.BROADCAST_CHANNEL.rawValue {
                let conVC = ConversationsViewController.getWith(labelId: "\(labelId)")
                conVC.delegate = allConVC
                allConVC.navigationController?.pushViewController(conVC, animated: true)
                
            } else if channelId > 0 {
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
            
            if channel_Type == channelType.BROADCAST_CHANNEL.rawValue {
                   let conVC = ConversationsViewController.getWith(labelId: "\(labelId)")
                   let navVC = UINavigationController(rootViewController: conVC)
                   navVC.isNavigationBarHidden = true
                   navVC.modalPresentationStyle = .fullScreen
                   visibleController?.present(navVC, animated: true, completion: nil)
               } else if channelId > 0 {
                   let conVC = ConversationsViewController.getWith(channelID: channelId, channelName: channelName)
                   let navVC = UINavigationController(rootViewController: conVC)
                   navVC.isNavigationBarHidden = true
                   navVC.modalPresentationStyle = .fullScreen
                   visibleController?.present(navVC, animated: true, completion: nil)
               } else if labelId > 0 {
                   let conVC = ConversationsViewController.getWith(labelId: "\(labelId)")
                   let navVC = UINavigationController(rootViewController: conVC)
                   navVC.isNavigationBarHidden = true
                   navVC.modalPresentationStyle = .fullScreen
                   visibleController?.present(navVC, animated: true, completion: nil)
               }
        }
    }
}

extension HippoConfig{
    
    public func getPaymentGateways(_ appSecretKey : String, completion: @escaping (Bool) -> Void){
        HippoConfig.shared.appSecretKey = appSecretKey
        HippoUserDetail.getPaymentGateway(completion: completion)
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

extension HippoConfig{
    //MARK:- Create channel for group calling
    /// - Get data from parent app  as GroupCallModel for create new channel for group calling
   
    public func createGroupCallChannel(request: GroupCallModel, callback: @escaping HippoResponseRecieved){
        GroupCall.createGroupCallChannel(request: request, callback: callback)
    }
    
    public func joinGroupCall(request: GroupCallModel, callback: @escaping HippoResponseRecieved){
        GroupCall.getGroupCallChannelDetails(request: request, callback: callback)
    }
    
    public func restoreSession(_ transactionId : String){
         groupCallData.removeValue(forKey: transactionId)
    }
    
   
    public func forceKillOnTermination(){
        #if canImport(JitsiMeet)
        HippoCallClient.shared.terminateSessionIfAny()
        #endif
    }
    
    public func keyWindowChangedFromParent(){
        #if canImport(JitsiMeet)
        HippoCallClient.shared.keyWindowChangedFromParent()
        #endif
    }
}
extension HippoConfig {
    func sendp2pUnreadCount(_ unreadCount : Int, _ channelId : Int){
        HippoConfig.shared.delegate?.sendp2pUnreadCount(unreadCount: unreadCount,channelId: channelId)
    }
    
    func sendDataIfChatIsAssignedToSelfAgent(_ dic : [String : Any]){
        HippoConfig.shared.delegate?.sendDataIfChatIsAssignedToSelfAgent(dic)
    }
    
    func sendAgentUnreadCount(_ totalCount: Int) {
       // showAlertWith(message: "\(totalCount)", action: nil)
        HippoConfig.shared.delegate?.hippoAgentTotalUnreadCount(totalCount)
        print("sendAgentUnreadCount====================",totalCount)
    }
    
    func sendAgentChannelsUnreadCount(_ totalCount: Int) {        HippoConfig.shared.delegate?.hippoAgentTotalChannelsUnreadCount(totalCount)
        print("sendAgentChannelsUnreadCount====================",totalCount)
    }
    
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
extension HippoConfig{
    
    func HideJitsiView(){
         #if canImport(JitsiMeet)
            HippoCallClient.shared.hideViewInPip()
         #endif
    }
    
    func UnhideJitsiView(){
         #if canImport(JitsiMeet)
            HippoCallClient.shared.unHideViewInPip()
         #endif
    }
}
extension HippoConfig{
    public func createSupportChat(o2oModel : O2OChatModel){
        O2OChat.createO2OChat(request: o2oModel) { (error, data) in
            
        }
    }
    
    public func openSupportChatListing(){
        let supportChatVC = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle).instantiateViewController(withIdentifier: "SupportChatViewController") as! SupportChatViewController
        guard let topVC = getLastVisibleController() else { return }
        let navVC = UINavigationController(rootViewController: supportChatVC)
        navVC.setTheme()
        navVC.navigationBar.isHidden = true
        navVC.modalPresentationStyle = .fullScreen
        topVC.present(navVC, animated: true, completion: nil)
    }
}



