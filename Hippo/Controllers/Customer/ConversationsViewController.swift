//
//  ConversationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/9/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import Photos

class LeadDataTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

protocol NewChatSentDelegate: class {
    func updateConversationWith(conversationObj: FuguConversation)
}


 class ConversationsViewController: HippoConversationViewController {
    
    //MARK: Constants
    var createConversationOnStart = false
    
    // MARK: -  IBOutlets
    @IBOutlet weak var audioCAllButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundView: UIView!
   @IBOutlet var navigationBackgroundView: UIView!
   @IBOutlet var navigationTitleLabel: UILabel!
   @IBOutlet var backButton: UIButton!
   
   @IBOutlet var sendMessageButton: UIButton!
   @IBOutlet var messageTextView: UITextView!
   @IBOutlet weak var errorContentView: UIView!
   @IBOutlet var errorLabel: UILabel!
   @IBOutlet var textViewBgView: UIView!
   @IBOutlet var placeHolderLabel: UILabel!
   @IBOutlet var addFileButtonAction: UIButton!
   @IBOutlet var seperatorView: UIView!
   @IBOutlet weak var loaderView: So_UIImageView!
   
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
   @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
   @IBOutlet var errorLabelTopConstraint: NSLayoutConstraint!
   @IBOutlet weak var hieghtOfNavigationBar: NSLayoutConstraint!
   @IBOutlet weak var loadMoreActivityTopContraint: NSLayoutConstraint!
   @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!
    
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

   
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        HippoConfig.shared.notifiyDeinit()
        print("Conversation View Controller deintialized")
    }
   
   // MARK: - LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setNavBarHeightAccordingtoSafeArea()
      configureChatScreen()
    
        guard channel != nil else {
        if createConversationOnStart {
            startNewConversation(completion: { [weak self] (success) in
                guard success else {
                    return
                }
                self?.populateTableViewWithChannelData()
                self?.fetchMessagesFrom1stPage()
            })
        } else {
            fetchMessagesFrom1stPage()
        }
        return
       }
      
      channel.delegate = self

      populateTableViewWithChannelData()
      fetchMessagesFrom1stPage()
      HippoConfig.shared.notifyDidLoad()
    }
    
   override  func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      messageTextView.contentInset.top = 8
      self.navigationController?.isNavigationBarHidden = true

      handleVideoIcon()
      handleAudioIcon()
      HippoConfig.shared.notifyDidLoad()
   }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaderView.isHidden {
            startLoaderAnimation()
        }
        reloadVisibleCellsToStartActivityIndicator()
        HippoConfig.shared.notifyDidLoad()
    }

    override func closeKeyBoard() {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
    }
   
    override func addRemoveShadowInTextView(toAdd: Bool) {
      guard isViewLoaded else {
         return
      }
      
      self.seperatorView.isHidden = true
      self.seperatorView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.9294117647, alpha: 1)
      if toAdd {
         self.seperatorView.isHidden = false
      }
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
      
   override  func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    
   }
   
    override func didSetChannel() {
        channel?.delegate = self
    }
   func navigationSetUp() {
      navigationBackgroundView.layer.shadowColor = UIColor.black.cgColor
      navigationBackgroundView.layer.shadowOpacity = 0.25
      navigationBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
      navigationBackgroundView.layer.shadowRadius = 4
      
      navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
      
      navigationTitleLabel.textColor = HippoConfig.shared.theme.headerTextColor
      
      if HippoConfig.shared.theme.headerTextFont  != nil {
         navigationTitleLabel.font = HippoConfig.shared.theme.headerTextFont
      }
      
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
      
      if HippoConfig.shared.theme.headerTextFont  != nil {
         navigationTitleLabel.font = HippoConfig.shared.theme.headerTextFont
      }
      
      if HippoConfig.shared.navigationTitleTextAlignMent != nil {
         navigationTitleLabel.textAlignment = HippoConfig.shared.navigationTitleTextAlignMent!
      }
      

      
      if !label.isEmpty {
         navigationTitleLabel.text = label
      } else {
         if let businessName = userDetailData["business_name"] as? String {
            navigationTitleLabel.text = businessName
         }
      }

   }
   
