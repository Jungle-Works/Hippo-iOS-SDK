//
//  HippoConversationViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 30/08/18.
//

import UIKit
import Photos
import QuickLook
import SafariServices

class HippoConversationViewController: UIViewController {
    //MARK: Constants
    let heightOfActionableMessageImage = 103.5
    let textViewFixedHeight = 50
    let heightOfDateLabel: CGFloat = 40
    
    // MARK: - PROPERTIES
    var processingRequestCount = 0
    var labelId = -11
    var forceDisableReply: Bool = false
    var forceHideActionButton: Bool = false
    var botGroupID: Int?
    
    
    var storeRequest: MessageStore.messageRequest?
    var storeResponse: MessageStore.ChannelMessagesResult?
    var isFirstResponseComplete: Bool = false
    
    var directChatDetail: FuguNewChatAttributes?
    var agentDirectChatDetail: AgentDirectChatAttributes?
    var label = ""
    var userImage: String?
    var imagePicker = UIImagePickerController()
    var keyBoard: KeyBoard?
    weak var delegate: NewChatSentDelegate?
    weak var agentConversationDelegate: AgentChatDeleagate?
    var navigationTitleButton: UIButton?
    
    var heightForFeedBackCell: [String: CGFloat] = [:] //[muid: height]
    var typingMessageValue = TypingMessage.messageRecieved.rawValue
    var textInTextField = ""
    var timer = Timer()
    var isTypingLabelHidden = true
    var willPaginationWork = false
    var isObserverAdded = false
    var isGettingMessageViaPaginationInProgress = false
    var actionableMessageRightMargin: CGFloat = 60
    var messagesGroupedByDate: [[HippoMessage]] = []
    
    var messageArrayCount: Int { return channel?.messages.count ?? 0 }
    var channel: HippoChannel! { didSet { didSetChannel() } }
    var getSavedUserId: Int { return currentUserId() }
    var channelId: Int { return channel?.id ?? -1 }
    
    var qldataSource: HippoQLDataSource?
    var pickerHelper: PickerHelper?
    var isAttachmentOpenedForTicket: Bool?
    var titleForNavigation: NavigationTitleView?
    
    var errorMessage: String = ""
    var chatType: ChatType? {
        return channel.chatDetail?.chatType
    }
    
    var heightForActionSheet: CGFloat = 175//125//250
    var actionSheetTitleArr = [String]()
    var actionSheetImageArr = [String]()
    var addedPaymentGatewaysArr: [PaymentGateway] = []
    var isProceedToPayActionSheet = false
    var proceedToPayMessage : HippoMessage?
    var proceedToPaySelectedCard : CustomerPayment?
    var proceedToPayChannel: HippoChannel?
    var attachments: [Attachment]  = []
    var isMessageEditing : Bool = false
    let attachmentObj = CreateTicketAttachmentHelper()


    //MARK:
    @IBOutlet var tableViewChat: UITableView!{
        didSet{
            tableViewChat.allowsSelection = false
        }
    }
    
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var errorLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var view_Navigation : NavigationBarChat!
    @IBOutlet weak var height_errorView : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setTheme()
        
//        tableViewChat.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        removeNotificationsFromNotificationCenter(channelId: channelId)
        registerFayeNotification()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        checkNetworkConnection()
         
        
        registerFayeNotification()
        registerKeyBoardNotification()
        registerNotificationWhenAppEntersForeground()
        registerNotificationToKnowWhenAppIsKilledOrMovedToBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .ConversationScreenDisappear, object: nil)
        removeKeyboardNotificationObserver()
        removeAppDidEnterForegroundObserver()
        removeNotificationObserverToKnowWhenAppIsKilledOrMovedToBackground()
        NotificationCenter.default.removeObserver(self, name: .socketConnected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .socketDisconnected, object: nil)
    }
    
    //Set Delegate For channels
    func didSetChannel() { }
    func getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: ((_ success: Bool) -> Void)?) { }
    func getMessagesWith(labelId: Int, completion: ((_ success: Bool) -> Void)?) { }
    func closeKeyBoard() { }
    func reloadVisibleCellsToStartActivityIndicator() { }
    func adjustChatWhenKeyboardIsOpened(withHeight keyboardHeight: CGFloat) { }
    func addRemoveShadowInTextView(toAdd: Bool) { }
    func startNewConversation(replyMessage: HippoMessage?, completion: ((_ success: Bool, _ result: HippoChannelCreationResult?) -> Void)?) { }
    func startLoaderAnimation() { }
    func stopLoaderAnimation() { }
    func callGetMessagesApi() { }
    
    func clearUnreadCountForChannel(id: Int) { }
    @objc func titleButtonclicked() { }
    func addMessageToUIBeforeSending(message: HippoMessage) { }
    
    func openCustomSheet() { }
    func closeAttachment(){}
    func paymentCardPaymentOfCreatePaymentCalled() { }
    func startEditing(with message : HippoMessage, indexPath : IndexPath){}
    func checkNetworkConnection() {
        if FuguNetworkHandler.shared.isNetworkConnected {
            hideErrorMessage()
        } else {
            errorMessage = HippoStrings.noNetworkConnection
            showErrorMessage()
        }
    }
    
    func fetchMessagesFrom1stPage() {
        if isDefaultChannel() {
            getMessagesWith(labelId: labelId, completion: nil)
        } else {
            getMessagesBasedOnChannel(fromMessage: 1, pageEnd: nil, completion: nil)
        }
    }
    func isDefaultChannel() -> Bool {
        return labelId > -1
    }
    
