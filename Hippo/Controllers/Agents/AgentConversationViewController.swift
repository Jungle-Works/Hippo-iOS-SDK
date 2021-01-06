//
//  AgentConversationViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 19/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit
import Photos
//import SZMentionsSwift

protocol AgentChatDeleagate: class {
    func updateConversationWith(channelId: Int, lastMessage: HippoMessage, unreadCount: Int)
}


class AgentConversationViewController: HippoConversationViewController {
    
    struct IntializationRequest {
        let config: MessageSendingViewConfig
        let dataManager: MentionDataManager
    }
    
    // MARK: -  IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
//    @IBOutlet weak var audioButton: UIBarButtonItem!
    @IBOutlet var backgroundView: UIView!
//    @IBOutlet var backButton: UIButton!
    @IBOutlet var sendMessageButton: UIButton!
//    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var messageTextView: HippoMessageTextView!
    //    @IBOutlet weak var errorContentView: UIView!
    //    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var textViewBgView: UIView!
    @IBOutlet var placeHolderLabel: UILabel!
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet var addFileButtonAction: UIButton!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet weak var loaderView: So_UIImageView!
//    @IBOutlet weak var infoButton: UIBarButtonItem!
    
//    @IBOutlet weak var videoButton: UIBarButtonItem!
    //    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentViewBottomConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var hieghtOfNavigationBar: NSLayoutConstraint!
    @IBOutlet weak var loadMoreActivityTopContraint: NSLayoutConstraint!
    @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!

//    @IBOutlet weak var bottomContentView: So_UIView!//
//    @IBOutlet weak var paymentButton: UIButton!//
    
//    @IBOutlet weak var botActionButton: UIButton!

    @IBOutlet weak var retryLabelView: UIView!
    @IBOutlet weak var retryLoader: UIActivityIndicatorView!
    @IBOutlet weak var labelViewRetryButton: UIButton!

    @IBOutlet weak var takeOverButtonContainer: UIView!
    @IBOutlet weak var takeOverButton: UIButton!
    @IBOutlet weak var takeOverButtonHeightConstraint: NSLayoutConstraint!
    
    //NewConversation view
    @IBOutlet weak var newConversationContainer: So_UIView!
    @IBOutlet weak var newConversationLabel: So_CustomLabel!
    @IBOutlet weak var newConversationShadow: So_UIView!
    @IBOutlet weak var newConversationCountButton: UIButton!

    @IBOutlet weak var collectionViewOptions: UICollectionView!
    @IBOutlet weak var attachmentViewHeightConstraint: NSLayoutConstraint!