// MARK: - UIButton Actions
    
    @IBAction func audiCallButtonClicked(_ sender: Any) {
        startAudioCall()
    }
    @IBAction func videoButtonClicked(_ sender: Any) {
     startVideoCall()
   }
    
   @IBAction func addImagesButtonAction(_ sender: UIButton) {
      if channel != nil, !channel.isSubscribed() {
        buttonClickedOnNetworkOff()
        return
      }
     attachmentButtonclicked()
//      imagePicker.delegate = self
//      let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//
//      let cameraAction = UIAlertAction(title: HippoConfig.shared.strings.cameraString, style: .default, handler: { (alert: UIAlertAction!) -> Void in
//         self.view.endEditing(true)
//         if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
//            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//            self.performActionBasedOnCameraPermission()
//         }
//      })
//
//      let photoLibraryAction = UIAlertAction(title: HippoConfig.shared.strings.photoLibrary, style: .default, handler: { (alert: UIAlertAction!) -> Void in
//         self.view.endEditing(true)
//         self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//         self.performActionBasedOnGalleryPermission()
//      })
//
//      let cancelAction = UIAlertAction(title: HippoConfig.shared.strings.attachmentCancel, style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
//
//      if UIDevice.current.userInterfaceIdiom == .pad {
//        var rect = CGRect()
//        rect = CGRect(x: sender.frame.origin.x + sender.frame.width / 2, y: sender.frame.origin.y + self.textViewBgView.frame.origin.y, width:1, height:1)
//        if let presenter = actionSheet.popoverPresentationController {
//            presenter.sourceView = self.view
//            presenter.sourceRect = rect
//         }
//      }
//
//      actionSheet.addAction(photoLibraryAction)
//      actionSheet.addAction(cameraAction)
//      actionSheet.addAction(cancelAction)
//
//      self.present(actionSheet, animated: true, completion: nil)
   }
   
