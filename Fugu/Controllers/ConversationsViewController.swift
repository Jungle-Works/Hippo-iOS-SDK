//
//  ConversationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/9/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import Photos

protocol NewChatSentDelegate: class {
    func newChatStartedDelgegate(isChatUpdated: Bool)
    func updateConversationWith(conversationObj: FuguConversation)
}

extension UIView {
 
  @IBInspectable var borderStrokeWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderStrokeColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
  @IBInspectable var headerColor: UIColor {
    get {
      return self.backgroundColor!
    }
    set {
      self.backgroundColor = UIColor.white
    }
  }
  
  @IBInspectable var bottomShadow: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      
      
      layer.shadowColor = UIColor.gray.cgColor
      layer.shadowOpacity = 1
      layer.shadowOffset = CGSize(width: 0, height: 4) //CGSize.zero
      layer.shadowRadius = 6
      layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height+10)).cgPath
      layer.shouldRasterize = true
      layer.masksToBounds = true
      
      
      // layer.cornerRadius = newValue
      // layer.masksToBounds = newValue > 0
      // layer.addBorder(.Bottom, color: UIColor.blueColor(), thickness: newValue)
      // self.layer.addBorder(.bottom, color: UIColor.lightGray.withAlphaComponent(0.4), thickness: 1)
      // CommonFunctions.shareCommonMethods().createShadow(of: self)
      // UIBezierPath *mainScreenShadowPath = [UIBezierPath bezierPathWithRoundedRect:mainScreenRect cornerRadius:mainScreen.layer.cornerRadius];
      // let mainScreenShadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius)
      // layer.masksToBounds = false;
      // layer.shadowColor = UIColor.greenColor().CGColor;
      // layer.shadowOffset = CGSizeMake(0.5, 0.5)
      // layer.shadowOpacity = 1.0;
      // layer.shadowRadius = 0
      // layer.shadowPath = mainScreenShadowPath.CGPath;
    }
  }
}

public class ConversationsViewController: UIViewController {
   
   // MARK: -  IBOutlets
   @IBOutlet var backgroundView: UIView!
   @IBOutlet var navigationBackgroundView: UIView!
   @IBOutlet var navigationTitleLabel: UILabel!
   @IBOutlet var backButton: UIButton!
   @IBOutlet var chatScreenTableView: UITableView!
   @IBOutlet var sendMessageButton: UIButton!
   @IBOutlet var messageTextView: UITextView!
   @IBOutlet weak var errorContentView: UIView!
   @IBOutlet var errorLabel: UILabel!
   @IBOutlet var textViewBgView: UIView!
   @IBOutlet var placeHolderLabel: UILabel!
   @IBOutlet var addFileButtonAction: UIButton!
   @IBOutlet var seperatorView: UIView!
   @IBOutlet weak var loaderView: So_UIImageView!
    @IBOutlet weak var textViewAndButtonContainerView: UIView!
    @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
    
//    @IBOutlet weak var paymentViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var requestMoneyButton: UIButton!
//    @IBOutlet weak var paymentView: UIView!
//    @IBOutlet weak var sendMoneyButton: UIButton!
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
   @IBOutlet var errorLabelTopConstraint: NSLayoutConstraint!
   @IBOutlet weak var hieghtOfNavigationBar: NSLayoutConstraint!
   @IBOutlet weak var loadMoreActivityTopContraint: NSLayoutConstraint!
   @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - PROPERTIES
   let textViewFixedHeight = 50
   let textViewPlaceHolder = "Send a message..."
   
   var imagePicker = UIImagePickerController()
   var keyBoard: KeyBoard?
   let heightOfActionableMessageImage = 103.5
   weak var delegate: NewChatSentDelegate? = nil

   var typingMessageValue = TypingMessage.messageRecieved.rawValue
   var textInTextField = ""
   var timer = Timer()

   var isTypingLabelHidden = true
   var willPaginationWork = false
   var isObserverAdded = false
   var isGettingMessageViaPaginationInProgress = false
    var actionableMessageRightMargin: CGFloat = 60
    let heightOfDateLabel = CGFloat(40)
   var channel: FuguChannel! {
      didSet {
         channel?.delegate = self
      }
   }
   var labelId = -1
   var directChatDetail: FuguNewChatAttributes?
   var label = ""
   
   var messagesGroupedByDate: [[FuguMessage]] = []
    var payObject: FuguPay?
   var messageArrayCount: Int {
      return channel?.messages.count ?? 0
   }
   
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

   
   var getSavedUserId: Int {
      return HippoConfig.shared.userDetail?.fuguUserID ?? -1
   }
   
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        print("Conversation View Controller deintialized")
    }
   
   // MARK: - LIFECYCLE
   override public func viewDidLoad() {
      super.viewDidLoad()
//      paymentViewHeightConstraint.constant = 0.0
      setNavBarHeightAccordingtoSafeArea()
      configureChatScreen()
    
      removeNotificationsFromNotificationCenter()
      
      guard channel != nil else {
         startNewConversation(completion: { [weak self] (success) in
            if success {
               self?.populateTableViewWithChannelData()
               self?.fetchMessagesFrom1stPage()
            }
         })
         return
      }
      
      channel.delegate = self

      populateTableViewWithChannelData()
      fetchMessagesFrom1stPage()
    }
    
    
   func isDefaultChannel() -> Bool {
      return labelId > -1
   }
   
   func populateTableViewWithChannelData() {
      updateMessagesGroupedByDate(channel.messages)
      
      chatScreenTableView.isHidden = true
      chatScreenTableView.reloadData()
      newScrollToBottom(animated: false)
      
      fuguDelay(0.2) {
         self.newScrollToBottom(animated: false)
         self.chatScreenTableView.isHidden = false
      }
   }
   
   func fetchMessagesFrom1stPage() {

      if isDefaultChannel() {
         getMessagesWith(labelId: labelId, completion: nil)
      } else {
         getMessagesBasedOnChannel(fromMessage: 1, completion: nil)
      }
   }
   
   func removeNotificationsFromNotificationCenter() {
      UIApplication.shared.clearNotificationCenter()
   }
   
   override public func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      if channel != nil {
//         FuguChannel.activeChannel = channel
      }
      
      messageTextView.contentInset.top = 8

      checkNetworkConnection()

      registerKeyBoardNotification()
      registerNotificationWhenAppEntersForeground()
      registerNotificationToKnowWhenAppIsKilledOrMovedToBackground()
   }
   
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaderView.isHidden {
            startLoaderAnimation()
        }
        reloadVisibleCellsToStartActivityIndicator()
        