    //MARK: - Outlets for MessageSendingView
    @IBOutlet weak var mentionsListTableView: UITableView!
    @IBOutlet weak var mentionsListTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var Button_CancelEdit : UIButton!{
        didSet{
            Button_CancelEdit.imageView?.tintColor = .black
            Button_CancelEdit.setImage(HippoConfig.shared.theme.cancelIcon, for: .normal)
        }
    }
    @IBOutlet weak var Button_EditMessage : UIButton!{
        didSet{
            Button_EditMessage.imageView?.tintColor = .black
            Button_EditMessage.setImage(UIImage(named: "tick_green", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    // MARK: - PROPERTIES
    var heightOfNavigation: CGFloat = 0
    var isSingleChat = false
    var botActionView = BotTableView.loadView(CGRect.zero)
    var custombarbuttonParam : CGFloat = 32.0
    var messageInEditing : HippoMessage?
    var editingMessageIndex : IndexPath?
    var channelType : Int?
    //MARK: - Variables for MessageSendingView
    private let animationDuration: TimeInterval = 0.3
    var maxMentionViewHeight: CGFloat = windowScreenHeight
    let heightOfTableViewCell: CGFloat = 50
    private let leadingConstantForSelectedBar: CGFloat = 8
//    weak var delegate: MessageSendingViewDelegate?
    private var dataSource: MentionTableDataSourceDelegate!
    private var dataManager: MentionDataManager!
    private var mentionListener: MentionListener!
    private var messageSendingViewConfig: MessageSendingViewConfig = MessageSendingViewConfig()
//    private var timer: Timer?
//    var lastUnsendMessage:String?
    
    // MARK: - Computed Properties
    var localFilePath: String {
        get {
            let existingImageCounter = FuguDefaults.totalImagesInImagesFlder() + 1
            guard
                let documentImageUrl = FuguDefaults.fuguImagesDirectory(),
                existingImageCounter > 0
                else { return "" }
            return documentImageUrl.appendingPathComponent("\(existingImageCounter).jpg").path
        }
    }

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewOptions?.delegate = self
        collectionViewOptions?.dataSource = self
        HippoConfig.shared.notifyDidLoad()
        setNavBarHeightAccordingtoSafeArea()
        configureChatScreen()
        self.setTitleForCustomNavigationBar()
        getAgentsData()
        guard channel != nil else {
            startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
                if success {
                    self?.populateTableViewWithChannelData()
                    self?.fetchMessagesFrom1stPage()
                }
            })
            return
        }
        //        infoButton.isHidden = true
        
        let unsendMessage = self.getUnsentMessage()
        self.setUpLastUnsendMessage(message:unsendMessage)
        
        populateTableViewWithChannelData()
        fetchMessagesFrom1stPage()
    }
    
    override func didSetChannel() {
        channel?.delegate = self
        if !channel.isSubscribed(){
            channel?.subscribe()
        }
    }
    
    override func closeAttachment(){
        self.attachmentViewHeightConstraint.constant = 0
    }
    
    override func closeKeyBoard() {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        messageTextView.contentInset.top = 8
        handleInfoIcon()
        handleVideoIcon()
        handleAudioIcon()
        setNavigationTitle(title: label)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let unsendMessage = self.getUnsentMessage()
//        self.setUpLastUnsendMessage(message:unsendMessage)
        
        if !loaderView.isHidden {
            startLoaderAnimation()
        }
        AgentConversationManager.getUserUnreadCount()
        reloadVisibleCellsToStartActivityIndicator()
        
    }
    
    override func startEditing(with message : HippoMessage, indexPath : IndexPath){
        self.editingMessageIndex = indexPath
        self.messageEditingStarted(with: message)
    }
    override func reloadVisibleCellsToStartActivityIndicator() {
        let visibleCellsIndexPath = tableViewChat.visibleCells
        
        for cell in visibleCellsIndexPath {
            if let outImageCell = cell as? OutgoingImageCell, !outImageCell.customIndicator.isHidden {
                outImageCell.startIndicatorAnimation()
            }
            
            if let inImageCell = cell as? IncomingImageCell, !inImageCell.customIndicator.isHidden {
                inImageCell.startIndicatorAnimation()
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
//            self.bottomSpaceOfFooterView.constant = 0
        }
//        var dict = HippoConfig.folder.object(forKey: "StoredUnsendMessages") as? [String: Any] ?? [:]
//        dict["\(channelId)"] = messageTextView.text
//        HippoConfig.folder.set(value: dict, forKey: "StoredUnsendMessages")
        var dict = FuguDefaults.object(forKey: "StoredUnsendMessages") as? [String: Any] ?? [:]
        dict["\(channelId)"] = messageTextView.text
        FuguDefaults.set(value: dict, forKey: "StoredUnsendMessages")
        
    }
    
    override func backButtonClicked() {
        backbtnClicked()
    }
    
    override func titleClicked() {
        titleButtonclicked()
    }
    
    override func paymentCardPaymentOfCreatePaymentCalled(){
        self.attachmentViewHeightConstraint.constant = 0
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        guard !mentionsListTableView.isHidden && mentionsListTableViewHeightConstraint.constant > 0 else {
//            return super.hitTest(point, with: event)
//        }
//        let pointForTableView = mentionsListTableView.convert(point, from: self)
//        if mentionsListTableView.bounds.contains(pointForTableView) {
//            return mentionsListTableView.hitTest(pointForTableView, with: event)
//        }
//
//        return super.hitTest(point, with: event)
//    }
    
    

    func navigationSetUp() {
         setTitleButton()
         if HippoConfig.shared.theme.sendBtnIcon != nil {
             sendMessageButton.tintColor = HippoConfig.shared.theme.themeColor
             sendMessageButton.setImage(HippoConfig.shared.theme.sendBtnIcon, for: .normal)
            
             sendMessageButton.setTitle("", for: .normal)
         } else { sendMessageButton.setTitle(HippoStrings.send, for: .normal) }
         
         if HippoConfig.shared.theme.addButtonIcon != nil {
             addFileButtonAction.tintColor = HippoConfig.shared.theme.themeColor
             addFileButtonAction.setImage(HippoConfig.shared.theme.addButtonIcon, for: .normal)
     
             addFileButtonAction.setTitle("", for: .normal)
         } else { addFileButtonAction.setTitle("ADD", for: .normal) }
         
        if HippoConfig.shared.theme.moreOptionsButtonIcon != nil {
                moreOptionsButton.tintColor = HippoConfig.shared.theme.themeColor
                moreOptionsButton.setImage(HippoConfig.shared.theme.moreOptionsButtonIcon, for: .normal)
        
                moreOptionsButton.setTitle("", for: .normal)
        } else { moreOptionsButton.setTitle("More Options", for: .normal) }
        
         if !label.isEmpty {
             setNavigationTitle(title: label)
         } else if let businessName = userDetailData["business_name"] as? String {
             label = businessName
             setNavigationTitle(title: label)
         }
         
     }

    // MARK: - UIButton Actions
    
    @IBAction func retryLabelButtonTapped(_ sender: Any) {
        retryLoader.isHidden = false
        labelViewRetryButton.isHidden = true
        fuguDelay(2.0) {
            self.fetchMessagesFrom1stPage()
        }
    }

    func hideRetryLabelView() {
        labelViewRetryButton.isHidden = false
        retryLoader.isHidden = true
        retryLabelView.isHidden = true
    }

    @IBAction func audioButtonClicked(_ sender: Any) {
        startAudioCall()
    }
    
    @IBAction func videoCallButtonClicked(_ sender: Any) {
        startVideoCall()
    }
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        
        guard let channelDetail = channel?.chatDetail else {
            handleInfoIcon()
            return
        }
        
        guard let vc = AgentChatInfoViewController.get(chatDetail: channelDetail, userImage: self.userImage) else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addAttachmentButtonAction(_ sender: UIButton) {
        attachmentViewHeightConstraint.constant = attachmentViewHeightConstraint.constant == 128 ? 0 : 128
    }
    
    @IBAction func addImagesButtonAction(_ sender: UIButton) {
        if (channel != nil && !channel.isSubscribed()) || !FuguNetworkHandler.shared.isNetworkConnected {
            buttonClickedOnNetworkOff()
            return
        }
        self.attachmentButtonclicked(sender)
    }
    func buttonClickedOnNetworkOff() {
        guard !FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        messageTextView.resignFirstResponder()
        showAlertForNoInternetConnection()
    }
    
    
    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
//        if channel != nil, !channel.isSubscribed() {
//            buttonClickedOnNetworkOff()
//            return
//        }
//        if isMessageInvalid(messageText: messageTextView.text) {
//            return
//        }
//        let trimmedMessage = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//
//        let message = HippoMessage(message: trimmedMessage, type: .normal, uniqueID: String.generateUniqueId(), chatType: channel?.chatDetail?.chatType)
//        channel?.unsentMessages.append(message)
//
//        if channel != nil {
//            addMessageToUIBeforeSending(message: message)
//            self.sendMessage(message: message)
//        } else {
//            //TODO: - Loader animation
//            startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
//                if success {
//                    self?.populateTableViewWithChannelData()
//                    self?.addMessageToUIBeforeSending(message: message)
//                    self?.sendMessage(message: message)
//                }
//            })
//        }
        
        let mentions = messageTextView.isPrivateMode ? mentionListener.mentions : []
        self.sendButtonClicked(mentions: mentions, message: messageTextView.text, isPrivateMessage: messageTextView.isPrivateMode, config: self.messageSendingViewConfig)
        
    }

    @IBAction func getBotActions(_ sender: Any) {
        self.closeKeyBoard()
        AgentConversationManager.getBotsAction(userId: self.channel.chatDetail?.customerID ?? 0, channelId: self.channelId) { (botActions) in
            self.addBotActionView(with: botActions)
        }
    }

    func addBotActionView(with botArray: [BotAction]) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        if botArray.isEmpty {
            showAlertWith(message: HippoStrings.noBotActionAvailable, action: nil)
            return
        }
        self.botActionView.removeFromSuperview()
        self.botActionView.frame = window.frame
        self.botActionView.delegate = self
        self.botActionView.setupCell(botArray)
        self.botActionView.alpha = 0.0
        window.addSubview(self.botActionView)
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.botActionView.alpha = 1.0
        }
    }
    
    func getUnsentMessage() -> String{
//        let unsentCache = HippoConfig.folder.object(forKey: "StoredUnsendMessages") as? [String: Any]
        let unsentCache = FuguDefaults.object(forKey: "StoredUnsendMessages") as? [String: Any] ?? [:]
//        print(unsentCache ?? [:])
        let value = (unsentCache["\(channelId)"]) ?? ""
        return value as! String
    }

    func setUpLastUnsendMessage(message:String){
        messageTextView.text = message
        placeHolderLabel.isHidden = !message.isEmpty
//        manageSendButton()
        self.sendMessageButton.isEnabled = !message.isEmpty
    }
    
    override func addMessageToUIBeforeSending(message: HippoMessage) {
        self.updateMessagesArrayLocallyForUIUpdation(message)
        self.messageTextView.text = ""
        self.newScrollToBottom(animated: false)
    }
    
    
    func backbtnClicked(){
        messageTextView.resignFirstResponder()
        
        channel?.send(message: HippoMessage.stopTyping, completion: {})
        
        let channelID = self.channel?.id ?? -1
        
        clearUnreadCountForChannel(id: channelID)
        
        
        if let lastMessage = getLastMessage() {
            agentConversationDelegate?.updateConversationWith(channelId: channel?.id ?? -1, lastMessage: lastMessage, unreadCount: 0)
        }
        
        if isSingleChat {
            HippoConfig.shared.notifiyDeinit()
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        if channel != nil {
            self.channel.saveMessagesInCache()
            self.channel.deinitObservers()
        }
        NotificationCenter.default.removeObserver(self)
        
        if self.navigationController == nil {
            HippoConfig.shared.notifiyDeinit()
            dismiss(animated: true, completion: nil)
        } else {
            if self.navigationController!.viewControllers.count > 1 {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                HippoConfig.shared.notifiyDeinit()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        
    }

    @IBAction func takeOverButtonPressed(_ sender: Any) {
        askBeforeAssigningChat()
    }
    
    @IBAction func newConversationCountButtonAction(_ sender: Any) {
        //        newConversationLabel.text = nil
        //        newConversationLabel.isHidden = true
        //        newConversationCounter  = 0
        scrollTableViewToBottom(true)
    }
    
    func askBeforeAssigningChat() {
        showOptionAlert(title: "", message: HippoStrings.takeOverChat, successButtonName: HippoStrings.yes, successComplete: { (action) in
            self.assignChatToSelf()
        }, failureButtonName: HippoStrings.no, failureComplete: nil)
    }
    
    func assignChatToSelf() {
        AgentConversationManager.assignChatToMe(channelID: self.channelId) {[weak self] (success) in
            guard success, let strongSelf = self else {
                return
            }
            strongSelf.channel?.chatDetail?.assignedAgentID = currentUserId()
            strongSelf.channel?.chatDetail?.assignedAgentName = HippoConfig.shared.agentDetail?.fullName ?? ""
            strongSelf.channel?.chatDetail?.isBotInProgress = false
            strongSelf.channel?.chatDetail?.disableReply = false
            strongSelf.channel?.isSendingDisabled = false
            strongSelf.setFooterView(isReplyDisabled: strongSelf.channel?.chatDetail?.disableReply ?? false, isBotInProgress: strongSelf.channel?.chatDetail?.isBotInProgress ?? false)
        }
    }


    
    override func titleButtonclicked() {
        guard isCustomerInfoAvailable() else {
            return
        }
        guard let channelDetail = channel?.chatDetail else {
            handleInfoIcon()
            return
        }
        
        guard let vc = AgentChatInfoViewController.get(chatDetail: channelDetail, userImage: userImage) else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func clearUnreadCountForChannel(id: Int) {
        
        ConversationStoreManager().readAllNotificationFor(channelID: id)
    }
    override func adjustChatWhenKeyboardIsOpened(withHeight keyboardHeight: CGFloat) {
        // TODO: - Refactor
        guard tableViewChat.contentSize.height + keyboardHeight > UIScreen.main.bounds.height - heightOfNavigation else {
            return
        }
        
        let diff = ((tableViewChat.contentSize.height + keyboardHeight) - (UIScreen.main.bounds.height - heightOfNavigation))
        
        let keyboardHeightNew = keyboardHeight - textViewBgView.frame.height - UIView.safeAreaInsetOfKeyWindow.bottom
        
        let mini = min(diff, keyboardHeightNew)
        
        var newOffSetY = tableViewChat.contentOffset.y + mini
        if !shouldShiftUpWithThis(newOffsetY: newOffSetY) {
            newOffSetY = getMaxScrollableOffset()
        }
        
        let newOffSet = CGPoint(x: 0, y: newOffSetY)
        tableViewChat.setContentOffset(newOffSet, animated: false)
    }
    
    func getLastMessage() -> HippoMessage? {
        
        for groupedMessages in messagesGroupedByDate.reversed() {
            for tempMessage in groupedMessages.reversed() {
                
                if tempMessage.senderId == getSavedUserId {
                    if tempMessage.status != .none {
                        return tempMessage
                    }
                    continue
                }
                
                return tempMessage
            }
        }
        
        return nil
    }
    
    
    override func checkNetworkConnection() {
        if FuguNetworkHandler.shared.isNetworkConnected {
            hideErrorMessage()
        } else {
            errorMessage = HippoStrings.noNetworkConnection
            showErrorMessage()
        }
    }
    
    func isPaginationInProgress() -> Bool {
        return loadMoreActivityTopContraint.constant == 10
    }
    override func startLoaderAnimation() {
        loaderView.startRotationAnimation()
    }
    
    override func stopLoaderAnimation() {
        loaderView.stopRotationAnimation()
    }
    
    override func getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: ((_ success: Bool) -> Void)?) {

        guard channel != nil else {
            completion?(false)
            return
        }
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            let message = HippoStrings.noNetworkConnection
            showErrorMessage(messageString: message, bgColor: UIColor.red)
            completion?(false)
            return
        }
        
        if HippoConfig.shared.agentDetail?.fuguToken == nil {
            showHideActivityIndicator()
            completion?(false)
            return
        }
        processingRequestCount += 1
        if pageStart == 1, channel.messages.count == 0 {
            startLoaderAnimation()
            disableSendingNewMessages()
        }  else if !isPaginationInProgress()  {
            //            startGettingNewMessages()
        }
        storeResponse = nil
        
        let request = MessageStore.messageRequest(pageStart: pageStart, showLoader: false, pageEnd: pageEnd, channelId: channel.id, labelId: -1)
        
        storeRequest = request
        
        MessageStore.getMessages(requestParam: request, ignoreIfInProgress: false) {[weak self] (response, isCreateConversationRequired)  in
            guard self != nil else {
                completion?(false)
                return
            }
            self?.processingRequestCount -= 1
            
            if self!.processingRequestCount < 1 {
                self?.hideErrorMessage()
            }
            self?.enableSendingNewMessages()
            self?.stopLoaderAnimation()
            self?.showHideActivityIndicator(hide: true)
            self?.isGettingMessageViaPaginationInProgress = false

            guard let result = response, result.isSuccessFull, let weakself = self else {
                completion?(false)
                self?.goForApiRetry()
                return
            }
            weakself.storeResponse = result
            weakself.hideRetryLabelView()
            weakself.handleSuccessCompletionOfGetMessages(result: result, request: request, completion: completion)
        }
    }

    func goForApiRetry() {
        if FuguNetworkHandler.shared.isNetworkConnected{
            //If There are No Cached Msg
            if self.messagesGroupedByDate.count == 0 {
            }
            else{
                //If there are cached msgs
                retryLabelView.isHidden = false
                retryLoader.isHidden = true
                labelViewRetryButton.isHidden = false
            }
        }
    }
    
    func handleSuccessCompletionOfGetMessages(result: MessageStore.ChannelMessagesResult, request: MessageStore.messageRequest, completion: ((_ success: Bool) -> Void)?) {
        
        
        channel?.chatDetail = result.chatDetail
        handleInfoIcon()
        handleVideoIcon()
        handleAudioIcon()
        handleMoreButton()
        
        var messages = result.newMessages
        let newMessagesHashMap = result.newMessageHashmap

        label = result.channelName

        setTitleForCustomNavigationBar()
        
        if request.pageStart == 1 && messages.count > 0 {
            filterMessages(newMessagesHashMap: newMessagesHashMap, lastMessage: messages.last!)
        } else {
            messages = filterForMultipleMuid(newMessages: messages, newMessagesHashMap: newMessagesHashMap)
        }
        updateMessagesInLocalArrays(messages: messages)
        if channel != nil {
            self.channel.saveMessagesInCache()
        }
        
        let contentOffsetBeforeNewMessages = tableViewChat.contentOffset.y
        let contentHeightBeforeNewMessages = tableViewChat.contentSize.height
        tableViewChat.reloadData()
        
        if request.pageStart > 1 {
            keepTableViewWhereItWasBeforeReload(oldContentHeight: contentHeightBeforeNewMessages, oldYOffset: contentOffsetBeforeNewMessages)
        }
//        if result.isSendingDisabled {
//            disableSendingReply()
//            setFooterView(isReplyDisabled: result.isSendingDisabled, isBotInProgress: result.isBotInProgress)
//        }
        if result.isSendingDisabled {
            disableSendingReply()
            setFooterView(isReplyDisabled: result.isSendingDisabled, isBotInProgress: result.isBotInProgress)
        }else{
            enableSendingReply()
        }
        
        if request.pageStart == 1, request.pageEnd == nil {
            newScrollToBottom(animated: true)
            sendReadAllNotification()
        }
        
        willPaginationWork = result.isMoreDataToLoad
        
        completion?(true)
    }
    
    
    func keepTableViewWhereItWasBeforeReload(oldContentHeight: CGFloat, oldYOffset: CGFloat) {
        let newContentHeight = tableViewChat.contentSize.height
        let differenceInContentSizes = newContentHeight - oldContentHeight
        
        let oldYPosition = differenceInContentSizes + oldYOffset
        
        let newContentOffset = CGPoint(x: 0, y: oldYPosition)
        
        tableViewChat.setContentOffset(newContentOffset, animated: false)
        
    }
    
    
    override func startNewConversation(replyMessage: HippoMessage?, completion: ((_ success: Bool, _ result: HippoChannelCreationResult) -> Void)?) {
        
        disableSendingNewMessages()
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            errorMessage = HippoStrings.noNetworkConnection
            showErrorMessage()
            disableSendingNewMessages()
            return
        }
        
        startLoaderAnimation()
        
        guard let detail = HippoConfig.shared.agentDetail, !detail.fuguToken.isEmpty else {
            enableSendingNewMessages()
            stopLoaderAnimation()
            return
        }
        
        if isDefaultChannel() {
            
        } else if agentDirectChatDetail != nil {
            HippoChannel.get(withFuguChatAttributes: agentDirectChatDetail!) { [weak self] (result) in
                self?.enableSendingNewMessages()
                self?.channelCreatedSuccessfullyWith(result: result)
                completion?(result.isSuccessful, result)
            }
        } else {
            enableSendingNewMessages()
            stopLoaderAnimation()
        }
    }
    
    func enableSendingNewMessages() {
        addFileButtonAction.isUserInteractionEnabled = true
        moreOptionsButton.isUserInteractionEnabled = true
        messageTextView.isEditable = true
    }
    
    func disableSendingNewMessages() {
        addFileButtonAction.isUserInteractionEnabled = false
        moreOptionsButton.isUserInteractionEnabled = false
        messageTextView.isEditable = false
    }
    
    func channelCreatedSuccessfullyWith(result: HippoChannelCreationResult) {
        if let error = result.error {
            errorMessage = error.localizedDescription
            showErrorMessage()
            updateErrorLabelView(isHiding: true)
        }
        guard result.isSuccessful else {
            stopLoaderAnimation()
            return
        }
        channel = result.channel
        channel.delegate = self
        if !channel.isSubscribed(){
            channel?.subscribe()
        }
        stopLoaderAnimation()
        fetchMessagesFrom1stPage()
    }
    
    func updateChatInfoWith(chatObj: AgentConversation) {
        
        if let channelId = chatObj.channel_id, channelId > 0 {
            self.channel = AgentChannelPersistancyManager.shared.getChannelBy(id: channelId)
        }
        self.channelType = chatObj.channel_type
        self.label = chatObj.label ?? ""
        self.userImage = chatObj.user_image ?? ""
    }
    
    // MARK: - Type Methods
    class func getWith(conversationObj: AgentConversation) -> AgentConversationViewController {
        let vc = getNewInstance()
        vc.channelType = conversationObj.channel_type
        vc.updateChatInfoWith(chatObj: conversationObj)
        return vc
    }
    
    
    class func getWith(chatAttributes: AgentDirectChatAttributes) -> AgentConversationViewController {
        let vc = getNewInstance()
        vc.agentDirectChatDetail = chatAttributes
        vc.label = chatAttributes.channelName
        return vc
    }
    
    class func getWith(channelID: Int, channelName: String, channelType : channelType? = .DEFAULT) -> AgentConversationViewController {
        let vc = getNewInstance()
        vc.channel = AgentChannelPersistancyManager.shared.getChannelBy(id: channelID)
//        vc.label = channelName
        if channelName != ""{
            vc.label = channelName
        }else{
            vc.label = vc.channel.chatDetail?.customerName ?? ""
        }
        vc.channelType = channelType?.rawValue
        return vc
    }
    
    private class func getNewInstance() -> AgentConversationViewController {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AgentConversationViewController") as! AgentConversationViewController
        return vc
    }
    
    
}

// MARK: - HELPERS
extension AgentConversationViewController {
    
 
    
    func handleVideoIcon() {
        setTitleButton()
        
        if isDirectCallingEnabledFor(type: .video) {
            
            view_Navigation.video_button.tintColor = HippoConfig.shared.theme.headerTextColor
            view_Navigation.video_button.isEnabled = true
            view_Navigation.video_button.setImage(HippoConfig.shared.theme.videoCallIcon, for: .normal)
            view_Navigation.video_button.isHidden = false
        } else {
            view_Navigation.video_button.isHidden = true
            view_Navigation.video_button.setImage(UIImage(), for: .normal)
            view_Navigation.video_button.isEnabled = false
        }
        view_Navigation.video_button.addTarget(self, action: #selector(videoCallButtonClicked(_:)), for: .touchUpInside)
    }
    
    func handleAudioIcon() {
        setTitleButton()
        
        //image icon name = audioCallIcon
        
        if isDirectCallingEnabledFor(type: .audio) {
            view_Navigation.call_button.tintColor = HippoConfig.shared.theme.headerTextColor
            view_Navigation.call_button.isEnabled = true
            view_Navigation.call_button.setImage(HippoConfig.shared.theme.audioCallIcon, for: .normal)
            view_Navigation.call_button.isHidden = false
        } else {
            view_Navigation.call_button.setImage(UIImage(), for: .normal)
            view_Navigation.call_button.isEnabled = false
            view_Navigation.call_button.isHidden = true
        }
        view_Navigation.call_button.addTarget(self, action: #selector(audioButtonClicked(_:)), for: .touchUpInside)
    }
    
    func handleInfoIcon() {
        setTitleButton()
        view_Navigation.info_button.isHidden = false
        view_Navigation.info_button.setImage(HippoConfig.shared.theme.informationIcon, for: .normal)
        view_Navigation.info_button.addTarget(self, action:  #selector(infoButtonClicked), for: UIControl.Event.touchUpInside)
        view_Navigation.info_button.tintColor = HippoConfig.shared.theme.headerTextColor
        view_Navigation.info_button.isEnabled = true
    }
    
    
//    func handleVideoIcon() {
//        setTitleButton()
//        if canStartVideoCall() {
//            videoButton.image = HippoConfig.shared.theme.videoCallIcon
//            videoButton.tintColor = HippoConfig.shared.theme.headerTextColor
//            videoButton.isEnabled = true
//            videoButton.title = nil
//        } else {
//            videoButton.title = ""
//            videoButton.image = nil
//            videoButton.isEnabled = false
//        }
//    }
//    func handleAudioIcon() {
//        setTitleButton()
//        if canStartAudioCall() {
//            audioButton.image = HippoConfig.shared.theme.audioCallIcon
//            audioButton.tintColor = HippoConfig.shared.theme.headerTextColor
//            audioButton.isEnabled = true
//        } else {
//            audioButton.image = nil
//            audioButton.isEnabled = false
//        }
//    }
    func returnRetryCancelButtonHeight(chatMessageObject: HippoMessage) -> CGFloat {
        if chatMessageObject.wasMessageSendingFailed, chatMessageObject.type != MessageType.imageFile, chatMessageObject.status == ReadUnReadStatus.none, isSentByMe(senderId: chatMessageObject.senderId) {
            return 40
        }
        return 0
    }
    
    func configureChatScreen() {
        
        navigationSetUp()
        tableViewSetUp()
        configureFooterView()
        addTapGestureInTableView()
        
        self.messageTextView.font = HippoConfig.shared.theme.typingTextFont
        self.messageTextView.textColor = HippoConfig.shared.theme.typingTextColor
        self.messageTextView.backgroundColor = .clear
        self.messageTextView.tintColor = HippoConfig.shared.theme.messageTextViewTintColor//
//        placeHolderLabel.text = HippoConfig.shared.strings.messagePlaceHolderText
        placeHolderLabel.text = HippoConfig.shared.theme.messagePlaceHolderText == nil ? HippoStrings.messagePlaceHolderText : HippoConfig.shared.theme.messagePlaceHolderText
            //
        hideErrorMessage()
        sendMessageButton.isEnabled = false
        
        if channel != nil, channel.isSendingDisabled == true {
            disableSendingReply()
            setFooterView(isReplyDisabled: channel.isSendingDisabled, isBotInProgress: channel.chatDetail?.isBotInProgress ?? false)
        }
        
        if HippoConfig.shared.theme.chatbackgroundImage != nil {
            tableViewChat.backgroundColor = .clear
            backgroundImageView.image = HippoConfig.shared.theme.chatbackgroundImage
            backgroundImageView.contentMode = .scaleToFill
        }

        self.attachments.append(Attachment(icon : HippoConfig.shared.theme.alphabetSymbolIcon , title : HippoStrings.text))
        self.attachments.append(Attachment(icon : HippoConfig.shared.theme.privateInternalNotesIcon  , title : HippoStrings.internalNotes))
        if BussinessProperty.current.isAskPaymentAllowed{
            self.attachments.append(Attachment(icon : HippoConfig.shared.theme.paymentIcon , title : HippoStrings.payment))
        }
        
        if BussinessProperty.current.eFormEnabled ?? false{
            self.attachments.append(Attachment(icon : HippoConfig.shared.theme.eFormIcon  , title : HippoConfig.shared.strings.presciption))
        }
        
        self.newConversationCountButton.roundCorner(cornerRect: [.topLeft, .bottomLeft], cornerRadius: 5)
        self.newConversationShadow.layer.cornerRadius = 5
        self.newConversationShadow.showShadow(shadowSideAngles: ShadowSideView(topSide: true, leftSide: true, bottomSide: true))
        //        self.newConversationShadow.showShadow(shadowSideAngles: ShadowSideView(topSide: true, leftSide: true, bottomSide: true, rightSide: true))
        //        self.updateNewConversationCountButton(animation: false)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    func getAgentsData() {
        AgentConversationManager.getAgentsList(showLoader: false) {[weak self] (_) in
            self?.intalizeMessageSendingView()
        }
    }
    
    func addTapGestureInTableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AgentConversationViewController.dismissKeyboard(sender:)))
        tapGesture.cancelsTouchesInView = false
        tableViewChat.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(sender: UIGestureRecognizer) {
        
        guard messageTextView.isFirstResponder else {
            return
        }
        
        //Delayed so that tableview gets correct touch event to run didselect
        let currentOffsetY = self.tableViewChat.contentOffset.y
        var newOffsetY = max(0, currentOffsetY - self.getKeyboardHeight())
        
        fuguDelay(0.1) {
            self.messageTextView.resignFirstResponder()
            
            if !self.shouldShiftUpWithThis(newOffsetY: newOffsetY) {
                newOffsetY = self.getMaxScrollableOffset()
            }
            
            let newOffset = CGPoint(x: 0, y: newOffsetY)
            self.tableViewChat.setContentOffset(newOffset, animated: true)
        }
    }
    
    func getKeyboardHeight() -> CGFloat {
        let screenHeight = backgroundView.bounds.height
        let tableViewEnd = tableViewChat.frame.maxY + UIView.safeAreaInsetOfKeyWindow.bottom
        
        let keyboardHeight = screenHeight - tableViewEnd - textViewBgView.frame.height
        
        return messageTextView.isFirstResponder ? keyboardHeight : 0
    }
    
    func getLastVisibleYCoordinateOfTableView() -> CGFloat {
        let tableViewHeight = tableViewChat.frame.height
        let tableViewYOffset = tableViewChat.contentOffset.y
        
        return tableViewYOffset + tableViewHeight
    }
    
    func setNavBarHeightAccordingtoSafeArea() {
        let topInset = UIView.safeAreaInsetOfKeyWindow.top == 0 ? 20 : UIView.safeAreaInsetOfKeyWindow.top
        heightOfNavigation = 44 + topInset
    }
    
    func configureFooterView() {
//        textViewBgView.backgroundColor = .white
        let isPrivate = messageTextView.isPrivateMode
        textViewBgView.backgroundColor = isPrivate ? HippoConfig.shared.theme.privateNoteChatBoxColor : UIColor.white
//        messageTextView.tintColor = isPrivate ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) : UIColor.black
//        bottomContentView.backgroundColor = .white
        if isObserverAdded == false {
            textViewBgView.layoutIfNeeded()
            let inputView = FrameObserverAccessaryView(frame: textViewBgView.bounds)
            inputView.isUserInteractionEnabled = false
            
            messageTextView.inputAccessoryView = inputView
            
            inputView.changeKeyboardFrame { [weak self] (keyboardVisible, keyboardFrame) in
                let value = UIScreen.main.bounds.height - keyboardFrame.minY - UIView.safeAreaInsetOfKeyWindow.bottom
                let maxValue = max(0, value)
                //                self?.textViewBottomConstraint.constant = maxValue
                self?.bottomContentViewBottomConstraint?.constant = maxValue
                
                self?.view.layoutIfNeeded()
            }
            isObserverAdded = true
        }
        
        takeOverButtonContainer.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        takeOverButton.backgroundColor = HippoConfig.shared.theme.themeTextcolor
        takeOverButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
        takeOverButton.setTitle(HippoConfig.shared.theme.takeOverButtonText == nil ? HippoStrings.takeOver : HippoConfig.shared.theme.takeOverButtonText, for: .normal)
        
    }
    
    
    
    func shouldShiftUpWithThis(newOffsetY: CGFloat) -> Bool {
        let tableHeight = tableViewChat.frame.height
        let tableContentHeight = tableViewChat.contentSize.height
        
        return newOffsetY + tableHeight < tableContentHeight + 10
    }
    
    func getMaxScrollableOffset() -> CGFloat {
        let tableHeight = tableViewChat.frame.height
        let tableContentHeight = tableViewChat.contentSize.height
        
        if tableContentHeight > tableHeight {
            return tableContentHeight - tableHeight + 3
        } else {
            return 0
        }
    }
    

    
    func getTopDistanceOfCell(atIndexPath indexPath: IndexPath) -> CGFloat {
        
        let row = indexPath.row
        
        guard row != 0 else {
            return 5
        }
        
        let groupedArray = messagesGroupedByDate[indexPath.section]
        
        let previousMessage = groupedArray[row-1]
        let currentMessage = groupedArray[row]
        
        if previousMessage.senderId == currentMessage.senderId {
            return 1
        } else {
            return 2
        }
    }
    
    func updateTopBottomSpace(cell: UITableViewCell, indexPath: IndexPath) {
        
        let topConstraint = getTopDistanceOfCell(atIndexPath: indexPath)
        if let editedCell = cell as? SelfMessageTableViewCell {
            editedCell.topConstraint.constant = topConstraint
        } else if let editedCell = cell as? SupportMessageTableViewCell {
            editedCell.topConstraint.constant = topConstraint
        }
        else if let editedCell = cell as? IncomingImageCell {
            editedCell.topConstraint.constant = topConstraint + 2
        } else if let editedCell = cell as? OutgoingImageCell {
            editedCell.topConstraint.constant = topConstraint + 2
        }
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @objc func watcherOnTextView() {
        if textInTextField == messageTextView.text,
            typingMessageValue == TypingMessage.stopTyping.rawValue,
            channel != nil {
            
            channel?.send(message: HippoMessage.stopTyping, completion: {})
            self.typingMessageValue = TypingMessage.startTyping.rawValue
        } else {
            textInTextField = messageTextView.text
        }
    }
    
    func showHideActivityIndicator(hide: Bool = true) {
        if hide {
            if self.loadMoreActivityTopContraint.constant == 10 {
                self.loadMoreActivityTopContraint.constant = -30
                self.view.layoutIfNeeded()
                self.loadMoreActivityIndicator.stopAnimating()
                self.errorLabel.isHidden = false
            }
            return
        }
        
        if loadMoreActivityTopContraint != nil && loadMoreActivityTopContraint.constant != 10 {
            self.loadMoreActivityTopContraint.constant = 10
            self.loadMoreActivityIndicator.startAnimating()
            self.errorLabel.isHidden = true
            self.view.layoutIfNeeded()
        }
        
    }
//    func scrollTableViewToBottom(animated: Bool = false) {
//
//        DispatchQueue.main.async {
//            if self.messagesGroupedByDate.count > 0 {
//                let givenMessagesArray = self.messagesGroupedByDate[self.messagesGroupedByDate.count - 1]
//                if givenMessagesArray.count > 0 {
//                    let indexPath = IndexPath(row: givenMessagesArray.count - 1, section: self.messagesGroupedByDate.count - 1)
//                    self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
//                }
//            }
//        }
//    }
    func scrollTableViewToBottom(_ animation: Bool = false) {
        
        DispatchQueue.main.async {
            
            var numberOfSections = -1
            if self.tableViewChat.numberOfSections > 1 {
                numberOfSections = self.tableViewChat.numberOfSections - 1
            } else {
                numberOfSections = self.tableViewChat.numberOfSections
            }
            
            guard numberOfSections > 0 else {
                return
            }
            
            if self.messagesGroupedByDate.count > 0, let lastIndex = self.messagesGroupedByDate.last, lastIndex.count > 0 {
                
                let max = self.tableViewChat.numberOfRows(inSection: self.messagesGroupedByDate.count - 1)
                let min = lastIndex.count - 1
                
                let row = min < max ? min : max - 1
                guard numberOfSections >= self.messagesGroupedByDate.count - 1 else {
                    return
                }
                let indexPath = IndexPath(row: row, section: self.messagesGroupedByDate.count - 1)
                
                self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animation)
                self.newConversationContainer.isHidden = true
            }
        }
    }
    
//    func updateNewConversationCountButton(animation: Bool) {
//        if newConversationCounter > 0 {
//            newConversationLabel.text = "\(newConversationCounter)"
//            newConversationLabel.isHidden = false
//            newConversationContainer.isHidden = false
//        } else {
//            newConversationLabel.isHidden = true
//        }
//    }
    
    //    func expectedHeight(OfMessageObject chatMessageObject: HippoMessage) -> CGFloat {
    //
    ////        let isProfileImageEnabled: Bool = channel?.chatDetail?.chatType.isImageViewAllowed ?? false
    ////        let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId)
    //
    //        let availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
    //        let availableBoxSize = CGSize(width: availableWidthSpace,
    //                                      height: CGFloat.greatestFiniteMagnitude)
    //
    //        var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7
    //
    //        let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: chatMessageObject)
    //        cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
    //
    //        return cellTotalHeight
    //    }

//    func expectedHeight(OfMessageObject chatMessageObject: HippoMessage) -> CGFloat {
//        let isProfileImageEnabled: Bool = channel?.chatDetail?.chatType.isImageViewAllowed ?? (labelId > 0)
//        let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId) && chatMessageObject.type != .card
//        var availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
//        availableWidthSpace -= (isProfileImageEnabled && !isOutgoingMsg) ? 35 : 0
//        let availableBoxSize = CGSize(width: availableWidthSpace,
//                                      height: CGFloat.greatestFiniteMagnitude)
//        var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7 + 23
//        if isOutgoingMsg == true {
//            let messageString = chatMessageObject.message
//            #if swift(>=4.0)
//            var attributes: [NSAttributedString.Key: Any]?
//            attributes = [NSAttributedString.Key.font: HippoConfig.shared.theme.inOutChatTextFont]
//            if messageString.isEmpty == false {
//                cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
//            }
//            #else
//            var attributes: [String: Any]?
//            if let applicableFont = HippoConfig.shared.theme.inOutChatTextFont {
//                attributes = [NSFontAttributeName: applicableFont]
//            }
//            if messageString.isEmpty == false {
//                cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
//            }
//            #endif
//        } else {
//            let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: chatMessageObject)
//            cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
//        }
//        return cellTotalHeight
//    }
    func expectedHeight(OfMessageObject chatMessageObject: HippoMessage) -> CGFloat {
        let isProfileImageEnabled: Bool = channel?.chatDetail?.chatType.isImageViewAllowed ?? (labelId > 0)
        
        let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId) && chatMessageObject.type != .card
        
        var availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
        availableWidthSpace -= (isProfileImageEnabled && !isOutgoingMsg) ? 35 : 0
        
        let availableBoxSize = CGSize(width: availableWidthSpace,
       height: CGFloat.greatestFiniteMagnitude)
        
        
        
        var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7 + 23
      
        if isOutgoingMsg == true {
            
            let messageString = chatMessageObject.message
            
            #if swift(>=4.0)
            var attributes: [NSAttributedString.Key: Any]?
            attributes = [NSAttributedString.Key.font: HippoConfig.shared.theme.inOutChatTextFont]
            
            if messageString.isEmpty == false {
                cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
            }
            
            #else
            var attributes: [String: Any]?
            if let applicableFont = HippoConfig.shared.theme.inOutChatTextFont {
                attributes = [NSFontAttributeName: applicableFont]
            }
            
            if messageString.isEmpty == false {
                cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
            }
            #endif
            
        } else {
            let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: chatMessageObject)
            cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
        }
        
        return cellTotalHeight
    }

    
    //MARK: - funcs for MessageSendingView
    func intalizeMessageSendingView() {
        let config = MessageSendingViewConfig()
        
        handleMoreButton()
        let dataManager = MentionDataManager(mentions: Business.shared.agents)
        let request = IntializationRequest(config: config, dataManager: dataManager)
        self.messageSendingViewConfig = request.config
        self.dataManager = request.dataManager
        self.setUpUI()
        self.intalizeMention()
    }
    
    
    func handleMoreButton(){
        var config = MessageSendingViewConfig()
        if channel?.chatDetail?.chatType == .o2o {
            config.normalMessagePlaceHolder = HippoConfig.shared.theme.messagePlaceHolderText == nil ? HippoStrings.messagePlaceHolderText : HippoConfig.shared.theme.messagePlaceHolderText ?? ""
            moreOptionsButton.isHidden = true
        }else{
            moreOptionsButton.isHidden = false
        }
    }
    
    
    fileprivate func setUpUI() {
        setupTableView()
        setupTextView()
//        setActionButtonUI()
        enableNormalMessage(isInital: true)
//        setEditMessageText()
//        bottomContainer.backgroundColor = HippoTheme.theme.chatBox.chatBackgroundColor
//        viewsContainer.backgroundColor =  HippoTheme.theme.chatBox.chatBackgroundColor
        updateDefaultTextAttributes()
//        setEditCancelMessageButton()
//        let showBottomBar: Bool = config.showBottomBar()
//        bottomContainerHeightConstraint.constant = showBottomBar ? config.bottomBarHeight : 0
//        bottomContainer.isHidden = !showBottomBar
//        textViewContainer.isHidden = config.hideMessageBox
//        delegate?.updateMessContainerHeight(height: getHeightForTheView())
    }
    func setupTableView() {
        mentionsListTableView.isHidden = true
        mentionsListTableViewHeightConstraint.constant = 0
        let bundle = FuguFlowManager.bundle
        mentionsListTableView.register(UINib(nibName: "AgentListTableViewCell", bundle: bundle), forCellReuseIdentifier: "AgentListTableViewCell")
        dataSource = MentionTableDataSourceDelegate(mentions: dataManager?.filteredMentions ?? [], delegate: self)
        mentionsListTableView.delegate = dataSource
        mentionsListTableView.dataSource = dataSource
    }
    func setupTextView() {
//        delegate?.updateMessContainerHeight(height: getHeightForTheView())
//        messageTextView.imagePasteDelegate = self
//        messageTextView.backgroundColor = UIColor.clear
//        messageTextView.textContainerInset.bottom = 0
//        messageTextView.textContainerInset.top = 3
//        setEditMessageText()
    }
//    fileprivate func setEditMessageText() {
//        guard let editMessage = config.editMessage, config.mode == .editMessage else {
//            return
//        }
//        messageTextView.text = editMessage.message
//        placeHolderLabel.isHidden = !editMessage.message.isEmpty
//        manageSendButton()
//    }
//    func manageSendButton() {
//        sendMessageButton.isHidden = !messageTextView.hasText
//    }
//    fileprivate func setActionButtonUI() {
//        takeOverButtonContainer.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
//        takeOverButton.backgroundColor = HippoConfig.shared.theme.themeTextcolor
//        takeOverButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
//        takeOverButton.setTitle(HippoConfig.shared.theme.takeOverButtonText, for: .normal)
//    }
    fileprivate func enableNormalMessage(isInital: Bool = false) {
        guard messageTextView.isPrivateMode || isInital else {
            return
        }
        resetMention()
//        selectedBarLeadingConstraint.constant = normalMessageButton.frame.minX + leadingConstantForSelectedBar
        animateConstraintChanges()
        if messageTextView.isPrivateMode {
            messageTextView.isPrivateMode = false
        }
        updateUIAsPerMessageType()
    }
    func resetMention() {
        mentionListener?.reset()
    }
    func animateConstraintChanges(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
//            self.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    func updateUIAsPerMessageType() {
        let isPrivate = messageTextView.isPrivateMode
//        let isForwardSlashAllowed =  Business.shared.properties.isForwardSlashAllowed
        let isForwardSlashAllowed =  false
        addFileButtonAction.isHidden = isPrivate
//        cannedButton.isHidden = isPrivate || config.shouldHideBottonButtons()
//        botButton.isHidden = isPrivate || config.shouldHideBottonButtons()
        let isBotButtonHidden = isPrivate || self.messageSendingViewConfig.shouldHideBottonButtons()
        
        if isBotButtonHidden == true{
            if let index = self.attachments.firstIndex(where: {$0.title == HippoStrings.bot}), index < self.attachments.count{
               self.attachments.remove(at: index)
            }
        }else{
            self.attachments.append(Attachment(icon : HippoConfig.shared.theme.botIcon  , title : HippoStrings.bot))
        }
        
        collectionViewOptions.reloadData()
        
        textViewBgView.backgroundColor = isPrivate ? HippoConfig.shared.theme.privateNoteChatBoxColor : UIColor.white
//        messageTextView.tintColor = isPrivate ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) : UIColor.black
//        placeHolderLabel.textColor = isPrivate ? theme.chatBox.privateMessageTheme.placeholderColor : theme.label.primary
        placeHolderLabel.text = !isPrivate ? (HippoConfig.shared.theme.messagePlaceHolderText == nil ? HippoStrings.messagePlaceHolderText : HippoConfig.shared.theme.messagePlaceHolderText) : HippoStrings.privateMessagePlaceHolder
        textViewDidChange(messageTextView)
        updateDefaultTextAttributes()
    }
    func updateDefaultTextAttributes() {
        let isPrivate = messageTextView.isPrivateMode
        let defaultParam = messageSendingViewConfig.createDefaultAttributeds(for: isPrivate)
        mentionListener?.updateDefaultTextAttributes(newAttributes: defaultParam)
    }
//    fileprivate func setEditCancelMessageButton() {
//        let isEditEnabled = config.mode == .editMessage && config.editMessage != nil
//        cancelEditButton.isHidden = !isEditEnabled
//        cancelEditButtonWidthConstraint.constant = isEditEnabled ? 56 : 0
//        textViewContainer.layoutIfNeeded()
//    }
    func intalizeMention() {
        mentionListener = MentionListener(mentionsTextView: messageTextView, delegate: self, mentionTextAttributes: { (c) -> [AttributeContainer] in
            return self.messageSendingViewConfig.mentionAttributes
        }, defaultTextAttributes: messageSendingViewConfig.defaultAttributes, spaceAfterMention: true, triggers: messageSendingViewConfig.allowedMentionForPrivate, cooldownInterval: 0, searchSpaces: true, hideMentions: {
            print("+++++++++")
            DispatchQueue.main.async {
                self.hideMentionsList()
            }
        }, didHandleMentionOnReturn: { () -> Bool in
            print("------")
            return false
        }, showMentionsListWithString: {[weak self] (mentionString, triggerString) in
            //hanlde string
            guard let weakSelf = self else {
                return
            }
            DispatchQueue.main.async {
                weakSelf.handleMentionTableFor(mentionString: mentionString, triggerString: triggerString)
            }
        })
        updateDefaultTextAttributes()
    }
    fileprivate func enablePrivateNote() {
        guard !messageTextView.isPrivateMode else {
            return
        }
        resetMention()
//        selectedBarLeadingConstraint.constant = privateNoteButton.frame.minX + leadingConstantForSelectedBar
        animateConstraintChanges()
        messageTextView.isPrivateMode = true
        updateUIAsPerMessageType()
    }
    fileprivate func handleMentionTableFor(mentionString: String, triggerString: String) {
//        guard triggerString != "/" else {
//            handleSavedReplies(mentionString)
//            return
//        }
        guard messageSendingViewConfig.isMentionEnabled, messageTextView.isPrivateMode else {
            return
        }
        let filteredMentions = dataManager.filterMentions(with: mentionString)
        let wasPreviouslyHidden = self.mentionsListTableViewHeightConstraint.constant == 0
        let expectedHeight = CGFloat(filteredMentions.count) * heightOfTableViewCell
        let actualHeight = min(maxMentionViewHeight, expectedHeight)
//        self.mentionsListTableViewHeightConstraint.constant = actualHeight
        if actualHeight > tableViewChat.frame.height{
            self.mentionsListTableViewHeightConstraint.constant = tableViewChat.frame.height - 100
        }else{
            self.mentionsListTableViewHeightConstraint.constant = actualHeight
        }
        dataSource.updateMentions(newMentions: filteredMentions)
        mentionsListTableView.reloadData()
        if filteredMentions.count != 0 {
            mentionsListTableView.isHidden = false
        }
        animateConstraintChanges {
            guard wasPreviouslyHidden else {
                return
            }
            self.mentionsListTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    func sendButtonClicked(mentions: [Mention], message: String, isPrivateMessage isPrivate: Bool, config: MessageSendingViewConfig) {
        if storeResponse?.restrictPersonalInfo ?? false{
            if message.matches(for: phoneNumberRegex).count > 0 || message.isValidEmail(){
                showErrorMessage(messageString: HippoStrings.donotAllowPersonalInfo)
                updateErrorLabelView(isHiding: true)
                return
            }
        }
        
       if channel != nil, !channel.isSubscribed() {
            channel.subscribe()
        }
        
        if isMessageInvalid(messageText: messageTextView.text) {
            return
        }
        let trimmedMessage = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

//        let message = HippoMessage(message: trimmedMessage, type: .normal, uniqueID: String.generateUniqueId(), chatType: channel?.chatDetail?.chatType)
//        channel?.unsentMessages.append(message)

        if channel != nil {
//            addMessageToUIBeforeSending(message: message)
//            self.sendMessage(message: message)
            self.sendMessageToFaye(mentions: mentions, messageString: trimmedMessage, isPrivate: isPrivate)
        } else {
            //TODO: - Loader animation
            startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
                if success {
                    self?.populateTableViewWithChannelData()
//                    self?.addMessageToUIBeforeSending(message: message)
//                    self?.sendMessage(message: message)
                    self?.sendMessageToFaye(mentions: mentions, messageString: trimmedMessage, isPrivate: isPrivate)
                }
            })
        }
    }
    func sendMessageToFaye(mentions: [Mention], messageString: String, isPrivate: Bool) {
        guard channelId >= 0, currentUserId() >= 0 else {
            return
        }
        let (text, ids) = addTag(mentions: mentions, messageString: messageString)
        let messageType = isPrivate ? MessageType.privateNote : MessageType.normal
        let muid = generateUniqueId()
        resetVariables()
        let message = HippoMessage(message: text, type: messageType, uniqueID: muid, taggedUserArray: ids, chatType: chatType)
        
        channel?.unsentMessages.append(message)
        addMessageToUIBeforeSending(message: message)
        
//        publishMessageOnChannel(message: message)
        self.sendMessage(message: message)
    }
//    func publishMessageOnChannel(message: HippoMessage) {
//        if channelId == -1 {
//            self.startNewConversation() {[weak self] (result) in
//                self?.channel?.send(message: message, completion: {})
//            }
//        } else {
//            channel?.send(message: message, completion: {})
//        }
//    }
    func addTag(mentions: [Mention], messageString: String) -> (String, [Int]) {
        var finalString: NSString = ""
        var ids: [Int] = []
        finalString = (messageTextView.text ?? "").trimWhiteSpacesAndNewLine() as NSString
        let filteredMention = mentions.sorted { (m1, m2) -> Bool in
            return m1.range.location > m2.range.location
        }
        for mention in filteredMention {
            guard let agent = mention.object as? Agent else {
                continue
            }
//            finalString = finalString.replacingOccurrences(of: agent.mentionName, with: agent.attributedFullName!, options: .regularExpression, range: mention.range) as NSString
            guard let id = agent.userId else {
                continue
            }
            if !ids.contains(id) {
              ids.append(id)
            }
        }
        return (finalString as String, ids)
    }
    func resetVariables() {
        resetVariablesToDefault()
        typingMessageValue = TypingMessage.startTyping.rawValue
//        taggedAgentArray.removeAll()
    }
    func resetVariablesToDefault() {
        messageTextView.text = ""
        resetMention()
        hideMentionsList()
        textViewDidChange(messageTextView)
    }
    fileprivate func hideMentionsList() {
       self.mentionsListTableViewHeightConstraint.constant = 0
       animateConstraintChanges()
    }
    
}

// MARK: - MentionTableDelegate
extension AgentConversationViewController: MentionTableDelegate {
    func mentionSelected(_ agent: Agent) {
        mentionListener.addMention(agent)
    }
}

// MARK: - UIScrollViewDelegate
extension AgentConversationViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableViewChat.contentOffset.y < -5.0 && self.willPaginationWork, FuguNetworkHandler.shared.isNetworkConnected {
            