//   func checkPhotoLibraryPermission() {
//      let status = PHPhotoLibrary.authorizationStatus()
//      switch status {
//      case .authorized: break //handle authorized status
//      case .denied, .restricted : break //handle denied status
//      case .notDetermined: // ask for permissions
//         PHPhotoLibrary.requestAuthorization() { status in
//            switch status {
//            case .authorized: break // as above
//            case .denied, .restricted: break // as above
//            case .notDetermined: break // won't happen but still
//            }
//         }
//      }
//   }
   
    
    func buttonClickedOnNetworkOff() {
        guard !FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        messageTextView.resignFirstResponder()
        showAlertForNoInternetConnection()
    }
    
   @IBAction func sendMessageButtonAction(_ sender: UIButton) {
    if channel != nil, !channel.isSubscribed()  {
        buttonClickedOnNetworkOff()
        return
    }
      if isMessageInvalid(messageText: messageTextView.text) {
         return
      }
      let trimmedMessage = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      
      let message = HippoMessage(message: trimmedMessage, type: .normal, uniqueID: String.generateUniqueId())
      channel?.unsentMessages.append(message)
    // Check if we have quick reply pending action
       sendQuickReplyReposeIfRequired()
      
      if channel != nil {
         addMessageToUIBeforeSending(message: message)
         self.sendMessage(message: message)
      } else {
         //TODO: - Loader animation
         startNewConversation(completion: { [weak self] (success) in
            if success {
               self?.populateTableViewWithChannelData()
               self?.addMessageToUIBeforeSending(message: message)
               self?.sendMessage(message: message)
            }
         })
      }
      
   }
   
    
    func sendQuickReplyReposeIfRequired() {
        guard self.channel != nil else {
            return
        }
        guard let quickReplyMessage = self.getMessageForQuickReply(messages: self.channel.messages), quickReplyMessage.values.isEmpty, !quickReplyMessage.content.actionId.isEmpty else {
            return
        }
        var selectedActionId = quickReplyMessage.defaultActionId ?? ""
        if !quickReplyMessage.content.buttonTitles.isEmpty, selectedActionId.isEmpty {
            selectedActionId = quickReplyMessage.content.actionId[0]
        }
        quickReplyMessage.selectedActionId = selectedActionId
        let index = quickReplyMessage.content.actionId.index(of: selectedActionId) ?? 0
        self.sendQuickMessage(shouldSendButtonTitle: false, chat: quickReplyMessage, buttonIndex: index)
    }
    
    override func addMessageToUIBeforeSending(message: HippoMessage) {
      self.updateMessagesArrayLocallyForUIUpdation(message)
      self.messageTextView.text = ""
      self.newScrollToBottom(animated: false)
   }
   
   
   
   @IBAction func backButtonAction(_ sender: UIButton) {
      messageTextView.resignFirstResponder()
      
      channel?.send(message: HippoMessage.stopTyping, completion: {})
      let rawLabelID = self.labelId == -1 ? nil : self.labelId
      let channelID = self.channel?.id ?? -1
    
     clearUnreadCountForChannel(id: channelID)
    if let lastMessage = getLastMessage(), let conversationInfo = FuguConversation(channelId: channelID, unreadCount: 0, lastMessage: lastMessage, labelID: rawLabelID) {
        
         delegate?.updateConversationWith(conversationObj: conversationInfo)
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
 override func clearUnreadCountForChannel(id: Int) {
        
        let channelRaw: [String: Any] = ["channel_id": id]
        resetForChannel(pushInfo: channelRaw)
        
        var chats = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] ?? [[:]]
        let index = chats.index { (o) -> Bool in
            return (o["channel_id"] as? Int) ?? -2 == id
        }
        
        if index != nil {
            var obj = chats[index!]
            obj["unread_count"] = 0
            chats[index!] = obj
            FuguDefaults.set(value: chats, forKey: DefaultName.conversationData.rawValue)
            pushTotalUnreadCount()
        }
    }

    func disableSendingReply() {
        self.channel?.isSendingDisabled = true
        self.textViewBottomConstraint.constant = -self.textViewBgView.frame.height
        self.textViewBgView.isHidden = true
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
   
   
    override func adjustChatWhenKeyboardIsOpened(withHeight keyboardHeight: CGFloat) {
        // TODO: - Refactor
        guard tableViewChat.contentSize.height + keyboardHeight > UIScreen.main.bounds.height - hieghtOfNavigationBar.constant else {
            return
        }
        
        let diff = ((tableViewChat.contentSize.height + keyboardHeight) - (UIScreen.main.bounds.height - hieghtOfNavigationBar.constant))
        
        let keyboardHeightNew = keyboardHeight - textViewBgView.frame.height - UIView.safeAreaInsetOfKeyWindow.bottom
        
        let mini = min(diff, keyboardHeightNew)
        
        var newOffSetY = tableViewChat.contentOffset.y + mini
        if !shouldShiftUpWithThis(newOffsetY: newOffSetY) {
            newOffSetY = getMaxScrollableOffset()
        }
        
        let newOffSet = CGPoint(x: 0, y: newOffSetY)
        tableViewChat.setContentOffset(newOffSet, animated: false)
    }
    
    override func checkNetworkConnection() {
        errorLabel.backgroundColor = UIColor.red
        if FuguNetworkHandler.shared.isNetworkConnected {
            errorLabelTopConstraint.constant = -20
            updateErrorLabelView(isHiding: true)
        } else {
            errorLabelTopConstraint.constant = -20
            errorLabel.text = "No internet connection"
            updateErrorLabelView(isHiding: false)
        }
    }
   
    func isPaginationInProgress() -> Bool {
        return loadMoreActivityTopContraint.constant == 10
    }
    
   // MARK: - SERVER HIT
    override func getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: (() -> Void)?) {
      
      guard channel != nil else {
         completion?()
         return
      }
      
      if FuguNetworkHandler.shared.isNetworkConnected == false {
//         if self.messagesGroupedByDate.isEmpty {
            self.errorLabel.text = "No Internet Connection"
            self.updateErrorLabelView(isHiding: false)
//         }
         completion?()
         return
      }
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         showHideActivityIndicator()
         completion?()
         return
      }
      
      if pageStart == 1, channel.messages.count == 0 {
         startLoaderAnimation()
         disableSendingNewMessages()
      } else if !isPaginationInProgress() {
            startGettingNewMessages()
       }
        let request = MessageStore.messageRequest(pageStart: pageStart, showLoader: false, pageEnd: pageEnd, channelId: channel.id, labelId: -1)
        
        MessageStore.getMessages(requestParam: request, ignoreIfInProgress: false) {[weak self] (response, isCreateConversationRequired)  in
            
            self?.finishGettingNewMessages()
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
        
        var messages = result.newMessages
        let newMessagesHashMap = result.newMessageHashmap
        
        
        
        
        label = result.channelName
        navigationTitleLabel.text = result.channelName
        channel?.chatDetail = result.chatDetail
        
        handleVideoIcon()
        handleAudioIcon()
        
        if request.pageStart == 1 && messages.count > 0 {
            filterMessages(newMessagesHashMap: newMessagesHashMap, lastMessage: messages.last!)
        } else if messages.count > 0 {
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
    
    func handleVideoIcon() {
        videoButton.isHidden = !canStartVideoCall()
        videoButton.setImage(HippoConfig.shared.theme.videoCallIcon, for: .normal)
        videoButton.tintColor = HippoConfig.shared.theme.headerTextColor
    }
    func handleAudioIcon() {
        let enableAudioCall: Bool = canStartAudioCall()
        audioCallButton.isHidden = !enableAudioCall
        audioCallButton.setImage(HippoConfig.shared.theme.audioCallIcon, for: .normal)
        audioCallButton.tintColor = HippoConfig.shared.theme.headerTextColor
        audioCAllButtonWidthConstraint.constant = enableAudioCall ? 46 : 0
    }
   
   func keepTableViewWhereItWasBeforeReload(oldContentHeight: CGFloat, oldYOffset: CGFloat) {
      let newContentHeight = tableViewChat.contentSize.height
      let differenceInContentSizes = newContentHeight - oldContentHeight
      
      let oldYPosition = differenceInContentSizes + oldYOffset
      
      let newContentOffset = CGPoint(x: 0, y: oldYPosition)
      
      tableViewChat.setContentOffset(newContentOffset, animated: false)
      
   }
   
//    func updateMessagesGroupedByDate(_ chatMessagesArray: [HippoMessage]) {
//
//        for message in chatMessagesArray {
//
//            guard let latestDateTime = getDateTimeStringOfLatestStoredMessage() else {
//                addMessageToNewGroup(message: message)
//                continue
//            }
//
//            let comparisonResult = Calendar.current.compare(latestDateTime, to: message.creationDateTime, toGranularity: .day)
//
//            switch comparisonResult {
//            case .orderedSame:
//                var latestMessageGroup = messagesGroupedByDate.last ?? []
//                latestMessageGroup.append(message)
//                messagesGroupedByDate[messagesGroupedByDate.count - 1] = latestMessageGroup
//            default:
//               addMessageToNewGroup(message: message)
//            }
//        }
//    }
    
//    func getDateTimeStringOfLatestStoredMessage() -> Date? {
//        guard !messagesGroupedByDate.isEmpty else {
//            return nil
//        }
//        guard var latestMessageGroup = messagesGroupedByDate.last, latestMessageGroup.count > 0 else {
//                return nil
//        }
//
//      let groupsFirstMessage = latestMessageGroup[0]
//
//        return groupsFirstMessage.creationDateTime
//    }
   
//   func addMessageToNewGroup(message: HippoMessage) {
//      self.messagesGroupedByDate.append([message])
//   }
   
    func handleRequestForCreateConersationForGetMessages(error: MessageStore.GetMessagesError?, completion: (() -> Void)?) {
        guard let result = error, result.isCreateConversationRequired, HippoConfig.shared.userDetail?.userUniqueKey != nil else {
            completion?()
            return
        }

        channel?.delegate = nil
        channel = nil
        messagesGroupedByDate = []
        labelId = -1
        tableViewChat.reloadData()
        
        directChatDetail = FuguNewChatAttributes.defaultChat
        navigationTitleLabel.text = (userDetailData["business_name"] as? String) ?? "Support"
        completion?()
        startNewConversation(completion: { [weak self] (success) in
            if success {
                self?.populateTableViewWithChannelData()
                self?.fetchMessagesFrom1stPage()
            }
        })
    }
    override func startGettingNewMessages() {
        errorLabel.text = HippoConfig.shared.strings.checkingNewMessages
        errorLabel.backgroundColor = HippoConfig.shared.theme.processingGreenColor
        updateErrorLabelView(isHiding: false)
    }
    override func finishGettingNewMessages() {
//        errorLabel.text = ""
        updateErrorLabelView(isHiding: true, delay: 0)
    }
    
    override func getMessagesWith(labelId: Int, completion: (() -> Void)?) {
      
      if FuguNetworkHandler.shared.isNetworkConnected == false {
         self.errorLabel.text = "No Internet Connection"
         self.updateErrorLabelView(isHiding: false)
         completion?()
         return
      }
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         completion?()
         return
      }
//
//      let params: [String: Any] = [
//         "app_secret_key" : FuguConfig.shared.appSecretKey,
//         "label_id" : labelId,
//         "en_user_id" : FuguConfig.shared.userDetail?.fuguEnUserID ?? "-1",
//         "page_start": 1
//      ]
//
      if channel?.messages.count == 0  || channel == nil {
         startLoaderAnimation()
      } else if !isPaginationInProgress() {
         startGettingNewMessages()
      }

     let request = MessageStore.messageRequest(pageStart: 1, showLoader: false, pageEnd: nil, channelId: -1, labelId: labelId)
    
     MessageStore.getMessagesByLabelID(requestParam: request, ignoreIfInProgress: false) {[weak self] (response, error)  in
        
        self?.stopLoaderAnimation()
        self?.finishGettingNewMessages()
        
        guard error == nil else {
            self?.handleRequestForCreateConersationForGetMessages(error: error, completion: completion)
            return
        }
        
        guard let result = response, result.isSuccessFull, let weakSelf = self else {
            completion?()
            return
        }
        
        weakSelf.labelId = result.labelID
        
        if result.channelID > 0 {
            weakSelf.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: result.channelID)
            weakSelf.channel.delegate = self
            weakSelf.populateTableViewWithChannelData()
        }
        weakSelf.handleSuccessCompletionOfGetMessages(result: result, request: request, completion: completion)
    }
    
    }
   
    override func startNewConversation(completion: ((_ success: Bool) -> Void)?) {
      
      disableSendingNewMessages()
      if FuguNetworkHandler.shared.isNetworkConnected == false {
         self.errorLabel.text = "No Internet Connection"
         self.updateErrorLabelView(isHiding: false)
         disableSendingNewMessages()
         return
      }
      
      startLoaderAnimation()
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         return
      }
      
      if isDefaultChannel() {
         HippoChannel.get(withLabelId: labelId.description) { [weak self] (result) in
            self?.enableSendingNewMessages()
            self?.channelCreatedSuccessfullyWith(result: result)
            completion?(result.isSuccessful)
         }
      } else if directChatDetail != nil {
         HippoChannel.get(withFuguChatAttributes: directChatDetail!) { [weak self] (result) in
            self?.enableSendingNewMessages()
            self?.channelCreatedSuccessfullyWith(result: result)
            completion?(result.isSuccessful)
         }
      } else {
         enableSendingNewMessages()
         stopLoaderAnimation()
      }
   }
   
   func enableSendingNewMessages() {
      addFileButtonAction.isUserInteractionEnabled = true
      messageTextView.isEditable = true
      sendMessageButton.isEnabled = true
   }
   
   func disableSendingNewMessages() {
      addFileButtonAction.isUserInteractionEnabled = false
      messageTextView.isEditable = false
      sendMessageButton.isEnabled = false
   }
      
   func channelCreatedSuccessfullyWith(result: HippoChannelCreationResult) {
      guard result.isSuccessful else {
         stopLoaderAnimation()
         return
      }
      channel = result.channel
      channel.delegate = self
      sendReadAllNotification()
      stopLoaderAnimation()
   }
   
   func updateChatInfoWith(chatObj: FuguConversation) {
      
      if let channelId = chatObj.channelId, channelId > 0 {
         self.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
      }

      self.labelId = chatObj.labelId ?? -1
      self.label = chatObj.label ?? ""
      
    
   }
   
   // MARK: - Type Methods
   class func getWith(conversationObj: FuguConversation) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.updateChatInfoWith(chatObj: conversationObj)
      return vc
   }
   
   class func getWith(labelId: String) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.labelId = Int(labelId) ?? -1
      return vc
   }
   
   class func getWith(chatAttributes: FuguNewChatAttributes) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.directChatDetail = chatAttributes
      vc.label = chatAttributes.channelName ?? ""
      return vc
   }
   
   class func getWith(channelID: Int, channelName: String) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
      vc.label = channelName
      return vc
   }
   
   private class func getNewInstance() -> ConversationsViewController {
      let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
      let vc = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
      return vc
   }
   
   
}