//    func startGettingNewMessages() {
//        let color = HippoConfig.shared.theme.processingGreenColor
//        showErrorMessage(messageString: HippoConfig.shared.strings.checkingNewMessages, bgColor: color)
//    }
    
    func isMessageInvalid(messageText: String) -> Bool {
        if messageText.replacingOccurrences(of: " ", with: "").count == 0 ||
            messageText.trimWhiteSpacesAndNewLine().count == 0 {
            
            if FuguNetworkHandler.shared.isNetworkConnected == false {
                return true
            }
            errorMessage = HippoStrings.enterSomeText
            showErrorMessage()
            updateErrorLabelView(isHiding: true)
            return true
        }
        return false
    }
    
    func showErrorMessage(messageString: String = "", bgColor: UIColor = UIColor.red) {
        var message = messageString.trimWhiteSpacesAndNewLine()
        message = message.isEmpty ? errorMessage  : messageString

        guard !message.isEmpty else {
            hideErrorMessage()
            return
        }
        errorLabel.text = message
        errorLabel.backgroundColor = bgColor

        if height_errorView != nil && height_errorView.constant != 20 {
            height_errorView.constant = 20
            view.layoutIfNeeded()
        }
    }
    
    func hideErrorMessage() {
        let height: CGFloat = 0
        guard height_errorView.constant != height else {
            return
        }
        DispatchQueue.main.async {
            self.height_errorView.constant = height
            self.errorLabel.text = ""
            self.errorMessage = ""
            self.view.layoutIfNeeded()
            self.errorLabel.backgroundColor = UIColor.red
        }
    }
    
    func updateErrorLabelView(isHiding: Bool, delay: Double = 3) {
        if isHiding {
            if self.height_errorView.constant == 20 {
                fuguDelay(3, completion: {
                    // self.errorLabelTopConstraint.constant = -20
                    self.errorLabel.text = ""
                    self.height_errorView.constant = 0
                    self.view.layoutIfNeeded()
                    self.errorLabel.backgroundColor = UIColor.red
                })
            }
            return
        }else{
            height_errorView.constant = 20
            self.view.layoutIfNeeded()
        }
        
    }
    
    func populateTableViewWithChannelData() {
        guard channel != nil else {
            return
        }
        self.updateMessagesInLocalArrays(messages: [])
//        self.updateMessagesGroupedByDate(self.channel.messages)
//        if tableViewChat.numberOfSections == 0 {
//            self.tableViewChat.isHidden = true
//            self.tableViewChat.alpha = 0
//        }
        
        self.tableViewChat.reloadData()
        self.scrollToBottomWithIndexPath(animated: false)
        
//        fuguDelay(0.2) {
//            self.tableViewChat.isHidden = false
//            UIView.animate(withDuration: 0.3) {
//                self.tableViewChat.alpha = 1
//            }
//        }
    }
    
    func registerFayeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.fayeConnected), name: .socketConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fayeDisconnected), name: .socketDisconnected, object: nil)
    }
    func registerNotificationToKnowWhenAppIsKilledOrMovedToBackground() {
        #if swift(>=4.2)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        #endif
        
        
    }
    func registerKeyBoardNotification() {
        
        #if swift(>=4.2)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        #endif
    }

    func tableViewSetUp() {
        automaticallyAdjustsScrollViewInsets = false
        tableViewChat.contentInset.bottom = 3
        
        tableViewChat.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        let bundle = FuguFlowManager.bundle
        
        tableViewChat.register(UINib(nibName: "SelfMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "SelfMessageTableViewCell")
        tableViewChat.register(UINib(nibName: "PaymentMessageCell", bundle: bundle), forCellReuseIdentifier: "PaymentMessageCell")
        
        tableViewChat.register(UINib(nibName: "MultiSelectTableViewCell", bundle: bundle), forCellReuseIdentifier: "MultiSelectTableViewCell")
        
        tableViewChat.register(UINib(nibName: "SupportMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "SupportMessageTableViewCell")
        
        tableViewChat.register(UINib(nibName: "OutgoingImageCell", bundle: bundle), forCellReuseIdentifier: "OutgoingImageCell")
        tableViewChat.register(UINib(nibName: "IncomingImageCell", bundle: bundle), forCellReuseIdentifier: "IncomingImageCell")
        tableViewChat.register(UINib(nibName: "ActionableMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "ActionableMessageTableViewCell")
        
        tableViewChat.register(UINib(nibName: "BotOutgoingMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "BotOutgoingMessageTableViewCell")
        tableViewChat.register(UINib(nibName: "LeadTableViewCell", bundle: bundle), forCellReuseIdentifier: "LeadTableViewCell")
        tableViewChat.register(UINib(nibName: "FeedbackTableViewCell", bundle: bundle), forCellReuseIdentifier: "FeedbackTableViewCell")
        
        tableViewChat.register(UINib(nibName: "AssignedAgentTableViewCell", bundle: bundle), forCellReuseIdentifier: "AssignedAgentTableViewCell")
        
        tableViewChat.register(UINib(nibName: "OutgoingVideoCallMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "OutgoingVideoCallMessageTableViewCell")
        tableViewChat.register(UINib(nibName: "IncomingVideoCallMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "IncomingVideoCallMessageTableViewCell")
        
        tableViewChat.register(UINib(nibName: "OutgoingDocumentTableViewCell", bundle: bundle), forCellReuseIdentifier: "OutgoingDocumentTableViewCell")
        tableViewChat.register(UINib(nibName: "IncomingDocumentTableViewCell", bundle: bundle), forCellReuseIdentifier: "IncomingDocumentTableViewCell")
        tableViewChat.register(UINib(nibName: "OutgoingAudioTableViewCell", bundle: bundle), forCellReuseIdentifier: "OutgoingAudioTableViewCell")
        tableViewChat.register(UINib(nibName: "IncomingAudioTableViewCell", bundle: bundle), forCellReuseIdentifier: "IncomingAudioTableViewCell")
        tableViewChat.register(UINib(nibName: "IncomingVideoTableViewCell", bundle: bundle), forCellReuseIdentifier: "IncomingVideoTableViewCell")
        tableViewChat.register(UINib(nibName: "OutgoingVideoTableViewCell", bundle: bundle), forCellReuseIdentifier: "OutgoingVideoTableViewCell")
        
        tableViewChat.register(UINib(nibName: "ActionTableView", bundle: bundle), forCellReuseIdentifier: "ActionTableView")
        tableViewChat.register(UINib(nibName: "CardMessageTableViewCell", bundle: bundle), forCellReuseIdentifier: "CardMessageTableViewCell")
        tableViewChat.register(UINib(nibName: "SearchAgentTableViewCell", bundle: bundle), forCellReuseIdentifier: "SearchAgentTableViewCell")
        
    }
    
    func registerNotificationWhenAppEntersForeground() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: HippoVariable.didBecomeActiveNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let key = HippoVariable.keyboardFrameEndUserInfoKey
        
        guard let keyBoardFrame = notification.userInfo?[key] as? CGRect, UIApplication.shared.applicationState == .active else {
            return
        }
        self.adjustChatWhenKeyboardIsOpened(withHeight: keyBoardFrame.height)
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if self.typingMessageValue == TypingMessage.startTyping.rawValue, channel != nil {
            typingMessageValue = TypingMessage.stopTyping.rawValue
            sendTypingStatusMessage(isTyping: .stopTyping)
        }
        self.addRemoveShadowInTextView(toAdd: false)
    }
    
    
    
    @objc func willEnterForeground(_ notification: NSNotification!) {
        isTypingLabelHidden = true
        checkNetworkConnection()
        reloadVisibleCellsToStartActivityIndicator()
        removeNotificationsFromNotificationCenter(channelId: channelId)
        
        recreateRequestIfRequired()
    }
    
    func recreateRequestIfRequired() {
        guard let storeRequest = storeRequest else {
            fetchMessagesFrom1stPage()
            return
        }
    
        if storeResponse == nil {
            fetchMessagesFrom1stPage()
        }
    }
    
    @objc func fayeConnected(_ notification: Notification) {
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        
        guard channel != nil else {
            getAllNewMessages()
            return
        }
        if channel.isSubscribed() {
            getAllNewMessages()
        } else {
            channel.subscribe { (sccuess, error) in
                guard sccuess else {
                    return
                }
                self.getAllNewMessages()
            }
        }
        
    }
    @objc func fayeDisconnected(_ notification: Notification) {
        
    }
    
    func getAllNewMessages() {
        var totalCount: Int? = channel?.messages.count
        
        if let count = totalCount, count < 100 { totalCount = nil }
        getMessagesBasedOnChannel(fromMessage: 1, pageEnd: totalCount, completion: nil)
    }
    
    @objc func appMovedToBackground() {
        checkNetworkConnection()
        sendTypingStatusMessage(isTyping: TypingMessage.stopTyping)
        closeKeyBoard()
    }
    func sendTypingStatusMessage(isTyping: TypingMessage) {
        if isTyping == .startTyping {
            channel?.send(message: HippoMessage.startTyping, completion: {})
        } else {
            channel?.send(message: HippoMessage.stopTyping, completion: {})
        }
    }
    // MARK: Message Filtering Methods
    func filterMessages(newMessagesHashMap: [String: Int], lastMessage: HippoMessage) {
        let unsentMessages = getFilteredUnsentMessagesFromChannelMessageArray(newMessagesHashMap: newMessagesHashMap)
        let sentMessages = getFilteredSentMessagesBeforeUpdatingMessagesWithNewResponse(newMessagesHashMap: newMessagesHashMap, lastMessage: lastMessage)
        
        channel?.sentMessages = sentMessages
        channel?.unsentMessages = unsentMessages
    }
    
    
    func showAlertForNoInternetConnection() {
        showAlertWith(message: HippoStrings.noNetworkConnection) {
            return
        }
    }
    
    func filterForMultipleMuid(newMessages: [HippoMessage], newMessagesHashMap: [String: Int]) -> [HippoMessage] {
        let extistingMuids = channel?.messageHashMap ?? [:]
        var newSentMessages = [HippoMessage]()
        
        for message in newMessages {
            guard let muid = message.messageUniqueID else {
                continue
            }
            if extistingMuids[muid] == nil {
                newSentMessages.append(message)
            }
        }
        
        return newSentMessages
    }
    
    func openSelectedImage(for message: HippoMessage) {
        
        var showImageVC: ShowImageViewController?
        if let localPath = message.localImagePath {
            showImageVC = ShowImageViewController.getFor(localPath: localPath)
        } else  if let originalUrl = message.imageUrl, originalUrl.count > 0  {
            showImageVC = ShowImageViewController.getFor(imageUrlString: originalUrl)
        }
        
        guard showImageVC != nil else {
            return
        }
        
        self.modalPresentationStyle = .overFullScreen
        self.present(showImageVC!, animated: true, completion: nil)
    }
    
    func getFilteredSentMessagesBeforeUpdatingMessagesWithNewResponse(newMessagesHashMap: [String: Int], lastMessage: HippoMessage) -> [HippoMessage] {
        var messageCheckedCount = 0
        var messagesNotReceivedInResponse = [HippoMessage]()
        
        let messagesTobeFiltered = getMessagesToBeFiltered()
        for message in messagesTobeFiltered.reversed() {
            if messageCheckedCount > 30 {
                break
            }
            messageCheckedCount += 1
            
            guard message.messageUniqueID != nil, (message.status != .none || !message.isSentByMe()) else {
                continue
            }
            
            if newMessagesHashMap[message.messageUniqueID!] == nil && message.creationDateTime.compare(lastMessage.creationDateTime) == ComparisonResult.orderedDescending {
                messagesNotReceivedInResponse.append(message)
            }
        }
        
        return messagesNotReceivedInResponse
    }
    
    func getFilteredUnsentMessagesFromChannelMessageArray(newMessagesHashMap: [String: Int]) ->  [HippoMessage] {
        let unsentMessges = self.getMessagesToBeFiltered().filter { (message) in
            let isFailedMessage = message.status == .none && message.isSentByMe()
            
            if message.isDeleted {
                return false
            }
            
            if isFailedMessage, message.type == MessageType.imageFile, message.imageUrl == nil {
                
                guard let localPathOfImage = message.localImagePath, !localPathOfImage.isEmpty else {
                    return false
                }
//                print("====== \(message.getDictToSaveInCache())")
//                print("====== \(self.doesFileExistsAt(filePath: localPathOfImage))")
                return self.doesFileExistsAt(filePath: localPathOfImage)
            }
            
            
            var didUnsentMessageCameInNewMessage = false
            if let uniqueID = message.messageUniqueID, isFailedMessage {
                didUnsentMessageCameInNewMessage = newMessagesHashMap[uniqueID] != nil
            }
            
            return isFailedMessage && !didUnsentMessageCameInNewMessage
        }
        
        return unsentMessges
    }
    func getMessagesToBeFiltered() -> [HippoMessage] {
        return channel?.messages ?? []
    }
    func isCustomerInfoAvailable() -> Bool {
        let customerId = channel?.chatDetail?.customerID ?? -1
        return customerId > 0
    }
    func setTitleButton() {
        
        let color = HippoConfig.shared.theme.headerTextColor
        let button =  UIButton(type: .custom)
        button.sizeToFit()
        button.backgroundColor = UIColor.clear
        button.setTitleColor(color, for: .normal)
        
        button.titleLabel?.font = HippoConfig.shared.theme.headerTextFont//
        
        button.addTarget(self, action: #selector(self.titleButtonclicked), for: .touchUpInside)

        self.navigationItem.titleView = button
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationTitleButton = button
        setNavigationTitle(title: label)
    }
    
    func setTitleForCustomNavigationBar() {
//        guard HippoConfig.shared.appUserType == .customer else {
//            return
//        }
//        let rectForNavigationTitle: CGRect = CGRect(x: 0, y: 0, width: 500, height: 100)
//        let navigationView: NavigationTitleView
//        if let parsedTitleForNavigation = titleForNavigation {
//            navigationView = parsedTitleForNavigation
//        } else {
//            navigationView = NavigationTitleView.loadView(rectForNavigationTitle, delegate: self)
//            titleForNavigation = navigationView
//        }
        if let chatType = channel?.chatDetail?.chatType, (chatType == .other || chatType == .o2o){
            let title: String? = channel?.chatDetail?.channelName ?? label
             view_Navigation.setData(imageUrl: userImage, name: title)
        } else if labelId > 0, channel == nil {
             view_Navigation.setData(imageUrl: userImage, name: label)
        } else {
             view_Navigation.hideProfileImage()
        }
  //      navigationView.removeFromSuperview()
        view_Navigation.setTitle(title: label)
        title = nil
        //let button = UIBarButtonItem(customView: navigationView)
        if HippoConfig.shared.appUserType != .customer{
            view_Navigation.hideProfileImage()
        }
        view_Navigation.delegate = self
   //     navigationItem.leftBarButtonItem = button
    }
    
    
    func setNavigationTitle(title: String) {
        guard titleForNavigation == nil else {
            setTitleForCustomNavigationBar()
            return
        }
        let info_icon = UIImage(named: "info_button_icon_on_navigation_bar", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = info_icon
        
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let myString: NSMutableAttributedString = NSMutableAttributedString(string: title)
        
        #if swift(>=4.0)
          myString.append(attachmentString)
        #else
          myString.append(attachmentString)
        #endif
        navigationTitleButton?.setTitle(title, for: .normal)
        navigationTitleButton?.titleLabel?.lineBreakMode = .byTruncatingTail
//        navigationTitleButton?.setAttributedTitle(myString, for: .normal)
        DispatchQueue.main.async {
            self.navigationTitleButton?.sizeToFit()
        }
    }
    func startAudioCall() {
        guard canStartAudioCall() else {
            return
        }
        guard let peerDetail = channel?.chatDetail?.peerDetail else {
            return
        }
        
        self.view.endEditing(true)
        
        let call = CallData.init(peerData: peerDetail, callType: .audio, muid: String.uuid(), signallingClient: channel)
        
        if versionCode < 350{
            CallManager.shared.startCall(call: call) { (success,error) in
                if !success {
                    assertionFailure("Cannot start the call")
                }
            }
        }else{
            //            // #####-------USE THIS METHOD IF YOU ARE USING JITSI CALLING BARNCH FOR CALLING FEATURE -----#####
            //
            CallManager.shared.startCall(call: call) { (success, error) in
                
                if let mismatchError = error, mismatchError.code == 415 {
                    
                    let message = peerDetail.fullName + " " + HippoStrings.callOldSdk
                    self.showOptionAlert(title: HippoStrings.versionMismatch, message: message, successButtonName: HippoStrings.callAnyway, successComplete: { (successAction) in
                        
                        CallManager.shared.startWebRTCCall(call: call) { (success) in
                            if !success {
                                assertionFailure("Cannot start webrtc the call too")
                            }
                        }
                        
                    }, failureButtonName: HippoStrings.cancel) { (failureAction) in
                        //do nothing
                    }
                }
                else if !success {
                    assertionFailure("Cannot start the call")
                }
            }
        }
    }
    func startVideoCall() {
        guard canStartVideoCall() else {
            return
        }
        guard let peerDetail = channel?.chatDetail?.peerDetail else {
            return
        }
        self.view.endEditing(true)
        
        let call = CallData.init(peerData: peerDetail, callType: .video, muid: String.uuid(), signallingClient: channel)
        if versionCode < 350{
            CallManager.shared.startCall(call: call) { (success,error) in
                if !success {
                    assertionFailure("Cannot start the call")
                }
            }
        }else{
            //            // #####-------USE THIS METHOD IF YOU ARE USING JITSI CALLING BARNCH FOR CALLING FEATURE -----#####
            CallManager.shared.startCall(call: call) { (success, error) in
                
                if let mismatchError = error, mismatchError.code == 415 {
                    
                    let message = peerDetail.fullName + " " + HippoStrings.callOldSdk
                    self.showOptionAlert(title: HippoStrings.versionMismatch, message: message, successButtonName: HippoStrings.callAnyway, successComplete: { (successAction) in
                        
                        CallManager.shared.startWebRTCCall(call: call) { (success) in
                            if !success {
                                assertionFailure("Cannot start webrtc the call too")
                            }
                        }
                        
                    }, failureButtonName: HippoStrings.cancel) { (failureAction) in
                        //do nothing
                    }
                }
                else if !success {
                    assertionFailure("Cannot start the call")
                }
            }
        }
    }
    func canMakeAnyCall() -> Bool {
        guard channel?.chatDetail?.peerDetail != nil else {
            return false
        }
        let assignemdAgentID = channel?.chatDetail?.assignedAgentID ?? -1000
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            if channel?.chatDetail?.chatType == .o2o{
                return assignemdAgentID == currentUserId() || channel?.chatDetail?.customerID == currentUserId()
            }
            return assignemdAgentID == currentUserId()
        case .customer:
            return true
        }
    }
    
    func canStartAudioCall() -> Bool {
        guard canMakeAnyCall() else {
            return false
        }
        guard BussinessProperty.current.isAudioCallEnabled else {
            return false
        }
        guard let allowAudioCall = channel?.chatDetail?.allowAudioCall, allowAudioCall  else {
            return false
        }
        return true
        
    }
    
    func canStartVideoCall() -> Bool {
        guard canMakeAnyCall() else {
            return false
        }
        guard BussinessProperty.current.isVideoCallEnabled else {
            return false
        }
        guard let allowVideoCall = channel?.chatDetail?.allowVideoCall, allowVideoCall  else {
            return false
        }
        return true
        
    }
    func isCallingEnabledFor(type: CallType) -> Bool {
        switch type {
        case .video:
            return canStartVideoCall()
        case .audio:
            return canStartAudioCall()
        }
    }
    func isDirectCallingEnabledFor(type: CallType) -> Bool {
        let callingDisableOnNavigationForCustomer: Bool = BussinessProperty.current.hideCallIconOnNavigationForCustomer
        switch type {
        case .video:
            let status = canStartVideoCall()
            switch HippoConfig.shared.appUserType {
            case .customer:
                return status && !callingDisableOnNavigationForCustomer
            default:
                return status
            }
            
        case .audio:
            let status = canStartAudioCall()
            switch HippoConfig.shared.appUserType {
            case .customer:
                return status && !callingDisableOnNavigationForCustomer
            default:
                return status
            }
        }
    }
    
    func updateMessagesInLocalArrays(messages: [HippoMessage]) {
        
        self.messagesGroupedByDate = []
        self.updateMessagesGroupedByDate(messages) //1. first, update new messages
        
        if self.messageArrayCount > 0 {
            self.updateMessagesGroupedByDate(self.channel.messages)//2.second, update existing messages
        }
        
        self.channel?.sentMessages = messages + self.channel.sentMessages
        self.channel?.refreshHashMap()
    }
    
    func updateMessagesGroupedByDate(_ chatMessagesArray: [HippoMessage]) {
        
        for message in chatMessagesArray {
            
            guard let latestDateTime = getDateTimeStringOfLatestStoredMessage() else {
                addMessageToNewGroup(message: message)
                continue
            }
            
            let comparisonResult = Calendar.current.compare(latestDateTime, to: message.creationDateTime, toGranularity: .day)
            
            switch comparisonResult {
            case .orderedSame:
                var latestMessageGroup = messagesGroupedByDate.last ?? []
                let lastMessage: HippoMessage? = latestMessageGroup.last
                if lastMessage?.messageUniqueID != message.messageUniqueID{
                    self.setDataFor(belowMessage: message, aboveMessage: lastMessage)
                    latestMessageGroup.append(message)
                    messagesGroupedByDate[messagesGroupedByDate.count - 1] = latestMessageGroup
                }
            default:
                addMessageToNewGroup(message: message)
            }
        }
    }
    
    func setDataFor(belowMessage: HippoMessage?, aboveMessage: HippoMessage?) {
        aboveMessage?.belowMessageMuid = belowMessage?.messageUniqueID
        aboveMessage?.belowMessageUserId = belowMessage?.senderId
        aboveMessage?.belowMessageType = belowMessage?.type
        
        belowMessage?.aboveMessageMuid = aboveMessage?.messageUniqueID
        belowMessage?.aboveMessageUserId = aboveMessage?.senderId
        belowMessage?.aboveMessageType = aboveMessage?.type
    
        aboveMessage?.messageRefresed?()
    }
    
    func addMessageToNewGroup(message: HippoMessage) {
        self.messagesGroupedByDate.append([message])
    }
    
    func getDateTimeStringOfLatestStoredMessage() -> Date? {
        guard !messagesGroupedByDate.isEmpty else {
            return nil
        }
        guard var latestMessageGroup = messagesGroupedByDate.last, latestMessageGroup.count > 0 else {
            return nil
        }
        
        let groupsFirstMessage = latestMessageGroup[0]
        
        return groupsFirstMessage.creationDateTime
    }
    func isSentByMe(senderId: Int) -> Bool {
        return getSavedUserId == senderId
    }
    func attachmentButtonclicked(_ sender: UIButton)
    {
        isAttachmentOpenedForTicket = false
        let showPaymentOption = channel == nil ? false : HippoProperty.current.isPaymentRequestEnabled
        pickerHelper = PickerHelper(viewController: self, enablePayment: showPaymentOption)
        pickerHelper?.present(sender: sender, controller: self)
        pickerHelper?.delegate = self
    }
    
    func attachmentButtonclickedOfCustomSheet(_ sender: UIView, openType: String){
        isAttachmentOpenedForTicket = false
        let showPaymentOption = channel == nil ? false : HippoProperty.current.isPaymentRequestEnabled
        pickerHelper = PickerHelper(viewController: self, enablePayment: showPaymentOption)
        pickerHelper?.delegate = self
        pickerHelper?.presentCustomActionSheet(sender: sender, controller: self, openType: openType)
    }
    
    func getMessageAt(indexPath: IndexPath) -> HippoMessage? {
        guard doesMessageAtIndexPathExists(indexPath) else {
            return nil
        }
        
        return messagesGroupedByDate[indexPath.section][indexPath.row]
    }
    
    func doesMessageAtIndexPathExists(_ indexPath: IndexPath) -> Bool {
        guard messagesGroupedByDate.count > indexPath.section else {
            return false
        }
        
        let groupedArray = messagesGroupedByDate[indexPath.section]
        
        guard groupedArray.count > indexPath.row else {
            return false
        }
        
        return true
    }
}


extension HippoConversationViewController: PickerHelperDelegate {
    func payOptionClicked() {
        let paymentStore = PaymentStore(plan: nil, channelId: UInt(channelId), isEditing: (channelId != -1), isSending: channelId != -1, isCustomisedPayment : true)
        let vc = CreatePaymentViewController.get(store: paymentStore)
        vc.delegate = self
        //self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func imagePickingError(mediaSelector: CoreMediaSelector, error: Error) {
        showAlert(title: "", message: error.localizedDescription, actionComplete: nil)
    }
    
    func fileSelectedWithBiggerSize(maxSizeAllowed: UInt) {
        showAlert(title: "", message: "File size should be smaller than \(maxSizeAllowed).", actionComplete: nil)
    }
    
    func imageViewPickerDidFinish(mediaSelector: CoreMediaSelector, with result: CoreMediaSelector.Result) {
        guard result.isSuccessful else {
            showAlert(title: "", message: result.error?.localizedDescription ?? HippoStrings.somethingWentWrong, actionComplete: nil)
            return
        }
        let mediaType = result.mediaType ?? .imageType
        switch mediaType {
        case .gifType, .imageType:
            guard let selectedImage = result.image else {
                showAlert(title: "", message: HippoStrings.somethingWentWrong, actionComplete: nil)
                return
            }
//            sendConfirmedImage(image: selectedImage, mediaType: mediaType)
            let vc = SelectImageViewController.getWith(pickedImage: selectedImage, imageFormat: nil, delegate: self, isMentioningEnabled: false, gifData: nil, mediaType: mediaType)
            self.present(vc, animated: true, completion: nil)

        case .movieType:
            guard let filePath = result.filePath else {
                showAlert(title: "", message: HippoStrings.somethingWentWrong, actionComplete: nil)
                return
            }
            let filePathUrl = URL(fileURLWithPath: filePath)
            sendSelectedDocumentWith(filePath: filePathUrl.path, fileName: filePathUrl.lastPathComponent, messageType: .attachment, fileType: FileType.video)
        }
        
        
    }
    
    func didPickDocumentWith(url: URL) {
        HippoConfig.shared.UnhideJitsiView()
        sendSelectedDocumentWith(filePath: url.path, fileName: url.lastPathComponent, messageType: .attachment, fileType: .document)
    }
}

// MARK: - SelectImageViewControllerDelegate Delegates
extension HippoConversationViewController: SelectImageViewControllerDelegate {
    func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage) {
        //        selectedImageVC.dismiss(animated: false) {
        //            self.imagePicker.dismiss(animated: false) {
        //                self.sendConfirmedImage(image: selectedImage, mediaType: .imageType)
        //            }
        //        }
        selectedImageVC.dismiss(animated: true) {
            if self.presentedViewController == self.imagePicker {
                self.imagePicker.dismiss(animated: false) {
                    self.sendConfirmedImage(image: selectedImage, mediaType: .imageType)
                }
            } else {
                self.sendConfirmedImage(image: selectedImage, mediaType: .imageType)
            }
            HippoConfig.shared.UnhideJitsiView()
        }
        
    }
    
    func goToConversationViewController() {
        HippoConfig.shared.UnhideJitsiView()
    }
}

extension HippoConversationViewController {
    
    func sendSelectedDocumentWith(filePath: String, fileName: String, messageType: MessageType, fileType: FileType) {
        guard doesFileExistsAt(filePath: filePath) else {
            return
        }
        let uniqueName = DownloadManager.generateNameWhichDoestNotExistInCacheDirectoryWith(name: fileName)
        saveDocumentInCacheDirectoryWith(name: uniqueName, orignalFilePath: filePath)
        
        let message = HippoMessage(message: "", type: messageType, uniqueID: generateUniqueId(), imageUrl: nil, thumbnailUrl: nil, localFilePath: filePath, chatType: channel?.chatDetail?.chatType)
        
        message.fileName = uniqueName
        message.localImagePath = getCacheDirectoryUrlForFileWith(name: uniqueName).path
        
        //Changing messageType in case if new selected file is of image type
        let concreteType = message.concreteFileType ?? .document
        switch concreteType {
        case .image:
            message.type = .imageFile
            if let image = UIImage(contentsOfFile: filePath) {
                let size = image.size
                message.imageHeight = Float(size.height)
                message.imageWidth = Float(size.width)
            }
        default:
            break
        }
        //Checking if channel is created or not
//        if channel != nil {
//            self.UploadAndSendMessage(message: message)
//        } else {
//            startNewConversation(replyMessage: nil) { (success, result) in
//                guard success else {
//                    return
//                }
                self.UploadAndSendMessage(message: message)
//            }
//        }
        
    }
    //This function will upload ant file and send it on channel
    func UploadAndSendMessage(message: HippoMessage) {
        switch message.type {
        case .imageFile:
            PrepareUploadAndSendImage(message: message)
        default:
            self.prepareMessageForUploadingFile(message: message)
            self.uploadFileFor(message: message) { (success) in
                if success {
                    self.handleUploadSuccessOfFileIn(message: message)
                }
            }
        }
    }
    func addMessageInUnsentArray(message: HippoMessage) {
        channel?.unsentMessages.append(message)
        channel?.messageHashMap[message.messageUniqueID!] = (channel?.messages.count ?? 1) - 1
    }
    
    func prepareMessageForUploadingFile(message: HippoMessage) {
        addMessageInUnsentArray(message: message)
        message.isFileUploading = true
        updateMessagesArrayLocallyForUIUpdation(message)
        scrollToBottomWithIndexPath(animated: true)
    }
    
    func saveDocumentInCacheDirectoryWith(name: String, orignalFilePath: String) {
        
        let orignalFilePathURL = URL.init(fileURLWithPath: orignalFilePath)
        let fileUrl = getCacheDirectoryUrlForFileWith(name: name)
        
        try? FileManager.default.copyItem(at: orignalFilePathURL, to: fileUrl)
    }
    func scrollToBottomWithIndexPath(animated: Bool) {
        DispatchQueue.main.async {
            if self.tableViewChat.numberOfSections == 0 { return }
            
            if let lastCell = self.getLastMessageIndexPath() {
                self.scroll(toIndexPath: lastCell, animated: animated)
            }
        }
    }
    func scroll(toIndexPath indexPath: IndexPath, animated: Bool) {
         let indexPath = IndexPath(
            row: tableViewChat.numberOfRows(inSection: tableViewChat.numberOfSections - 1) - 1,
                section: tableViewChat.numberOfSections - 1)
        if hasRowAtIndexPath(indexPath: indexPath) {
            tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < tableViewChat.numberOfSections && indexPath.row < tableViewChat.numberOfRows(inSection: indexPath.section)
    }
    
    
    func getLastMessageIndexPath() -> IndexPath? {
        if self.messagesGroupedByDate.count > 0 {
            let section = self.messagesGroupedByDate.count - 1
            let groupedArray = self.messagesGroupedByDate[section]
            if groupedArray.count > 0 {
                let row = groupedArray.count - 1
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
    
    func handleUploadSuccessOfFileIn(message: HippoMessage) {
        DownloadManager.shared.addAlreadyDownloadedFileWith(name: message.fileName!, WRTurl: message.fileUrl!)
        message.localImagePath = nil
        publishMessageOnChannel(message: message)
    }
    
    func sendConfirmedImage(image confirmedImage: UIImage, mediaType: CoreMediaSelector.Result.MediaType ) {
        var imageExtention: String = ".jpg"
        let imageData: Data?
        
        #if swift(>=4.2)
        let imageSize = confirmedImage.jpegData(compressionQuality: 1)!.count
        #else
        let imageSize = UIImageJPEGRepresentation(confirmedImage, 1)!.count
        #endif
        
        print(imageSize)
        
        let compressionRate = getCompressonRateForImageWith(size: imageSize)
        
        switch mediaType {
        case .gifType:
            imageExtention = ".gif"
            imageData = confirmedImage.kf.gifRepresentation() ?? confirmedImage.kf.jpegRepresentation(compressionQuality: 1)
        default:
            imageExtention = ".jpg"
            
            #if swift(>=4.2)
            imageData = confirmedImage.jpegData(compressionQuality: compressionRate)
            #else
            imageData = UIImageJPEGRepresentation(confirmedImage, compressionRate)
            #endif
        }
        
        let imageName = Date.timeIntervalSinceReferenceDate.description + imageExtention
        let imageFilePath = getCacheDirectoryUrlForFileWith(name: imageName).path
        
        ((try? imageData?.write(to: URL(fileURLWithPath: imageFilePath), options: [.atomic])) as ()??)
        
        if imageFilePath.isEmpty == false {
            self.imageSelectedToSendWith(localPath: imageFilePath, imageSize: confirmedImage.size)
        }
    }
    func PrepareUploadAndSendImage(message: HippoMessage) {
        channel?.unsentMessages.append(message)
        self.addMessageToUIBeforeSending(message: message)
        
        uploadFileFor(message: message) { (success) in
            guard success else {
                return
            }
            self.saveImageInKingfisherCacheFor(message: message)
            self.publishMessageOnChannel(message: message)
        }
    }
    
    func imageSelectedToSendWith(localPath: String, imageSize: CGSize) {
        let message = HippoMessage(message: "", type: .imageFile, uniqueID: generateUniqueId(), localFilePath: localPath, chatType: channel?.chatDetail?.chatType)
        message.fileName = localPath.fileName()
        message.imageWidth = Float(imageSize.width)
        message.imageHeight = Float(imageSize.height)
        PrepareUploadAndSendImage(message: message)
    }
    
    func saveImageInKingfisherCacheFor(message: HippoMessage) {
        guard let originalURL = message.imageUrl, let thumbnailURL = message.thumbnailUrl, let localPath = message.localImagePath else {
            return
        }
        FileUploader.saveImageInKingfisherCacheFor(thumbnailUrl: thumbnailURL, originalUrl: originalURL, localPath: localPath)
    }
    func uploadFileFor(message: HippoMessage, completion: @escaping (_ success: Bool) -> Void) {
        guard message.localImagePath != nil else {
            completion(false)
            return
        }
        
        message.isFileUploading = true
        message.wasMessageSendingFailed = false
        
        guard doesFileExistsAt(filePath: message.localImagePath!) else {
            message.isFileUploading = false
            message.wasMessageSendingFailed = true
            completion(false)
            return
        }
        
        let request = FileUploader.RequestParams(path: message.localImagePath!, mimeType: message.mimeType ?? "application/octet-stream", fileName: message.fileName ?? "")
        
        let pathURL = URL.init(fileURLWithPath: message.localImagePath!)
        let dataOfFile = try? Data.init(contentsOf: pathURL, options: [])
        let fileSize = dataOfFile?.getFormattedSize()
        message.fileSize = fileSize
        
        FileUploader.uploadFileWith(request: request, completion: {[weak self] (result) in
            message.isFileUploading = false
            
            guard result.isSuccessful else {
                if result.status == 400{
                    message.wasMessageSendingFailed = true
                    message.status = .none
                    self?.showErrorMessage(messageString: (result.error?.localizedDescription) ?? "" , bgColor: .red)
                    self?.updateErrorLabelView(isHiding: true)
                    self?.cancelMessage(message: message)
                }else{
                  message.wasMessageSendingFailed = true
                }
                self?.tableViewChat.reloadData()
                completion(false)
                return
            }
            
            message.wasMessageSendingFailed = false
            message.imageUrl = result.imageUrl
            message.thumbnailUrl = result.imageThumbnailUrl
            message.fileUrl = result.fileUrl
            completion(true)
        })
    }
    func publishMessageOnChannel(message: HippoMessage) {
        if channelId == -1 {
            self.startNewConversation(replyMessage: message) {[weak self] (success, result) in
                let isReplyMessageSent = result?.isReplyMessageSent ?? false
                
                if !isReplyMessageSent {
                    message.status = .none
                    self?.channel?.send(message: message, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            self?.callGetMessagesApi()
                        })
                    })
                }
            }
        } else {
            channel?.send(message: message, completion: {})
        }
    }
    
    func getCacheDirectoryUrlForFileWith(name: String) -> URL {
        let cacheDirectoryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path
        var fileUrl = URL.init(fileURLWithPath: cacheDirectoryPath)
        fileUrl.appendPathComponent(name)
        return fileUrl
    }
    func generateUniqueId() -> String {
        return String.generateUniqueId()
    }
    func doesFileExistsAt(filePath: String) -> Bool {
        return (try? Data(contentsOf: URL(fileURLWithPath: filePath))) != nil
    }
    func getCompressonRateForImageWith(size: Int) -> CGFloat {
        var compressionRate: CGFloat = 1
        
        if size > 3*1024 {
            compressionRate = 0.3
        } else if size > 2*1024 {
            compressionRate = 0.5
        } else {
            compressionRate = 0.7
        }
        
        return compressionRate
    }
    
    
    func updateMessagesArrayLocallyForUIUpdation(_ messageDict: HippoMessage) {
        
        DispatchQueue.main.async {
            
            let countOfDateGroupedArrayBeforeUpdate = self.messagesGroupedByDate.count
            var previousLastSectionRows = 0
            
            if countOfDateGroupedArrayBeforeUpdate > 0 {
                previousLastSectionRows = self.messagesGroupedByDate.last!.count
            }
            
            self.updateMessagesGroupedByDate([messageDict])
            
            if self.messagesGroupedByDate.count == 0 {
                return
            }
            self.tableViewChat.reloadData()
//            self.tableViewChat.beginUpdates()
//
//            if countOfDateGroupedArrayBeforeUpdate == self.messagesGroupedByDate.count {
//
//                let currentLastSectionRows = self.messagesGroupedByDate.last!.count
//
//                if previousLastSectionRows != currentLastSectionRows {
//                    let lastIndexPath = IndexPath(row: currentLastSectionRows - 1, section: self.messagesGroupedByDate.count - 1)
//                    self.tableViewChat.insertRows(at: [lastIndexPath], with: .none)
//                }
//
//            } else {
//                let newSectionsOfTableView = IndexSet([self.messagesGroupedByDate.count - 1])
//                self.tableViewChat.insertSections(newSectionsOfTableView, with: .none)
//            }
//            self.tableViewChat.endUpdates()
        }
        
    }
    func openQuicklookFor(fileURL: String, fileName: String) {
//        if message?.type == .embeddedVideoUrl{
//            guard let fileURL = message?.customAction?.videoLink else {
//                return
//            }
//            let url = URL(string: fileURL)//URL(fileURLWithPath: fileURL)
//            let qlItem = QuickLookItem(previewItemURL: url, previewItemTitle: fileName)
//            let qlPreview = QLPreviewController()
//            self.qldataSource = HippoQLDataSource(previewItems: [qlItem])
//            qlPreview.delegate = self.qldataSource
//            qlPreview.dataSource = self.qldataSource
//            qlPreview.title = fileName
//            //        qlPreview.setupCustomThemeOnNavigationBar(hideNavigationBar: false)
//            qlPreview.navigationItem.hidesBackButton = false
//            qlPreview.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(qlPreview, animated: true)
//        }else{
            guard let localPath = DownloadManager.shared.getLocalPathOf(url: fileURL) else {
                return
            }
            let url = URL(fileURLWithPath: localPath)
            
            let qlItem = QuickLookItem(previewItemURL: url, previewItemTitle: fileName)
            
            let qlPreview = QLPreviewController()
            self.qldataSource = HippoQLDataSource(previewItems: [qlItem])
            qlPreview.delegate = self.qldataSource
            qlPreview.dataSource = self.qldataSource
            qlPreview.title = fileName
            //        qlPreview.setupCustomThemeOnNavigationBar(hideNavigationBar: false)
            qlPreview.navigationItem.hidesBackButton = false
            qlPreview.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(qlPreview, animated: true)
//        }
    }
    func sendMessage(message: HippoMessage) {
        channel?.send(message: message, completion: { [weak self] in
            //TODO: Reload Table View Cell
            self?.tableViewChat.reloadData()
            
            if self?.shouldScrollToBottomWhenStatusUpdatedOf(message: message) == true {
                self?.newScrollToBottom(animated: true)
            }
        })
    }
    func shouldScrollToBottomWhenStatusUpdatedOf(message: HippoMessage) -> Bool {
        guard let lastMessageUniqueID = getLastMessageOfAnyStatus()?.messageUniqueID else {
            return false
        }
        
        let isMessageLastMessage = message.messageUniqueID == lastMessageUniqueID
        
        return message.wasMessageSendingFailed && isLastMessageVisible() && isMessageLastMessage
    }
    func getLastMessageOfAnyStatus() -> HippoMessage? {
        guard let indexPath = getLastMessageIndexPath() else {
            return nil
        }
        
        return messagesGroupedByDate[indexPath.section][indexPath.row]
    }
    
    func isLastMessageVisible() -> Bool {
        guard let indexPath = getLastMessageIndexPath() else {
            return false
        }
        
        let visibleIndexPaths = tableViewChat.indexPathsForVisibleRows
        return visibleIndexPaths?.contains(indexPath) ?? false
    }
    func newScrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            if self.tableViewChat.numberOfSections == 0 { return }
            
            if let lastCell = self.getLastMessageIndexPath() {
                self.scroll(toIndexPath: lastCell, animated: animated)
            }
        }
        
    }
    
    func presentPlansVc() {
        guard channelId > 0 else {
            return
        }
        
        let id = UInt(channelId)
        
        let vc = PaymentPlansViewController.get(channelId: id)
        vc.sendNewPaymentDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.navigationBar.isHidden = true
//        navVC.setupCustomThemeOnNavigationController(hideNavigationBar: false)
        self.present(navVC, animated: true, completion: nil)
    }
    
}


extension HippoConversationViewController: RetryMessageUploadingDelegate {
    func cancelImageUploadFor(message: HippoMessage) {
        
    }
    func retryUploadFor(message: HippoMessage) {
        guard message.imageUrl == nil && message.fileUrl == nil else {
            publishMessageOnChannel(message: message)
            return
        }
        
        uploadFileFor(message: message) { (success) in
            guard success else {
                return
            }
            if message.imageUrl != nil && message.type == .imageFile {
                self.saveImageInKingfisherCacheFor(message: message)
                self.publishMessageOnChannel(message: message)
            } else if message.fileUrl != nil {
                self.handleUploadSuccessOfFileIn(message: message)
            }
        }
    }
}
extension HippoConversationViewController: VideoCallMessageTableViewCellDelegate {
    func callAgainButtonPressed(callType: CallType) {
        switch callType {
        case .audio:
            startAudioCall()
        case .video:
            startVideoCall()
        }
    }
}


extension HippoConversationViewController: VideoTableViewCellDelegate {
    func downloadFileIn(message: HippoMessage) {
        guard let fileURL = message.fileUrl else {
            print("-------\nERROR\nCannot Download File URL is Nil\n--------")
            return
        }
        
        DownloadManager.shared.downloadFileWith(url: fileURL, name: message.fileName ?? "")
    }
    
    func openFileIn(message: HippoMessage) {
        if message.type == .embeddedVideoUrl{
            guard let fileURL = message.customAction?.videoLink else {
                print("-------\nERROR\nEmbedded video link empty\n--------")
                return
            }
            var fileName = message.fileName ?? ""
            if fileName.count > 10 {
                let stringIndex = fileName.index(fileName.startIndex, offsetBy: 9)
                fileName = String(fileName[..<stringIndex])
            }
//            //openQuicklookFor(fileURL: fileURL, fileName: fileName)
//            let url = URL(string: fileURL)//URL(fileURLWithPath: fileURL)
//            let qlItem = QuickLookItem(previewItemURL: url, previewItemTitle: fileName)
//            let qlPreview = QLPreviewController()
//            self.qldataSource = HippoQLDataSource(previewItems: [qlItem])
//            qlPreview.delegate = self.qldataSource
//            qlPreview.dataSource = self.qldataSource
//            qlPreview.title = fileName
//            //        qlPreview.setupCustomThemeOnNavigationBar(hideNavigationBar: false)
//            qlPreview.navigationItem.hidesBackButton = false
//            qlPreview.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(qlPreview, animated: true)
            if let url = URL(string: fileURL){
                let config = WebViewConfig(url: url, title: fileName)
                let vc = PrePaymentViewController.getNewInstance(config: config)
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                print("Error----")
            }
            
        }else{
            guard let fileURL = message.fileUrl, DownloadManager.shared.isFileDownloadedWith(url: fileURL) else {
                print("-------\nERROR\nFile is not downloaded\n--------")
                return
            }
            var fileName = message.fileName ?? ""
            if fileName.count > 10 {
                let stringIndex = fileName.index(fileName.startIndex, offsetBy: 9)
                fileName = String(fileName[..<stringIndex])
            }
            openQuicklookFor(fileURL: fileURL, fileName: fileName)
        }
    }
}

extension HippoConversationViewController: DocumentTableViewCellDelegate {
    func performActionAccordingToStatusOf(message: HippoMessage, inCell cell: DocumentTableViewCell) {
        guard let fileUrl = message.fileUrl else {
            return
        }
        guard message.concreteFileType != nil else {
            return
        }
        
        if DownloadManager.shared.isFileDownloadedWith(url: fileUrl) {
            openQuicklookFor(fileURL: fileUrl, fileName: message.fileName ?? "")
        } else {
            DownloadManager.shared.downloadFileWith(url: fileUrl, name: message.fileName ?? "")
        }
    }
    
    
}
// MARK: - SelfMessageDelegate
extension HippoConversationViewController: SelfMessageDelegate {
    
    func longPressOnMessage(message: HippoMessage, indexPath: IndexPath) {
        if message.messageState == MessageState.MessageDeleted || message.isDateExpired(timeInterval: TimeInterval((BussinessProperty.current.editDeleteExpiryTime ?? 0.0) * 60.0)){
            return
        }
        
        var options = [ActionSheetAction]()
        
        if let edit = editOption(for: message, atIndexPath: indexPath)  {
            options.append(edit)
        }
        
        if let delete = addDeleteOption(for: message, at: indexPath) {
            options.append(delete)
        }
        
        let type: ActionSheetViewController.ActionType = ActionSheetViewController.ActionType.none
        if options.count == 0{
            return
        }
        
        let actionView = ActionSheetViewController.get(with: options, type: type, emojiSelected: { (emojiString) in
            
        }) { (action) in
            
        }
        
        actionView.modalPresentationStyle = .overCurrentContext
        self.present(actionView, animated: false) {
           // actionView.addEmojiInStackView()
            actionView.showViewAnimation()
        }
        
    }
    
    func cancelMessage(message: HippoMessage) {
        if channel != nil{
            for (index, tempMessage) in channel.unsentMessages.enumerated() {
                if tempMessage.messageUniqueID == message.messageUniqueID, message.messageUniqueID != nil {
                    channel.unsentMessages.remove(at: index)
                    messagesGroupedByDate = []
                    updateMessagesGroupedByDate(channel.messages)
                    break
                }
            }
        }
        tableViewChat.reloadData()
    }
    
    func retryMessageUpload(message: HippoMessage) {
        message.status = .none
        message.wasMessageSendingFailed = false
        tableViewChat.reloadData()
        sendMessage(message: message)
    }
    func createChannelIfRequiredAndContinue(replyMessage: HippoMessage?, completion: @escaping ((_ success: Bool, _ result: HippoChannelCreationResult?) -> ())) {
        if channel != nil {
            completion(true, nil)
        } else {
            startNewConversation(replyMessage: replyMessage, completion: completion)
        }
    }
}

extension HippoConversationViewController: ActionTableViewDelegate {
    func performActionFor(selectionId: String, message: HippoMessage) {
        if let channel = self.channel, channel.isSendingDisabled {
            print("isSendingDisabled disabled")
            return
        }
        
        guard let customMessage = message as? HippoActionMessage else {
            return
        }
        customMessage.selectBtnWith(btnId: selectionId)
        tableViewChat.reloadData()
        
        let replyMessage = botGroupID != nil ? customMessage : nil
        if replyMessage?.messageUniqueID == nil {
            replyMessage?.messageUniqueID = String.generateUniqueId()
        }
        createChannelIfRequiredAndContinue(replyMessage: replyMessage) { (_, result) in
            let isReplyMessageSent = result?.isReplyMessageSent ?? false
            
            if !isReplyMessageSent {
               self.sendMessage(message: customMessage)
            }
            if let button = customMessage.getButtonWithId(id: selectionId), let action = button.action, button.buttonType == .action {
                switch action {
                case .audioCall:
//                    self.showAlert(title: "", message: "Audio call", actionComplete: nil)
                    self.startAudioCall()
                case .videoCall:
//                    self.showAlert(title: "", message: "Video call", actionComplete: nil)
                    self.startVideoCall()
                case .openUrl:
                    if let link = button.getUrlToOpen() {
                        self.presentSafariViewcontorller(for: link)
                    }
                default:
                    break
                }
            }
        }
    }
    func presentSafariViewcontorller(for url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.navigationController?.setTheme()
        self.navigationController?.pushViewController(safariVC, animated: true)
    }
}
extension HippoConversationViewController: CreatePaymentDelegate {
    func sendMessage(for store: PaymentStore) {
        let message = HippoMessage(message: "", type: .hippoPay, uniqueID: String.generateUniqueId(), chatType: channel?.chatDetail?.chatType)
        let custom_action = store.getJsonToSend()
        message.actionableMessage = FuguActionableMessage(dict: custom_action)
        message.rawJsonToSend = ["custom_action": custom_action]
        addMessageInUnsentArray(message: message)
        updateMessagesArrayLocallyForUIUpdation(message)
        scrollToBottomWithIndexPath(animated: true)
        
        publishMessageOnChannel(message: message)
    }
    func backButtonPressed(shouldUpdate: Bool){
        //code
        print("")
    }
    func paymentCardPayment(isSuccessful: Bool) {
        //code
    }
}

extension HippoConversationViewController {
    func getNormalMessageTableViewCell(tableView: UITableView, isOutgoingMessage: Bool, message: HippoMessage, indexPath: IndexPath) -> UITableViewCell {
        switch isOutgoingMessage {
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMessageTableViewCell", for: indexPath) as! SupportMessageTableViewCell
            let bottomSpace = getBottomSpaceOfMessageAt(indexPath: indexPath, message: message)
            cell.updateBottomConstraint(bottomSpace)
            let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: message)
            return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel?.id ?? labelId, chatMessageObject: message)
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelfMessageTableViewCell", for: indexPath) as! SelfMessageTableViewCell
            cell.delegate = self
            let bottomSpace = getBottomSpaceOfMessageAt(indexPath: indexPath, message: message)
            cell.updateBottomConstraint(bottomSpace)
            cell.messageLongPressed = {[weak self](message) in
                DispatchQueue.main.async {
                    self?.longPressOnMessage(message: message, indexPath: indexPath)
                }
            }
            return cell.configureIncomingMessageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath)
        }
    }
}


extension HippoConversationViewController: NavigationTitleViewDelegate {
    func backButtonClicked() {
        
    }
    
    func imageIconClicked() {
        if let id = channel?.chatDetail?.assignedAgentID, id > 0 {
            openProfile(for: -1, agentId: "\(id)", profile: nil)
        } else {
            self.backButtonClicked()
        }
    }
    func titleClicked() {
        if let id = channel?.chatDetail?.assignedAgentID, id > 0 {
            openProfile(for: -1, agentId: "\(id)", profile: nil)
        }
    }
    func openProfile(for channelId: Int, agentId: String?, profile: ProfileDetail?) {
//        let presenter = AgentProfilePresenter(channelID: channelId, agentID: agentId, profile: profile)
//        let vc = AgentProfileViewController.get(presenter: presenter)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HippoConversationViewController: CardMessageDelegate {
    func cardSelected(cell: CardMessageTableViewCell, card: MessageCard, message: HippoMessage) {
        if let channel = self.channel, channel.isSendingDisabled {
            print("isSendingDisabled disabled")
            return
        }
        
        message.selectedCardId = card.id
        sendMessage(message: message)
        cell.set(message: message)
    }
    func labelContainerClicked(cell: CardMessageTableViewCell, card: MessageCard, message: HippoMessage) {
        let profile = ProfileDetail(json: [:])
        profile.image = card.image?.url.path
        profile.fullName = card.title
        profile.rating = card.rating
        
        openProfile(for: -1, agentId: card.id, profile: profile)
    }
}

extension HippoConversationViewController: PaymentMessageCellDelegate {
    func cellButtonPressed(message: HippoMessage, card: HippoCard) {
//        if let channel = self.channel, channel.isSendingDisabled {
//            print("isSendingDisabled disabled")
//            return
//        }
//        guard let selectedCard = (card as? PayementButton)?.selectedCardDetail, let url = URL(string: selectedCard.paymentUrlString ?? "") else {
//            generatePaymentUrl(for: message, card: card)
//            return
//        }
//        initatePayment(for: url)
        if let channel = self.channel, channel.isSendingDisabled {
            print("isSendingDisabled disabled")
            return
        }
        guard let selectedCard = (card as? PayementButton)?.selectedCardDetail else {
            //, let url = URL(string: selectedCard.paymentUrlString ?? "") else {
            //generatePaymentUrl(for: message, card: card)
            return
        }
        
        proceedToPayMessage = message
        proceedToPaySelectedCard = selectedCard
        proceedToPayChannel = channel
        
        if HippoConfig.shared.appUserType == .customer{
            closeKeyBoard()
            switch addedPaymentGatewaysArr.count{
            case 0:
                showAlertWith(message: HippoStrings.noPaymentMethod, action: nil)
            case 1:
                if let currencyStr = selectedCard.currency, let currencyAllowed = addedPaymentGatewaysArr.first?.currency_allowed{
                    if currencyAllowed.contains(currencyStr){
                        if let proceedToPayMessage = proceedToPayMessage, let proceedToPayChannel = proceedToPayChannel, let proceedToPaySelectedCard = proceedToPaySelectedCard{
                            generatePaymentUrlWithSelectedPaymentGateway(for: proceedToPayMessage, card: proceedToPaySelectedCard, selectedPaymentGateway: addedPaymentGatewaysArr.first, proceedToPayChannel: proceedToPayChannel)
                            return
                        }
                    }else{
                       showAlertWith(message: HippoStrings.noPaymentMethod, action: nil)
                    }
                }
                break
            default:
                if let currencyStr = selectedCard.currency{
                    actionSheetTitleArr.removeAll()
                    actionSheetImageArr.removeAll()
                    for i in 0..<addedPaymentGatewaysArr.count{
                        if let currencyAllowedArr = addedPaymentGatewaysArr[i].currency_allowed {
                            if currencyAllowedArr.contains(currencyStr){
                                if let gatewayName = addedPaymentGatewaysArr[i].gateway_name {
                                    if let gatewayImage = addedPaymentGatewaysArr[i].gateway_image {
                                        actionSheetTitleArr.append(gatewayName)
                                        actionSheetImageArr.append(gatewayImage)
                                    }
                                }
                            }
                        }
                    }
                    if actionSheetTitleArr.count > 0{
                        heightForActionSheet = CGFloat((actionSheetTitleArr.count * 60))
                        isProceedToPayActionSheet = true
                        openCustomSheet()
                    }else{
                      showAlertWith(message: HippoStrings.noPaymentMethod, action: nil)
                    }
                }
                
                break
            }
        }else{
            if let channel = self.channel, channel.isSendingDisabled {
                print("isSendingDisabled disabled")
                return
            }
            guard let selectedCard = (card as? PayementButton)?.selectedCardDetail, let url = URL(string: selectedCard.paymentUrlString ?? "") else {
                generatePaymentUrl(for: message, card: card, selectedPaymentGateway: nil)
                return
            }
            initatePayment(for: url)
        }
    }
    
    func initatePayment(for url: URL) {
        let config = WebViewConfig(url: url, title: HippoStrings.payment)
        let vc = PrePaymentViewController.getNewInstance(config: config)
        vc.isComingForPayment = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func initatePayment(for razorPayDic: RazorPayData) {
    
    }
    
    func generatePaymentUrl(for message: HippoMessage, card: HippoCard, selectedPaymentGateway: PaymentGateway?) {
        guard let selectedCard = (card as? PayementButton)?.selectedCardDetail, let channelId = channel?.id else {
            HippoConfig.shared.log.error("cannot find selected card.... Please select the card", level: .error)
            return
        }
        
        HippoConfig.shared.delegate?.startLoading(message: "Redirecting to payment...")
        
        PaymentStore.generatePaymentUrl(channelId: channelId, message: message, selectedCard: selectedCard, selectedPaymentGateway: selectedPaymentGateway) { (success, data) in
            HippoConfig.shared.delegate?.stopLoading()
            guard success, let result = data else {
                return
            }
            guard let paymentUrl = result["payment_url"] as? String else {
                return
            }
            HippoConfig.shared.log.debug("Response --\(result)", level: .response)
            selectedCard.paymentUrlString = paymentUrl
            
            guard let url = URL(string: paymentUrl) else {
                return
            }
            self.initatePayment(for: url)
        }
        
    }
    

    func getNextMessageInDateGroupOfMessageAt(indexPath: IndexPath) -> HippoMessage? {
        let row = indexPath.row
        let section = indexPath.section

        guard messagesGroupedByDate.count > section else {
            return nil
        }
        
        let groupedArray = messagesGroupedByDate[section]
        
        guard groupedArray.count > row + 1 else {
            return nil
        }
        
        let nextMessage = groupedArray[row+1]
        return nextMessage
    }
    
    
    
    func getBottomSpaceOfMessageAt(indexPath: IndexPath, message: HippoMessage) -> CGFloat {
        guard let nextMessage = getNextMessageInDateGroupOfMessageAt(indexPath: indexPath) else {
            return 1
        }
        
        if nextMessage.senderId != message.senderId {
            return 10 // bottom space from other user massage
         }
        
        return 0 // onle top pennding for same user message extra bottom space is 0
    }
    

    func generatePaymentUrlWithSelectedPaymentGateway(for message: HippoMessage, card: CustomerPayment, selectedPaymentGateway: PaymentGateway?, proceedToPayChannel: HippoChannel?) {
        let selectedCard = card
        guard let channelId = proceedToPayChannel?.id else {
            HippoConfig.shared.log.error("cannot find selected card.... Please select the card", level: .error)
            return
        }
        HippoConfig.shared.delegate?.startLoading(message: "Redirecting to payment...")
        PaymentStore.generatePaymentUrl(channelId: channelId, message: message, selectedCard: selectedCard, selectedPaymentGateway: selectedPaymentGateway) { (success, data) in
            HippoConfig.shared.delegate?.stopLoading()
            guard success, let result = data else {
                return
            }
            if let razorPayDic = RazorPayData().getRazorPayDic(result){
                if razorPayDic.amount != nil{
                    self.initatePayment(for: razorPayDic)
                    return
                }
            }
            
            guard let paymentUrl = result["payment_url"] as? String else {
                return
            }
            HippoConfig.shared.log.debug("Response --\(result)", level: .response)
            selectedCard.paymentUrlString = paymentUrl
            guard let url = URL(string: paymentUrl) else {
                return
            }
            self.initatePayment(for: url)
        }
    }

}

extension HippoConversationViewController: submitButtonTableViewDelegate
{
    func submitButtonPressed(hippoMessage: HippoMessage) {
        
        createChannelIfRequiredAndContinue(replyMessage: nil) { (success, result) in
            
            self.sendMessage(message: hippoMessage)
            self.tableViewChat.reloadData()
        }
    }
    
    
}

//MARK:- COLLECTION VIEW DELEAGATE/DATASOURCE
extension HippoConversationViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let attachmentOptionCVCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentOptionCollectionViewCell", for: indexPath) as? AttachmentOptionCollectionViewCell else { return UICollectionViewCell() }
        attachmentOptionCVCell.attachmentDetail = attachments[indexPath.item]
        return attachmentOptionCVCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let param = UIScreen.main.bounds.width/4 - 8
        return CGSize(width: param, height: param)
    }
    
    
}




//MARK:- COLLECTIONVIEW CELL
class AttachmentOptionCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var imageViewAttachment: UIImageView!
    @IBOutlet weak var labelAttachment: UILabel!
    
    var attachmentDetail : Attachment?{
        didSet{
            imageViewAttachment?.image = attachmentDetail?.icon
            labelAttachment?.text = attachmentDetail?.title
            imageViewAttachment?.tintColor = HippoConfig.shared.theme.moreOptionsIconsTintColor
            labelAttachment?.tintColor = HippoConfig.shared.theme.moreOptionsTitlesTintColor
        }
    }
}

class Attachment : NSObject{
    
    var icon  : UIImage?
    var title : String?
    
    init(icon : UIImage?, title : String?) {
        self.icon = icon
        self.title = title
    }
}

extension HippoConversationViewController : paymentCardPaymentOfCreatePaymentDelegate{
    func paymentCardPaymentOfCreatePayment(isSuccessful: Bool) {
        if isSuccessful == true{
            //self.attachmentViewHeightConstraint.constant = 0
            paymentCardPaymentOfCreatePaymentCalled()
        }
    }
}

extension HippoConversationViewController{
    
    //MARK:- Edit / Delete functions
    func editOption(for message: HippoMessage, atIndexPath indexPath: IndexPath)-> ActionSheetAction? {
        if message.type != .normal{
            return nil
        }
        
        let edit = ActionSheetAction(icon: HippoConfig.shared.theme.editIcon, title: HippoStrings.edit, subTitle: nil, attTitle: nil, tag: nil) { (action) in
            
            self.sendTypingStatusMessage(isTyping: TypingMessage.stopTyping)
            self.highlightMessageAt(indexPath: indexPath)
            self.startEditing(with: message, indexPath: indexPath)
            
        }
        return edit
    }

    func addDeleteOption(for message: HippoMessage, at indexPath: IndexPath)-> ActionSheetAction? {
        if message.type == .normal || message.type == .imageFile || message.type == .attachment{
            
        }else{
            return nil
        }
        
        let delete = ActionSheetAction(icon: HippoConfig.shared.theme.deleteIcon, title: HippoStrings.delete, subTitle: nil, attTitle: nil, tag: nil) { (action) in
            self.showOptionAlert(title: nil, message: HippoStrings.deleteMessagePopup, successButtonName: HippoStrings.deleteForEveryone, successComplete: { (successAction) in
                self.apiHitToEditDeleteMsg(message: message, isDeleted: true) { (status) in
                    if status{
                        
                    }
                }
            }, failureButtonName: HippoStrings.cancel) { (failureAction) in
                //do nothing
            }
        }
        return delete
    }
    
    
    func apiHitToEditDeleteMsg(message : HippoMessage, isDeleted : Bool, completion: ((_ success: Bool) -> Void)?){
        if FuguNetworkHandler.shared.isNetworkConnected == false {
           checkNetworkConnection()
           completion?(false)
           return
        }
        
        var params = [String : Any]()
        if currentUserType() == .agent{
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }else{
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }
        params["en_user_id"] = currentEnUserId()
        params["channel_id"] = channelId
        params["message_muid"] = message.messageUniqueID
        params["task_status"] = isDeleted ? 1 : 2
        if isDeleted == false{
            params["new_message"] = message.message
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.editDeleteMessage.rawValue) { (response, error, _, statusCode) in
            if statusCode == 200{
                completion?(true)
            }else{
                completion?(false)
            }
        }
    }
    
    func highlightMessageAt(indexPath: IndexPath) {
        tableViewChat.allowsSelection = true
        tableViewChat.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableViewChat.allowsSelection = false
    }
    
    func openSelectTemplate(){
        let vc = SelectPresciptionTemplateController.getNewInstance(channelId: channelId)
        vc.pdfUploadResult = {[weak self](result) in
            DispatchQueue.main.async {
                self?.closeAttachment()
                let message = HippoMessage(message: "", type: .attachment, uniqueID: self?.generateUniqueId(), imageUrl: result.url, thumbnailUrl: result.thumbnail_url, localFilePath: nil, chatType: self?.channel?.chatDetail?.chatType)
                message.fileName = result.file_name
                message.localImagePath = self?.getCacheDirectoryUrlForFileWith(name: result.file_name ?? "").path
                message.fileUrl = result.url
                self?.addMessageInUnsentArray(message: message)
                self?.updateMessagesArrayLocallyForUIUpdation(message)
                self?.scrollToBottomWithIndexPath(animated: true)
                self?.handleUploadSuccessOfFileIn(message: message)
            }
        }
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        self.present(navController, animated: true, completion: {
            vc.showViewAnimation()
        })
    }
}
