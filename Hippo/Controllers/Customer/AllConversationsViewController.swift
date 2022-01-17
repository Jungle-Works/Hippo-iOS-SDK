//
//  ShowAllConersationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/10/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import NotificationCenter


enum ConversationChatType: Int {
    case defaultChat = 0
    case broadcast = 1
    case p2p = 2
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
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var poweredByFuguLabel: UILabel!
    
    @IBOutlet weak var heightOfBottomLabel: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var defaultChatButton: UIButton!
    @IBOutlet weak var broadcastChatButton: UIButton!
    @IBOutlet weak var p2pChatButton: UIButton!
    
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
//    var arrayOfFullConversation = [FuguConversation]()
    var arrayOfConversation = [FuguConversation]()
//    var ongoingConversationArr = [FuguConversation]()
//    var closedConversationArr = [FuguConversation]()
    var arrayOfConversations: [[FuguConversation]] = [[],[],[]]
    var config: AllConversationsConfig = AllConversationsConfig.defaultConfig
    var conversationChatType: ConversationChatType = .defaultChat
    var conversationFilter: ChatStatus = .open
    var shouldHideBackBtn : Bool = false
    var whatsappWidgetConfig: WhatsappWidgetConfig?
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiSetup()
        addObservers()
        _ = handleIntialCustomerForm()
        
        if let labelId = HippoProperty.current.openLabelIdOnHome, labelId > 0 {
            moveToChatViewcontroller(labelId: labelId)
        }
        
        //        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.defaultChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        self.p2pChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        self.broadcastChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        
        self.defaultChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        self.p2pChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.broadcastChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        
        self.defaultChatButton.setTitle(HippoStrings.Default, for: .normal)
        self.p2pChatButton.setTitle(HippoStrings.p2p, for: .normal)
        self.broadcastChatButton.setTitle(HippoStrings.broadcast, for: .normal)
        
        self.bottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
        
        if HippoUserDetail.fuguUserID == nil {
            putUserDetails()
        } else {
//            getAllConversations()
            getAllConvo()
        }
        
        view_NavigationBar.title = config.title ?? HippoConfig.shared.theme.headerText
        view_NavigationBar.isLeftButtonHidden = shouldHideBackBtn
        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        
        
