//
//  ShowAllConersationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import NotificationCenter
import XLPagerTabStrip

class AllConversationsViewController: UIViewController, NewChatSentDelegate {
    
    // MARK: - IBOutlets
     @IBOutlet var containerView: UIView!
    @IBOutlet var showConversationsTableView: UITableView!
    @IBOutlet var navigationBackgroundView: UIView!
    @IBOutlet var navigationTitleLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var errorLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var poweredByFuguLabel: UILabel!
    @IBOutlet weak var heightOfBottomLabel: NSLayoutConstraint!
    @IBOutlet weak var heightofNavigationBar: NSLayoutConstraint!
  @IBOutlet weak var newChatBtn: UIButton!
  
    
    // MARK: - PROPERTIES
    let refreshControl = UIRefreshControl()
    var tableViewDefaultText: String = "Loading ..."
    let urlForFuguChat = "https://fuguchat.com/"
    
    var arrayOfConversation = [FuguConversation]()
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
      self.newChatBtn.isHidden = !HippoConfig.shared.showNewChatBtn
        self.containerView.isHidden = true
        addObservers()
        let topInset = UIView.safeAreaInsetOfKeyWindow.top == 0 ? 20 : UIView.safeAreaInsetOfKeyWindow.top
        heightofNavigationBar.constant = 44 + topInset
        
