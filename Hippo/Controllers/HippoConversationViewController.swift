//
//  HippoConversationViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 30/08/18.
//

import UIKit
import Photos
import QuickLook


class HippoConversationViewController: UIViewController {
    //MARK: Constants
    let heightOfActionableMessageImage = 103.5
    let textViewFixedHeight = 50
    let textViewPlaceHolder = "Send a message..."
    let heightOfDateLabel: CGFloat = 40
    
    // MARK: - PROPERTIES
    var processingRequestCount = 0
    var labelId = -11
    var directChatDetail: FuguNewChatAttributes?
    var agentDirectChatDetail: AgentDirectChatAttributes?
    var label = ""
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
    
    //MARK: 
    @IBOutlet var tableViewChat: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setTheme()
        removeNotificationsFromNotificationCenter(channelId: channelId)
        registerFayeNotification()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        checkNetworkConnection()
         self.navigationController?.isNavigationBarHidden = true
        
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
    }
    
    //Set Delegate For channels
    func didSetChannel() { }
    func getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: (() -> Void)?) { }
    func getMessagesWith(labelId: Int, completion: (() -> Void)?) { }
    func checkNetworkConnection() { }
    func closeKeyBoard() { }
    func reloadVisibleCellsToStartActivityIndicator() { }
    func adjustChatWhenKeyboardIsOpened(withHeight keyboardHeight: CGFloat) { }
    func addRemoveShadowInTextView(toAdd: Bool) { }
    func startNewConversation(completion: ((_ success: Bool) -> Void)?) { }
    
    func startGettingNewMessages() { }
    func finishGettingNewMessages() { }
    func clearUnreadCountForChannel(id: Int) { }
    @objc func titleButtonclicked() { }
    func addMessageToUIBeforeSending(message: HippoMessage) { }
    

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
    
    func populateTableViewWithChannelData() {
        guard channel != nil else {
            return
        }
        self.updateMessagesGroupedByDate(self.channel.messages)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.fayeConnected), name: .fayeConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fayeDisconnected), name: .fayeDisconnected, object: nil)
    }
    func registerNotificationToKnowWhenAppIsKilledOrMovedToBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    func registerKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func tableViewSetUp() {
        automaticallyAdjustsScrollViewInsets = false
        tableViewChat.contentInset.bottom = 3
        
        tableViewChat.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        let bundle = FuguFlowManager.bundle
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
        
    }
    
    func registerNotificationWhenAppEntersForeground() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyBoardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, UIApplication.shared.applicationState == .active else {
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
        showAlertWith(message: HippoConfig.shared.strings.noNetworkConnection) {
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
        
        self.modalPresentationStyle = .overCurrentContext
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
//        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
//        container.isUserInteractionEnabled = true
//        container.backgroundColor = UIColor.clear
        
        let color = HippoConfig.shared.theme.headerTextColor
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .center
        button.setTitleColor(color, for: .normal)
        button.addTarget(self, action: #selector(self.titleButtonclicked), for: .touchUpInside)

        self.navigationItem.titleView = button
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationTitleButton = button
        setNavigationTitle(title: label)
    }
    
    
    func setNavigationTitle(title: String) {
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
        
        CallManager.shared.startCall(call: call) { (success) in
            if !success {
                assertionFailure("Cannot start the call")
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
        CallManager.shared.startCall(call: call) { (success) in
            if !success {
                assertionFailure("Cannot start the call")
            }
        }
    }
    func canStartAudioCall() -> Bool {
        guard HippoConfig.shared.isAudioCallEnabled else {
            return false
        }
        guard let allowAudioCall = channel?.chatDetail?.allowAudioCall, allowAudioCall  else {
            return false
        }
        guard channel?.chatDetail?.peerDetail != nil else {
            return false
        }
        let assignemdAgentID = channel?.chatDetail?.assignedAgentID ?? -1
        if HippoConfig.shared.appUserType == .agent && assignemdAgentID != currentUserId()  {
            return false
        }
        return true
        
    }
    
    func canStartVideoCall() -> Bool {
        guard HippoConfig.shared.isVideoCallEnabled else {
            return false
        }
        guard let allowVideoCall = channel?.chatDetail?.allowVideoCall, allowVideoCall  else {
            return false
        }
        guard channel?.chatDetail?.peerDetail != nil else {
            return false
        }
        let assignemdAgentID = channel?.chatDetail?.assignedAgentID ?? -1
        if HippoConfig.shared.appUserType == .agent && assignemdAgentID != currentUserId()  {
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
                latestMessageGroup.append(message)
                messagesGroupedByDate[messagesGroupedByDate.count - 1] = latestMessageGroup
            default:
                addMessageToNewGroup(message: message)
            }
        }
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
    func attachmentButtonclicked() {
        pickerHelper = PickerHelper(viewController: self, enablePayment: HippoProperty.current.isPaymentRequestEnabled)
        pickerHelper?.present(sender: self.view, controller: self)
        pickerHelper?.delegate = self
    }
    
}


extension HippoConversationViewController: PickerHelperDelegate {
    func payOptionClicked() {
        let vc = CreatePaymentViewController.get()
        vc.delegate = self
        self.navigationController?.isNavigationBarHidden = false
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
            showAlert(title: "", message: result.error?.localizedDescription ?? HippoConfig.shared.strings.somethingWentWrong, actionComplete: nil)
            return
        }
        let mediaType = result.mediaType ?? .imageType
        switch mediaType {
        case .gifType, .imageType:
            guard let selectedImage = result.image else {
                showAlert(title: "", message: HippoConfig.shared.strings.somethingWentWrong, actionComplete: nil)
                return
            }
            sendConfirmedImage(image: selectedImage, mediaType: mediaType)
        case .movieType:
            guard let filePath = result.filePath else {
                showAlert(title: "", message: HippoConfig.shared.strings.somethingWentWrong, actionComplete: nil)
                return
            }
            let filePathUrl = URL(fileURLWithPath: filePath)
            sendSelectedDocumentWith(filePath: filePathUrl.path, fileName: filePathUrl.lastPathComponent, messageType: .attachment, fileType: FileType.video)
        }
        
        
    }
    
    func didPickDocumentWith(url: URL) {
        sendSelectedDocumentWith(filePath: url.path, fileName: url.lastPathComponent, messageType: .attachment, fileType: .document)
    }
}
extension HippoConversationViewController {
    
    func sendSelectedDocumentWith(filePath: String, fileName: String, messageType: MessageType, fileType: FileType) {
        guard doesFileExistsAt(filePath: filePath) else {
            return
        }
        let uniqueName = DownloadManager.generateNameWhichDoestNotExistInCacheDirectoryWith(name: fileName)
        saveDocumentInCacheDirectoryWith(name: uniqueName, orignalFilePath: filePath)
        
        let message = HippoMessage(message: "", type: messageType, uniqueID: generateUniqueId(), imageUrl: nil, thumbnailUrl: nil, localFilePath: filePath)
        
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
        if channel != nil {
            self.UploadAndSendMessage(message: message)
        } else {
            startNewConversation { (success) in
                guard success else {
                    return
                }
                self.UploadAndSendMessage(message: message)
            }
        }
        
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
        tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
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
        channel?.send(message: message, completion: nil)
    }
    
    func sendConfirmedImage(image confirmedImage: UIImage, mediaType: CoreMediaSelector.Result.MediaType ) {
        var imageExtention: String = ".jpg"
        let imageData: Data?
        
        let imageSize =  confirmedImage.jpegData(compressionQuality: 1)!.count
        print(imageSize)
        
        let compressionRate = getCompressonRateForImageWith(size: imageSize)
        
        switch mediaType {
        case .gifType:
            imageExtention = ".gif"
            imageData = confirmedImage.kf.gifRepresentation() ?? confirmedImage.kf.jpegRepresentation(compressionQuality: 1)
        default:
            imageExtention = ".jpg"
            imageData = confirmedImage.jpegData(compressionQuality: compressionRate)
        }
        
        let imageName = Date.timeIntervalSinceReferenceDate.description + imageExtention
        let imageFilePath = getCacheDirectoryUrlForFileWith(name: imageName).path
        
        try? imageData?.write(to: URL(fileURLWithPath: imageFilePath), options: [.atomic])
        
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
        let message = HippoMessage(message: "", type: .imageFile, uniqueID: generateUniqueId(), localFilePath: localPath)
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
                message.wasMessageSendingFailed = true
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
            self.startNewConversation() {[weak self] (result) in
                self?.channel?.send(message: message, completion: {})
            }
        } else {
            channel?.send(message: message, completion: {})
        }
    }
    
//    func updateChatInfoWith(chatObj: ConversationObject) {
//        if let channelId = chatObj.channel_id, channelId > 0 {
//            self.channel = AgentChannelPersistancyManager.shared.getChannelBy(id: channelId)
//        }
//        channel?.channelInfo?.assignedAgentID = chatObj.agent_id ?? -1
//        channel?.channelInfo?.assignedAgentName = chatObj.agent_name ?? ""
//
//        self.channelTitle = chatObj.label ?? "User"
//    }
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
            self.tableViewChat.beginUpdates()
            
            if countOfDateGroupedArrayBeforeUpdate == self.messagesGroupedByDate.count {
                
                let currentLastSectionRows = self.messagesGroupedByDate.last!.count
                
                if previousLastSectionRows != currentLastSectionRows {
                    let lastIndexPath = IndexPath(row: currentLastSectionRows - 1, section: self.messagesGroupedByDate.count - 1)
                    self.tableViewChat.insertRows(at: [lastIndexPath], with: .none)
                }
                
            } else {
                let newSectionsOfTableView = IndexSet([self.messagesGroupedByDate.count - 1])
                self.tableViewChat.insertSections(newSectionsOfTableView, with: .none)
            }
            self.tableViewChat.endUpdates()
        }
        
    }
    func openQuicklookFor(fileURL: String, fileName: String) {
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
    func getIncomingAttributedString(chatMessageObject: HippoMessage) -> NSMutableAttributedString {
        let messageString = chatMessageObject.message
        let userNameString = chatMessageObject.senderFullName
        
        
        return attributedStringForLabel(userNameString, secondString: "\n" + messageString, thirdString: "", colorOfFirstString: HippoConfig.shared.theme.senderNameColor, colorOfSecondString: HippoConfig.shared.theme.incomingMsgColor, colorOfThirdString: UIColor.black.withAlphaComponent(0.5), fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString:  HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.systemFont(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
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
    
    func cancelMessage(message: HippoMessage) {
        for (index, tempMessage) in channel.unsentMessages.enumerated() {
            if tempMessage.messageUniqueID == message.messageUniqueID, message.messageUniqueID != nil {
                channel.unsentMessages.remove(at: index)
                messagesGroupedByDate = []
                updateMessagesGroupedByDate(channel.messages)
                break
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
    
}

extension HippoConversationViewController: ActionTableViewDelegate {
    func performActionFor(selectionId: String, message: HippoMessage) {
        guard let customMessage = message as? HippoActionMessage else {
            return
        }
        customMessage.selectBtnWith(btnId: selectionId)
        sendMessage(message: customMessage)
    }
}
extension HippoConversationViewController: CreatePaymentDelegate {
    func sendMessage(for store: PaymentStore) {
        let message = HippoMessage(message: "", type: .hippoPay, uniqueID: String.generateUniqueId())
        let custom_action = store.getJsonToSend()
        message.actionableMessage = FuguActionableMessage(dict: custom_action)
        message.rawJsonToSend = ["custom_action": custom_action]
        addMessageInUnsentArray(message: message)
        updateMessagesArrayLocallyForUIUpdation(message)
        scrollToBottomWithIndexPath(animated: true)
        
        publishMessageOnChannel(message: message)
    }
}