        //Configuring whatsapp button
        if let whatsappData = HippoConfig.shared.whatsappWidgetConfig{
            self.whatsappWidgetConfig = whatsappData
            view_NavigationBar.whtsappBtn.isHidden = false
            view_NavigationBar.whtsappBtn.addTarget(self, action: #selector(btnWhatsappTapped), for: .touchUpInside)
        }
        
        self.setFilterButtonIcon()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if config.shouldUseCache && arrayOfConversation.isEmpty{
            arrayOfConversations[conversationChatType.rawValue] = fetchAllConversationCache(with: conversationChatType)
            arrayOfConversation = arrayOfConversations[conversationChatType.rawValue]
            showConversationsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.height_ErrorLabel.constant = 0
        checkNetworkConnection()
        HippoConfig.shared.hideTabbar?(false)
        self.navigationController?.isNavigationBarHidden = true
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
    
    fileprivate func handleNoChatData() {
        if self.arrayOfConversations[0].isEmpty && self.arrayOfConversations[1].isEmpty && self.arrayOfConversations[2].isEmpty && HippoConfig.shared.theme.shouldShowBtnOnChatList{
            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else if self.arrayOfConversations[0].isEmpty && self.arrayOfConversations[1].isEmpty && self.arrayOfConversations[2].isEmpty { self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else{
            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
        }
    }
    
    func putUserDetails() {
        HippoUserDetail.getUserDetailsAndConversation(completion: { [weak self] (success, error) in
            guard success else {
//                let errorMessage = error?.localizedDescription ?? HippoStrings.somethingWentWrong
                self?.arrayOfConversation = []
                self?.showConversationsTableView?.reloadData()
                return
            }

//            let fetchAllConversationCacheData = self?.fetchAllConversationCache(with: self?.conversationChatType ?? ConversationChatType.defaultChat) ?? []
            
            self?.showConversationsTableView.reloadData()
            
            switch self?.conversationChatType {
            case .defaultChat:
                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
            case .broadcast, .p2p:
                self?.view_NewConversationBtn.isHidden = true
            default:
                return
            }
            
            if let result = self?.handleIntialCustomerForm(), result {
                return
            } else if self?.arrayOfConversation.count == 0 {
                if HippoConfig.shared.shouldOpenDefaultChannel{
                    self?.openDefaultChannel()
                    return
                }
                
                self?.handleNoChatData()
            }
        })
        
    }
    
    func uiSetup() {
        
        if #available(iOS 11.0, *) {
            showConversationsTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        if HippoConfig.shared.hasChannelTabs == true{
            self.buttonContainerViewHeightConstraint.constant = 45
            self.defaultChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
            self.p2pChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
        }else{
            self.buttonContainerViewHeightConstraint.constant = 0
            self.defaultChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
            self.p2pChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
        }

        updateErrorLabelView(isHiding: true)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        setTableView()
        showConversationsTableView.backgroundView = refreshControl
        let theme = HippoConfig.shared.theme
        
        //    newConversationBiutton.isEnabled = HippoProperty.current.enableNewConversationButton
        if self.conversationChatType == .defaultChat{
            view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
        }else if self.conversationChatType == .p2p{
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
    //    updateBottomLabel()
    
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
//    @objc func openFuguChatWebLink(_ sender: UITapGestureRecognizer) {
//        guard let fuguURL = URL(string: urlForFuguChat),
//              UIApplication.shared.canOpenURL(fuguURL) else {
//                  return
//              }
//
//        UIApplication.shared.openURL(fuguURL)
//    }
    
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
        //        if let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController{
//            if let tabBarController = navigationController.viewControllers[0] as? UITabBarController{
//                tabBarController.selectedIndex = 0
//            }
//        }
        
        if config.shouldPopVc {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        FuguConversation.paginationData = [PaginationData(), PaginationData(), PaginationData()]
        FilterManager.shared.resetData()
        saveConversationsInCache()
        HippoConfig.shared.notifiyDeinit()
        self.navigationController?.dismiss(animated: true, completion: nil)
        
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
    
    @IBAction func defaultChatButtonClicked(_ sender: UIButton) {
        guard conversationChatType != .defaultChat else {
            return
        }
        
        self.view_NavigationBar.rightButton.isEnabled = true
        self.defaultChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        self.p2pChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.broadcastChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        
        self.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
        conversationChatType = .defaultChat
        animateBottomLineView()
        self.showDefaultChatData()
    }
    
    @IBAction func broadcastChatButtonClicked(_ sender: Any) {
        guard conversationChatType != .broadcast else {
            return
        }
        self.view_NavigationBar.rightButton.isEnabled = false
        self.defaultChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.p2pChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.broadcastChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        
        conversationChatType = .broadcast
        animateBottomLineView()
        showBroadcastChatData()
    }
    
    @IBAction func p2pChatButtonClicked(_ sender: Any) {
        guard conversationChatType != .p2p else {
            return
        }
        self.view_NavigationBar.rightButton.isEnabled = false
        self.defaultChatButton.titleLabel?.font = UIFont.regular(ofSize: 16)
        self.p2pChatButton.titleLabel?.font = UIFont.bold(ofSize: 16)
        self.broadcastChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        
        self.view_NewConversationBtn.isHidden = true
        conversationChatType = .p2p
        animateBottomLineView()
        self.showP2pChatData()
    }
    
    func showDefaultChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.arrayOfConversations[0]
        self.showConversationsTableView.reloadData()
        
        if self.arrayOfConversation.count > 0{
            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func showBroadcastChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.arrayOfConversations[1]
        self.showConversationsTableView.reloadData()
        
        if self.arrayOfConversations[1].isEmpty{
            self.getAllConvo()
        }
        
        if self.arrayOfConversation.count > 0{
            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func showP2pChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.arrayOfConversations[2]
        self.showConversationsTableView.reloadData()

        if self.arrayOfConversations[2].isEmpty{
            self.getAllConvo()
        }
        
        if self.arrayOfConversation.count > 0{
            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func animateBottomLineView() {
        var leading = 0.0
        
        switch conversationChatType {
        case .defaultChat:
            leading = 0.0
        case .broadcast:
            leading = broadcastChatButton.frame.minX
        case .p2p:
            leading = p2pChatButton.frame.minX
        }
        
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
//            getAllConversations()
            getAllConvo()
        }
    }
    
    // MARK: - UIRefreshControl
    @objc func refresh(_ refreshControl: UIRefreshControl) {
//        getAllConversations()
        FuguConversation.paginationData[self.conversationChatType.rawValue].pageNumber = 0
        FuguConversation.paginationData[self.conversationChatType.rawValue].canPaginate = true
        getAllConvo()
    }
    
    // MARK: - Action for whatsapp open button
    @objc func btnWhatsappTapped(){
        openWhatsapp(with: self.whatsappWidgetConfig?.whatsappContactNumber ?? "", message: self.whatsappWidgetConfig?.defaultMessage ?? "")
    }
    
    // MARK: - Function to open whatsapp
    func openWhatsapp(with number: String, message: String){
        let urlWhats = "whatsapp://send?phone=\(number)&text=\(message)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(whatsappURL)
                    }
                }
                else {
                    let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(number)&text=\(message)")!
                    if UIApplication.shared.canOpenURL(appURL) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(appURL)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func filterBtnAction(_ sender: Any) {
        if let vc = FilterViewController.getNewInstance(){
            vc.filterScreenButtonsDelegate = self
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - SERVER HIT
//    func getAllConversations() {
//        
//        if HippoConfig.shared.appSecretKey.isEmpty {
//            arrayOfConversation = []
//            showConversationsTableView?.reloadData()
//            showErrorMessageInTopErrorLabel(withMessage: "Invalid app secret key")
//            return
//        }
//        
//        FuguConversation.getAllConversationFromServer(config: config) { [weak self] (result) in
//            self?.refreshControl.endRefreshing()
//            resetPushCount()
//            pushTotalUnreadCount()
//            
//            guard result.isSuccessful else {
//                let errorMessage = result.error?.localizedDescription ?? HippoStrings.somethingWentWrong
//                self?.showErrorMessageInTopErrorLabel(withMessage: errorMessage)
//                return
//            }
//            
//            var conversation = result.conversations!
//            if self?.config.isStaticRemoveConversation ?? false, let status = self?.config.enabledChatStatus, !status.isEmpty {
//                let lastChannelId = self?.config.lastChannelId ?? -12
//                conversation = conversation.filter({ (con) -> Bool in
//                    print(con.channelStatus)
//                    return (status.contains(con.channelStatus) && lastChannelId != con.channelId)
//                })
//            }
//            
//            
//            self?.arrayOfConversation = conversation
//            self?.arrayOfFullConversation = conversation
//            let conversationData = conversation
//            
//            if !conversationData.isEmpty{
//                self?.filterConversationArr(conversationArr: conversationData)
//            }
//            
//            if self?.conversationChatType == .defaultChat{
//                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
//            }else if self?.conversationChatType == .p2p{
//                self?.view_NewConversationBtn.isHidden = true
//            }else{
//                
//            }
//            
//            if result.conversations?.count == 0 {
//                self?.closedConversationArr.removeAll()
//                self?.ongoingConversationArr.removeAll()
//                if HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
//                    self?.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//                }
//                if HippoConfig.shared.shouldOpenDefaultChannel{
//                    self?.openDefaultChannel()
//                    return
//                }
//            }
//        }
//    }
    
//    func getConversations(){
//        if HippoConfig.shared.appSecretKey.isEmpty {
//            arrayOfConversation = []
//            showConversationsTableView?.reloadData()
//            showErrorMessageInTopErrorLabel(withMessage: "Invalid app secret key")
//            return
//        }
//    }
    
    
//    func filterConversationArr(conversationArr:[FuguConversation]){
//        //        if conversationArr.count <= 0 {
//        //            self.noConversationFound()
//        //            DispatchQueue.main.async {
//        //                self.showConversationsTableView.reloadData()
//        //            }
//        //            return
//        //        }else{
//
//        var tempArrayOfConversation = [FuguConversation]()
//        tempArrayOfConversation = conversationArr
//
//        self.ongoingConversationArr.removeAll()
//        self.ongoingConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 1}
//
//        self.closedConversationArr.removeAll()
//        self.closedConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 2}
//
//        if self.conversationChatType == .defaultChat{
//            self.showDefaultChatData()
//        }else if self.conversationChatType == .p2p{
//            self.showP2pChatData()
//        }else{}
//
//        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
//            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
//            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else{
//            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
//        }
//    }
    
    func noConversationFound(_ shouldShowBtn : Bool, _ errorMessage : String){
        tableViewDefaultText = ""
        if self.arrayOfConversation.count <= 0{
            //self.navigationItem.rightBarButtonItem?.tintColor = .clear
            if informationView == nil {
                informationView = InformationView.loadView(self.showConversationsTableView.bounds)
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
    
    func getAllConvo(){
        if HippoConfig.shared.appSecretKey.isEmpty {
            arrayOfConversation = []
            showConversationsTableView?.reloadData()
            showErrorMessageInTopErrorLabel(withMessage: "Invalid app secret key")
            return
        }
        
        FuguConversation.paginationData[conversationChatType.rawValue].isApiHitting = true
        
        FuguConversation.getConversationsFromServer(for: conversationChatType, and: conversationFilter.rawValue){ [weak self] (result) in
            self?.refreshControl.endRefreshing()
            self?.showConversationsTableView.tableFooterView = nil
            FuguConversation.paginationData[self?.conversationChatType.rawValue ?? 0].isApiHitting = false
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
            
            if FuguConversation.paginationData[self?.conversationChatType.rawValue ?? 0].pageNumber == 1{
                self?.arrayOfConversations[self?.conversationChatType.rawValue ?? 0] = conversation
            }else{
                self?.arrayOfConversations[self?.conversationChatType.rawValue ?? 0].append(contentsOf: conversation)
            }
            
            switch self?.conversationChatType{
                
            case .defaultChat:
                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
            case .broadcast, .p2p:
                self?.view_NewConversationBtn.isHidden = true
            case .none:
                return
            }
            
            self?.arrayOfConversation = (self?.arrayOfConversations[self?.conversationChatType.rawValue ?? 0])!
            
            if result.conversations?.count == 0{
                self?.arrayOfConversations = [[],[],[]]
                if HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
                    self?.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
                }
                if HippoConfig.shared.shouldOpenDefaultChannel &&  self?.conversationChatType == .defaultChat && self?.conversationFilter == .open{
                    self?.openDefaultChannel()
                    return
                }
            }
            
            self?.handleNoChatData()
            
            DispatchQueue.main.async {
                self?.showConversationsTableView.reloadData()
            }
        }
    }
    
    func setFilterButtonIcon(){
        if conversationFilter == .close {
            if HippoConfig.shared.theme.filterSelectedBarButtonImage != nil {                view_NavigationBar.rightButton.setImage(HippoConfig.shared.theme.filterSelectedBarButtonImage, for: .normal)
                view_NavigationBar.rightButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }else{
            if HippoConfig.shared.theme.filterUnselectedBarButtonImage != nil {                view_NavigationBar.rightButton.setImage(HippoConfig.shared.theme.filterUnselectedBarButtonImage, for: .normal)
                view_NavigationBar.rightButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
        view_NavigationBar.rightButton.addTarget(self, action: #selector(filterBtnAction(_:)), for: .touchUpInside)
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
        self.errorLabel?.text = message
        self.updateErrorLabelView(isHiding: true)
    }
    
    
    // MARK: - HELPER
    func updateErrorLabelView(isHiding: Bool) {
        if isHiding{
            self.height_ErrorLabel?.constant = 0
            errorLabel.text = ""
        }else{
            self.height_ErrorLabel?.constant = 20
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
        
        var key = ""
        var arr = [FuguConversation]()
        
        for chat in 0...2{
            if chat == 0{
                key = DefaultName.defaultConversationData.rawValue
                arr = arrayOfConversations[chat]
            }else if chat == 1 {
                if !(arrayOfConversations[safe: chat]?.isEmpty ?? true){
                    key = DefaultName.broadcastConversationData.rawValue
                    arr = arrayOfConversations[chat]
                }else{
                    continue
                }
                
            }else{
                if !(arrayOfConversations[safe: chat]?.isEmpty ?? true){
                    key = DefaultName.p2pConversationData.rawValue
                    arr = arrayOfConversations[chat]
                }else{
                    continue
                }
            }
            
            let conversationJson = FuguConversation.getJsonFrom(conversations: arr)
            FuguDefaults.set(value: conversationJson, forKey: key)
        }
        
    }
    
    func fetchAllConversationCache(with chatType: ConversationChatType) -> [FuguConversation] {
        
        var key = ""
        
        switch chatType {
        case .defaultChat:
            key = DefaultName.defaultConversationData.rawValue
        case .broadcast:
            key = DefaultName.broadcastConversationData.rawValue
        case .p2p:
            key = DefaultName.p2pConversationData.rawValue
        }
        
        guard let convCache = FuguDefaults.object(forKey: key) as? [[String: Any]] else {
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
        
//        let obj = arrayOfFullConversation.filter{$0.channelId == conversationObj.channelId}.first
        let obj = arrayOfConversations[conversationChatType.rawValue].filter{$0.channelId == conversationObj.channelId}.first
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
    fileprivate func getChannelIdData(from pushChannelId: Int) -> (Int?, Int?, [FuguConversation]?) {
        
        var channelIdIndex: Int?
        
        channelIdIndex = arrayOfConversations[0].firstIndex { (f) -> Bool in
            return f.channelId ?? -1 == pushChannelId
        }
        
        if channelIdIndex != nil{
            return (channelIdIndex, 0, arrayOfConversations[0])
        }
        
        channelIdIndex = arrayOfConversations[1].firstIndex { (f) -> Bool in
            return f.channelId ?? -1 == pushChannelId
        }
        
        if channelIdIndex != nil{
            return (channelIdIndex, 1, arrayOfConversations[1])
        }
        
        channelIdIndex = arrayOfConversations[2].firstIndex { (f) -> Bool in
            return f.channelId ?? -1 == pushChannelId
        }
        
        if channelIdIndex != nil{
            return (channelIdIndex, 2, arrayOfConversations[2])
        }
        
        return (nil, nil, nil)
    }
    
    fileprivate func getLabelIdData(from pushLabelId: Int) -> (Int?, Int?, [FuguConversation]?) {
        
        var labelIdIndex: Int?
        
        labelIdIndex = arrayOfConversations[0].firstIndex { (f) -> Bool in
            return f.labelId ?? -1 == pushLabelId
        }
        
        if labelIdIndex != nil{
            return (labelIdIndex, 0, arrayOfConversations[0])
        }
        
        labelIdIndex = arrayOfConversations[1].firstIndex { (f) -> Bool in
            return f.labelId ?? -1 == pushLabelId
        }
        
        if labelIdIndex != nil{
            return (labelIdIndex, 1, arrayOfConversations[1])
        }
        
        labelIdIndex = arrayOfConversations[2].firstIndex { (f) -> Bool in
            return f.labelId ?? -1 == pushLabelId
        }
        
        if labelIdIndex != nil{
            return (labelIdIndex, 2, arrayOfConversations[2])
        }
        
        return (nil, nil, nil)
    }
    
    func updateChannelsWithrespectToPush(pushInfo: [String: Any]) {
        
        guard config.shouldHandlePush else {
            return
        }
        
        if let notificationType = pushInfo["notification_type"] as? Int, notificationType == 23 || notificationType == 20{
            return
        }
        
        if let notificationType = pushInfo["notification_type"] as? Int, notificationType == 5 {
            //            getAllConversations()
            getAllConvo()
            return
        }
        
        let pushChannelId = pushInfo["channel_id"] as? Int ?? -1
        let pushLabelId = pushInfo["label_id"] as? Int ?? -1
        
        var channelIdIndex: Int?
        var labelIdIndex: Int?
        var arrayWhereChannelIdFound: [FuguConversation]?
        var arrayWhereLabelIdFound: [FuguConversation]?
        var arrIndex: Int?
        
        
        if pushChannelId > 0 {
           (channelIdIndex, arrIndex, arrayWhereChannelIdFound) = getChannelIdData(from: pushChannelId)
        }else if pushLabelId > 0 {
            (labelIdIndex, arrIndex, arrayWhereLabelIdFound) = getLabelIdData(from: pushLabelId)
        }
        
        guard channelIdIndex != nil || labelIdIndex != nil else {
            getAllConvo()
            return
        }
        
        let rawIndex: Int? = channelIdIndex ?? labelIdIndex
        let rawArr = arrayWhereChannelIdFound ?? arrayWhereLabelIdFound
        
        
        guard let index = rawIndex, rawArr?.count ?? 0 > index else {
            getAllConvo()
            return
        }
        
        let convObj = rawArr?[index]
        let lastMessage = HippoMessage(convoDict: pushInfo)
        
        
        if let lastMuid = convObj?.lastMessage?.messageUniqueID, let newMuid = lastMessage?.messageUniqueID, lastMuid == newMuid {
            return
        }
        
        convObj?.lastMessage = lastMessage
        
        if let unreadCount = pushInfo["unread_count"] as? Int, unreadCount > 0 {
            convObj?.unreadCount = unreadCount
        } else if let unreadCount = convObj?.unreadCount, UIApplication.shared.applicationState != .inactive {
            convObj?.unreadCount = unreadCount + 1
        }
        
        arrayOfConversations[arrIndex ?? 0][index] = convObj!
        arrayOfConversation = arrayOfConversations[conversationChatType.rawValue]
        
        saveConversationsInCache()
        resetPushCount()
        pushTotalUnreadCount()
        
        if arrIndex == conversationChatType.rawValue{
            showConversationsTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return arrayOfConversation.count > 0 ? 0 : tableView.frame.height
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
//        let fullconversationObj = arrayOfFullConversation.filter{$0.channelId == arrayOfConversation[indexPath.row].channelId}
        let fullconversationObj = arrayOfConversation[indexPath.row]
        moveToChatViewController(chatObj: conversationObj)
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            resetPushCount()
            conversationObj.unreadCount = 0
            fullconversationObj.unreadCount = 0
            saveConversationsInCache()
            pushTotalUnreadCount()
            showConversationsTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
           // print("this is the last cell")
            
            let spinner = UIActivityIndicatorView()
            
            if #available(iOS 13.0, *) {
                spinner.style = .large
            } else {
                spinner.style = .whiteLarge
            }
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            self.showConversationsTableView.tableFooterView = spinner
            self.showConversationsTableView.tableFooterView?.isHidden = false
            
            if FuguConversation.paginationData[conversationChatType.rawValue].canPaginate && !FuguConversation.paginationData[conversationChatType.rawValue].isApiHitting{
                self.getAllConvo()
            }else{
                self.showConversationsTableView.tableFooterView = nil
            }
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
    
//    func closeChat(_ channelId : Int){
//        let index = arrayOfFullConversation.firstIndex(where: {$0.channelId == channelId})
//        if let index = index , index < arrayOfFullConversation.count{
//            arrayOfFullConversation[index].channelStatus = .close
//        }
//        self.filterConversationArr(conversationArr: arrayOfFullConversation)
//    }
    
}

extension AllConversationsViewController: FilterScreenButtonsDelegate{
    func cancelButtonPressed() {
        
    }
    
    func resetButtonPressed() {
        
        guard self.conversationFilter != .open else {
            return
        }
    
        self.conversationFilter = .open
        setFilterButtonIcon()
    
        FuguConversation.paginationData[self.conversationChatType.rawValue].pageNumber = 0
        FuguConversation.paginationData[self.conversationChatType.rawValue].canPaginate = true
        self.getAllConvo()
    }
    
    func applyButtonPressed() {
        
        guard self.conversationFilter.rawValue != FilterManager.shared.selectedChatStatus.first else {
            return
        }
        
        self.conversationFilter = FilterManager.shared.selectedChatStatus.first == 1 ? .open : .close
        setFilterButtonIcon()
        
        FuguConversation.paginationData[self.conversationChatType.rawValue].pageNumber = 0
        FuguConversation.paginationData[self.conversationChatType.rawValue].canPaginate = true
        self.getAllConvo()
    }
    
}