//        self.getPayData {
//
//        }
    }
   
   func registerKeyBoardNotification() {
      NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
   }
   
   func registerNotificationWhenAppEntersForeground() {
      NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: .UIApplicationDidBecomeActive, object: nil)
   }
   
   func registerNotificationToKnowWhenAppIsKilledOrMovedToBackground() {
      NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: .UIApplicationWillTerminate, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: .UIApplicationWillResignActive, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: .UIApplicationDidEnterBackground, object: nil)
    
   }
   
    @objc func keyboardWillShow(_ notification: Notification) {
      guard let keyBoardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, UIApplication.shared.applicationState == .active else {
         return
      } 
      
      adjustChatWhenKeyboardIsOpened(withHeight: keyBoardFrame.height)
   }
   
   
   @objc func keyboardWillHide(_ notification: Notification) {

      if self.typingMessageValue == TypingMessage.startTyping.rawValue, channel != nil {
         typingMessageValue = TypingMessage.stopTyping.rawValue
         sendTypingStatusMessage(isTyping: .stopTyping)
      }
      self.addRemoveShadowInTextView(toAdd: false)
   }
   
   func addRemoveShadowInTextView(toAdd: Bool) {
      guard isViewLoaded else {
         return
      }
      
      self.seperatorView.isHidden = true
    //  self.seperatorView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.9294117647, alpha: 1)
//
      if toAdd {
         self.seperatorView.isHidden = false
      }
   }
   
    @objc func appMovedToBackground() {
      checkNetworkConnection()
      sendTypingStatusMessage(isTyping: TypingMessage.stopTyping)
      messageTextView.resignFirstResponder()
   }
   
    @objc func willEnterForeground(_ notification: NSNotification!) {
      isTypingLabelHidden = true
      
      reloadVisibleCellsToStartActivityIndicator()
      removeNotificationsFromNotificationCenter()
      getMessagesBasedOnChannel(fromMessage: 1, completion: nil)
      checkNetworkConnection()
   }
   
   func reloadVisibleCellsToStartActivityIndicator() {
      let visibleCellsIndexPath = chatScreenTableView.visibleCells
      
      for cell in visibleCellsIndexPath {
         if let outImageCell = cell as? OutgoingImageCell, !outImageCell.customIndicator.isHidden {
            outImageCell.startIndicatorAnimation()
         }
         
         if let inImageCell = cell as? IncomingImageCell, !inImageCell.customIndicator.isHidden {
            inImageCell.startIndicatorAnimation()
         }
         
      }
   }
      
   override public func viewWillDisappear(_ animated: Bool) {
      
      removeKeyboardNotificationObserver()
      removeAppDidEnterForegroundObserver()
      removeNotificationObserverToKnowWhenAppIsKilledOrMovedToBackground()
   }
   
   func removeKeyboardNotificationObserver() {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
   }
   
   func removeAppDidEnterForegroundObserver() {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
   }
   
   func removeNotificationObserverToKnowWhenAppIsKilledOrMovedToBackground() {
      NotificationCenter.default.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
      NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
      NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
   }

   func tableViewSetUp() {
      automaticallyAdjustsScrollViewInsets = false
      chatScreenTableView.contentInset.bottom = 3

      chatScreenTableView.backgroundColor = HippoConfig.shared.theme.backgroundColor
    
      chatScreenTableView.register(UINib(nibName: "OutgoingImageCell", bundle: HippoFlowManager.bundle), forCellReuseIdentifier: "OutgoingImageCell")
      chatScreenTableView.register(UINib(nibName: "IncomingImageCell", bundle: HippoFlowManager.bundle), forCellReuseIdentifier: "IncomingImageCell")
      chatScreenTableView.register(UINib(nibName: "ActionableMessageTableViewCell", bundle: HippoFlowManager.bundle), forCellReuseIdentifier: "ActionableMessageTableViewCell")
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
         sendMessageButton.imageView?.contentMode = .scaleAspectFit
    }
         if let tintColor = HippoConfig.shared.theme.sendBtnIconTintColor {

      if HippoConfig.shared.theme.sendBtnIcon != nil {
         sendMessageButton.setImage(HippoConfig.shared.theme.sendBtnIcon, for: .normal)
         
         if let tintColor = HippoConfig.shared.theme.sendBtnIconTintColor {

            sendMessageButton.tintColor = tintColor
         }
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
         
         
         backButton.setTitleColor(HippoConfig.shared.theme.headerTextColor, for: .normal)

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
   
   // MARK:- UIButton Actions
    
    @IBAction func requestMoneyButtonAction(_ sender: Any) {
        if self.payObject?.sendRequestMoneyData != nil {
            var dict = self.payObject?.sendRequestMoneyData
            dict!["channel_id"] = channel.id
            dict!["action_type"] = "REQUEST_MONEY"
            let dictToBeSend: [String: Any] = ["button_action": dict ?? ""]
            HippoConfig.shared.delegate?.fuguMessageRecievedWith(response: dictToBeSend, viewController: self)
        }
        }
        
    
    @IBAction func sendMoneyButtonAction(_ sender: Any) {
        if self.payObject?.sendRequestMoneyData != nil {
            var dict = self.payObject?.sendRequestMoneyData
                dict!["channel_id"] = channel.id
            dict!["action_type"] = "SEND_MONEY"
            let dictToBeSend: [String: Any] = ["button_action": dict ?? ""]
            HippoConfig.shared.delegate?.fuguMessageRecievedWith(response: dictToBeSend, viewController: self)
        }
        
    }
    
   @IBAction func addImagesButtonAction(_ sender: UIButton) {
      imagePicker.delegate = self
      let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
      
      let cameraAction = UIAlertAction(title: "New Image via Camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
         self.view.endEditing(true)
         if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.performActionBasedOnCameraPermission()
         }
      })
      
      let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (alert: UIAlertAction!) -> Void in
         self.view.endEditing(true)
         self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
         self.performActionBasedOnGalleryPermission()
      })
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
      
      actionSheet.addAction(photoLibraryAction)
      actionSheet.addAction(cameraAction)
      actionSheet.addAction(cancelAction)
      
      self.present(actionSheet, animated: true, completion: nil)
   }
   
   func checkPhotoLibraryPermission() {
      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .authorized: break //handle authorized status
      case .denied, .restricted : break //handle denied status
      case .notDetermined: // ask for permissions
         PHPhotoLibrary.requestAuthorization() { status in
            switch status {
            case .authorized: break // as above
            case .denied, .restricted: break // as above
            case .notDetermined: break // won't happen but still
            }
         }
      }
   }
   
   @IBAction func sendMessageButtonAction(_ sender: UIButton) {
      if isMessageInvalid(messageText: messageTextView.text) {
         return
      }
      let trimmedMessage = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
      let message = FuguMessage(message: trimmedMessage, type: .normal, uniqueID: generateUniqueId())
      channel?.messages.append(message)

      
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
   
   func addMessageToUIBeforeSending(message: FuguMessage) {
      self.updateMessagesArrayLocallyForUIUpdation(message)
      self.messageTextView.text = ""
      self.newScrollToBottom(animated: false)
   }
   
   func sendMessage(message: FuguMessage) {
      channel?.send(message: message, completion: {
         //TODO: Reload Table View Cell
         self.chatScreenTableView.reloadData()
         
         if self.shouldScrollToBottomWhenStatusUpdatedOf(message: message) == true {
            self.newScrollToBottom(animated: true)
         }
      })
   }
   
   func shouldScrollToBottomWhenStatusUpdatedOf(message: FuguMessage) -> Bool {
      guard let lastMessageUniqueID = getLastMessageOfAnyStatus()?.messageUniqueID else {
         return false
      }
      
      let isMessageLastMessage = message.messageUniqueID == lastMessageUniqueID
      
      return message.wasMessageSendingFailed && isLastMessageVisible() && isMessageLastMessage
   }
   
   func isLastMessageVisible() -> Bool {
      guard let indexPath = getLastMessageIndexPath() else {
         return false
      }
      
      let visibleIndexPaths = chatScreenTableView.indexPathsForVisibleRows
      return visibleIndexPaths?.contains(indexPath) ?? false
   }
   
   func getLastMessageOfAnyStatus() -> FuguMessage? {
      guard let indexPath = getLastMessageIndexPath() else {
         return nil
      }
      
      return messagesGroupedByDate[indexPath.section][indexPath.row]
   }
   
   @IBAction func backButtonAction(_ sender: UIButton) {
    
      messageTextView.resignFirstResponder()
       HippoConfig.shared.delegate?.backFromFugu(viewController: self)
      channel?.send(message: FuguMessage.stopTyping, completion: {})
      
      if let lastMessage = getLastMessage(),
         
         let conversationInfo = FuguConversation(channelId: channel?.id ?? -1, unreadCount: 0, lastMessage: lastMessage) {
         delegate?.updateConversationWith(conversationObj: conversationInfo)
      }
      
      if self.navigationController == nil {
         dismiss(animated: true, completion: nil)
      } else {
         if self.navigationController!.viewControllers.count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
         } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
         }
      }
   }
    
    func getLastMessage() -> FuguMessage? {
        
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
   
   
    func checkNetworkConnection() {
        errorLabel.backgroundColor = UIColor.red
        if HippoConnection.isNetworkConnected {
            errorLabelTopConstraint.constant = -20
            updateErrorLabelView(isHiding: true)
        } else {
            errorLabelTopConstraint.constant = -20
            errorLabel.text = "No internet connection"
            updateErrorLabelView(isHiding: false)
        }
    }
   
   // MARK: - SERVER HIT
      func getMessagesBasedOnChannel(fromMessage pageStart: Int, completion: (() -> Void)?) {
      
      guard channel != nil else {
         completion?()
         return
      }
      
      if HippoConnection.isNetworkConnected == false {
         if self.messagesGroupedByDate.isEmpty {
            self.errorLabel.text = "No Internet Connection"
            self.updateErrorLabelView(isHiding: false)
         }
         completion?()
         return
      }
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         showHideActivityIndicator()
         completion?()
         return
      }
      
      let params: [String: Any] = ["app_secret_key" : HippoConfig.shared.appSecretKey,
                                   "channel_id" : channel.id,
                                   "en_user_id" : HippoConfig.shared.userDetail?.fuguEnUserID ?? "-1",
                                   "page_start": pageStart]
      
      if pageStart == 1, channel.messages.count == 0 {
         startLoaderAnimation()
         disableSendingNewMessages()
      }
      
      HTTPClient.shared.makeSingletonConnectionWith(method: .POST ,para: params, extendedUrl: FuguEndPoints.API_GET_MESSAGES.rawValue) { (responseObject, error, tag, statusCode) in
         
         
         self.enableSendingNewMessages()
         self.stopLoaderAnimation()
         self.showHideActivityIndicator(hide: true)
         self.isGettingMessageViaPaginationInProgress = false
         
         switch (statusCode ?? -1) {
         case STATUS_CODE_SUCCESS:
            guard let response = responseObject as? [String: Any], let data = response["data"] as? [String: Any] else {
               completion?()
               return
            }
            
            if let channelName = data["label"] as? String {
               self.label = channelName
               self.navigationTitleLabel.text = channelName
            } else if let fullName = data["full_name"] as? String,
               fullName.count > 0 {
               self.navigationTitleLabel.text = fullName
            }
            
            guard let rawMessages = data["messages"] as? [[String : Any]],
               rawMessages.count > 0  else {
                  completion?()
                  self.willPaginationWork = false
                  return
            }
            
            let messages = FuguMessage.getArrayFrom(json: rawMessages)
            
            if let pageSize = data["page_size"] as? Int {
               self.willPaginationWork = messages.count - pageSize == 0
            } else {
               self.willPaginationWork = false
            }
            
            if pageStart == 1 {
               self.filterUnsentMessagesFromChannelMessageArray()
            }
            
            self.updateMessagesInLocalArrays(messages: messages)
            
            let contentOffsetBeforeNewMessages = self.chatScreenTableView.contentOffset.y
            let contentHeightBeforeNewMessages = self.chatScreenTableView.contentSize.height
            self.chatScreenTableView.reloadData()
            
            if pageStart > 1 {
               self.keepTableViewWhereItWasBeforeReload(oldContentHeight: contentHeightBeforeNewMessages, oldYOffset: contentOffsetBeforeNewMessages)
            }
            
            if pageStart == 1 {
               self.newScrollToBottom(animated: true)
               self.sendReadAllNotification()
            }
            
         default:
            completion?()
         }
         
      }
   }
   
   func filterUnsentMessagesFromChannelMessageArray() {
      self.channel.messages = self.channel.messages.filter { (message) in
         let isFailedMessage = message.status == .none && self.isSentByMe(senderId: message.senderId)
         
         if isFailedMessage,
            message.type == MessageType.imageFile,
            let localPathOfImage = message.localImagePath,
            !localPathOfImage.isEmpty {
            return self.doesImageExistsAt(filePath: localPathOfImage)
         }
         return isFailedMessage
      }
   }
   
   func updateMessagesInLocalArrays(messages: [FuguMessage]) {
      self.messagesGroupedByDate = []
      self.updateMessagesGroupedByDate(messages) //1. first, update new messages
      
      if self.messageArrayCount > 0 {
         self.updateMessagesGroupedByDate(self.channel.messages)//2.second, update existing messages
      }
      
      self.channel.messages = messages + self.channel.messages
   }
   
   func keepTableViewWhereItWasBeforeReload(oldContentHeight: CGFloat, oldYOffset: CGFloat) {
      let newContentHeight = chatScreenTableView.contentSize.height
      let differenceInContentSizes = newContentHeight - oldContentHeight
      
      let oldYPosition = differenceInContentSizes + oldYOffset
      
      let newContentOffset = CGPoint(x: 0, y: oldYPosition)
      
      chatScreenTableView.setContentOffset(newContentOffset, animated: false)
      
   }
   
   func newScrollToBottom(animated: Bool) {
      if chatScreenTableView.numberOfSections == 0 { return }
      
      if let lastCell = getLastMessageIndexPath() {
         scroll(toIndexPath: lastCell, animated: animated)
      }
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
   
   func scroll(toIndexPath indexPath: IndexPath, animated: Bool) {
      chatScreenTableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
   }
   
    func updateMessagesGroupedByDate(_ chatMessagesArray: [FuguMessage]) {
        
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
   
   func addMessageToNewGroup(message: FuguMessage) {
      self.messagesGroupedByDate.append([message])
   }
   
    func getPayData(completion: (() -> Void)?) {
        
//            if HippoConnection.isNetworkConnected == false {
//                self.errorLabel.text = "No Internet Connection"
//                self.updateErrorLabelView(isHiding: false)
//                completion?()
//                return
//            }
//
//            if HippoConfig.shared.appSecretKey.isEmpty {
//                completion?()
//                return
//            }
//            //
//            let params: [String: Any] = [
//                "access_token" : HippoConfig.shared.theme.jugnooAccessToken,
//                "channel_id" : channel.id,
//            ]
//
//            if channel?.messages.count == 0 {
//                startLoaderAnimation()
//            }
      
        
//            HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, baseUrl: HippoConfig.shared.theme.checkPaymentStatusBaseURL, extendedUrl: FuguEndPoints.API_CHECK_SEND_REQUEST_MONEY.rawValue) { [weak self] (responseObject, error, tag, statusCode) in
//                self?.stopLoaderAnimation()
//                print(responseObject)
//                guard let weakSelf = self else {
//                    return
//                }
//
//                switch (statusCode ?? -1) {
//                case StatusCodeValue.Authorized_Min.rawValue..<StatusCodeValue.Authorized_Max.rawValue:
//                let response = responseObject as? [String: Any]
//
//                weakSelf.payObject = FuguPay(dict: response!)
//
//                if (weakSelf.payObject?.canRequestMoney)! {
//                    weakSelf.requestMoneyButton.isHidden = false
//                } else {
//                    weakSelf.requestMoneyButton.isHidden = true
//                }
//
//                if (weakSelf.payObject?.canSendMoney)! {
//                    weakSelf.sendMoneyButton.isHidden = false
//                } else {
//                    weakSelf.sendMoneyButton.isHidden = true
//                }
//
//                 if weakSelf.requestMoneyButton.isHidden == true && weakSelf.sendMoneyButton.isHidden == true {
////                     weakSelf.paymentViewHeightConstraint.constant = 0.0
//                 } else {
////                    weakSelf.paymentViewHeightConstraint.constant = 0.0
//                    }
//                self?.configeurSendMoneyView()
//                case 406: break
//
//                default:
//                    completion?()
//
//                }
//            }
      
    }
    
   func getMessagesWith(labelId: Int, completion: (() -> Void)?) {
      
      if HippoConnection.isNetworkConnected == false {
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
      let params: [String: Any] = [
         "app_secret_key" : HippoConfig.shared.appSecretKey,
         "label_id" : labelId,
         "en_user_id" : HippoConfig.shared.userDetail?.fuguEnUserID ?? "-1",
         "page_start": 1
      ]

      if channel?.messages.count == 0 {
         startLoaderAnimation()
      }

      HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.API_GET_MESSAGES_BASED_ON_LABEL.rawValue) { [weak self] (responseObject, error, tag, statusCode) in
         self?.stopLoaderAnimation()
         print(responseObject)
         guard let weakSelf = self else {
            return
         }

         switch (statusCode ?? -1) {
         case StatusCodeValue.Authorized_Min.rawValue..<StatusCodeValue.Authorized_Max.rawValue:
            let response = responseObject as? [String: Any]
            if let data = response?["data"] as? [String: Any] {


               if let channelName = data["label"] as? String {
                  weakSelf.label = channelName
                  weakSelf.navigationTitleLabel.text = channelName
               } else if let fullName = data["full_name"] as? String, fullName.count > 0 {
                  weakSelf.navigationTitleLabel.text = fullName
               }

               if let labelId = data["label_id"] as? Int {
                  weakSelf.labelId = labelId
               }

               if let channelId = data["channel_id"] as? Int,
                  channelId != -1, weakSelf.channel?.id != channelId {
                  weakSelf.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
                  weakSelf.channel.delegate = self
                  weakSelf.populateTableViewWithChannelData()
               }



               if let rawMessages = data["messages"] as? [[String: Any]], rawMessages.count > 0 {

                  let messages = FuguMessage.getArrayFrom(json: rawMessages)
                  
                  if let pageSize = data["page_size"] as? Int {
                     weakSelf.willPaginationWork = messages.count - pageSize == 0
                  } else {
                     weakSelf.willPaginationWork = false
                  }
                  
                  weakSelf.filterUnsentMessagesFromChannelMessageArray()

                  weakSelf.updateMessagesInLocalArrays(messages: messages)
                  weakSelf.chatScreenTableView.reloadData()
                  weakSelf.newScrollToBottom(animated: false)
                  weakSelf.sendReadAllNotification()
               }
            }
completion?()
         case 406:
            guard let response = responseObject as? [String: Any],
               let type = response["type"] as? Int, type == 1,
               HippoConfig.shared.userDetail?.userUniqueKey != nil else {
                  completion?()
                  return
            }

            weakSelf.channel?.delegate = nil
            weakSelf.channel = nil
            weakSelf.messagesGroupedByDate = []
            weakSelf.labelId = -1
            weakSelf.chatScreenTableView.reloadData()

            weakSelf.directChatDetail = FuguNewChatAttributes.defaultChat
            weakSelf.navigationTitleLabel.text = (userDetailData["business_name"] as? String) ?? "Support"
            completion?()
            weakSelf.startNewConversation(completion: { [weak self] (success) in
               if success {
                  self?.populateTableViewWithChannelData()
                  self?.fetchMessagesFrom1stPage()
               }
            })

         default:
            completion?()
            
         }
      }
   }
   
   func startNewConversation(completion: ((_ success: Bool) -> Void)?) {
      
      disableSendingNewMessages()
      if HippoConnection.isNetworkConnected == false {
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
         FuguChannel.get(withLabelId: labelId.description) { [weak self] (result) in
            self?.enableSendingNewMessages()
            self?.channelCreatedSuccessfullyWith(result: result)
            completion?(result.isSuccessful)
         }
      } else if directChatDetail != nil {
         FuguChannel.get(withFuguChatAttributes: directChatDetail!) { [weak self] (result) in
            self?.enableSendingNewMessages()
            self?.channelCreatedSuccessfullyWith(result: result)
            if let att = self?.directChatDetail, !att.preMessage.isEmpty, result.isChannelAvailableLocallay {
             self?.publishMessageWithAttributes(chatAttributes: att)
            }
            completion?(result.isSuccessful)
         }
      } else {
         enableSendingNewMessages()
         stopLoaderAnimation()
      }
   }
   
    func publishMessageWithAttributes(chatAttributes: FuguNewChatAttributes) {
        let trimmedMessage = chatAttributes.preMessage.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let message = FuguMessage(message: trimmedMessage, type: .normal, uniqueID: generateUniqueId())
        channel?.messages.append(message)
        addMessageToUIBeforeSending(message: message)
        self.sendMessage(message: message)
    }
   func enableSendingNewMessages() {
      addFileButtonAction.isUserInteractionEnabled = true
      messageTextView.isEditable = true
   }
   
   func disableSendingNewMessages() {
      addFileButtonAction.isUserInteractionEnabled = false
      messageTextView.isEditable = false
   }
      
   func channelCreatedSuccessfullyWith(result: FuguChannelCreationResult) {
      guard result.isSuccessful else {
         stopLoaderAnimation()
         return
      }
      channel = result.channel
      channel.delegate = self
      stopLoaderAnimation()
   }
   
   func updateChatInfoWith(chatObj: FuguConversation) {
      
      if let channelId = chatObj.channelId, channelId > 0 {
         self.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
      }

      self.labelId = chatObj.labelId ?? -1
      self.label = chatObj.label ?? ""
      
      
//      if let user_name = userDetailData["full_name"] as? String {
//         self.userName = user_name
//      }
//      
//      if channelId == -1 {
//         updateMessagesGroupedByDate([chatRawDict])
//      }
//
//      if let channelName = chatRawDict["label"] as? String {
//         self.channelName = channelName
//      }
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
      let storyboard = UIStoryboard(name: "FuguUnique", bundle: HippoFlowManager.bundle)
      let vc = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
      return vc
   }
   
   
}

// MARK: - HELPERS
extension ConversationsViewController {
   
    func returnRetryCancelButtonHeight(chatMessageObject: FuguMessage) -> CGFloat {
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
        
        self.backgroundView.backgroundColor = .white
        
        self.messageTextView.textAlignment = .left
        self.messageTextView.font = HippoConfig.shared.theme.typingTextFont
        self.messageTextView.textColor = HippoConfig.shared.theme.typingTextColor
        self.messageTextView.backgroundColor = .clear
        self.messageTextView.layer.cornerRadius = self.messageTextView.bounds.height/2
        
        errorLabel.text = ""
        if errorLabelTopConstraint != nil {
            errorLabelTopConstraint.constant = -20
        }
        
        sendMessageButton.isEnabled = false
       configeurSendMoneyView()
        
    }
   
    func configeurSendMoneyView() {
//        if self.sendMoneyButton != nil {
//            self.sendMoneyButton.setTitleColor(HippoConfig.shared.theme.sendMoneyButtonColor, for: .normal)
//            self.sendMoneyButton.layer.borderColor = HippoConfig.shared.theme.sendMoneyButtonColor.cgColor
//            self.sendMoneyButton.layer.borderWidth = 2.0
//            self.sendMoneyButton.titleLabel?.font = HippoConfig.shared.theme.sendMoneyButtonFont
//        }
//        if self.requestMoneyButton != nil {
//            self.requestMoneyButton.setTitleColor(HippoConfig.shared.theme.sendMoneyButtonColor, for: .normal)
//            self.requestMoneyButton.layer.borderColor = HippoConfig.shared.theme.sendMoneyButtonColor.cgColor
//            self.requestMoneyButton.layer.borderWidth = 2.0
//            self.requestMoneyButton.titleLabel?.font = HippoConfig.shared.theme.sendMoneyButtonFont
//        }
    }
    
   func addTapGestureInTableView() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ConversationsViewController.dismissKeyboard(sender:)))
      tapGesture.cancelsTouchesInView = false
      chatScreenTableView.addGestureRecognizer(tapGesture)
   }
   
    @objc func dismissKeyboard(sender: UIGestureRecognizer) {
      
      guard messageTextView.isFirstResponder else {
         return
      }
      
      //Delayed so that tableview gets correct touch event to run didselect
      let currentOffsetY = self.chatScreenTableView.contentOffset.y
      var newOffsetY = max(0, currentOffsetY - self.getKeyboardHeight())
      
      fuguDelay(0.1) {
         self.messageTextView.resignFirstResponder()
         
         if !self.shouldShiftUpWithThis(newOffsetY: newOffsetY) {
            newOffsetY = self.getMaxScrollableOffset()
         }
         
         let newOffset = CGPoint(x: 0, y: newOffsetY)
         self.chatScreenTableView.setContentOffset(newOffset, animated: true)
      }
   }
   
   func getKeyboardHeight() -> CGFloat {
      let screenHeight = backgroundView.bounds.height
      let tableViewEnd = chatScreenTableView.frame.maxY + UIView.safeAreaInsetOfKeyWindow.bottom
      
      let keyboardHeight = screenHeight - tableViewEnd - textViewBgView.frame.height
      
      return messageTextView.isFirstResponder ? keyboardHeight : 0
   }
   
   func getLastVisibleYCoordinateOfTableView() -> CGFloat {
      let tableViewHeight = chatScreenTableView.frame.height
      let tableViewYOffset = chatScreenTableView.contentOffset.y
      
      return tableViewYOffset + tableViewHeight
   }
   
   func setNavBarHeightAccordingtoSafeArea() {
      let topInset = UIView.safeAreaInsetOfKeyWindow.top == 0 ? 20 : UIView.safeAreaInsetOfKeyWindow.top
      hieghtOfNavigationBar.constant = 44 + topInset
   }
   
   func configureFooterView() {
       textViewBgView.backgroundColor = HippoConfig.shared.theme.backgroundColor
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
   
   func adjustChatWhenKeyboardIsOpened(withHeight keyboardHeight: CGFloat) {
      // TODO: - Refactor
      guard chatScreenTableView.contentSize.height + keyboardHeight > UIScreen.main.bounds.height - hieghtOfNavigationBar.constant else {
         return
      }
      
      let diff = ((chatScreenTableView.contentSize.height + keyboardHeight) - (UIScreen.main.bounds.height - hieghtOfNavigationBar.constant))
      
      let keyboardHeightNew = keyboardHeight - textViewBgView.frame.height - UIView.safeAreaInsetOfKeyWindow.bottom
      
      let mini = min(diff, keyboardHeightNew)
      
      var newOffSetY = chatScreenTableView.contentOffset.y + mini
      if !shouldShiftUpWithThis(newOffsetY: newOffSetY) {
         newOffSetY = getMaxScrollableOffset()
      }
      
      let newOffSet = CGPoint(x: 0, y: newOffSetY)
      chatScreenTableView.setContentOffset(newOffSet, animated: false)
   }
   
   func shouldShiftUpWithThis(newOffsetY: CGFloat) -> Bool {
      let tableHeight = chatScreenTableView.frame.height
      let tableContentHeight = chatScreenTableView.contentSize.height
      
      return newOffsetY + tableHeight < tableContentHeight + 10
   }
   
   func getMaxScrollableOffset() -> CGFloat {
      let tableHeight = chatScreenTableView.frame.height
      let tableContentHeight = chatScreenTableView.contentSize.height
      
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
         
         channel?.send(message: FuguMessage.stopTyping, completion: {})
         self.typingMessageValue = TypingMessage.startTyping.rawValue
      } else {
         textInTextField = messageTextView.text
      }
   }
   
    func updateErrorLabelView(isHiding: Bool) {
        if isHiding {
            if self.errorLabelTopConstraint.constant == 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
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
   
   func sendTypingStatusMessage(isTyping: TypingMessage) {
      if isTyping == .startTyping {
         channel?.send(message: FuguMessage.startTyping, completion: {})
      } else {
         channel?.send(message: FuguMessage.stopTyping, completion: {})
      }
   }

   func scrollTableViewToBottom(animated: Bool = false) {
      
      DispatchQueue.main.async {
         if self.messagesGroupedByDate.count > 0 {
            let givenMessagesArray = self.messagesGroupedByDate[self.messagesGroupedByDate.count - 1]
            if givenMessagesArray.count > 0 {
               let indexPath = IndexPath(row: givenMessagesArray.count - 1, section: self.messagesGroupedByDate.count - 1)
               self.chatScreenTableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
         }
      }
   }
   
   func isMessageInvalid(messageText: String) -> Bool {
      if messageText.replacingOccurrences(of: " ", with: "").count == 0 ||
         messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
         
         if HippoConnection.isNetworkConnected == false {
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
      getMessagesBasedOnChannel(fromMessage: 1, completion: nil)
   }
   
   func getIncomingAttributedString(chatMessageObject: FuguMessage) -> NSMutableAttributedString {
      let messageString = chatMessageObject.message
      let userNameString = chatMessageObject.senderFullName
      
      
      return attributedStringForLabel(userNameString, secondString: "\n" + messageString, thirdString: "", colorOfFirstString: HippoConfig.shared.theme.senderNameColor, colorOfSecondString: HippoConfig.shared.theme.incomingMsgColor, colorOfThirdString: UIColor.black.withAlphaComponent(0.5), fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString:  HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.systemFont(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
   }
   
   func expectedHeight(OfMessageObject chatMessageObject: FuguMessage) -> CGFloat {
    
      let availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
      let availableBoxSize = CGSize(width: availableWidthSpace,
                                    height: CGFloat.greatestFiniteMagnitude)
    
      let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId)
    
      var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7
    
      if isOutgoingMsg == true {
         var attributes: [NSAttributedStringKey : Any]?
         if let applicableFont = HippoConfig.shared.theme.inOutChatTextFont {
            attributes = [NSAttributedStringKey.font: applicableFont]
         }
         let messageString = chatMessageObject.message
         if messageString.isEmpty == false {
            cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
         }
         
      } else {
         let incomingAttributedString = getIncomingAttributedString(chatMessageObject: chatMessageObject)
         cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
      }
      
      return cellTotalHeight
   }
   
    
    func generateUniqueId() -> String {
        return UUID().uuidString
    }
   
   func updateMessagesArrayLocallyForUIUpdation(_ messageDict: FuguMessage) {
      if delegate != nil {
         delegate?.newChatStartedDelgegate(isChatUpdated: true)
      }
      
      //TODO: - Can add checks if message is not just a notification
      
      let countOfDateGroupedArrayBeforeUpdate = self.messagesGroupedByDate.count
      var previousLastSectionRows = 0
      
      if countOfDateGroupedArrayBeforeUpdate > 0 {
         self.chatScreenTableView.beginUpdates()
         previousLastSectionRows = self.messagesGroupedByDate.last!.count
      }
      
      self.updateMessagesGroupedByDate([messageDict])
      
      if self.messagesGroupedByDate.count == 0 {
         return
      }
      
      if countOfDateGroupedArrayBeforeUpdate == self.messagesGroupedByDate.count {
         
         let currentLastSectionRows = self.messagesGroupedByDate.last!.count
         
         if previousLastSectionRows != currentLastSectionRows {
            let lastIndexPath = IndexPath(row: currentLastSectionRows - 1, section: self.messagesGroupedByDate.count - 1)
            self.chatScreenTableView.insertRows(at: [lastIndexPath], with: .none)
         }
         
      } else {
         let newSectionsOfTableView = IndexSet([self.messagesGroupedByDate.count - 1])
         
         self.chatScreenTableView.insertSections(newSectionsOfTableView, with: .none)
      }
      
      self.chatScreenTableView.endUpdates()
   }

}

// MARK: - UIScrollViewDelegate
extension ConversationsViewController: UIScrollViewDelegate {
   public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      if self.chatScreenTableView.contentOffset.y < -5.0 && self.willPaginationWork, HippoConnection.isNetworkConnected {
         
         guard !isGettingMessageViaPaginationInProgress else {
            return
         }
         
         showHideActivityIndicator(hide: false)
         let unSentMessagesCount = getUnsentMessageCount()
         
         isGettingMessageViaPaginationInProgress = true
         self.getMessagesBasedOnChannel(fromMessage: self.messageArrayCount - unSentMessagesCount + 1, completion: { [weak self] in
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
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
   public func numberOfSections(in tableView: UITableView) -> Int {
      if !isTypingLabelHidden {
         return self.messagesGroupedByDate.count + 1
      }
      return self.messagesGroupedByDate.count
   }
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if section < self.messagesGroupedByDate.count {
         return messagesGroupedByDate[section].count
      } else {
         return isTypingLabelHidden ? 0 : 1
      }
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      switch indexPath.section {
      case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "TypingViewTableViewCell", for: indexPath) as! TypingViewTableViewCell
         
         cell.backgroundColor = .clear
         cell.selectionStyle = .none
         cell.bgView.isHidden = false
         cell.gifImageView.image = nil
         cell.bgView.backgroundColor = .clear
         cell.gifImageView.layer.cornerRadius = 15.0
         
         let imageBundle = HippoFlowManager.bundle ?? Bundle.main
         if let getImagePath = imageBundle.path(forResource: "typingImage", ofType: ".gif") {
            cell.gifImageView.image = UIImage.animatedImageWithData(try! Data(contentsOf: URL(fileURLWithPath: getImagePath)))!
         }
         
         return cell
      case let chatSection where chatSection < self.messagesGroupedByDate.count:
         var messagesArray = messagesGroupedByDate[chatSection]
         
         if messagesArray.count > indexPath.row {
            let chatMessageObject = messagesArray[indexPath.row]
            let messageType = chatMessageObject.type
            let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId)
            
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
                return cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: chatMessageObject, indexPath: indexPath)
               } else {
                  guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingImageCell", for: indexPath) as? IncomingImageCell
                     else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                  }
                cell.delegate = self
                return cell.configureIncomingCell(resetProperties: true, channelId: channel.id, chatMessageObject: chatMessageObject, indexPath: indexPath)
               }
            default:
               if isOutgoingMsg == false {
                
                if MessageType.actionableMessage.rawValue  == messageType.rawValue{
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableMessageTableViewCell", for: indexPath) as? ActionableMessageTableViewCell else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                    }
                    cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: chatMessageObject)
                    cell.timeLabel.text = ""
                    cell.rootViewController = self
                    cell.registerNib()
                    cell.setUpData(messageObject: chatMessageObject)
                    cell.actionableMessageTableView.reloadData()
                    cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: chatMessageObject) 
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
                
                  guard let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMessageTableViewCell", for: indexPath) as? SupportMessageTableViewCell
                     else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                  }
                  
//                  updateTopBottomSpace(cell: cell, indexPath: indexPath)
                
                  let incomingAttributedString = getIncomingAttributedString(chatMessageObject: chatMessageObject)
                  return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel.id, chatMessageObject: chatMessageObject)
               } else {
                  guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelfMessageTableViewCell", for: indexPath) as? SelfMessageTableViewCell else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                  }
                  
//                  updateTopBottomSpace(cell: cell, indexPath: indexPath)
                  cell.delegate = self
                return cell.configureIncomingMessageCell(resetProperties: true, chatMessageObject: chatMessageObject, indexPath: indexPath)
               }
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

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateTopBottomSpace(cell: cell, indexPath: indexPath)
    }
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = self.messagesGroupedByDate[chatSection]
            if messagesArray.count > indexPath.row {
                let chatMessageObject = messagesArray[indexPath.row]
                let messageType = chatMessageObject.type.rawValue
                switch messageType {
                case MessageType.imageFile.rawValue:
                    return 288
                case MessageType.normal.rawValue:
                    var rowHeight = expectedHeight(OfMessageObject: chatMessageObject)
                    
                    rowHeight += returnRetryCancelButtonHeight(chatMessageObject: chatMessageObject)
                    rowHeight += getTopDistanceOfCell(atIndexPath: indexPath)
                    return rowHeight
                case MessageType.actionableMessage.rawValue:
                    return self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: chatMessageObject) + heightOfDateLabel
                default:
                    return 210//UITableViewAutomaticDimension
                    
                }
            }
        default: break
        }
        return UITableViewAutomaticDimension
    }
    
    
   public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      if section < self.messagesGroupedByDate.count {

         if section == 0 && channel == nil {
            return 0
         }
         return 28
      }
      return 0
   }
   
   public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    let widthIs: CGFloat = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: dateLabel.font], context: nil).size.width) + 10
      let dateLabelHeight = CGFloat(24)
      dateLabel.frame = CGRect(x: (UIScreen.main.bounds.size.width / 2) - (widthIs/2), y: (labelBgView.frame.height - dateLabelHeight)/2, width: widthIs + 10, height: dateLabelHeight)
      labelBgView.addSubview(dateLabel)
      
      return labelBgView
   }

