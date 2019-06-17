//
//  AgentConversationViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 19/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit
import Photos

protocol AgentChatDeleagate: class {
    func updateConversationWith(channelId: Int, lastMessage: HippoMessage, unreadCount: Int)
}


class AgentConversationViewController: HippoConversationViewController {
    
    // MARK: -  IBOutlets
    @IBOutlet weak var audioButton: UIBarButtonItem!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageTextView: UITextView!
//    @IBOutlet weak var errorContentView: UIView!
//    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var textViewBgView: UIView!
    @IBOutlet var placeHolderLabel: UILabel!
    @IBOutlet var addFileButtonAction: UIButton!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet weak var loaderView: So_UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var videoButton: UIBarButtonItem!
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    
    //    @IBOutlet weak var hieghtOfNavigationBar: NSLayoutConstraint!
    @IBOutlet weak var loadMoreActivityTopContraint: NSLayoutConstraint!
    @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - PROPERTIES
    var heightOfNavigation: CGFloat = 0
    
    var isSingleChat = false
    
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
    
    
    //    var getSavedUserId: Int {
    //        return FuguConfig.shared.agentDetail?.id ?? -1
    //    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        HippoConfig.shared.notifyDidLoad()
        setNavBarHeightAccordingtoSafeArea()
        configureChatScreen()
        
        guard channel != nil else {
            startNewConversation(completion: { [weak self] (success, result) in
                if success {
                    self?.populateTableViewWithChannelData()
                    self?.fetchMessagesFrom1stPage()
                }
            })
            return
        }
//        infoButton.isHidden = true
        