            guard !isGettingMessageViaPaginationInProgress else {
                return
            }
            
            showHideActivityIndicator(hide: false)
            let count = channel?.sentMessages.count ?? 0
            
            isGettingMessageViaPaginationInProgress = true
            self.getMessagesBasedOnChannel(fromMessage: count + 1, pageEnd: nil, completion: { [weak self] (_) in
                self?.showHideActivityIndicator(hide: true)
                self?.isGettingMessageViaPaginationInProgress = false
            })
        }
//        if shouldRecognizeScroll {
        if scrollView.contentOffset.y < (tableViewChat.contentSize.height - tableViewChat.frame.height - 180) {
            newConversationContainer.isHidden = false
        } else {
//                if newConversationCounter == 0 {
            newConversationContainer.isHidden = true
//                }
        }
//
//        if scrollView.contentOffset.y > (tableViewChat.contentSize.height - tableViewChat.frame.height - 10) {
//            newConversationCounter = 0
//            updateNewConversationCountButton(animation: true)
//        }
//    }
        
    }
    
    func getUnsentMessageCount() -> Int {
        let messages = channel?.messages ?? []
        
        let unsentMessages = messages.filter {$0.status == .none && isSentByMe(senderId: $0.senderId)}
        return unsentMessages.count
    }
}