func getHeighOfButtonCollectionView(actionableMessage: HippoActionableMessage) -> CGFloat {
    
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
    
    func getHeightOfActionableMessageAt(indexPath: IndexPath, chatObject: FuguMessage)-> CGFloat {
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


extension ConversationsViewController {
   
   func shouldScrollToBottomInCaseOfSomeoneElseTyping() -> Bool {
      guard let visibleIndexPaths = chatScreenTableView.indexPathsForVisibleRows,
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
   
   func isSentByMe(senderId: Int) -> Bool {
      return getSavedUserId == senderId
   }
   
   
   func sendNotificaionAfterReceivingMsg(senderUserId: Int) {
    if senderUserId != getSavedUserId {
        sendReadAllNotification()
    }
   }
   
   func sendReadAllNotification() {
      channel?.send(message: FuguMessage.readAllNotification, completion: {})
   }
}

// MARK: - UITextViewDelegates
extension ConversationsViewController: UITextViewDelegate {
   public func textViewDidChangeSelection(_ textView: UITextView) {
      placeHolderLabel.isHidden = textView.hasText
   }
   
   public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      self.addRemoveShadowInTextView(toAdd: true)
      
      placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.8)
      textInTextField = textView.text
     //textViewBgView.backgroundColor = UIColor(red: 249.0/255.5, green: 252.0/255.0, blue: 252.0/255.0, alpha: 1.0)
      timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.watcherOnTextView), userInfo: nil, repeats: true)
      
      return true
   }
   
   public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
      //textViewBgView.backgroundColor = UIColor(red: 249.0/255.5, green: 252.0/255.0, blue: 252.0/255.0, alpha: 1.0)
      placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.5)
      
      timer.invalidate()
      return true
   }
   
   public func textViewDidBeginEditing(_ textView: UITextView) {
      typingMessageValue = TypingMessage.startTyping.rawValue
   }
   
   public func textViewDidChange(_ textView: UITextView) {

   }
   
   public func textViewDidEndEditing(_ textView: UITextView) {
   }
   
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = ((textView.text as NSString?)?.replacingCharacters(in: range,
                                                                         with: text))!
        
        let startHeight = textView.frame.size.height
        let calcHeight = textView.sizeThatFits(textView.frame.size).height
        
        if startHeight != calcHeight, calcHeight > 50, calcHeight < 150 {
            
            self.messageTextViewHeight.constant = calcHeight
        }
        
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
   public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
         else {
            picker.dismiss(animated: true, completion: nil)
            return
      }
      
      if picker.sourceType == .camera {
         sendConfirmedImage(image: pickedImage)
         picker.dismiss(animated: true, completion: nil)
      } else if let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectImageViewController") as? SelectImageViewController {
         destinationVC.pickedImage = pickedImage
         destinationVC.delegate = self
         picker.modalPresentationStyle = .overCurrentContext
         self.imagePicker.present(destinationVC, animated: true, completion: nil)
      }
   }
   
   func sendConfirmedImage(image confirmedImage: UIImage) {
      let imageFilePath = localFilePath
      if UIImageJPEGRepresentation(confirmedImage, 1)!.count > 3*1024 {
         try? UIImageJPEGRepresentation(confirmedImage, 0.03)?.write(to: Foundation.URL(fileURLWithPath: imageFilePath), options: [.atomic])
      } else if UIImageJPEGRepresentation(confirmedImage, 1.0)!.count > 2*1024 {
         try? UIImageJPEGRepresentation(confirmedImage, 0.05)?.write(to: Foundation.URL(fileURLWithPath: imageFilePath), options: [.atomic])
      } else {
        try? UIImageJPEGRepresentation(confirmedImage, 0.1)?.write(to: Foundation.URL(fileURLWithPath: imageFilePath), options: [.atomic])
      }
      print("File Path:+++++++++", imageFilePath)
      
      if imageFilePath.isEmpty == false {
         imageSelectedToSendWith(filePath: imageFilePath)
      }
   }
   
   public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
   }
   
   func performActionBasedOnGalleryPermission() {
      let status = PHPhotoLibrary.authorizationStatus()
      if status == .authorized {
         DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: nil)
         }
      } else if status == .denied {
         if HippoConnection.isNetworkConnected == false { return }
         
         self.updateErrorLabelView(isHiding: false)
         self.errorLabel.text = "Access to photo library is denied. Please enable from setings."
         self.updateErrorLabelView(isHiding: true)
      } else if status == .notDetermined {
         PHPhotoLibrary.requestAuthorization({ [weak self] (newStatus) in
            guard let weakSelf = self else {
               return
            }
            if (newStatus == .authorized) {
               DispatchQueue.main.async {
                  weakSelf.present(weakSelf.imagePicker, animated: true, completion: nil)
               }
            } else {
               weakSelf.performActionBasedOnGalleryPermission()
            }
         })
      }
   }
   
   func performActionBasedOnCameraPermission() {
    let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
      if status == .authorized {
         DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: nil)
         }
      } else if status == .denied {
         if HippoConnection.isNetworkConnected == false { return }
         
         self.updateErrorLabelView(isHiding: false)
         self.errorLabel.text = "Access to Camera is denied. Please enable from setings."
         self.updateErrorLabelView(isHiding: true)
      } else if status == .notDetermined {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] (newStatus) in
            
            guard let weakSelf = self else {
               return
            }
            if newStatus {
               DispatchQueue.main.async {
                  self?.present(weakSelf.imagePicker, animated: true, completion: nil)
               }
            } else {
               self?.performActionBasedOnCameraPermission()
            }
         })
      }
   }
   
   func imageSelectedToSendWith(filePath: String) {
   
      guard doesImageExistsAt(filePath: filePath) else {
         return
      }
      
      let messageUniqueId = generateUniqueId()
      let message = FuguMessage(message: "", type: .imageFile, uniqueID: messageUniqueId, localFilePath: filePath)
      message.localImagePath = filePath
      
      if channel != nil {
      channel.messages.append(message)
         message.isImageUploading = true
         updateMessagesArrayLocallyForUIUpdation(message)
         newScrollToBottom(animated: false)
         uploadImageFor(message: message) { (success) in
            if success {
               self.sendMessage(message: message)
            }
         }
      } else {
         startNewConversation(completion: { [weak self] (success) in
            guard success else {
               return
            }
            self?.channel?.messages.append(message)
            message.isImageUploading = true
            self?.updateMessagesArrayLocallyForUIUpdation(message)
            self?.newScrollToBottom(animated: false)
            self?.uploadImageFor(message: message) {  (success) in
               if success {
                  if self == nil {
                     message.wasMessageSendingFailed = true
                  } else {
                     self?.sendMessage(message: message)
                  }
               }
            }
         })
      }
   }
   
   func uploadImageFor(message: FuguMessage, completion: @escaping (_ success: Bool) -> Void) {
      message.isImageUploading = true
      message.wasMessageSendingFailed = false
      
      guard doesImageExistsAt(filePath: message.localImagePath!) else {
         message.isImageUploading = false
         message.wasMessageSendingFailed = true
         completion(false)
         return
      }
      
      FuguImageUploader.uploadImageWith(path: message.localImagePath!, completion: { [weak self] (result) in
         message.isImageUploading = false
         
         guard result.isSuccessful else {
            message.wasMessageSendingFailed = true
            self?.chatScreenTableView.reloadData()
            completion(false)
            return
         }
         
         message.wasMessageSendingFailed = false
         message.imageUrl = result.imageUrl
         message.thumbnailUrl = result.imageThumbnailUrl
         
         if let cachedImage = UIImage(contentsOfFile: message.localImagePath!) {
            message.localImagePath = nil
            ImageCache.default.store(cachedImage, forKey: message.thumbnailUrl ?? "")
            ImageCache.default.store(cachedImage, forKey: message.imageUrl ?? "")
         }
         
         completion(true)
      })
   }
   
   func doesImageExistsAt(filePath: String) -> Bool {
      return UIImage.init(contentsOfFile: filePath) != nil
   }
   
}