// MARK: - HELPERS
extension ConversationsViewController {
   
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
        
//        self.messageTextView.textAlignment = .left
        self.messageTextView.font = HippoConfig.shared.theme.typingTextFont
        self.messageTextView.textColor = HippoConfig.shared.theme.typingTextColor
        self.messageTextView.backgroundColor = .clear
        
        placeHolderLabel.text = HippoConfig.shared.strings.messagePlaceHolderText
        
        errorLabel.text = ""
        if errorLabelTopConstraint != nil {
            errorLabelTopConstraint.constant = -20
        }
        
        sendMessageButton.isEnabled = false
        
        if channel != nil, channel.isSendingDisabled == true {
            disableSendingReply()
        }
    }
   
   func addTapGestureInTableView() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ConversationsViewController.dismissKeyboard(sender:)))
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
      hieghtOfNavigationBar.constant = 44 + topInset
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
            return 0.01
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
   
    func updateErrorLabelView(isHiding: Bool, delay: Double = 3) {
        if isHiding {
            if self.errorLabelTopConstraint.constant == 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                    self.errorLabelTopConstraint.constant = -20
                    //               UIView.animate(withDuration: 0.5, animations: {
                    self.errorLabel.text = ""
                    self.view.layoutIfNeeded()
                    //               }, completion: {_ in
                    self.errorLabel.backgroundColor = UIColor.red
                    //               })
                }
            }
            return
        }
      
        if errorLabelTopConstraint != nil && errorLabelTopConstraint.constant != 0 {
            self.errorLabelTopConstraint.constant = 0
            //         UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            //         })
        }
    }
   
    func showHideActivityIndicator(hide: Bool = true) {
        if hide {
            if self.loadMoreActivityTopContraint.constant == 10 {
                    self.loadMoreActivityTopContraint.constant = -30
                
//                    UIView.animate(withDuration: 0.2, animations: {
                                    self.view.layoutIfNeeded()
//                    }, completion: {_ in
                        self.loadMoreActivityIndicator.stopAnimating()
                        self.errorLabel.isHidden = false
//                    } )
            }
            return
        }
        
        if loadMoreActivityTopContraint != nil && loadMoreActivityTopContraint.constant != 10 {
            self.loadMoreActivityTopContraint.constant = 10
            self.loadMoreActivityIndicator.startAnimating()
            self.errorLabel.isHidden = true
//            UIView.animate(withDuration: 0.2, animations: {
               self.view.layoutIfNeeded()
               
//            })
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
   
   func isMessageInvalid(messageText: String) -> Bool {
      if messageText.replacingOccurrences(of: " ", with: "").count == 0 ||
         messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
         
         if FuguNetworkHandler.shared.isNetworkConnected == false {
            return true
         }
         
         self.updateErrorLabelView(isHiding: false)
         self.errorLabel.text = "Please enter some text."
         self.updateErrorLabelView(isHiding: true)
         return true
      }
      return false
   }
   
   func internetIsBack() {
//      getMessagesBasedOnChannel(fromMessage: 1, completion: nil)
   }
   
   func expectedHeight(OfMessageObject chatMessageObject: HippoMessage) -> CGFloat {
    
      let availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
      let availableBoxSize = CGSize(width: availableWidthSpace,
                                    height: CGFloat.greatestFiniteMagnitude)
    
      let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId)
    
      var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7
      if chatMessageObject.type == MessageType.botText {
        let incomingAttributedString = getIncomingAttributedString(chatMessageObject: chatMessageObject)
        cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
        return cellTotalHeight
       }
    
    if isOutgoingMsg == true {
        
        let messageString = chatMessageObject.message
        
        #if swift(>=4.0)
         var attributes: [NSAttributedString.Key: Any]?
         if let applicableFont = HippoConfig.shared.theme.inOutChatTextFont {
        attributes = [NSAttributedString.Key.font: applicableFont]
        }
        
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
         let incomingAttributedString = getIncomingAttributedString(chatMessageObject: chatMessageObject)
         cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
      }
      
      return cellTotalHeight
   }

}