// MARK: - UITableView Delegates
extension AgentConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func getDefaultCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isTypingLabelHidden {
            return self.messagesGroupedByDate.count + 1
        }
        return self.messagesGroupedByDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.messagesGroupedByDate.count {
            return messagesGroupedByDate[section].count
        } else {
            return isTypingLabelHidden ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypingViewTableViewCell", for: indexPath) as! TypingViewTableViewCell
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.bgView.isHidden = false
            cell.gifImageView.image = nil
            cell.bgView.backgroundColor = .clear
            cell.gifImageView.layer.cornerRadius = 15.0
            
            let imageBundle = FuguFlowManager.bundle ?? Bundle.main
            if let getImagePath = imageBundle.path(forResource: "typingImage", ofType: ".gif") {
                cell.gifImageView.image = UIImage.animatedImageWithData(try! Data(contentsOf: URL(fileURLWithPath: getImagePath)))!
            }
            
            return cell
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = messagesGroupedByDate[chatSection]
            
            if messagesArray.count > indexPath.row {
                let message = messagesArray[indexPath.row]
                let messageType = message.type
                let chatType = channel?.chatDetail?.chatType ?? .other
                let isOutgoingMsg = message.isSelfMessage(for: chatType) //isSentByMe(senderId: chatMessageObject.senderId)
                
                guard messageType.isMessageTypeHandled() else {
                    return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
                }
                
                switch messageType {
                case MessageType.imageFile:
                    if isOutgoingMsg == true {
                        guard
                            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingImageCell", for: indexPath) as? OutgoingImageCell
                            else {
                                return getDefaultCell()
                        }
                        cell.delegate = self
                        cell.messageLongPressed = {[weak self](message) in
                            DispatchQueue.main.async {
                                self?.longPressOnMessage(message: message, indexPath: indexPath)
                            }
                        }
                        cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath)
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingImageCell", for: indexPath) as? IncomingImageCell
                            else {
                                return getDefaultCell()
                        }
                        cell.delegate = self
                        return cell.configureIncomingCell(resetProperties: true, channelId: channel.id, chatMessageObject: message, indexPath: indexPath)
                    }
                case .normal, .privateNote, .botText:
                    return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
                case .call:
                    if isOutgoingMsg {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingVideoCallMessageTableViewCell", for: indexPath) as? OutgoingVideoCallMessageTableViewCell else {
                            let cell = UITableViewCell()
                            cell.backgroundColor = .clear
                            return cell
                        }
                        let peerName = channel?.chatDetail?.peerName ?? "   "
                        let isCallingEnabled = isCallingEnabledFor(type: message.callType)
                        cell.setCellWith(message: message, otherUserName: peerName, isCallingEnabled: isCallingEnabled)
                        cell.delegate = self
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingVideoCallMessageTableViewCell", for: indexPath) as? IncomingVideoCallMessageTableViewCell else {
                            let cell = UITableViewCell()
                            cell.backgroundColor = .clear
                            return cell
                        }
                        let isCallingEnabled = isCallingEnabledFor(type: message.callType)
                        cell.setCellWith(message: message, isCallingEnabled: isCallingEnabled)
                        cell.delegate = self
                        return cell
                    }
                    
                case MessageType.assignAgent:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignedAgentTableViewCell", for: indexPath) as? AssignedAgentTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.setupCell(message: message)
                    return cell
                case .actionableMessage, .hippoPay:
                    
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableMessageTableViewCell", for: indexPath) as? ActionableMessageTableViewCell else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                    }
                    //cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message)
                    cell.timeLabel.text = ""
                    cell.rootViewController = self
                    cell.registerNib()
                    cell.setUpData(messageObject: message, isIncomingMessage: !isOutgoingMsg)
                    cell.backgroundColor = UIColor.clear
                    return cell
                case .attachment:
                    if isOutgoingMsg {
                        switch message.concreteFileType! {
                        case .video:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingVideoTableViewCell", for: indexPath) as! OutgoingVideoTableViewCell
                            cell.messageLongPressed = {[weak self](message) in
                                DispatchQueue.main.async {
                                    self?.longPressOnMessage(message: message, indexPath: indexPath)
                                }
                            }
                            cell.setCellWith(message: message)
                            cell.retryDelegate = self
                            cell.delegate = self
                            return cell
                        default:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingDocumentTableViewCell") as! OutgoingDocumentTableViewCell
                            cell.messageLongPressed = {[weak self](message) in
                                DispatchQueue.main.async {
                                    self?.longPressOnMessage(message: message, indexPath: indexPath)
                                }
                            }
                            cell.setCellWith(message: message)
                            cell.actionDelegate = self
                            cell.delegate = self
                            return cell
                        }
                    } else {
                        switch message.concreteFileType! {
                        case .video:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingVideoTableViewCell", for: indexPath) as! IncomingVideoTableViewCell
                            cell.setCellWith(message: message)
                            cell.delegate = self
                            return cell
                        default:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingDocumentTableViewCell") as! IncomingDocumentTableViewCell
                            cell.setCellWith(message: message)
                            cell.actionDelegate = self
                            return cell
                        }
                    }
                case .consent:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableView", for: indexPath) as? ActionTableView, let actionMessage = message as? HippoActionMessage else {
                        return UITableView.defaultCell()
                    }
                    cell.setCellData(message: actionMessage)
                    return cell
                case .leadForm:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeadTableViewCell", for: indexPath) as? LeadTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.delegate = self
                    cell.setData(indexPath: indexPath, arr: message.leadsDataArray, message: message)
                    cell.isUserInteractionEnabled = false
                    return cell
                case .multipleSelect:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultiSelectTableViewCell", for: indexPath) as? MultiSelectTableViewCell else {
                        return UITableView.defaultCell()
                    }
                    //                    cell.submitButtonDelegate = self
                    cell.isAgent = true
                    cell.isUserInteractionEnabled = false
                    cell.set(message: message)
                    return cell
                case .feedback:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackTableViewCell") as? FeedbackTableViewCell else {
                        return UITableViewCell()
                    }
                    var param = FeedbackParams(title: message.message, indexPath: indexPath, messageObj: message)
                    param.showSendButton = false
                    cell.isAgent = true
                    cell.setDataForAgent(with: param)
                    //                    cell.delegate = self
                    cell.backgroundColor = .clear
                    if let muid = message.messageUniqueID {
                        heightForFeedBackCell["\(muid)"] = cell.alertContainer.bounds.height
                    }
                    cell.isUserInteractionEnabled = false
                    return cell
                case .paymentCard:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMessageCell", for: indexPath) as? PaymentMessageCell else {
                        return UITableView.defaultCell()
                    }
                    cell.set(message: message)
                    return cell
                default:
                    return getDefaultCell()
                }
            }
        default:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            return cell
        }
        
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateTopBottomSpace(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = self.messagesGroupedByDate[chatSection]
            if messagesArray.count > indexPath.row {
                let message = messagesArray[indexPath.row]
                let messageType = message.type
                if messageType == .leadForm {
                    print("leadForm")
                }
                
                guard messageType.isMessageTypeHandled() else {
                    var rowHeight = expectedHeight(OfMessageObject: message)
                    rowHeight += returnRetryCancelButtonHeight(chatMessageObject: message)
                    rowHeight += getTopDistanceOfCell(atIndexPath: indexPath)
                    return rowHeight
                }
                switch messageType {
                case MessageType.imageFile:
                    return 288
                case MessageType.normal, .privateNote, .botText:
                    return UIView.tableAutoDimensionHeight
                case .attachment:
                    switch message.concreteFileType! {
                    case .video:
                        return 234
                    default:
                        return 80
                    }
                case MessageType.assignAgent:
                    return UIView.tableAutoDimensionHeight
                case MessageType.call:
                    return UIView.tableAutoDimensionHeight
                case .consent:
                    return message.cellDetail?.cellHeight ?? 0.01
                case .actionableMessage, .hippoPay:
                    return UIView.tableAutoDimensionHeight
                        //self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message) + heightOfDateLabel
                case .leadForm:
                    return getHeightForLeadFormCell(message: message)
                case .multipleSelect:
                    return message.calculatedHeight ?? 0.01
                case .feedback:
                    return UIView.tableAutoDimensionHeight
//                    guard let muid = message.messageUniqueID, var rowHeight: CGFloat = heightForFeedBackCell["\(muid)"] else {
//                        return 0.001
//                    }
//                    rowHeight += 7 //Height for bottom view
//                    return rowHeight
                case .paymentCard:
                    return message.calculatedHeight ?? 0.01
                default:
                    return 0.01//UITableViewAutomaticDimension
                    
                }
            }
        default: break
        }
        return UIView.tableAutoDimensionHeight
    }

    func getHeightForLeadFormCell(message: HippoMessage) -> CGFloat {
        var count = 0
        var buttonAction: [FormData] = []
        for lead in message.leadsDataArray {
            if lead.isShow  && lead.type != .button {
                count += 1
            }
            if lead.type == .button {
                buttonAction.append(lead)
            }
        }
        var height = LeadDataTableViewCell.rowHeight * CGFloat(count)
        if count > 1 {
            height -= CGFloat(5*(count))
        }
        // Check if count is more than or equal to 2
        if (count - 2) >= 0 {
            // Check if last visible cell value is submitted
            if message.leadsDataArray[count - 2].isCompleted {
                // Check if last cell is visible.
                if count == message.leadsDataArray.count {
                    // Check if last cell value is submitted.
                    if message.leadsDataArray[count - 1].isCompleted {
                        height -= CGFloat(10 * (count))
                    } else {
                        height -= CGFloat(10 * (count - 1))
                    }
                } else {
                    height -= CGFloat(10 * (count - 1))
                }
            }
        }
        let buttonHeight: CGFloat = CGFloat(buttonAction.count * 30)
        let skipButtonHeight: CGFloat = message.shouldShowSkipButton() ? LeadTableViewCell.skipButtonHeightConstant : 0
        if height > 0 {
            return CGFloat(height) + buttonHeight + skipButtonHeight + 2
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = self.messagesGroupedByDate[chatSection]
            if messagesArray.count > indexPath.row {
                let message = messagesArray[indexPath.row]
                if message.type == .leadForm {
                    print("leadform")
                }
                switch message.type {
                case .call:
                    return 85
                default:
                    return self.tableView(tableView, heightForRowAt: indexPath)
                }
            }
        default:
            break
        }
        return 0.01
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < self.messagesGroupedByDate.count {
            
            if section == 0 && channel == nil {
                return 0
            }
            return 28
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelBgView = UIView()
        
        labelBgView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 28)
        labelBgView.backgroundColor = .clear
        
        let dateLabel = UILabel()
        dateLabel.layer.masksToBounds = true
        
        dateLabel.text = ""
        dateLabel.layer.cornerRadius = 10
        dateLabel.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.bold(ofSize: 12)//UIFont.boldSystemFont(ofSize: 12.0)
        dateLabel.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        dateLabel.layer.borderColor = #colorLiteral(red: 0.862745098, green: 0.8784313725, blue: 0.9019607843, alpha: 1).cgColor
        dateLabel.layer.borderWidth = 0.5
        if section < self.messagesGroupedByDate.count {
            let localMessagesArray = self.messagesGroupedByDate[section]
            if  localMessagesArray.count > 0,
                let dateTime = localMessagesArray.first?.creationDateTime {
                dateLabel.text = changeDateToParticularFormat(dateTime,
                                                              dateFormat: "MMM d, yyyy",
                                                              showInFormat: false).capitalized
            }
        }
        var widthIs: CGFloat = 0
        #if swift(>=4.0)
        widthIs = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: dateLabel.font], context: nil).size.width) + 10
        #else
        widthIs = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: dateLabel.font], context: nil).size.width) + 10
        #endif
        let dateLabelHeight = CGFloat(24)
        dateLabel.frame = CGRect(x: (UIScreen.main.bounds.size.width / 2) - (widthIs/2), y: (labelBgView.frame.height - dateLabelHeight)/2, width: widthIs + 10, height: dateLabelHeight)
        labelBgView.addSubview(dateLabel)
        
        return labelBgView
    }
    
    func getHeighOfButtonCollectionView(actionableMessage: FuguActionableMessage) -> CGFloat {
        
        let collectionViewDividerHeight = CGFloat(1)
        if  (actionableMessage.actionButtonsArray.count) > 0 {
            var numberOfRows = 0
            if (actionableMessage.actionButtonsArray.count) < 4 {
                numberOfRows = 1
            } else {
                numberOfRows = (actionableMessage.actionButtonsArray.count)/2
                let extraRow = (actionableMessage.actionButtonsArray.count)%2
                numberOfRows += extraRow
                
            }
            
            return CGFloat((40 * numberOfRows)) + collectionViewDividerHeight
            
        }
        return 0
    }
    
    func getHeightOfActionableMessageAt(indexPath: IndexPath, chatObject: HippoMessage)-> CGFloat {
        if let cell = tableViewChat.cellForRow(at: indexPath) as? ActionableMessageTableViewCell{
            return cell.tableViewHeightConstraint.constant
        }
        
        let chatMessageObject = chatObject
        var cellHeight = CGFloat(0)
        let bottomSpace = CGFloat(10)
        let marginBetweenHeaderAndDescription = CGFloat(1.5)
        let margin = CGFloat(5)
        
        
        let headerFont = HippoConfig.shared.theme.actionableMessageHeaderTextFont
        let descriptionFont = HippoConfig.shared.theme.actionableMessageDescriptionFont
        let priceFont = HippoConfig.shared.theme.actionableMessagePriceBoldFont
        let senderNameFont = HippoConfig.shared.theme.senderNameFont
        
        
        
        
        if chatMessageObject.senderFullName.isEmpty == false {
            let titleText = chatMessageObject.senderFullName
            let heightOfContent = (titleText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: senderNameFont)) + bottomSpace + margin
            cellHeight += heightOfContent
        }
        
        
        if chatMessageObject.actionableMessage?.messageImageURL.isEmpty == false {
            cellHeight += CGFloat(heightOfActionableMessageImage)
            cellHeight += bottomSpace
        }
        
        if chatMessageObject.actionableMessage?.messageTitle.isEmpty == false {
            let titleText = chatMessageObject.actionableMessage?.messageTitle
            let heightOfContent = (titleText?.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: headerFont!))! + margin + marginBetweenHeaderAndDescription +  bottomSpace + 1
            cellHeight += heightOfContent
        }

        if chatMessageObject.actionableMessage?.titleDescription.isEmpty == false {
            let titleText = chatMessageObject.actionableMessage?.titleDescription
            let heightOfContent = (titleText?.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: descriptionFont!))!
            cellHeight += heightOfContent
        }
        let collectionViewHeight = self.getHeighOfButtonCollectionView(actionableMessage: chatMessageObject.actionableMessage ?? FuguActionableMessage())
        cellHeight += collectionViewHeight

        if chatMessageObject.actionableMessage?.descriptionArray != nil, (chatMessageObject.actionableMessage?.descriptionArray.count)! > 0 {

            for info in (chatMessageObject.actionableMessage?.descriptionArray)! {
                if let messageInfo = info as? [String: Any] {
                    if let priceText = messageInfo["content"] as? String {

                        let heightOFPriceLabel = priceText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20 ), font: priceFont!)

                        let widthOfPriceLabel = priceText.width(withConstraintedHeight: heightOFPriceLabel, font: priceFont!)

                        if let priceText = messageInfo["header"] as? String {
                            let heightOfContent = priceText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 10 - widthOfPriceLabel), font: descriptionFont!) + marginBetweenHeaderAndDescription + (margin)
                            cellHeight += heightOfContent
                        }



                    }
                }
            }
        }

        return cellHeight - 3
    }
}


