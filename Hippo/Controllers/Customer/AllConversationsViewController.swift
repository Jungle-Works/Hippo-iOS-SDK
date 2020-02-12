//
//  ShowAllConersationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import NotificationCenter

class AllConversationsViewController: UIViewController, NewChatSentDelegate {
   
   // MARK: - IBOutlets
   @IBOutlet var showConversationsTableView: UITableView!
   @IBOutlet var navigationBackgroundView: UIView!
//   @IBOutlet var navigationTitleLabel: UILabel!
   @IBOutlet var backButton: UIBarButtonItem!
   @IBOutlet weak var errorContentView: UIView!
   @IBOutlet var errorLabel: UILabel!
   @IBOutlet var errorLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var newConversationButton:UIButton!
   @IBOutlet var poweredByFuguLabel: UILabel!
   @IBOutlet weak var heightOfBottomLabel: NSLayoutConstraint!
//   @IBOutlet weak var heightofNavigationBar: NSLayoutConstraint!
   
   // MARK: - PROPERTIES
   let refreshControl = UIRefreshControl()
   
   var tableViewDefaultText: String = "Loading ..."
   let urlForFuguChat = "https://fuguchat.com/"
   
   var arrayOfConversation = [FuguConversation]()
   
   // MARK: - LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
    
//      let topInset = UIView.safeAreaInsetOfKeyWindow.top == 0 ? 20 : UIView.safeAreaInsetOfKeyWindow.top
//      heightofNavigationBar.constant = 44 + topInset
    
      self.automaticallyAdjustsScrollViewInsets = false
      navigationSetUp()
      uiSetup()
      addObservers()
      _ = handleIntialCustomerForm()
      