        HippoConfig.shared.unreadCount = { (count) in
            print("total count of unread chat==>\(count)")
        }
        self.automaticallyAdjustsScrollViewInsets = false
        navigationSetUp()
        uiSetup()
        addObservers()
        self.arrayOfConversation = fetchAllConversationCache()
        self.setupMultipleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkNetworkConnection()
        if HippoConfig.shared.userDetail?.fuguUserID == nil {
            putUserDetails()
        } else {
            getAllConversations()
        }
        
    }
    
    func putUserDetails() {
        HippoUserDetail.getUserDetailsAndConversation(completion: { [weak self] (success, error) in
            guard success else {
                let errorMessage = error?.localizedDescription ?? "Something went wrong."
                
                self?.tableViewDefaultText = errorMessage + "\n Please tap to retry."
                self?.arrayOfConversation = []
                self?.showConversationsTableView?.reloadData()
                self?.setDataOfCollection(true)
                return
            }
            
            self?.arrayOfConversation = self?.fetchAllConversationCache() ?? []
            self?.showConversationsTableView.reloadData()
            self?.setDataOfCollection(true)
            if self?.arrayOfConversation.count == 0 {
                self?.openDefaultChannel()
                return
            }
        })
    }
    
    func uiSetup() {
        
        updateErrorLabelView(isHiding: true)
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        showConversationsTableView.backgroundView = refreshControl
        
        poweredByFuguLabel.attributedText = attributedStringForLabelForTwoStrings("Powered by ", secondString: "Fugu", colorOfFirstString: HippoConfig.shared.powererdByColor, colorOfSecondString: HippoConfig.shared.HippoColor, fontOfFirstString: HippoConfig.shared.poweredByFont, fontOfSecondString: HippoConfig.shared.HippoStringFont, textAlighnment: .center, dateAlignment: .center)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFuguChatWebLink(_:)))
        poweredByFuguLabel.addGestureRecognizer(tap)
        updateBottomLabel()
    }
    
    
    
    func navigationSetUp() {
        
//        navigationBackgroundView.layer.shadowColor = UIColor.black.cgColor
//        navigationBackgroundView.layer.shadowOpacity = 0.25
//        navigationBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
//        navigationBackgroundView.layer.shadowRadius = 4
        
        
        navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        
        navigationTitleLabel.textColor =  HippoConfig.shared.theme.headerTextColor
        backButton.setTitleColor(HippoConfig.shared.theme.headerTextColor, for: .normal)
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
            
            if HippoConfig.shared.theme.leftBarButtonFont != nil {
                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            }
            
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
            }
        }
        
        navigationTitleLabel.text = HippoConfig.shared.theme.headerText
        
        if HippoConfig.shared.theme.headerTextFont  != nil {
            navigationTitleLabel.font = HippoConfig.shared.theme.headerTextFont
        }
        
        
        if HippoConfig.shared.navigationTitleTextAlignMent != nil {
            navigationTitleLabel.textAlignment = HippoConfig.shared.navigationTitleTextAlignMent!
        }
        
    }
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
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
        if HippoConnection.isNetworkConnected {
            errorLabelTopConstraint.constant = -20
            updateErrorLabelView(isHiding: true)
        } else {
            errorLabelTopConstraint.constant = -20
            errorLabel.text = "No internet connection"
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
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        saveConversationsInCache()
        _ = self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func headerEmptyAction(_ sender: UITapGestureRecognizer) {
        
        guard arrayOfConversation.count == 0, tableViewDefaultText != "Loading..." else {
            return
        }
        
        tableViewDefaultText = "Loading..."
        self.showConversationsTableView.reloadData()
        self.setDataOfCollection(true)
        if HippoConfig.shared.userDetail?.fuguUserID == nil {
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
            self.setDataOfCollection(true)
            showErrorMessageInTopErrorLabel(withMessage: "Invalid app secret key")
            return
        }
        
        FuguConversation.getAllConversationFromServer { [weak self] (result) in
            
            
            _ = checkUnreadChatCount()
            
            guard result.isSuccessful else {
                let errorMessage = result.error?.localizedDescription ?? "Something went wrong."
                
                self?.showErrorMessageInTopErrorLabel(withMessage: errorMessage)
                return
            }
            
           /* if result.conversations!.count == 0 {
                self?.openDefaultChannel()
                return
            }*/
            
            self?.arrayOfConversation = result.conversations!
            self?.showConversationsTableView.reloadData()
            self?.showConversationsTableView.setContentOffset(.zero, animated: true)
            self?.setDataOfCollection(false)
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                
            }
            
            
        }
    }
    
    func openDefaultChannel() {
        let conVC = ConversationsViewController.getWith(chatAttributes: FuguNewChatAttributes.defaultChat)
        self.navigationController?.setViewControllers([conVC], animated: false)
    }
    
    func showErrorMessageInTopErrorLabel(withMessage message: String) {
        if HippoConnection.isNetworkConnected == false {
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
        poweredByFuguLabel.isHidden = true
        if let isWhiteLabel = userDetailData["is_whitelabel"] as? Bool,
            isWhiteLabel == true { heightOfBottomLabel.constant = 0 }
        else {
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
        self.setDataOfCollection(false)
    }
    
    
    // MARK: - Navigation
    
    func moveToChatViewController(chatObj: FuguConversation) {
        let conversationVC = ConversationsViewController.getWith(conversationObj: chatObj)
        conversationVC.delegate = self
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    //MARK: - HANDLE PUSH NOTIFICATION
    func updateChannelsWithrespectToPush(pushInfo: [String: Any]) {
        
        if let notificationType = pushInfo["notification_type"] as? Int,
            notificationType == 5 {
            getAllConversations()
            return
        }
        
        guard let pushChannelId = pushInfo["channel_id"] as? Int else {
            return
        }
        
        for (index, convObj) in arrayOfConversation.enumerated() {
            
            guard let channelId = convObj.channelId,
                channelId == pushChannelId  else {
                    continue
            }
            
            let lastMessage = FuguMessage(convoDict: pushInfo)
            convObj.lastMessage = lastMessage
            
            if let unreadCount = pushInfo["unread_count"] as? Int, unreadCount > 0 {
                convObj.unreadCount = unreadCount
            } else if let unreadCount = convObj.unreadCount,
                UIApplication.shared.applicationState != .inactive {
                convObj.unreadCount = unreadCount + 1
            }
            
            if (convObj.unreadCount ?? 0) > 0 {
                convObj.channelStatus = .open
            }
            
            _ = checkUnreadChatCount()
            
//            if showConversationsTableView != nil {
//                showConversationsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
//            }
            self.setDataOfCollection(true)
            
            break
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    
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
            
            conversationObj.unreadCount = 0
            _ = checkUnreadChatCount()
            showConversationsTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
}


extension AllConversationsViewController {
    
    @IBAction func createChatBtnTapped(_ sender: UIButton) {
        let dict: [String: Any] = ["button_action": ["action_type": "CREATE_CHAT"]]
        HippoConfig.shared.delegate?.fuguMessageRecievedWith(response: dict, viewController: self)
    }
   
    
    func EmptyheaderAction(_ sender: UITapGestureRecognizer) {
        self.headerEmptyAction(sender)
    }
    
    func refreshTable(_ refreshControl: UIRefreshControl) {
        self.refresh(refreshControl)
    }
    
    
    func setupMultipleView() {
      
      if HippoConfig.shared.allConversationTypes.count == 0 {
        self.containerView.isHidden = true
        self.showConversationsTableView.isHidden = false
        print(self.childViewControllers)
        if self.childViewControllers.count > 0{
          let viewControllers:[UIViewController] = self.childViewControllers
          for viewContoller in viewControllers{
            viewContoller.willMove(toParentViewController: nil)
            viewContoller.view.removeFromSuperview()
            viewContoller.removeFromParentViewController()
          }
        }
        
        self.showConversationsTableView.reloadData()
        
      } else {
        self.showConversationsTableView.isHidden = true
        self.showConversationsTableView.delegate = nil
        self.showConversationsTableView.delegate = nil
        guard let userDetails = HippoConfig.shared.userDetail else {
          return
        }
        
        var showMultiView = false
        
        if !HippoConfig.shared.allConversationTypes.contains(where: { (element) -> Bool in
          if let value = element["values"] as? String {
            if value == "ALL" {
              return true
            }
          }
          
          return false
        }) {
          let allChatType: [String: Any] = ["values": "ALL",
                                            "is_visible": true]
          HippoConfig.shared.allConversationTypes.insert(allChatType, at: 0)
        }
        
        if userDetails.isJugnooUser {
          if HippoConfig.shared.allConversationTypes.count > 0 {
            showMultiView = true
          }
        }
        
        if showMultiView {
          //            self.numberOfItemsInCollection = HippoConfig.shared.allConversationTypes.count
        } else {
          
        }
        
        setDataOfCollection(true)
        self.containerView.isHidden = false
      }
        
      
        
      
        
    }
    
    func setDataOfCollection(_ scrollToTop: Bool) {
        
        for childViewController in childViewControllers {
            guard let child = childViewController as? PagerViewController else {
                continue
            }
            child.shouldRemoveAllOffset = true
            child.reloadPagerTabStripView()
            break
        }
    }
    
    
    
    func openChat(withObj obj: FuguConversation) {
        moveToChatViewController(chatObj: obj)
    }
}