extension AgentConversationViewController {
    
    func shouldScrollToBottomInCaseOfSomeoneElseTyping() -> Bool {
        guard let visibleIndexPaths = tableViewChat.indexPathsForVisibleRows,
            visibleIndexPaths.count > 0,
            messagesGroupedByDate.count > 0 else {
                return false
        }
        
        let lastVisibleIndexPath = visibleIndexPaths.last!
        
        guard lastVisibleIndexPath.section >= (messagesGroupedByDate.count - 1) else {
            return false
        }
        
        if lastVisibleIndexPath.section == (messagesGroupedByDate.count - 1) && lastVisibleIndexPath.row < (messagesGroupedByDate.last!.count - 1) {
            return false
        }
        
        return true
    }
    
    func sendNotificaionAfterReceivingMsg(senderUserId: Int) {
        if senderUserId != getSavedUserId {
            sendReadAllNotification()
        }
    }
    
    func sendReadAllNotification() {
        channel?.send(message: HippoMessage.readAllNotification, completion: {})
    }
}

// MARK: - UITextViewDelegates
extension AgentConversationViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.hasText
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.addRemoveShadowInTextView(toAdd: true)
        
        placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.8)
        textInTextField = textView.text
//        textViewBgView.backgroundColor = .white
        let isPrivate = messageTextView.isPrivateMode
        textViewBgView.backgroundColor = isPrivate ? HippoConfig.shared.theme.privateNoteChatBoxColor : UIColor.white