// MARK: - UIScrollViewDelegate
extension ConversationsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      if self.tableViewChat.contentOffset.y < -5.0 && self.willPaginationWork, FuguNetworkHandler.shared.isNetworkConnected {
         
         guard !isGettingMessageViaPaginationInProgress, channel != nil else {
            return
         }
         showHideActivityIndicator(hide: false)
         isGettingMessageViaPaginationInProgress = true
        
         self.getMessagesBasedOnChannel(fromMessage: self.channel.sentMessages.count + 1, pageEnd: nil, completion: { [weak self] in
            self?.showHideActivityIndicator(hide: true)
            self?.isGettingMessageViaPaginationInProgress = false
         })
      }
   }
    
}

// MARK: - UITableView Delegates
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
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
            let isOutgoingMsg = isSentByMe(senderId: message.senderId)
            
            guard messageType.isMessageTypeHandled() else {
                return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
            }
            
            switch messageType {
            case MessageType.imageFile:
               if isOutgoingMsg == true {
                  guard
                     let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingImageCell", for: indexPath) as? OutgoingImageCell
                     else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                  }
                cell.delegate = self
                cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath)
                return cell
               } else {
                  guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingImageCell", for: indexPath) as? IncomingImageCell
                     else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                  }
                cell.delegate = self
                return cell.configureIncomingCell(resetProperties: true, channelId: channel.id, chatMessageObject: message, indexPath: indexPath)
               }
            case .feedback:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackTableViewCell") as? FeedbackTableViewCell else {
                    return UITableViewCell()
                }
                var param = FeedbackParams(title: message.message, indexPath: indexPath, messageObj: message)
                param.showSendButton = true
                cell.setData(params: param)
                cell.delegate = self
                cell.backgroundColor = .clear
                if let muid = message.messageUniqueID {
                   heightForFeedBackCell["\(muid)"] = cell.alertContainer.bounds.height
                }