// MARK: - SelectImageViewControllerDelegate Delegates
extension ConversationsViewController: SelectImageViewControllerDelegate {
   func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage) {
      selectedImageVC.dismiss(animated: false) {
         self.imagePicker.dismiss(animated: false) {
            self.sendConfirmedImage(image: selectedImage)
         }
      }
   }
   
   func goToConversationViewController() {}
}

// MARK: - ImageCellDelegate Delegates
extension ConversationsViewController: ImageCellDelegate {
   func retryUploadFor(message: FuguMessage) {
      if message.imageUrl == nil {
         uploadImageFor(message: message) { [weak self] (success) in
            if success {
               self?.sendMessage(message: message)
            }
         }
      } else {
         sendMessage(message: message)
      }
   }
    
    func reloadCell(withIndexPath indexPath: IndexPath) {
        if self.chatScreenTableView.numberOfSections >= indexPath.section, chatScreenTableView.numberOfRows(inSection: indexPath.section) >= indexPath.row {
            chatScreenTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
   
   func showImageFor(message: FuguMessage) {
      if messageTextView.isFirstResponder {
         messageTextView.resignFirstResponder()
      }
      
      guard let originalUrl = message.imageUrl, originalUrl.count > 0 else {
            return
      }
      
      let showImageVC = ShowImageViewController.getFor(imageUrlString: originalUrl)
      self.modalPresentationStyle = .overCurrentContext
      self.present(showImageVC, animated: true, completion: nil)
   }

}

// MARK: - SelfMessageDelegate
extension ConversationsViewController: SelfMessageDelegate {
   
    func cancelMessage(message: FuguMessage) {
        for (index, tempMessage) in channel.messages.enumerated() {
            if tempMessage.messageUniqueID == message.messageUniqueID, message.messageUniqueID != nil {
                channel.messages.remove(at: index)
                messagesGroupedByDate = []
                updateMessagesGroupedByDate(channel.messages)
                break
            }
        }
        
        chatScreenTableView.reloadData()
    }
    
   func retryMessageUpload(message: FuguMessage) {
      message.status = .none
      message.wasMessageSendingFailed = false
      chatScreenTableView.reloadData()
      sendMessage(message: message)
   }
   
}

extension ConversationsViewController: FuguChannelDelegate {
   func newMessageReceived(message: FuguMessage) {
      guard !isSentByMe(senderId: message.senderId) else {
         return
      }
      
      chatScreenTableView.reloadData()

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
      
      let typingSectionIndex = IndexSet([chatScreenTableView.numberOfSections])
      chatScreenTableView.insertSections(typingSectionIndex, with: .none)
      
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
      
      let typingSectionIndex = IndexSet([chatScreenTableView.numberOfSections - 1])
      chatScreenTableView.deleteSections(typingSectionIndex, with: .none)
   }
   
   func isTypingSectionPresent() -> Bool {
      return self.messagesGroupedByDate.count < chatScreenTableView.numberOfSections
   }
}