//        messageTextView.tintColor = isPrivate ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) : UIColor.black
//        bottomContentView.backgroundColor = .white
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.watcherOnTextView), userInfo: nil, repeats: true)
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        textViewBgView.backgroundColor = UIColor.white
        let isPrivate = messageTextView.isPrivateMode
        textViewBgView.backgroundColor = isPrivate ? HippoConfig.shared.theme.privateNoteChatBoxColor : UIColor.white
//        messageTextView.tintColor = isPrivate ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) : UIColor.black
//        bottomContentView.backgroundColor = UIColor.white
        placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.5)
        
        timer.invalidate()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        typingMessageValue = TypingMessage.startTyping.rawValue
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.hasText
//        manageSendButton()
//        delegate?.updateMessContainerHeight(height: getHeightForTheView())
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = ((textView.text as NSString?)?.replacingCharacters(in: range,
                                                                         with: text))!
        if newText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.sendMessageButton.isEnabled = false
            
            if text == "\n" {
                textView.resignFirstResponder()
            }
            if channel != nil {
                self.typingMessageValue = TypingMessage.stopTyping.rawValue
                sendTypingStatusMessage(isTyping: TypingMessage.stopTyping)
                self.typingMessageValue = TypingMessage.startTyping.rawValue
            }
            if text == " " {
                return false
            }
        } else {
            self.sendMessageButton.isEnabled = true
            if typingMessageValue == TypingMessage.startTyping.rawValue, channel != nil {
                sendTypingStatusMessage(isTyping: TypingMessage.startTyping)
                self.typingMessageValue = TypingMessage.stopTyping.rawValue
            }
        }
        return true
    }
}