//                print("-----\(cell.alertContainer.bounds.height)")
                return cell
            case .botText:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMessageTableViewCell", for: indexPath) as? SupportMessageTableViewCell
                    else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                }
                let incomingAttributedString = getIncomingAttributedString(chatMessageObject: message)
                return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel?.id ?? labelId, chatMessageObject: message)
            case .botFormMessage:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeadTableViewCell", for: indexPath) as? LeadTableViewCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.setData(indexPath: indexPath, arr: message.leadsDataArray)
                return cell
            case .quickReply:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BotOutgoingMessageTableViewCell", for: indexPath) as? BotOutgoingMessageTableViewCell
                    else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                }
                cell.delegate = self
                let incomingAttributedString = getIncomingAttributedString(chatMessageObject: message)
                return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel.id, chatMessageObject: message)
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
            case .actionableMessage, .hippoPay:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableMessageTableViewCell", for: indexPath) as? ActionableMessageTableViewCell else {
                    let cell = UITableViewCell()
                    cell.backgroundColor = .clear
                    return cell
                }
                cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message)
                cell.timeLabel.text = ""
                cell.rootViewController = self
                cell.registerNib()
                cell.setUpData(messageObject: message, isIncomingMessage: !isOutgoingMsg)
                cell.actionableMessageTableView.reloadData()
                cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message)
                cell.backgroundColor = UIColor.clear
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
                        cell.nameLabel.isHidden = true
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
                        cell.nameLabel.isHidden = false
                        return cell
                    }
                }
            case .consent:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableView", for: indexPath) as? ActionTableView, let actionMessage = message as? HippoActionMessage else {
                    return UITableView.defaultCell()
                }
                cell.delegate = self
                cell.setCellData(message: actionMessage)
                return cell
            default:
                return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
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
                case MessageType.normal, MessageType.botText:
                    var rowHeight = expectedHeight(OfMessageObject: message)
                    
                    rowHeight += returnRetryCancelButtonHeight(chatMessageObject: message)
                    rowHeight += getTopDistanceOfCell(atIndexPath: indexPath)
                    return rowHeight
                case MessageType.quickReply:
                    var rowHeight: CGFloat = 0
                    if message.values.count > 0 {
                        return rowHeight
                    }
                    if message.isQuickReplyEnabled {
                        rowHeight = rowHeight + 50
                    }
                    return rowHeight
                case MessageType.botFormMessage:
                    if message.content.questionsArray.count == 0 {
                        return 0.001
                    }
                    //TODO: Change it later on
                    //let count = chatMessageObject.content.values.count == chatMessageObject.content.questionsArray.count ? chatMessageObject.content.values.count : chatMessageObject.content.values.count + 1
                    return getHeightForLeadFormCell(message: message)
                case .attachment:
                    switch message.concreteFileType! {
                    case .video:
                        return 234
                    default:
                        return 80
                    }
                case MessageType.actionableMessage, MessageType.hippoPay:
                    return self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message) + heightOfDateLabel
                case MessageType.feedback:
                    
                    guard let muid = message.messageUniqueID, var rowHeight: CGFloat = heightForFeedBackCell["\(muid)"] else {
                        return 0.001
                    }
                    rowHeight += 5 //Height for bottom view
                    return rowHeight
                case .consent:
                    return message.cellDetail?.cellHeight ?? 0.01
                case MessageType.call:
                    return UITableView.automaticDimension
                default:
                    return 0.01
                    
                }
            }
        default: break
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            let messageGroup = messagesGroupedByDate[indexPath.section]
            let message = messageGroup[indexPath.row]
            
            switch message.type {
            case .call:
                return 85
            default:
                return self.tableView(tableView, heightForRowAt: indexPath)
            }
            
        default:
            return 0
        }
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
        #if swift(>=4.0)
      let widthIs: CGFloat = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: dateLabel.font], context: nil).size.width) + 10
        
        #else
        let widthIs: CGFloat = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: dateLabel.font], context: nil).size.width) + 10
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
    func getHeightForLeadFormCell(message: HippoMessage) -> CGFloat {
        var count = 0
        for lead in message.leadsDataArray {
            if lead.isShow {
                count += 1
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
        
        if height > 0 {
            return CGFloat(height)
        }
        return 0.001
    }
    
    func getHeightOfActionableMessageAt(indexPath: IndexPath, chatObject: HippoMessage)-> CGFloat {
        let chatMessageObject = chatObject
        var cellHeight = CGFloat(0)
        let bottomSpace = CGFloat(15)
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


extension ConversationsViewController {
    
    
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
   
//   func isSentByMe(senderId: Int) -> Bool {
//      return getSavedUserId == senderId
//   }
   
   
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
extension ConversationsViewController: UITextViewDelegate {
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
extension ConversationsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
   func doesImageExistsAt(filePath: String) -> Bool {
      return UIImage.init(contentsOfFile: filePath) != nil
   }
   
}

// MARK: - SelectImageViewControllerDelegate Delegates
extension ConversationsViewController: SelectImageViewControllerDelegate {
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
extension ConversationsViewController: ImageCellDelegate {
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



extension ConversationsViewController: HippoChannelDelegate {
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
        
        
    guard !isSentByMe(senderId: message.senderId) || message.type.isBotMessage  else {
        HippoConfig.shared.log.debug("Yahaa se nahi nikla", level: .custom)
        return
    }
    
    isTypingLabelHidden = message.typingStatus != .startTyping
    if isTypingLabelHidden {
        deleteTypingLabelSection()
    } else {
        insertTypingLabelSection()
        return
    }
    
    guard !message.isANotification() else {
        return
    }
    
    if !message.is_rating_given || message.type == .hippoPay {
        updateMessagesArrayLocallyForUIUpdation(message)
        newScrollToBottom(animated: true)
    }
    //TODO: - Scrolling Logic
    
    // NOTE: Keep "shouldScroll" method and action different, should scroll method should only detect whether to scroll or not
    sendNotificaionAfterReceivingMsg(senderUserId: message.senderId)
    
    if (message.type == MessageType.normal || message.type == .imageFile) &&  message.typingStatus == .messageRecieved {
        sendQuickReplyReposeIfRequired()
    }
    
    if message.type == MessageType.botFormMessage {
        self.replaceLastQuickReplyIncaseofBotForm()
    }
   }
    func getMessageForQuickReply(messages: [HippoMessage]) -> HippoMessage? {
        var quickReplyMessage: HippoMessage?
        for message in messages.reversed() {
            if message.type == MessageType.quickReply && message.isQuickReplyEnabled {
                quickReplyMessage = message
                break
            }
        }
        return quickReplyMessage
    }
    
    
    func replaceLastQuickReplyIncaseofBotForm() {
        if self.messagesGroupedByDate.count > 0 {
            let section = self.messagesGroupedByDate.count - 1
            let groupedArray = self.messagesGroupedByDate[section]
            var quickReplyMessage: HippoMessage?
            var row: Int = 0
            for (index, message) in groupedArray.enumerated().reversed() {
                if message.type == MessageType.quickReply {
                    quickReplyMessage = message
                    row = index
                    break
                } else {
                    continue
                }
            }
            guard let message = quickReplyMessage else {
                return
            }
            guard message.values.isEmpty else {
                return
            }
            self.messagesGroupedByDate[section][row].isQuickReplyEnabled = false
            self.tableViewChat.reloadRows(at: [IndexPath(row: row, section: section)], with: .fade)
        }
    }
   
   func insertTypingLabelSection() {
      guard !isTypingLabelHidden, !isTypingSectionPresent() else {
         return
      }
      
      let typingSectionIndex = IndexSet([tableViewChat.numberOfSections])
      tableViewChat.insertSections(typingSectionIndex, with: .none)
      
      if shouldScrollToBottomInCaseOfSomeoneElseTyping(), let lastMessageIndexPath = getLastMessageIndexPath() {
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
// MARK: Bot Form Cell Delegates
extension ConversationsViewController: LeadTableViewCellDelegate {
    func textfieldShouldBeginEditing(textfield: UITextField) {
        if self.messageTextView.isFirstResponder {
            self.messageTextView.resignFirstResponder()
        }
    }
    
    func textfieldShouldEndEditing(textfield: UITextField) {
        
        
    }
    
    func cellUpdated(for cell: LeadTableViewCell, data: [FormData]) {
        guard let indexPath = self.tableViewChat.indexPath(for: cell) else {
            return
        }
        if indexPath.section < self.messagesGroupedByDate.count {
            messagesGroupedByDate[indexPath.section][indexPath.row].leadsDataArray = data
            DispatchQueue.main.async {
                self.tableViewChat.beginUpdates()
                self.tableViewChat.endUpdates()
            }
            var count = 0
            for message in data {
                if message.isShow == true {
                    count += 1
                }
            }
            guard let cell = cell.tableView.cellForRow(at: IndexPath(row: 0, section: count - 1)) as? LeadDataTableViewCell else {
                return
            }
            cell.valueTextfield.becomeFirstResponder()
        }
    }
    
    func sendReply(forCell cell: LeadTableViewCell, data: [FormData]) {
        guard let indexPath = self.tableViewChat.indexPath(for: cell) else {
            return
        }
        if indexPath.section < self.messagesGroupedByDate.count {
            let message = messagesGroupedByDate[indexPath.section][indexPath.row]
            message.leadsDataArray = data
            self.channel.sendFormValues(message: message, completion: {
                self.cellUpdated(for: cell, data: data)
            })
        }
    }
    
    
}

// MARK: Bot Outgoing Cell Delegates
extension ConversationsViewController: BotOtgoingMessageCellDelegate {
    func didTapQuickReply(atIndex index: Int, forCell cell: BotOutgoingMessageTableViewCell) {
        self.messageTextView.resignFirstResponder()
        guard let indexPath = self.tableViewChat.indexPath(for: cell) else {
            return
        }
        switch indexPath.section {
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = messagesGroupedByDate[chatSection]
            let chat = messagesArray[indexPath.row]
            chat.selectedActionId = chat.content.actionId[index]
            self.sendQuickMessage(shouldSendButtonTitle: true, chat: chat, buttonIndex: index)
        default:
            return
        }
    }
    
    func sendQuickMessage(shouldSendButtonTitle: Bool, chat: HippoMessage, buttonIndex: Int) {
        if shouldSendButtonTitle {
            self.sendQuickReplyMessage(with: chat.content.buttonTitles[buttonIndex])
            fuguDelay(0.2, completion: {
                self.channel.sendFormValues(message: chat, completion: {
                    chat.isQuickReplyEnabled = false
                    self.tableViewChat.reloadData()
                })
            })
        } else {
            self.channel.sendFormValues(message: chat, completion: {
                chat.isQuickReplyEnabled = false
                self.tableViewChat.reloadData()
                
            })
        }
    }
    
    func sendQuickReplyMessage(with message: String) {
        let message = HippoMessage(message: message, type: .normal, uniqueID: String.generateUniqueId())
        channel?.unsentMessages.append(message)
        if channel != nil {
            addMessageToUIBeforeSending(message: message)
            self.sendMessage(message: message)
        }
    }
}
// MARK: Feedback Table Cell Delegates
extension ConversationsViewController: FeedbackTableViewCellDelegate {
    
    func cellTextViewEndEditing(data: FeedbackParams) {
        
    }
    func cellTextViewBeginEditing(textView: UITextView, data: FeedbackParams) {
        
    }
    
    func submitButtonClicked(with data: FeedbackParams) {
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        let mess = data.messageObject!
        mess.is_rating_given = true
        mess.total_rating = 5
        mess.rating_given = data.selectedIndex
        mess.comment = data.cellTextView.text.trimWhiteSpacesAndNewLine()
        mess.senderId = HippoUserDetail.fuguUserID ?? 0
        
        self.channel.send(message: mess) {
            print("Feedback faye send succesfully")
            self.channel.upateFeedbackStatus(newMessage: mess)
            DispatchQueue.main.async {
                self.tableViewChat.reloadData()
            }
            
        }
    }
    
    func updateHeightForCell(at data: FeedbackParams, textView: UITextView) {
        tableViewChat.beginUpdates()
        tableViewChat.cellForRow(at: data.indexPath!)?.updateConstraintsIfNeeded()
        tableViewChat.endUpdates()
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}


extension HippoConversationViewController {
    func getNormalMessageTableViewCell(tableView: UITableView, isOutgoingMessage: Bool, message: HippoMessage, indexPath: IndexPath) -> UITableViewCell {
        switch isOutgoingMessage {
        case false:
             let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMessageTableViewCell", for: indexPath) as! SupportMessageTableViewCell
            let incomingAttributedString = getIncomingAttributedString(chatMessageObject: message)
            return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel?.id ?? labelId, chatMessageObject: message)
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelfMessageTableViewCell", for: indexPath) as! SelfMessageTableViewCell
            cell.delegate = self
            return cell.configureIncomingMessageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath)
        }
    }
}