      self.arrayOfConversation = fetchAllConversationCache()
   }
   
    override func viewWillAppear(_ animated: Bool) {
        checkNetworkConnection()
        if HippoUserDetail.fuguUserID == nil {
            putUserDetails()
        } else {
            getAllConversations()
        }
        self.navigationController?.setTheme()
        self.navigationController?.isNavigationBarHidden = false
    }
   
    func handleIntialCustomerForm() -> Bool {
        guard HippoUserDetail.fuguUserID != nil else {
            return false
        }
        guard HippoChecker().shouldCollectDataFromUser() else {
            return false
        }
        let vc = HippoDataCollectorController.get(forms: HippoProperty.current.forms)
        vc.delegate = self
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: false)
        return true
    }
   func putUserDetails() {
      HippoUserDetail.getUserDetailsAndConversation(completion: { [weak self] (success, error) in
         guard success else {
            let errorMessage = error?.localizedDescription ?? "Something went wrong."
            
            self?.tableViewDefaultText = errorMessage + "\n Please tap to retry."
            self?.arrayOfConversation = []
            self?.showConversationsTableView?.reloadData()
            return
         }
         self?.arrayOfConversation = self?.fetchAllConversationCache() ?? []
         self?.showConversationsTableView.reloadData()
        
        if let result = self?.handleIntialCustomerForm(), result {
            return
        } else if self?.arrayOfConversation.count == 0 {
            self?.openDefaultChannel()
            return
         }
      })
        
   }
   
   func uiSetup() {
      
      updateErrorLabelView(isHiding: true)
      
      refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
      
      showConversationsTableView.backgroundView = refreshControl
    
      let theme = HippoConfig.shared.theme
      newConversationButton.setTitleColor(theme.themeTextcolor, for: .normal)
      newConversationButton.backgroundColor = theme.themeColor
      newConversationButton.layer.cornerRadius = newConversationButton.bounds.height / 2
      newConversationButton.layer.borderWidth = CGFloat(HippoConfig.shared.newConversationButtonBorderWidth)
      newConversationButton.layer.borderColor = theme.themeTextcolor.cgColor
      newConversationButton.layer.masksToBounds = true
      newConversationButton.titleLabel?.font = theme.newConversationButtonFont
      newConversationButton.setTitle(theme.newConversationText, for: .normal)
      newConversationButton.isHidden = HippoConfig.shared.isNewConversationButtonHidden
    
      poweredByFuguLabel.attributedText = attributedStringForLabelForTwoStrings("Runs on ", secondString: "Hippo", colorOfFirstString: HippoConfig.shared.powererdByColor, colorOfSecondString: HippoConfig.shared.FuguColor, fontOfFirstString: HippoConfig.shared.poweredByFont, fontOfSecondString: HippoConfig.shared.FuguStringFont, textAlighnment: .center, dateAlignment: .center)
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFuguChatWebLink(_:)))
      poweredByFuguLabel.addGestureRecognizer(tap)
      updateBottomLabel()
   }
   
    func navigationSetUp() {
        
        navigationBackgroundView.layer.shadowColor = UIColor.black.cgColor
        navigationBackgroundView.layer.shadowOpacity = 0.25
        navigationBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        navigationBackgroundView.layer.shadowRadius = 4
        
        navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        
        //      navigationTitleLabel.textColor =  HippoConfig.shared.theme.headerTextColor
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        
        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            backButton.image = HippoConfig.shared.theme.leftBarButtonImage
            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        }
        
        title = HippoConfig.shared.theme.headerText
        //      navigationTitleLabel.text = HippoConfig.shared.theme.headerText
        //
        //      if HippoConfig.shared.theme.headerTextFont  != nil {
        //         navigationTitleLabel.font = HippoConfig.shared.theme.headerTextFont
        //      }
        //
        //
        //      if HippoConfig.shared.navigationTitleTextAlignMent != nil {
        //         navigationTitleLabel.textAlignment = HippoConfig.shared.navigationTitleTextAlignMent!
        //      }
        
    }
   
   func addObservers() {
      let notificationCenter = NotificationCenter.default
      notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: HippoVariable.willResignActiveNotification, object: nil)
      notificationCenter.addObserver(self, selector: #selector(appMovedToForground), name: HippoVariable.willEnterForegroundNotification, object: nil)
   }
   
   @objc func appMovedToBackground() {
      checkNetworkConnection()
      saveConversationsInCache()
   }
   
   @objc func appMovedToForground() {
      checkNetworkConnection()
   }
   
   func checkNetworkConnection() {
      errorLabel.backgroundColor = UIColor.red
      if FuguNetworkHandler.shared.isNetworkConnected {
         errorLabelTopConstraint.constant = -20
         updateErrorLabelView(isHiding: true)
      } else {
         errorLabelTopConstraint.constant = -20
         errorLabel.text = HippoConfig.shared.strings.noNetworkConnection
         updateErrorLabelView(isHiding: false)
      }
   }
   // MARK: - UIView Actions
   
   @objc func openFuguChatWebLink(_ sender: UITapGestureRecognizer) {
      guard let fuguURL = URL(string: urlForFuguChat),
         UIApplication.shared.canOpenURL(fuguURL) else {
            return
      }
      
      UIApplication.shared.openURL(fuguURL)
   }
   
   // MARK: - UIButton Actions
   
    @IBAction func backButtonClicked(_ sender: Any) {
        saveConversationsInCache()
        HippoConfig.shared.notifiyDeinit()
        _ = self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        saveConversationsInCache()
        HippoConfig.shared.notifiyDeinit()
        _ = self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func newConversationButtonClicked(_ sender: Any) {
        let fuguNewChatAttributes = FuguNewChatAttributes(transactionId: "", userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: nil, channelName: nil, preMessage: "", groupingTag: nil)
        
        //print("bodID******* \(HippoProperty.current.newconversationBotGroupId ?? "")")
        //fuguNewChatAttributes.botGroupId = HippoProperty.current.newconversationBotGroupId
        
        let conversation = ConversationsViewController.getWith(chatAttributes: fuguNewChatAttributes)
        conversation.createConversationOnStart = true
        self.navigationController?.pushViewController(conversation, animated: true)
    }
    
   @objc func headerEmptyAction(_ sender: UITapGestureRecognizer) {
      
      guard arrayOfConversation.count == 0, tableViewDefaultText != "Loading..." else {
         return
      }
      
         tableViewDefaultText = "Loading..."
      self.showConversationsTableView.reloadData()
      if HippoUserDetail.fuguUserID == nil {
         putUserDetails()
      } else {
         getAllConversations()
      }
   }
   
   // MARK: - UIRefreshControl
   @objc func refresh(_ refreshControl: UIRefreshControl) {
      getAllConversations()
   }
   
   // MARK: - SERVER HIT
   func getAllConversations() {
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         arrayOfConversation = []
         showConversationsTableView.reloadData()
         showErrorMessageInTopErrorLabel(withMessage: "Invalid app secret key")
         return
      }
      
      FuguConversation.getAllConversationFromServer { [weak self] (result) in
        self?.refreshControl.endRefreshing()
         resetPushCount()
         pushTotalUnreadCount()
         
         guard result.isSuccessful else {
            let errorMessage = result.error?.localizedDescription ?? "Something went wrong."
            
            self?.showErrorMessageInTopErrorLabel(withMessage: errorMessage)
            return
         }
         
         if result.conversations!.count == 0 {
            self?.openDefaultChannel()
            return
         }
         
         self?.arrayOfConversation = result.conversations!
         self?.showConversationsTableView.reloadData()
      }
   }
   
   func openDefaultChannel() {
      HippoConfig.shared.notifyDidLoad()
      let conVC = ConversationsViewController.getWith(chatAttributes: FuguNewChatAttributes.defaultChat)
      self.navigationController?.setViewControllers([conVC], animated: false)
   }
   
   func showErrorMessageInTopErrorLabel(withMessage message: String) {
      if FuguNetworkHandler.shared.isNetworkConnected == false {
         return
      }
      self.updateErrorLabelView(isHiding: false)
      self.errorLabel.text = message
      self.updateErrorLabelView(isHiding: true)
   }
   
   // MARK: - HELPER
   func updateErrorLabelView(isHiding: Bool) {
      if errorLabelTopConstraint == nil || errorLabel == nil {
         return
      }
      
      if isHiding {
         if self.errorLabelTopConstraint.constant == 0 {
            fuguDelay(3, completion: {
               self.errorLabelTopConstraint.constant = -20
               self.errorLabel.text = ""
               
//               UIView.animate(withDuration: 0.5, animations: {
                  self.view.layoutIfNeeded()
//               }, completion: {_ in
                  self.errorLabel.backgroundColor = UIColor.red
//               })
            })
         }
         return
      }
      
      if errorLabelTopConstraint.constant != 0 {
         errorLabelTopConstraint.constant = 0
//         UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
//         }
      }
   }
   
   func updateBottomLabel() {
      if let isWhiteLabel = userDetailData["is_whitelabel"] as? Bool, isWhiteLabel == false {
        heightOfBottomLabel.constant = 20
      } else {
         heightOfBottomLabel.constant = 0
      }
      view.layoutIfNeeded()
   }
   
    
   func saveConversationsInCache() {
      let conversationJson = FuguConversation.getJsonFrom(conversations: arrayOfConversation)
      FuguDefaults.set(value: conversationJson, forKey: DefaultName.conversationData.rawValue)
   }
   
   func fetchAllConversationCache() -> [FuguConversation] {
      guard let convCache = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] else {
         return []
      }
      
      let arrayOfConversation = FuguConversation.getConversationArrayFrom(json: convCache)
      return arrayOfConversation
   }
   
   // MARK: - NewChatSentDelegate
   func newChatStartedDelgegate(isChatUpdated: Bool) {
   }
   
   func updateConversationWith(conversationObj: FuguConversation) {
      
      var chatObj: FuguConversation?
      
      for rawChat in arrayOfConversation {
         guard let channelId = rawChat.channelId,
            channelId > 0 else {
               continue
         }
         if conversationObj.channelId == channelId {
            chatObj = rawChat
            break
         }
      }
      
      chatObj?.unreadCount = conversationObj.unreadCount
      chatObj?.lastMessage = conversationObj.lastMessage
      
      guard isViewLoaded else {
         return
      }
      showConversationsTableView.reloadData()
   }
   
   
   // MARK: - Navigation
   
   func moveToChatViewController(chatObj: FuguConversation) {
      HippoConfig.shared.notifyDidLoad()
      let conversationVC = ConversationsViewController.getWith(conversationObj: chatObj)
      conversationVC.delegate = self
      self.navigationController?.pushViewController(conversationVC, animated: true)
   }
   
   //MARK: - HANDLE PUSH NOTIFICATION
    func updateChannelsWithrespectToPush(pushInfo: [String: Any]) {
        
        
        
        if let notificationType = pushInfo["notification_type"] as? Int, notificationType == 5 {
            getAllConversations()
            return
        }
        
        let pushChannelId = pushInfo["channel_id"] as? Int ?? -1
        let pushLabelId = pushInfo["label_id"] as? Int ?? -1
        
        var channelIdIndex: Int?
        var labelIdIndex: Int?
        
        if pushChannelId > 0 {
            channelIdIndex = arrayOfConversation.firstIndex { (f) -> Bool in
                return f.channelId ?? -1 == pushChannelId
            }
        }
        if pushLabelId > 0 {
            labelIdIndex = arrayOfConversation.firstIndex { (f) -> Bool in
                return f.labelId ?? -1 == pushLabelId
            }
        }
        guard channelIdIndex != nil || labelIdIndex != nil else {
            getAllConversations()
            return
        }
        let rawIndex: Int? = channelIdIndex ?? labelIdIndex
        
        guard let index = rawIndex, arrayOfConversation.count > index else {
            getAllConversations()
            return
        }

        let convObj = arrayOfConversation[index]
        let lastMessage = HippoMessage(convoDict: pushInfo)
        
        
        
        if let lastMuid = convObj.lastMessage?.messageUniqueID, let newMuid = lastMessage?.messageUniqueID, lastMuid == newMuid {
            return
        }
        
        convObj.lastMessage = lastMessage
        
        if let unreadCount = pushInfo["unread_count"] as? Int, unreadCount > 0 {
            convObj.unreadCount = unreadCount
        } else if let unreadCount = convObj.unreadCount, UIApplication.shared.applicationState != .inactive {
            convObj.unreadCount = unreadCount + 1
        }
        arrayOfConversation[index] = convObj
        
        if (convObj.unreadCount ?? 0) > 0 {
            convObj.channelStatus = .open
        }
        saveConversationsInCache()
        resetPushCount()
        pushTotalUnreadCount()
        
        if showConversationsTableView != nil {
            showConversationsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
   
}

extension AllConversationsViewController: UITableViewDelegate, UITableViewDataSource {
   
   // MARK: - UITableViewDataSource
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return arrayOfConversation.count
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationView", for: indexPath) as? ConversationView else {
         return UITableViewCell()
      }
      
      let convObj = arrayOfConversation[indexPath.row]
      cell.configureConversationCell(resetProperties: true, conersationObj: convObj)
      return cell
   }
   
   // MARK: - UITableViewDelegate
   public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
      cell.selectionView.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1)
   }
   
   public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
      cell.selectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
   }
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
   
   public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return 30 }
   
   public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      
      tableView.isScrollEnabled = true
      guard arrayOfConversation.count > 0 else {
         tableView.isScrollEnabled = false
         return tableView.frame.height
      }
      
      return 0
   }
   
   public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      let footerView = UIView()
      footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: tableView.frame.size.height)
      
      let footerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: (tableView.frame.height / 2) - 90, width: tableView.frame.width, height: 90))
      footerLabel.textAlignment = NSTextAlignment.center
      footerLabel.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
      footerLabel.numberOfLines = 0
      footerLabel.font = UIFont.systemFont(ofSize: 16.0)
      
      footerLabel.text = tableViewDefaultText
      
      footerView.addSubview(footerLabel)
      
      let emptyAction = UITapGestureRecognizer(target: self, action: #selector(headerEmptyAction(_:)))
      footerView.addGestureRecognizer(emptyAction)
      
      return footerView
   }
   
   public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      
      tableView.isUserInteractionEnabled = false
      fuguDelay(1) {
         tableView.isUserInteractionEnabled = true
      }
      
      let conversationObj = arrayOfConversation[indexPath.row]
      moveToChatViewController(chatObj: conversationObj)
      if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
         resetPushCount()
         conversationObj.unreadCount = 0
         pushTotalUnreadCount()
         showConversationsTableView.reloadRows(at: [indexPath], with: .none)
      }
   }
   
}

extension AllConversationsViewController: HippoDataCollectorControllerDelegate {
    func userUpdated() {
        fuguDelay(0.4) {
            self.putUserDetails()
        }
    }
}