// MARK: - UIImagePicker Delegates
extension AgentConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //// Local variable inserted by Swift 4.2 migrator.
    //
    //         let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    //
    //        guard let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
    //            else {
    //                picker.dismiss(animated: true, completion: nil)
    //                return
    //        }
    //
    //        let formattedImage = rotateCameraImageToProperOrientation(imageSource: pickedImage)
    //
    //        if picker.sourceType == .camera {
    //            sendConfirmedImage(image: formattedImage, mediaType: .imageType)
    //            picker.dismiss(animated: true, completion: nil)
    //        } else if let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectImageViewController") as? SelectImageViewController {
    //            destinationVC.pickedImage = formattedImage
    //            destinationVC.delegate = self
    //            picker.modalPresentationStyle = .overCurrentContext
    //            self.imagePicker.present(destinationVC, animated: true, completion: nil)
    //        }
    //    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func doesImageExistsAt(filePath: String) -> Bool {
        return UIImage.init(contentsOfFile: filePath) != nil
    }
    
    func disableSendingReply() {
        self.channel?.isSendingDisabled = true
        //        self.textViewBottomConstraint.constant = -self.textViewBgView.frame.height
//        self.bottomContentViewBottomConstraint.constant = -self.textViewBgView.frame.height
        self.bottomContentViewBottomConstraint.constant = -self.textViewBgView.frame.height
        self.textViewBgView.isHidden = true
    }
    
    func enableSendingReply() {
        self.channel?.isSendingDisabled = false
//        self.bottomContentViewBottomConstraint.constant = 0
        if self.bottomContentViewBottomConstraint.constant < 0{
            self.bottomContentViewBottomConstraint.constant = 0
        }else{}
        
        //configureFooterView()
        self.textViewBgView.isHidden = false
    }
    
    func setFooterView(isReplyDisabled: Bool = false, isBotInProgress : Bool = false) {
//        let isReplyDisabled = channel?.channelInfo?.isReplayDisabled ?? false
//        let isBotInProgress = channel?.channelInfo?.isBotInProgress ?? false
        
        disableTakeOverButton()
        
        switch (isReplyDisabled, isBotInProgress) {
        case (false, _):
            //messageSendingView?.disableActionButton()
            print(isReplyDisabled, isBotInProgress)
        case (true, false):
            //messageSendingView?.hideMessageBox(withBottomBar: false, setUI: true)
            print(isReplyDisabled, isBotInProgress)
        case (true, true):
            //messageSendingView?.enableActionButton()
            print(isReplyDisabled, isBotInProgress)
            enableTakeOverButton()
        }
        
    }
    
    func enableTakeOverButton(){
        takeOverButtonContainer.isHidden = false
        takeOverButton.isHidden = false
        takeOverButton.isEnabled = true
        takeOverButtonHeightConstraint.constant = 50
    }
    
    func disableTakeOverButton(){
        takeOverButtonContainer.isHidden = true
        takeOverButton.isHidden = true
        takeOverButton.isEnabled = false
        takeOverButtonHeightConstraint.constant = 0
    }
    
}

//// MARK: - SelectImageViewControllerDelegate Delegates
//extension AgentConversationViewController: SelectImageViewControllerDelegate {
//    func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage) {
//        selectedImageVC.dismiss(animated: false) {
//            self.imagePicker.dismiss(animated: false) {
//                self.sendConfirmedImage(image: selectedImage, mediaType: .imageType)
//            }
//        }
//    }
//
//    func goToConversationViewController() {}
//}

// MARK: - ImageCellDelegate Delegates
extension AgentConversationViewController: ImageCellDelegate {
    func retryUploadForImage(message: HippoMessage) {
        if message.imageUrl == nil {
            uploadFileFor(message: message) {(success) in
                if success {
                    self.sendMessage(message: message)
                }
            }
        } else {
            sendMessage(message: message)
        }
    }
    
