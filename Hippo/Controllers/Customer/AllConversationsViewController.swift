//
//  ShowAllConersationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import NotificationCenter

enum ConversationChatType {
    case openChat
    case closeChat
}

class AllConversationsViewController: UIViewController, NewChatSentDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var newConversationBiutton: UIButton!
    @IBOutlet var showConversationsTableView: UITableView!{
        didSet{
            showConversationsTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet var navigationBackgroundView: UIView!
    //   @IBOutlet var navigationTitleLabel: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet var errorLabel: UILabel!
   // @IBOutlet var errorLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var poweredByFuguLabel: UILabel!
    @IBOutlet weak var heightOfBottomLabel: NSLayoutConstraint!
    //   @IBOutlet weak var heightofNavigationBar: NSLayoutConstraint!
    
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var openChatButton: UIButton!
    @IBOutlet weak var closeChatButton: UIButton!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var buttonContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var width_NewConversation : NSLayoutConstraint!
    @IBOutlet weak var view_NewConversationBtn : UIView!
    @IBOutlet weak var height_ErrorLabel : NSLayoutConstraint!
    @IBOutlet weak var view_NavigationBar : NavigationBar!
    
    // MARK: - PROPERTIES
    let refreshControl = UIRefreshControl()
    var informationView: InformationView?
    
    var tableViewDefaultText: String = ""
    let urlForFuguChat = "https://fuguchat.com/"
    var arrayOfFullConversation = [FuguConversation]()
    var arrayOfConversation = [FuguConversation]()
    var ongoingConversationArr = [FuguConversation]()
    var closedConversationArr = [FuguConversation]()
    var config: AllConversationsConfig = AllConversationsConfig.defaultConfig
    var conversationChatType: ConversationChatType = .openChat
    var shouldHideBackBtn : Bool = false
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
       // navigationSetUp()
        uiSetup()
        addObservers()
        _ = handleIntialCustomerForm()
        
        if config.shouldUseCache {
            //self.arrayOfConversation = fetchAllConversationCache()
            arrayOfFullConversation = fetchAllConversationCache()
            let fetchAllConversationCacheData = fetchAllConversationCache()
            if !fetchAllConversationCacheData.isEmpty{
                self.filterConversationArr(conversationArr: fetchAllConversationCacheData)
            }
        }
        if let labelId = HippoProperty.current.openLabelIdOnHome, labelId > 0 {
            moveToChatViewcontroller(labelId: labelId)
        }
        
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.openChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        self.closeChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        
        self.openChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        self.closeChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.openChatButton.setTitle(HippoStrings.ongoing, for: .normal)
        self.closeChatButton.setTitle(HippoStrings.past, for: .normal)
        
        self.bottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
        
        if HippoUserDetail.fuguUserID == nil {
            putUserDetails()
        } else {
            getAllConversations()
        }
        
        view_NavigationBar.title = config.title ?? HippoConfig.shared.theme.headerText
        view_NavigationBar.isLeftButtonHidden = shouldHideBackBtn
        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.height_ErrorLabel.constant = 0
        checkNetworkConnection()
        HippoConfig.shared.hideTabbar?(false)
      //  self.navigationController?.setTheme()
        self.navigationController?.isNavigationBarHidden = true
        self.setUpTabBar()
        
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
    }
    
    override func viewWillLayoutSubviews() {
        self.setUpTabBar()
    }
    
    func setUpTabBar(){
        //        self.tabBarController?.hidesBottomBarWhenPushed = true
        //        self.tabBarController?.tabBar.isHidden = false
        //        self.tabBarController?.tabBar.layer.zPosition = 0
        //        self.tabBarController?.tabBar.items?[0].title = "Chats"
        
        //hide
//        self.tabBarController?.hidesBottomBarWhenPushed = true
//        self.tabBarController?.tabBar.isHidden = true
//        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    @IBAction func newConversationClicked(_ sender: Any) {
        var fuguNewChatAttributes = FuguNewChatAttributes(transactionId: "", userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: HippoProperty.current.newConversationButtonTags, channelName: nil, preMessage: "", groupingTag: nil)
        
        print("bodID******* \(HippoProperty.current.newconversationBotGroupId ?? "")")
        print("bodID*******First")
//        fuguNewChatAttributes.botGroupId = HippoProperty.current.newconversationBotGroupId//"72"//
        if let botID = HippoProperty.current.newconversationBotGroupId, botID != ""{
            fuguNewChatAttributes.botGroupId = botID
        }
        
        let conversation = ConversationsViewController.getWith(chatAttributes: fuguNewChatAttributes)
        conversation.createConversationOnStart = true
        conversation.hidesBottomBarWhenPushed = true
        HippoConfig.shared.hideTabbar?(true)
        self.navigationController?.pushViewController(conversation, animated: true)
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
                let errorMessage = error?.localizedDescription ?? HippoStrings.somethingWentWrong
                
                //self?.tableViewDefaultText = errorMessage + "\n Please tap to retry."
                self?.arrayOfConversation = []
                self?.showConversationsTableView?.reloadData()
                return
            }
            //self?.arrayOfConversation = self?.fetchAllConversationCache() ?? []
            let fetchAllConversationCacheData = self?.fetchAllConversationCache() ?? []
            if !fetchAllConversationCacheData.isEmpty{
                self?.filterConversationArr(conversationArr: fetchAllConversationCacheData)
            }
            
            self?.showConversationsTableView.reloadData()
            if self?.conversationChatType == .openChat{
                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
            }else if self?.conversationChatType == .closeChat{
                self?.view_NewConversationBtn.isHidden = true
            }else{}
            if let result = self?.handleIntialCustomerForm(), result {
                return
            } else if self?.arrayOfConversation.count == 0 {
                if HippoConfig.shared.shouldOpenDefaultChannel{
                    self?.openDefaultChannel()
                    return
                }
                
                if self?.ongoingConversationArr.count == 0 && self?.closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{ self?.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
                }else if self?.ongoingConversationArr.count == 0 && self?.closedConversationArr.count == 0{ self?.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
                }else{ self?.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
                }
            }
        })
        
    }
    
   func uiSetup() {
    if HippoConfig.shared.hasChannelTabs == true{
        self.buttonContainerViewHeightConstraint.constant = 45
        self.openChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
        self.closeChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
    }else{
        self.buttonContainerViewHeightConstraint.constant = 0
        self.openChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
        self.closeChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
    }
    automaticallyAdjustsScrollViewInsets = false
    updateErrorLabelView(isHiding: true)
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    setTableView()
    showConversationsTableView.backgroundView = refreshControl
    let theme = HippoConfig.shared.theme
    
//    newConversationBiutton.isEnabled = HippoProperty.current.enableNewConversationButton
    if self.conversationChatType == .openChat{
        view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
    }else if self.conversationChatType == .closeChat{
        view_NewConversationBtn.isHidden = true
    }else{}
    
    
//    DispatchQueue.main.async {
//        let gradient = CAGradientLayer()
//        gradient.frame = self.newConversationBiutton.bounds
//        gradient.colors = [theme.gradientTopColor.cgColor, theme.gradientBottomColor.cgColor]
//        self.newConversationBiutton.layer.insertSublayer(gradient, at: 0)
//    }
    
   // newConversationBiutton.setTitleColor(theme.themeTextcolor, for: .normal)
    newConversationBiutton.backgroundColor = theme.themeColor
    view_NewConversationBtn.backgroundColor = theme.themeColor
    view_NewConversationBtn.layer.cornerRadius = newConversationBiutton.bounds.height / 2
    //view_NewConversationBtn.layer.borderWidth = CGFloat(HippoConfig.shared.newConversationButtonBorderWidth)
    //view_NewConversationBtn.layer.borderColor = theme.themeTextcolor.cgColor
    view_NewConversationBtn.layer.masksToBounds = true
    newConversationBiutton.titleLabel?.font = theme.newConversationButtonFont
    newConversationBiutton.isSelected = false
    self.updateNewConversationBtnUI(isSelected: false)
    newConversationBiutton.setTitleColor(.white, for: .normal)
//    newConversationBiutton.isHidden = HippoConfig.shared.isNewConversationButtonHidden
//    newConversationBiutton.isHidden = !HippoProperty.current.enableNewConversationButton
    
    showConversationsTableView.contentInset.bottom = 70
//    addLogoutButton()
    
    //poweredByFuguLabel.attributedText = attributedStringForLabelForTwoStrings("Runs on ", secondString: "Hippo", colorOfFirstString: HippoConfig.shared.powererdByColor, colorOfSecondString: HippoConfig.shared.FuguColor, fontOfFirstString: HippoConfig.shared.poweredByFont, fontOfSecondString: HippoConfig.shared.FuguStringFont, textAlighnment: .center, dateAlignment: .center)
    
//    let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFuguChatWebLink(_:)))
//    poweredByFuguLabel.addGestureRecognizer(tap)
    
//    updateBottomLabel()
    
    }
    func addLogoutButton() {
        let theme = HippoConfig.shared.theme
        guard let logoutButtonIcon = theme.logoutButtonIcon else {
            return
        }
        let logoutButton = UIBarButtonItem(image: logoutButtonIcon, landscapeImagePhone: nil, style: .done, target: self, action: #selector(logoutButtonClicked))
        
        logoutButton.tintColor = theme.logoutButtonTintColor ?? theme.headerTextColor
        self.navigationItem.rightBarButtonItem = logoutButton
        
        
        let notificationButton = UIBarButtonItem(image: theme.notificationButtonIcon, landscapeImagePhone: nil, style: .done, target: self, action: #selector(notificationButtonClicked))
        
        notificationButton.tintColor = theme.notificationButtonTintColor ?? theme.headerTextColor
        
        self.navigationItem.rightBarButtonItems = [logoutButton]
    }
    @objc func logoutButtonClicked() {
        showOptionAlert(title: "", message: HippoStrings.logout, successButtonName: HippoStrings.yes, successComplete: { (_) in
            HippoConfig.shared.clearHippoUserData { (s) in
                HippoUserDetail.clearAllData()
                HippoConfig.shared.delegate?.hippoUserLogOut()
            }
        }, failureButtonName: HippoStrings.no.capitalized, failureComplete: nil)
    }
    
    @objc func notificationButtonClicked()
    {
       // PromotionsViewController
        HippoConfig.shared.notifyDidLoad()
        let promotionVC = self.storyboard?.instantiateViewController(withIdentifier: "PromotionsViewController") as! PromotionsViewController
        self.navigationController?.pushViewController(promotionVC, animated: true)
    }
    
    func setTableView() {
        let bundle = FuguFlowManager.bundle
        showConversationsTableView.register(UINib(nibName: "ConversationView", bundle: bundle), forCellReuseIdentifier: "ConversationCellCustom")
    }

    func navigationSetUp() {
        
//        navigationBackgroundView.layer.shadowColor = UIColor.black.cgColor
//        navigationBackgroundView.layer.shadowOpacity = 0.25
//        navigationBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
//        navigationBackgroundView.layer.shadowRadius = 4
//
        navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor

        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        
        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            backButton.image = HippoConfig.shared.theme.leftBarButtonImage
            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        }
        if config.disbaleBackButton {
            backButton.isEnabled = false
            backButton.image = nil
        }
      //  title = config.title ?? HippoConfig.shared.theme.headerText
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
            errorLabel.text = ""
            updateErrorLabelView(isHiding: true)
        } else {
            errorLabel.text = HippoStrings.noNetworkConnection
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
    
    func updateNewConversationBtnUI(isSelected : Bool){
        if isSelected{
           // width_NewConversation.constant = 210
            let chatImage = UIImage(named: "chat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            self.newConversationBiutton.setImage(chatImage, for: .normal)
            self.newConversationBiutton.setTitle("  " + HippoConfig.shared.strings.newConversation, for: .normal)
            self.newConversationBiutton.tintColor = .white//HippoConfig.shared.theme.themeTextcolor
            self.newConversationBiutton.backgroundColor = HippoConfig.shared.theme.themeColor
        }else{
          //  width_NewConversation.constant = 50
            let chatImage = UIImage(named: "chat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            self.newConversationBiutton.tintColor = .white//HippoConfig.shared.theme.themeTextcolor
            self.newConversationBiutton.setImage(chatImage, for: .normal)
            self.newConversationBiutton.setTitle("", for: .normal)
            self.newConversationBiutton.backgroundColor = HippoConfig.shared.theme.themeColor
        }
    }
    
    
    // MARK: - UIButton Actions
    
    @IBAction func backButtonClicked(_ sender: Any) {
//        saveConversationsInCache()
//        HippoConfig.shared.notifiyDeinit()
//        if config.shouldPopVc {
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            _ = self.navigationController?.dismiss(animated: true, completion: nil)
//        }
        
        saveConversationsInCache()
        HippoConfig.shared.notifiyDeinit()
//        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
//            if let tabBarController = navigationController.viewControllers[0] as? UITabBarController{
//                tabBarController.selectedIndex = 0
//            }
//        }
        if config.shouldPopVc {
            self.navigationController?.popViewController(animated: true)
        } else {
            _ = self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        saveConversationsInCache()
        HippoConfig.shared.notifiyDeinit()
        _ = self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func newConversationButtonClicked(_ sender: UIButton) {
        //After Merge func
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.updateNewConversationBtnUI(isSelected: sender.isSelected)
            })
            
        }else{
            
            var fuguNewChatAttributes = FuguNewChatAttributes(transactionId: "", userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: nil, channelName: nil, preMessage: "", groupingTag: nil)
            
            print("bodID******* \(HippoProperty.current.newconversationBotGroupId ?? "")")
            print("bodID*******Second")
//            fuguNewChatAttributes.botGroupId = HippoProperty.current.newconversationBotGroupId
            if let botID = HippoProperty.current.newconversationBotGroupId, botID != ""{
                fuguNewChatAttributes.botGroupId = botID
            }
            
            let conversation = ConversationsViewController.getWith(chatAttributes: fuguNewChatAttributes)
            conversation.createConversationOnStart = true
            self.navigationController?.pushViewController(conversation, animated: true)
             self.updateNewConversationBtnUI(isSelected: sender.isSelected)
        }
        
        
    }

    @IBAction func openChatButtonClicked(_ sender: UIButton) {
        guard conversationChatType != .openChat else {
            return
        }
        self.openChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        self.closeChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        //        self.newConversationBiutton.isHidden = false
        self.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
        conversationChatType = .openChat
        animateBottomLineView()
        //getAllConversations()
        self.showOpenChatData()
    }
    
    @IBAction func closeChatButtonClicked(_ sender: Any) {
        guard conversationChatType != .closeChat else {
            return
        }
        self.openChatButton.titleLabel?.font = UIFont.regular(ofSize: 16)
        self.closeChatButton.titleLabel?.font = UIFont.bold(ofSize: 16)
        self.view_NewConversationBtn.isHidden = true
        conversationChatType = .closeChat
        animateBottomLineView()
        //getAllConversations()
        self.showcloseChatData()
    }
    
    func showOpenChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.ongoingConversationArr
        self.showConversationsTableView.reloadData()
        //        if self.arrayOfConversation.count <= 0 {
        //            noConversationFound()
        //            DispatchQueue.main.async {
        //                self.showConversationsTableView.reloadData()
        //            }
        //        }else{
        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else{
            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
        }
        if self.arrayOfConversation.count > 0{
            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        
        // }
    }
    
    func showcloseChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.closedConversationArr
        self.showConversationsTableView.reloadData()
        //        if self.arrayOfConversation.count <= 0 {
        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else{
            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
        }
        if self.arrayOfConversation.count > 0{
            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        //            DispatchQueue.main.async {
        //                self.showConversationsTableView.reloadData()
        //            }
        //        }else{
        //            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        
    }
    
    func animateBottomLineView() {
        let leading = conversationChatType == .openChat ? 0 : openChatButton.bounds.width
        bottomViewLeadingConstraint.constant = leading
        UIView.animate(withDuration: 0.4) {
            self.buttonContainerView.layoutIfNeeded()
        }
    }
    
    @objc func headerEmptyAction(_ sender: UITapGestureRecognizer) {
        
        guard arrayOfConversation.count == 0, tableViewDefaultText != "" else {
            return
        }
        
        tableViewDefaultText = ""
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
        
        FuguConversation.getAllConversationFromServer(config: config) { [weak self] (result) in
            self?.refreshControl.endRefreshing()
            resetPushCount()
            pushTotalUnreadCount()
            
            guard result.isSuccessful else {
                let errorMessage = result.error?.localizedDescription ?? HippoStrings.somethingWentWrong
                self?.showErrorMessageInTopErrorLabel(withMessage: errorMessage)
                return
            }
          
            var conversation = result.conversations!
            if self?.config.isStaticRemoveConversation ?? false, let status = self?.config.enabledChatStatus, !status.isEmpty {
                let lastChannelId = self?.config.lastChannelId ?? -12
                conversation = conversation.filter({ (con) -> Bool in
                    print(con.channelStatus)
                    return (status.contains(con.channelStatus) && lastChannelId != con.channelId)
                })
            }
            
            
            self?.arrayOfConversation = conversation
            self?.arrayOfFullConversation = conversation
            let conversationData = conversation
            if !conversationData.isEmpty{
                self?.filterConversationArr(conversationArr: conversationData)
            }
            
            if self?.conversationChatType == .openChat{
                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
            }else if self?.conversationChatType == .closeChat{
                self?.view_NewConversationBtn.isHidden = true
            }else{}
            
            if result.conversations?.count == 0 {
                self?.closedConversationArr.removeAll()
                self?.ongoingConversationArr.removeAll()
                if HippoConfig.shared.theme.shouldShowBtnOnChatList == true{ self?.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
                }
                if HippoConfig.shared.shouldOpenDefaultChannel{
                    self?.openDefaultChannel()
                    return
                }
            }
        }
    }
    
    func filterConversationArr(conversationArr:[FuguConversation]){
        //        if conversationArr.count <= 0 {
        //            self.noConversationFound()
        //            DispatchQueue.main.async {
        //                self.showConversationsTableView.reloadData()
        //            }
        //            return
        //        }else{
       
        var tempArrayOfConversation = [FuguConversation]()
        tempArrayOfConversation = conversationArr
        
        self.ongoingConversationArr.removeAll()
        self.ongoingConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 1}
        
        self.closedConversationArr.removeAll()
        self.closedConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 2}
        
        if self.conversationChatType == .openChat{
            self.showOpenChatData()
        }else if self.conversationChatType == .closeChat{
            self.showcloseChatData()
        }else{}
        
        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else{
            
            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
        }
        
    }
    
    func noConversationFound(_ shouldShowBtn : Bool, _ errorMessage : String){
        tableViewDefaultText = ""
        if self.arrayOfConversation.count <= 0{
            //self.navigationItem.rightBarButtonItem?.tintColor = .clear
            if informationView == nil {
                informationView = InformationView.loadView(self.showConversationsTableView.bounds, delegate: self)
            }
            self.informationView?.informationLabel.text = errorMessage
            //self.showConversationsTableView.isHidden = true
            self.informationView?.informationImageView.image = HippoConfig.shared.theme.noChatImage
            self.informationView?.isButtonInfoHidden = !shouldShowBtn
            self.informationView?.button_Info.setTitle(HippoConfig.shared.theme.chatListRetryBtnText == nil ? HippoStrings.retry : HippoConfig.shared.theme.chatListRetryBtnText, for: .normal)
            
            self.informationView?.isHidden = false
            self.showConversationsTableView.addSubview(informationView!)
            showConversationsTableView.layoutSubviews()
        }else{
            for view in showConversationsTableView.subviews{
                if view is InformationView{
                     view.removeFromSuperview()
                }
            }
            showConversationsTableView.layoutSubviews()
            self.informationView?.isHidden = true
            //self.navigationItem.rightBarButtonItem?.tintColor = HippoConfig.shared.theme.logoutButtonTintColor ?? HippoConfig.shared.theme.headerTextColor
        }
        
        DispatchQueue.main.async {
            self.showConversationsTableView.reloadData()
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
        if isHiding{
           self.height_ErrorLabel.constant = 0
           errorLabel.text = ""
        }else{
            self.height_ErrorLabel.constant = 20
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
        guard config.shouldUseCache else {
            return
        }
        let conversationJson = FuguConversation.getJsonFrom(conversations: arrayOfFullConversation)
        FuguDefaults.set(value: conversationJson, forKey: DefaultName.conversationData.rawValue)
        //FuguDefaults.set(value: self.conversationChatType, forKey: "conversationType")
    }
    
    func fetchAllConversationCache() -> [FuguConversation] {
        guard let convCache = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] else {
            return []
        }
        
        let arrayOfConversation = FuguConversation.getConversationArrayFrom(json: convCache)
        return arrayOfConversation
    }
    
//    func fetchAllConversationType(){
//        if let conversationType = FuguDefaults.object(forKey: "conversationType") as? ConversationChatType {
//            self.conversationChatType = conversationType
//            self.animateBottomLineView()
//        }else{
//            self.conversationChatType = .openChat
//            self.animateBottomLineView()
//        }
//    }
    
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
        
//        if chatObj?.lastMessage?.messageUniqueID != conversationObj.lastMessage?.messageUniqueID{
//            self.getAllConversations()
//        }
        
        chatObj?.unreadCount = conversationObj.unreadCount
        chatObj?.lastMessage = conversationObj.lastMessage
        
        let obj = arrayOfFullConversation.filter{$0.channelId == conversationObj.channelId}.first
        obj?.unreadCount = 0
        resetPushCount()
        saveConversationsInCache()
        pushTotalUnreadCount()
        
        guard isViewLoaded else {
            return
        }
        showConversationsTableView.reloadData()
    }
    
    
    // MARK: - Navigation
    
    func moveToChatViewController(chatObj: FuguConversation) {
        HippoConfig.shared.notifyDidLoad()
        let conversationVC = ConversationsViewController.getWith(conversationObj: chatObj, allConversationConfig: config)
        conversationVC.delegate = self
        conversationVC.hidesBottomBarWhenPushed = true
        HippoConfig.shared.hideTabbar?(true)
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    func moveToChatViewcontroller(labelId: Int) {
        HippoConfig.shared.notifyDidLoad()
        let conversationVC = ConversationsViewController.getWith(labelId: "\(labelId)")
        conversationVC.delegate = self
        conversationVC.hidesBottomBarWhenPushed = true
        HippoConfig.shared.hideTabbar?(true)
        self.navigationController?.pushViewController(conversationVC, animated: false)
    }
    //MARK: - HANDLE PUSH NOTIFICATION
    func updateChannelsWithrespectToPush(pushInfo: [String: Any]) {
        
        guard config.shouldHandlePush else {
            return
        }
        
        if let notificationType = pushInfo["notification_type"] as? Int, notificationType == 23 || notificationType == 20{
            return
        }
        
        if let notificationType = pushInfo["notification_type"] as? Int, notificationType == 5 {
            getAllConversations()
            return
        }
        
        let pushChannelId = pushInfo["channel_id"] as? Int ?? -1
        let pushLabelId = pushInfo["label_id"] as? Int ?? -1
        
        var channelIdIndex: Int?
        var labelIdIndex: Int?
        var fullArraychannelIdIndex : Int?
        var fullArraylabelIdIndex: Int?
        
        
        if pushChannelId > 0 {
            channelIdIndex = arrayOfConversation.firstIndex { (f) -> Bool in
                return f.channelId ?? -1 == pushChannelId
            }
            fullArraychannelIdIndex = arrayOfFullConversation.firstIndex { (f) -> Bool in
                return f.channelId ?? -1 == pushChannelId
            }
        }
        if pushLabelId > 0 {
            labelIdIndex = arrayOfConversation.firstIndex { (f) -> Bool in
                return f.labelId ?? -1 == pushLabelId
            }
            fullArraylabelIdIndex = arrayOfFullConversation.firstIndex { (f) -> Bool in
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
        let fullrawIndex: Int? = fullArraychannelIdIndex ?? fullArraylabelIdIndex
        
        guard fullrawIndex != nil else {
            return
        }
        guard let fullArrIndex = fullrawIndex, arrayOfFullConversation.count > fullrawIndex ?? -1 else {
            return
        }
        
        arrayOfFullConversation[fullArrIndex] = convObj
        
        if (convObj.unreadCount ?? 0) > 0 {
//            convObj.channelStatus = .open
        }
        saveConversationsInCache()
        resetPushCount()
        pushTotalUnreadCount()
        
        if showConversationsTableView != nil {
            showConversationsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    class func get(config: AllConversationsConfig) -> AllConversationsViewController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AllConversationsViewController") as? AllConversationsViewController else {
            return nil
        }
        vc.config = config
        return vc
    }
}

extension AllConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfConversation.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationView", for: indexPath) as? ConversationView else {
//            return UITableViewCell()
//        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCellCustom", for: indexPath) as? ConversationView else {
            return UITableViewCell()
        }
        
        
        let convObj = arrayOfConversation[indexPath.row]
        cell.configureConversationCell(resetProperties: true, conersationObj: convObj)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
        cell.selectionView?.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1)
//        cell.bgView.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1)
        cell.bgView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
        cell.selectionView?.backgroundColor = .white
        cell.bgView.backgroundColor = .white
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
        footerLabel.font = UIFont.regular(ofSize: 16.0)
        
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
        let fullconversationObj = arrayOfFullConversation.filter{$0.channelId == arrayOfConversation[indexPath.row].channelId}
        moveToChatViewController(chatObj: conversationObj)
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            resetPushCount()
            conversationObj.unreadCount = 0
            fullconversationObj.first?.unreadCount = 0
            saveConversationsInCache()
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
struct AllConversationsConfig {
    let enabledChatStatus: [ChatStatus]
    let title: String?
    
    var shouldUseCache: Bool = true
    var shouldHandlePush: Bool = true
    var shouldPopVc: Bool = false
    var forceDisableReply: Bool = false
    var forceHideActionButton: Bool = false
    var isStaticRemoveConversation: Bool = false
    var lastChannelId: Int? = nil
    var disbaleBackButton: Bool = false
    
    static var defaultConfig: AllConversationsConfig {
        var config =  AllConversationsConfig(enabledChatStatus: [], title: nil, shouldUseCache: true, shouldHandlePush: true, shouldPopVc: false, forceDisableReply: false, forceHideActionButton: false, isStaticRemoveConversation: false, lastChannelId: nil, disbaleBackButton: false)
        
        if HippoProperty.current.singleChatApp {
            config.disbaleBackButton = true
        }
        return config
    }
    
    func getChatStatusToSend() -> [Int] {
        var list = [Int]()
        for each in enabledChatStatus {
            list.append(each.rawValue)
        }
        return list
    }
}

extension AllConversationsViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.2) {
            self.view_NewConversationBtn.alpha = 0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5) {
            self.view_NewConversationBtn.alpha = 1
        }
    }
    
}

extension AllConversationsViewController: InformationViewDelegate {
    
}

//extension AllConversationsViewController:UIGestureRecognizerDelegate {
////    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
////        return true
////    }
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false && gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
//            return false
//        }
//        return true
//    }
//}
extension AllConversationsViewController{
    
    //MARK:- Put conversation in closed based on Faye
    
    func closeChat(_ channelId : Int){
        let index = arrayOfFullConversation.firstIndex(where: {$0.channelId == channelId})
        if let index = index , index < arrayOfFullConversation.count{
            arrayOfFullConversation[index].channelStatus = .close
        }
        self.filterConversationArr(conversationArr: arrayOfFullConversation)
    }
    
}