        populateTableViewWithChannelData()
        fetchMessagesFrom1stPage()
    }
    
    override func didSetChannel() {
        channel?.delegate = self
    }
    
    override func closeKeyBoard() {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messageTextView.contentInset.top = 8
        handleInfoIcon()
        handleVideoIcon()
        handleAudioIcon()
        setNavigationTitle(title: label)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaderView.isHidden {
            startLoaderAnimation()
        }
        AgentConversationManager.getUserUnreadCount()
        reloadVisibleCellsToStartActivityIndicator()
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
    }
    
    
    func navigationSetUp() {
        setTitleButton()
        if HippoConfig.shared.theme.sendBtnIcon != nil {
            sendMessageButton.setImage(HippoConfig.shared.theme.sendBtnIcon, for: .normal)
            
            if let tintColor = HippoConfig.shared.theme.sendBtnIconTintColor {
                sendMessageButton.tintColor = tintColor
            }
            
            sendMessageButton.setTitle("", for: .normal)
        } else { sendMessageButton.setTitle("SEND", for: .normal) }
        
        if HippoConfig.shared.theme.addButtonIcon != nil {
            addFileButtonAction.setImage(HippoConfig.shared.theme.addButtonIcon, for: .normal)
            
            if let tintColor = HippoConfig.shared.theme.addBtnTintColor {
                addFileButtonAction.tintColor = tintColor
            }
            
            addFileButtonAction.setTitle("", for: .normal)
        } else { addFileButtonAction.setTitle("ADD", for: .normal) }
        
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
            
            if HippoConfig.shared.theme.leftBarButtonFont != nil {
                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            }
            
            
            backButton.setTitleColor(HippoConfig.shared.theme.leftBarButtonTextColor, for: .normal)
            
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
                backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
        
        if !label.isEmpty {
            setNavigationTitle(title: label)
        } else if let businessName = userDetailData["business_name"] as? String {
            label = businessName
            setNavigationTitle(title: label)
        }
        
    }
        
    // MARK: - UIButton Actions
    
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
        
        guard let vc = AgentChatInfoViewController.get(chatDetail: channelDetail) else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func addImagesButtonAction(_ sender: UIButton) {
        if (channel != nil && !channel.isSubscribed()) || !FuguNetworkHandler.shared.isNetworkConnected {
            buttonClickedOnNetworkOff()
            return
        }
        self.attachmentButtonclicked()
    }
    func buttonClickedOnNetworkOff() {
        guard !FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        messageTextView.resignFirstResponder()
        showAlertForNoInternetConnection()
    }
    
    
    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
        if channel != nil, !channel.isSubscribed() {
            buttonClickedOnNetworkOff()
            return
        }
        if isMessageInvalid(messageText: messageTextView.text) {
            return
        }
        let trimmedMessage = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let message = HippoMessage(message: trimmedMessage, type: .normal, uniqueID: String.generateUniqueId())
        channel?.unsentMessages.append(message)
        
        
        if channel != nil {
            addMessageToUIBeforeSending(message: message)
            self.sendMessage(message: message)
        } else {
            //TODO: - Loader animation
            startNewConversation(completion: { [weak self] (success, result) in
                if success {
                    self?.populateTableViewWithChannelData()
                    self?.addMessageToUIBeforeSending(message: message)
                    self?.sendMessage(message: message)
                }
            })
        }
        
    }
    
    override func addMessageToUIBeforeSending(message: HippoMessage) {
        self.updateMessagesArrayLocallyForUIUpdation(message)
        self.messageTextView.text = ""
        self.newScrollToBottom(animated: false)
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
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
    
    override func titleButtonclicked() {
        guard isCustomerInfoAvailable() else {
            return
        }
        guard let channelDetail = channel?.chatDetail else {
            handleInfoIcon()
            return
        }
        
        guard let vc = AgentChatInfoViewController.get(chatDetail: channelDetail) else {
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
            errorMessage = HippoConfig.shared.strings.noNetworkConnection
            showErrorMessage()
        }
    }
    
    func isPaginationInProgress() -> Bool {
        return loadMoreActivityTopContraint.constant == 10
    }
    
    override func
        getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: (() -> Void)?) {
        
        guard channel != nil else {
            completion?()
            return
        }
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            let message = HippoConfig.shared.strings.noNetworkConnection
            showErrorMessage(messageString: message, bgColor: UIColor.red)
            completion?()
            return
        }
        
        if HippoConfig.shared.agentDetail?.fuguToken == nil {
            showHideActivityIndicator()
            completion?()
            return
        }
        processingRequestCount += 1
        if pageStart == 1, channel.messages.count == 0 {
            startLoaderAnimation()
            disableSendingNewMessages()
        }  else if !isPaginationInProgress()  {
            startGettingNewMessages()
        }
        
        let request = MessageStore.messageRequest(pageStart: pageStart, showLoader: false, pageEnd: pageEnd, channelId: channel.id, labelId: -1)
        
        MessageStore.getMessages(requestParam: request, ignoreIfInProgress: false) {[weak self] (response, isCreateConversationRequired)  in
            guard self != nil else {
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
                completion?()
                return
            }
            weakself.handleSuccessCompletionOfGetMessages(result: result, request: request, completion: completion)
        }
    }
    
    func handleSuccessCompletionOfGetMessages(result: MessageStore.ChannelMessagesResult, request: MessageStore.messageRequest, completion: (() -> Void)?) {
        
        
        channel?.chatDetail = result.chatDetail
        handleInfoIcon()
        handleVideoIcon()
        handleAudioIcon()
        
        var messages = result.newMessages
        let newMessagesHashMap = result.newMessageHashmap
        
        label = result.channelName
        setNavigationTitle(title: label)
        
        if request.pageStart == 1 && messages.count > 0 {
            filterMessages(newMessagesHashMap: newMessagesHashMap, lastMessage: messages.last!)
        } else {
            messages = filterForMultipleMuid(newMessages: messages, newMessagesHashMap: newMessagesHashMap)
        }
        updateMessagesInLocalArrays(messages: messages)
        
        
        let contentOffsetBeforeNewMessages = tableViewChat.contentOffset.y
        let contentHeightBeforeNewMessages = tableViewChat.contentSize.height
        tableViewChat.reloadData()
        
        if request.pageStart > 1 {
            keepTableViewWhereItWasBeforeReload(oldContentHeight: contentHeightBeforeNewMessages, oldYOffset: contentOffsetBeforeNewMessages)
        }
        if result.isSendingDisabled {
            disableSendingReply()
        }
        if request.pageStart == 1, request.pageEnd == nil {
            newScrollToBottom(animated: true)
            sendReadAllNotification()
        }
        
        willPaginationWork = result.isMoreDataToLoad
        
        completion?()
    }
    
    
    func keepTableViewWhereItWasBeforeReload(oldContentHeight: CGFloat, oldYOffset: CGFloat) {
        let newContentHeight = tableViewChat.contentSize.height
        let differenceInContentSizes = newContentHeight - oldContentHeight
        
        let oldYPosition = differenceInContentSizes + oldYOffset
        
        let newContentOffset = CGPoint(x: 0, y: oldYPosition)
        
        tableViewChat.setContentOffset(newContentOffset, animated: false)
        
    }
    
    
    override func startNewConversation(completion: ((_ success: Bool, _ result: HippoChannelCreationResult) -> Void)?) {
        
        disableSendingNewMessages()
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            errorMessage = HippoConfig.shared.strings.noNetworkConnection
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
        messageTextView.isEditable = true
    }
    
    func disableSendingNewMessages() {
        addFileButtonAction.isUserInteractionEnabled = false
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
        stopLoaderAnimation()
        fetchMessagesFrom1stPage()
    }
    
    func updateChatInfoWith(chatObj: AgentConversation) {
        
        if let channelId = chatObj.channel_id, channelId > 0 {
            self.channel = AgentChannelPersistancyManager.shared.getChannelBy(id: channelId)
        }
        
        self.label = chatObj.label ?? ""
    }
    
    // MARK: - Type Methods
    class func getWith(conversationObj: AgentConversation) -> AgentConversationViewController {
        let vc = getNewInstance()
        vc.updateChatInfoWith(chatObj: conversationObj)
        return vc
    }
    
    
    class func getWith(chatAttributes: AgentDirectChatAttributes) -> AgentConversationViewController {
        let vc = getNewInstance()
        vc.agentDirectChatDetail = chatAttributes
        vc.label = chatAttributes.channelName
        return vc
    }
    
    class func getWith(channelID: Int, channelName: String) -> AgentConversationViewController {
        let vc = getNewInstance()
        vc.channel = AgentChannelPersistancyManager.shared.getChannelBy(id: channelID)
        vc.label = channelName
        return vc
    }
    
    private class func getNewInstance() -> AgentConversationViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AgentConversationViewController") as! AgentConversationViewController
        return vc
    }
    
    
}