    func reloadCell(withIndexPath indexPath: IndexPath) {
        if self.tableViewChat.numberOfSections >= indexPath.section, tableViewChat.numberOfRows(inSection: indexPath.section) >= indexPath.row {
            tableViewChat.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func showImageFor(message: HippoMessage) {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
        openSelectedImage(for: message)
    }
    
}

extension AgentConversationViewController: LeadTableViewCellDelegate {
    func cellUpdated(for cell: LeadTableViewCell, data: [FormData], isSkipAction: Bool) {
        print("CELL UPDATED")
    }

    func sendReply(forCell cell: LeadTableViewCell, data: [FormData]) {
        print("SEND REPLY")
    }

    func textfieldShouldBeginEditing(textfield: UITextField) {
        print("SHOULD BEGIN")
    }

    func textfieldShouldEndEditing(textfield: UITextField) {
        print("SHOULD END")
    }

    func leadSkipButtonClicked(message: HippoMessage, cell: LeadTableViewCell) {
        print("LEAD SKIP BUTTON CLICKED")
    }


}

extension AgentConversationViewController: BotTableDelegate {
    func sendButtonClicked(with object: BotAction) {
        switch object.messageType {
        case .feedback:
            sendFeedbackMessageToFaye()
        default:
            sendBotFormFaye(object: object)
        }
    }
    func sendFeedbackMessageToFaye() {
//        let message = HippoMessage(message: "Please provide a feedback for our conversation", type: .feedback, uniqueID: generateUniqueId(), chatType: chatType)
        let message = HippoMessage(message: HippoStrings.ratingReview, type: .feedback, uniqueID: generateUniqueId(), chatType: chatType)
        message.updateObject(with: message)
        channel.unsentMessages.append(message)
        self.addMessageToUIBeforeSending(message: message)
        //messageTextView.resignFirstResponder()
        channel.send(message: message) {
            //            self.assignAlertView.backgroundColor = UIColor.fadedOrange
            //            self.assignAlertLabel.text = "Feedback request has been sent."
            //            self.updateAssignAlert(isAgentCanSendMsg: true)
            //            self.channel?.channelInfo?.isFeedbackAsked = true
//            self.scrollTableViewToBottom(true)
//            self.view.layoutIfNeeded()
            self.attachmentViewHeightConstraint.constant = 0
        }
        
//        DispatchQueue.main.async {
//            let scrollPoint = CGPoint(x: 0, y: self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height)
//            self.tableViewChat.setContentOffset(scrollPoint, animated: true)
//        }
        
    }

    func sendBotFormFaye(object: BotAction) {
        let message: HippoMessage?
        switch object.messageType {
        case .leadForm:
            message = HippoMessage(message: object.message, type: object.messageType,uniqueID: generateUniqueId(), bot: object, chatType: chatType)
            channel.unsentMessages.append(message!)
            self.addMessageToUIBeforeSending(message: message!)
            channel.send(message: message!, completion: nil)
            self.attachmentViewHeightConstraint.constant = 0
        default:
            break
        }

    }

}


extension AgentConversationViewController{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let attachCVCell = collectionView.cellForItem(at: indexPath) as? AttachmentOptionCollectionViewCell else { return }
//        if attachCVCell.attachmentDetail?.title == "Payment"{
//            self.closeKeyBoard()
//            presentPlansVc()
//        }else if attachCVCell.attachmentDetail?.title == "Bot"{
//            self.closeKeyBoard()
//            AgentConversationManager.getBotsAction(userId: self.channel.chatDetail?.customerID ?? 0, channelId: self.channelId) { (botActions) in
//                self.addBotActionView(with: botActions)
//            }
//        }
        switch attachCVCell.attachmentDetail?.title {
        case HippoStrings.text:
            enableNormalMessage()
        case HippoStrings.internalNotes:
            enablePrivateNote()
        case HippoStrings.payment:
            self.closeKeyBoard()
            presentPlansVc()
        case HippoStrings.bot:
            self.closeKeyBoard()
            AgentConversationManager.getBotsAction(userId: self.channel.chatDetail?.customerID ?? 0, channelId: self.channelId) { (botActions) in
                self.addBotActionView(with: botActions)
            }
        case HippoConfig.shared.strings.presciption:
            self.openSelectTemplate()
            
        default:
            print("default")
        }
        
    }
}

extension AgentConversationViewController: HippoChannelDelegate {
    func closeChatActionFromRefreshChannel() {
        
    }
    
    func channelDataRefreshed() {
        
        if channel?.chatDetail?.disableReply == true{
            //disableSendingReply(withOutUpdate: true)
            disableSendingReply()
        }else{
            enableSendingReply()
        }
        setFooterView(isReplyDisabled: channel?.chatDetail?.disableReply ?? false, isBotInProgress: channel?.chatDetail?.isBotInProgress ?? false)

        handleAudioIcon()
        handleVideoIcon()
        tableViewChat.reloadData()
    }
    
    
    func cancelSendingMessage(message: HippoMessage, errorMessage: String?, errorCode: SocketClient.SocketError?) {
        self.cancelMessage(message: message)
        
        if let message = errorMessage {
            showErrorMessage(messageString: message)
            updateErrorLabelView(isHiding: true)
        }
        if errorCode == SocketClient.SocketError.personalInfoSharedError{
            self.messageTextView.text = message.message
        }
    }
    
    func typingMessageReceived(newMessage: HippoMessage) {
        guard !newMessage.isSentByMe() else {
            return
        }
        isTypingLabelHidden = newMessage.typingStatus != .startTyping
        if isTypingLabelHidden {
            deleteTypingLabelSection()
        } else {
            insertTypingLabelSection()
            return
        }
    }
    
    func sendingFailedFor(message: HippoMessage) {
        
    }
    
    func newMessageReceived(newMessage message: HippoMessage) {
        message.status = message.isSentByMe() ? message.status : .read
        message.wasMessageSendingFailed = false
        
        switch message.type {
        case .paymentCard:
            if (message.cards ?? []).isEmpty {
                return
            }
            let selectedCardId =  message.selectedCardId?.trimWhiteSpacesAndNewLine() ?? ""
            if !selectedCardId.isEmpty {
                self.tableViewChat.reloadData()
                return
            }
        default:
            break
        }

        tableViewChat.reloadData()
        
        guard !message.isANotification() else {
            return
        }
        updateMessagesArrayLocallyForUIUpdation(message)
        newScrollToBottom(animated: true)
        //TODO: - Scrolling Logic
        
        // NOTE: Keep "shouldScroll" method and action different, should scroll method should only detect whether to scroll or not
        sendNotificaionAfterReceivingMsg(senderUserId: message.senderId)
    }
    
    func insertTypingLabelSection() {
        guard !isTypingLabelHidden, !isTypingSectionPresent() else {
            return
        }
        guard CallManager.shared.findActiveCallUUID() == nil else {
            return
        }
        
        let typingSectionIndex = IndexSet([tableViewChat.numberOfSections])
        tableViewChat.insertSections(typingSectionIndex, with: .none)
        
        if shouldScrollToBottomInCaseOfSomeoneElseTyping(),
            let lastMessageIndexPath = getLastMessageIndexPath() {
            let newIndexPath = IndexPath(row: 0, section: lastMessageIndexPath.section + 1)
            scroll(toIndexPath: newIndexPath, animated: false)
        }
    }
    
    func deleteTypingLabelSection() {
        guard isTypingLabelHidden, isTypingSectionPresent() else {
            return
        }
        
        let typingSectionIndex = IndexSet([tableViewChat.numberOfSections - 1])
        tableViewChat.deleteSections(typingSectionIndex, with: .none)
    }
    
    func isTypingSectionPresent() -> Bool {
        return self.messagesGroupedByDate.count < tableViewChat.numberOfSections
    }
    
//    func checkScrollerPostion() {
//        let contentHeight = tableViewChat.contentSize.height
//        let tableHeight = tableViewChat.bounds.height
//        let offset = tableViewChat.contentOffset.y
//
//
//        if offset > (contentHeight - tableHeight - 10) {
//            self.newConversationCounter = 0
//            scrollTableViewToBottom(false)
//        } else if contentHeight > tableHeight {
//            self.newConversationCounter += 1
//        }
//        self.updateNewConversationCountButton(animation: true)
//    }
    
}
// Helper function inserted by Swift 4.2 migrator.
#if swift(>=4.2)
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
#endif

extension AgentConversationViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(self.navigationController?.interactivePopGestureRecognizer) else{ return true }
        messageTextView.resignFirstResponder()
        channel?.send(message: HippoMessage.stopTyping, completion: {})
        let channelID = self.channel?.id ?? -1
        clearUnreadCountForChannel(id: channelID)
        if let lastMessage = getLastMessage() {
            agentConversationDelegate?.updateConversationWith(channelId: channel?.id ?? -1, lastMessage: lastMessage, unreadCount: 0)
        }
        
        if channel != nil {
            self.channel.saveMessagesInCache()
            self.channel.deinitObservers()
        }
        NotificationCenter.default.removeObserver(self)
        
        if isSingleChat {
            HippoConfig.shared.notifiyDeinit()
        }
        return true
    }

}

//MARK: UserChannel Bot messages
extension AgentConversationViewController {
    
    func handleChannelRefresh(detail: ChatDetail) {
//        channel?.channelInfo?.isBotInProgress = detail.isBotInProgress
//        channel?.channelInfo?.isReplayDisabled = detail.isReplayDisabled
//        setFooterView()
        channel?.chatDetail?.isBotInProgress = detail.isBotInProgress
        channel?.chatDetail?.disableReply = detail.disableReply
        channel?.isSendingDisabled = detail.disableReply
        if channel?.chatDetail?.disableReply == true{
            //disableSendingReply(withOutUpdate: true)
            disableSendingReply()
        }else{
            enableSendingReply()
        }
        setFooterView(isReplyDisabled: channel?.chatDetail?.disableReply ?? false, isBotInProgress: channel?.chatDetail?.isBotInProgress ?? false)

    }
    
}

extension AgentConversationViewController{
    
    @IBAction func action_CancelEditMessage(){
        messageEditingStopped()
    }
    
    @IBAction func action_SendEditedMessage(){
        if messageInEditing?.message == messageTextView.text{
            self.messageEditingStopped()
            return
        }
        messageInEditing?.message = messageTextView.text
        guard let message = messageInEditing else {
            return
        }
        
        self.apiHitToEditDeleteMsg(message: message, isDeleted: false) { (status) in
            if status{
                self.messageEditingStopped()
            }
        }
    }
    
    func messageEditingStarted(with message : HippoMessage){
        self.messageInEditing = message
        self.moreOptionsButton.isHidden = true
        self.addFileButtonAction.isHidden = true
        self.sendMessageButton.isHidden = true
        self.Button_CancelEdit.isHidden = false
        self.Button_EditMessage.isHidden = false
        self.messageTextView.text = message.message
        self.messageTextView.becomeFirstResponder()
       
    }
    
    func messageEditingStopped(){
        self.messageInEditing = nil
        self.moreOptionsButton.isHidden = false
        self.addFileButtonAction.isHidden = false
        self.sendMessageButton.isHidden = false
        self.Button_CancelEdit.isHidden = true
        self.Button_EditMessage.isHidden = true
        self.messageTextView.text = ""
        self.tableViewChat.deselectRow(at: editingMessageIndex ?? IndexPath(), animated: true)
        self.messageTextView.resignFirstResponder()
    }
    
}