// MARK: - HELPERS
extension AgentConversationViewController {
    
    func handleInfoIcon() {
//        let customerId = channel?.chatDetail?.customerID ?? -1
//        infoButton.isHidden = customerId < 1
    }
    
    
    func handleVideoIcon() {
        setTitleButton()
        if canStartVideoCall() {
            videoButton.image = HippoConfig.shared.theme.videoCallIcon
            videoButton.tintColor = HippoConfig.shared.theme.headerTextColor
            videoButton.isEnabled = true
            videoButton.title = nil
        } else {
            videoButton.title = ""
            videoButton.image = nil
            videoButton.isEnabled = false
            
        }
    }
    func handleAudioIcon() {
        setTitleButton()
        if canStartAudioCall() {
            audioButton.image = HippoConfig.shared.theme.audioCallIcon
            audioButton.tintColor = HippoConfig.shared.theme.headerTextColor
            audioButton.isEnabled = true
        } else {
            audioButton.image = nil
            audioButton.isEnabled = false
        }
    }
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
        placeHolderLabel.text = HippoConfig.shared.strings.messagePlaceHolderText
        hideErrorMessage()
        sendMessageButton.isEnabled = false
        
        if channel != nil, channel.isSendingDisabled == true {
            disableSendingReply()
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
        textViewBgView.backgroundColor = .white
        if isObserverAdded == false {
            textViewBgView.layoutIfNeeded()
            let inputView = FrameObserverAccessaryView(frame: textViewBgView.bounds)
            inputView.isUserInteractionEnabled = false
            
            messageTextView.inputAccessoryView = inputView
            
            inputView.changeKeyboardFrame { [weak self] (keyboardVisible, keyboardFrame) in
                let value = UIScreen.main.bounds.height - keyboardFrame.minY - UIView.safeAreaInsetOfKeyWindow.bottom
                let maxValue = max(0, value)
                self?.textViewBottomConstraint.constant = maxValue
                
                self?.view.layoutIfNeeded()
            }
            isObserverAdded = true
        }
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
    
    func startLoaderAnimation() {
        loaderView.startRotationAnimation()
    }
    
    func stopLoaderAnimation() {
        loaderView.stopRotationAnimation()
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
    func scrollTableViewToBottom(animated: Bool = false) {
        
        DispatchQueue.main.async {
            if self.messagesGroupedByDate.count > 0 {
                let givenMessagesArray = self.messagesGroupedByDate[self.messagesGroupedByDate.count - 1]
                if givenMessagesArray.count > 0 {
                    let indexPath = IndexPath(row: givenMessagesArray.count - 1, section: self.messagesGroupedByDate.count - 1)
                    self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    
    func expectedHeight(OfMessageObject chatMessageObject: HippoMessage) -> CGFloat {
        
        let availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
        let availableBoxSize = CGSize(width: availableWidthSpace,
                                      height: CGFloat.greatestFiniteMagnitude)
        
        var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7
        
        let incomingAttributedString = getIncomingAttributedString(chatMessageObject: chatMessageObject)
        cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
        
        return cellTotalHeight
    }
    
}

// MARK: - UIScrollViewDelegate
extension AgentConversationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableViewChat.contentOffset.y < -5.0 && self.willPaginationWork, FuguNetworkHandler.shared.isNetworkConnected {
            
            guard !isGettingMessageViaPaginationInProgress else {
                return
            }
            
            showHideActivityIndicator(hide: false)
            let count = channel?.sentMessages.count ?? 0
            
            isGettingMessageViaPaginationInProgress = true
            self.getMessagesBasedOnChannel(fromMessage: count + 1, pageEnd: nil, completion: { [weak self] in
                self?.showHideActivityIndicator(hide: true)
                self?.isGettingMessageViaPaginationInProgress = false
            })
        }
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
                case .attachment:
                    if isOutgoingMsg {
                        switch message.concreteFileType! {
                        case .video:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingVideoTableViewCell", for: indexPath) as! OutgoingVideoTableViewCell
                            cell.setCellWith(message: message)
                            cell.retryDelegate = self
                            cell.delegate = self
                            return cell
                        default:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingDocumentTableViewCell") as! OutgoingDocumentTableViewCell
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
                    var rowHeight = expectedHeight(OfMessageObject: message)
                    rowHeight += returnRetryCancelButtonHeight(chatMessageObject: message)
                    rowHeight += getTopDistanceOfCell(atIndexPath: indexPath)
                    return rowHeight
                case .attachment:
                    switch message.concreteFileType! {
                        
                    case .video:
                        return 234
                    default:
                        return 80
                    }
                case MessageType.actionableMessage:
                    return 0.01
                case MessageType.assignAgent:
                    return UIView.tableAutoDimensionHeight
                case MessageType.call:
                    return UIView.tableAutoDimensionHeight
                default:
                    return 0.01//UITableViewAutomaticDimension
                    
                }
            }
        default: break
        }
        return UIView.tableAutoDimensionHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = self.messagesGroupedByDate[chatSection]
            if messagesArray.count > indexPath.row {
                let message = messagesArray[indexPath.row]
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
        dateLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
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
            let heightOfContent = (titleText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: senderNameFont!)) + bottomSpace + margin
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
        let collectionViewHeight = self.getHeighOfButtonCollectionView(actionableMessage: chatMessageObject.actionableMessage!)
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
        textViewBgView.backgroundColor = .white
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.watcherOnTextView), userInfo: nil, repeats: true)
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textViewBgView.backgroundColor = UIColor.white
        placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.5)
        
        timer.invalidate()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        typingMessageValue = TypingMessage.startTyping.rawValue
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
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
        self.textViewBottomConstraint.constant = -self.textViewBgView.frame.height
        self.textViewBgView.isHidden = true
    }
    
}

// MARK: - SelectImageViewControllerDelegate Delegates
extension AgentConversationViewController: SelectImageViewControllerDelegate {
    func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage) {
        selectedImageVC.dismiss(animated: false) {
            self.imagePicker.dismiss(animated: false) {
                self.sendConfirmedImage(image: selectedImage, mediaType: .imageType)
            }
        }
    }
    
    func goToConversationViewController() {}
}

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

extension AgentConversationViewController: HippoChannelDelegate {
    func channelDataRefreshed() {
        handleAudioIcon()
        handleVideoIcon()
        tableViewChat.reloadData()
    }
    
    
    func cancelSendingMessage(message: HippoMessage, errorMessage: String?) {
        self.cancelMessage(message: message)
        
        if let message = errorMessage {
            showErrorMessage(messageString: message)
            updateErrorLabelView(isHiding: true)
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
        message.status = .read
        message.wasMessageSendingFailed = false
        
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
