////
////  ALLViewController.swift
////  Hippo
////
////  Created by soc-admin on 30/12/21.
////
//
//import UIKit
//import NotificationCenter
//
//enum ConversationChatType {
//    case openChat
//    case closeChat
//}
//
//class ALLViewController: UIViewController {
//
//
//    // MARK: - IBOutlets
//    @IBOutlet weak var newConversationBiutton: UIButton!
//    @IBOutlet var showConversationsTableView: UITableView!{
//        didSet{
//            showConversationsTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//            showConversationsTableView.delegate = self
//            showConversationsTableView.dataSource = self
//        }
//    }
//
//    @IBOutlet weak var errorContentView: UIView!
//    @IBOutlet var errorLabel: UILabel!
//
//    @IBOutlet weak var buttonContainerView: UIView!
//    @IBOutlet weak var openChatButton: UIButton!
//    @IBOutlet weak var closeChatButton: UIButton!
//    @IBOutlet weak var bottomLineView: UIView!
//    @IBOutlet weak var buttonContainerViewHeightConstraint: NSLayoutConstraint!
//
//    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var width_NewConversation : NSLayoutConstraint!
//    @IBOutlet weak var view_NewConversationBtn : UIView!
//    @IBOutlet weak var height_ErrorLabel : NSLayoutConstraint!
//    @IBOutlet weak var view_NavigationBar : NavigationBar!
//
//    // MARK: - PROPERTIES
//    let refreshControl = UIRefreshControl()
//    var informationView: InformationView?
//    var tableViewDefaultText: String = ""
//    let urlForFuguChat = "https://fuguchat.com/"
//    var arrayOfFullConversation = [FuguConversation]()
//    var arrayOfConversation = [FuguConversation]()
//    var ongoingConversationArr = [FuguConversation]()
//    var closedConversationArr = [FuguConversation]()
//    var config: AllConversationsConfig = AllConversationsConfig.defaultConfig
//    var conversationChatType: ConversationChatType = .openChat
//    var shouldHideBackBtn : Bool = false
//
//
//    // MARK: - LIFECYCLE
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        uiSetup()
//        addObservers()
//        _ = handleIntialCustomerForm()
//
//        if config.shouldUseCache {
//            arrayOfFullConversation = fetchAllConversationCache()
//            let fetchAllConversationCacheData = fetchAllConversationCache()
//            if !fetchAllConversationCacheData.isEmpty{
//                self.filterConversationArr(conversationArr: fetchAllConversationCacheData)
//            }
//        }
//
//        if let labelId = HippoProperty.current.openLabelIdOnHome, labelId > 0 {
//            moveToChatViewcontroller(labelId: labelId)
//        }
//
//        if HippoUserDetail.fuguUserID == nil {
//            putUserDetails()
//        } else {
//            getAllConversations()
//        }
//
//        view_NavigationBar.isLeftButtonHidden = shouldHideBackBtn
//
//    }
//
//}
//
//extension ALLViewController{
//
//    func uiSetup() {
//        if HippoConfig.shared.hasChannelTabs == true{
//            self.buttonContainerViewHeightConstraint.constant = 45
//            self.openChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
//            self.closeChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
//        }else{
//            self.buttonContainerViewHeightConstraint.constant = 0
//            self.openChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
//            self.closeChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
//        }
//
//        automaticallyAdjustsScrollViewInsets = false
//        updateErrorLabelView(isHiding: true)
//        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
//        setTableView()
//
//        showConversationsTableView.backgroundView = refreshControl
//        let theme = HippoConfig.shared.theme
//
//        if self.conversationChatType == .openChat{
//            view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
//        }else if self.conversationChatType == .closeChat{
//            view_NewConversationBtn.isHidden = true
//        }else{}
//
//        newConversationBiutton.backgroundColor = theme.themeColor
//        view_NewConversationBtn.backgroundColor = theme.themeColor
//        view_NewConversationBtn.layer.cornerRadius = newConversationBiutton.bounds.height / 2
//        view_NewConversationBtn.layer.masksToBounds = true
//        newConversationBiutton.titleLabel?.font = theme.newConversationButtonFont
//
//        newConversationBiutton.isSelected = false
//        self.updateNewConversationBtnUI(isSelected: false)
//        newConversationBiutton.setTitleColor(.white, for: .normal)
//        showConversationsTableView.contentInset.bottom = 70
//
//        self.openChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
//        self.closeChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
//
//        self.openChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
//        self.closeChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
//        self.openChatButton.setTitle(HippoStrings.ongoing, for: .normal)
//        self.closeChatButton.setTitle(HippoStrings.past, for: .normal)
//
//        self.bottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
//
//        view_NavigationBar.title = config.title ?? HippoConfig.shared.theme.headerText
//        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
//        view_NavigationBar.whtsappBtn.isHidden = false
//    }
//
//    func updateNewConversationBtnUI(isSelected : Bool){
//        if isSelected{
//            let chatImage = UIImage(named: "chat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//            self.newConversationBiutton.setImage(chatImage, for: .normal)
//            self.newConversationBiutton.setTitle("  " + HippoConfig.shared.strings.newConversation, for: .normal)
//            self.newConversationBiutton.tintColor = .white//HippoConfig.shared.theme.themeTextcolor
//            self.newConversationBiutton.backgroundColor = HippoConfig.shared.theme.themeColor
//        }else{
//            let chatImage = UIImage(named: "chat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//            self.newConversationBiutton.tintColor = .white//HippoConfig.shared.theme.themeTextcolor
//            self.newConversationBiutton.setImage(chatImage, for: .normal)
//            self.newConversationBiutton.setTitle("", for: .normal)
//            self.newConversationBiutton.backgroundColor = HippoConfig.shared.theme.themeColor
//        }
//    }
//
//    func updateErrorLabelView(isHiding: Bool) {
//        if isHiding{
//            self.height_ErrorLabel.constant = 0
//            errorLabel.text = ""
//        }else{
//            self.height_ErrorLabel.constant = 20
//        }
//    }
//
//    func setTableView() {
//        let bundle = FuguFlowManager.bundle
//        showConversationsTableView.register(UINib(nibName: "ConversationView", bundle: bundle), forCellReuseIdentifier: "ConversationCellCustom")
//    }
//
//    func showErrorMessageInTopErrorLabel(withMessage message: String) {
//        if FuguNetworkHandler.shared.isNetworkConnected == false {
//            return
//        }
//        self.updateErrorLabelView(isHiding: false)
//        self.errorLabel.text = message
//        self.updateErrorLabelView(isHiding: true)
//    }
//
//    func filterConversationArr(conversationArr:[FuguConversation]){
//        var tempArrayOfConversation = [FuguConversation]()
//        tempArrayOfConversation = conversationArr
//
//        self.ongoingConversationArr.removeAll()
//        self.ongoingConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 1}
//
//        self.closedConversationArr.removeAll()
//        self.closedConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 2}
//
//        if self.conversationChatType == .openChat{
//            self.showOpenChatData()
//        }else if self.conversationChatType == .closeChat{
//            self.showcloseChatData()
//        }else{}
//
//        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
//            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
//            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else{
//
//            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
//        }
//    }
//
//    func openDefaultChannel() {
//        HippoConfig.shared.notifyDidLoad()
//        let conVC = ConversationsViewController.getWith(chatAttributes: FuguNewChatAttributes.defaultChat)
//        self.navigationController?.setViewControllers([conVC], animated: false)
//    }
//
//    func noConversationFound(_ shouldShowBtn : Bool, _ errorMessage : String){
//        tableViewDefaultText = ""
//        if self.arrayOfConversation.count <= 0{
//            if informationView == nil {
//                informationView = InformationView.loadView(self.showConversationsTableView.bounds)
//            }
//            self.informationView?.informationLabel.text = errorMessage
//            self.informationView?.informationImageView.image = HippoConfig.shared.theme.noChatImage
//            self.informationView?.isButtonInfoHidden = !shouldShowBtn
//            self.informationView?.button_Info.setTitle(HippoConfig.shared.theme.chatListRetryBtnText == nil ? HippoStrings.retry : HippoConfig.shared.theme.chatListRetryBtnText, for: .normal)
//
//            self.informationView?.isHidden = false
//            self.showConversationsTableView.addSubview(informationView!)
//            showConversationsTableView.layoutSubviews()
//        }else{
//            for view in showConversationsTableView.subviews{
//                if view is InformationView{
//                    view.removeFromSuperview()
//                }
//            }
//            showConversationsTableView.layoutSubviews()
//            self.informationView?.isHidden = true
//        }
//
//        DispatchQueue.main.async {
//            self.showConversationsTableView.reloadData()
//        }
//    }
//
//    func showOpenChatData(){
//        self.arrayOfConversation.removeAll()
//        self.arrayOfConversation = self.ongoingConversationArr
//        self.showConversationsTableView.reloadData()
//
//        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
//            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
//            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else{
//            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
//        }
//        if self.arrayOfConversation.count > 0{
//            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
//        }
//    }
//
//    func showcloseChatData(){
//        self.arrayOfConversation.removeAll()
//        self.arrayOfConversation = self.closedConversationArr
//        self.showConversationsTableView.reloadData()
//
//        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
//            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
//            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//        }else{
//            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
//        }
//        if self.arrayOfConversation.count > 0{
//            self.showConversationsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
//        }
//    }
//
//    func handleIntialCustomerForm() -> Bool {
//        guard HippoUserDetail.fuguUserID != nil else {
//            return false
//        }
//        guard HippoChecker().shouldCollectDataFromUser() else {
//            return false
//        }
//        let vc = HippoDataCollectorController.get(forms: HippoProperty.current.forms)
//        vc.delegate = self
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.pushViewController(vc, animated: false)
//        return true
//    }
//
//
//    func checkNetworkConnection() {
//        errorLabel.backgroundColor = UIColor.red
//        if FuguNetworkHandler.shared.isNetworkConnected {
//            errorLabel.text = ""
//            updateErrorLabelView(isHiding: true)
//        } else {
//            errorLabel.text = HippoStrings.noNetworkConnection
//            updateErrorLabelView(isHiding: false)
//        }
//    }
//
//    func saveConversationsInCache() {
//        guard config.shouldUseCache else {
//            return
//        }
//        let conversationJson = FuguConversation.getJsonFrom(conversations: arrayOfFullConversation)
//        FuguDefaults.set(value: conversationJson, forKey: DefaultName.conversationData.rawValue)
//    }
//
//    func fetchAllConversationCache() -> [FuguConversation] {
//        guard let convCache = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] else {
//            return []
//        }
//
//        let arrayOfConversation = FuguConversation.getConversationArrayFrom(json: convCache)
//        return arrayOfConversation
//    }
//
//    func animateBottomLineView() {
//        let leading = conversationChatType == .openChat ? 0 : openChatButton.bounds.width
//        bottomViewLeadingConstraint.constant = leading
//        UIView.animate(withDuration: 0.4) {
//            self.buttonContainerView.layoutIfNeeded()
//        }
//    }
//
//    // MARK: - Navigation
//    func moveToChatViewController(chatObj: FuguConversation) {
//        HippoConfig.shared.notifyDidLoad()
//        let conversationVC = ConversationsViewController.getWith(conversationObj: chatObj, allConversationConfig: config)
//        conversationVC.delegate = self
//        conversationVC.hidesBottomBarWhenPushed = true
//        HippoConfig.shared.hideTabbar?(true)
//        self.navigationController?.pushViewController(conversationVC, animated: true)
//    }
//
//    func moveToChatViewcontroller(labelId: Int) {
//        HippoConfig.shared.notifyDidLoad()
//        let conversationVC = ConversationsViewController.getWith(labelId: "\(labelId)")
//        conversationVC.delegate = self
//        conversationVC.hidesBottomBarWhenPushed = true
//        HippoConfig.shared.hideTabbar?(true)
//        self.navigationController?.pushViewController(conversationVC, animated: false)
//    }
//}
//
//
////OBSERVERS
//extension ALLViewController{
//    func addObservers() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: HippoVariable.willResignActiveNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(appMovedToForground), name: HippoVariable.willEnterForegroundNotification, object: nil)
//    }
//}
//
////TARGETS AND ACTIONS
//extension ALLViewController{
//
//    // MARK: - UIRefreshControl
//    @objc func refresh(_ refreshControl: UIRefreshControl) {
//        getAllConversations()
//    }
//
//    @objc func appMovedToBackground() {
//        checkNetworkConnection()
//        saveConversationsInCache()
//    }
//
//    @objc func appMovedToForground() {
//        checkNetworkConnection()
//    }
//
//    @IBAction func btnClosedChatTapped(_ sender: Any) {
//        guard conversationChatType != .closeChat else {
//            return
//        }
//
//        self.openChatButton.titleLabel?.font = UIFont.regular(ofSize: 16)
//        self.closeChatButton.titleLabel?.font = UIFont.bold(ofSize: 16)
//        self.view_NewConversationBtn.isHidden = true
//        conversationChatType = .closeChat
//        animateBottomLineView()
//        self.showcloseChatData()
//    }
//
//    @IBAction func btnOpenChatTapped(_ sender: Any) {
//        guard conversationChatType != .openChat else {
//            return
//        }
//
//        self.openChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
//        self.closeChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
//        self.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
//        conversationChatType = .openChat
//        animateBottomLineView()
//        self.showOpenChatData()
//    }
//
//    @IBAction func btnNewConversationTapped(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected{
//            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
//                self.updateNewConversationBtnUI(isSelected: sender.isSelected)
//            })
//
//        }else{
//
//            var fuguNewChatAttributes = FuguNewChatAttributes(transactionId: "", userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: nil, channelName: nil, preMessage: "", groupingTag: nil)
//
//            print("bodID******* \(HippoProperty.current.newconversationBotGroupId ?? "")")
//            print("bodID*******Second")
//
//            if let botID = HippoProperty.current.newconversationBotGroupId, botID != ""{
//                fuguNewChatAttributes.botGroupId = botID
//            }
//
//            let conversation = ConversationsViewController.getWith(chatAttributes: fuguNewChatAttributes)
//            conversation.createConversationOnStart = true
//            self.navigationController?.pushViewController(conversation, animated: true)
//            self.updateNewConversationBtnUI(isSelected: sender.isSelected)
//        }
//    }
//
//    @objc func backButtonAction(){
//        saveConversationsInCache()
//        HippoConfig.shared.notifiyDeinit()
//        self.navigationController?.dismiss(animated: true, completion: nil)
//    }
//
//    @objc func headerEmptyAction(_ sender: UITapGestureRecognizer) {
//
//        guard arrayOfConversation.count == 0, tableViewDefaultText != "" else {
//            return
//        }
//
//        tableViewDefaultText = ""
//        self.showConversationsTableView.reloadData()
//        if HippoUserDetail.fuguUserID == nil {
//            putUserDetails()
//        } else {
//            getAllConversations()
//        }
//    }
//}
//
//
////Server hits
//extension ALLViewController{
//    // MARK: - SERVER HIT
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
//            if !conversationData.isEmpty{
//                self?.filterConversationArr(conversationArr: conversationData)
//            }
//
//            if self?.conversationChatType == .openChat{
//                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
//            }else if self?.conversationChatType == .closeChat{
//                self?.view_NewConversationBtn.isHidden = true
//            }else{}
//
//            if result.conversations?.count == 0 {
//                self?.closedConversationArr.removeAll()
//                self?.ongoingConversationArr.removeAll()
//                if HippoConfig.shared.theme.shouldShowBtnOnChatList == true{ self?.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//                }
//                if HippoConfig.shared.shouldOpenDefaultChannel{
//                    self?.openDefaultChannel()
//                    return
//                }
//            }
//        }
//    }
//
//    func putUserDetails() {
//        HippoUserDetail.getUserDetailsAndConversation(completion: { [weak self] (success, error) in
//            guard success else {
//                let errorMessage = error?.localizedDescription ?? HippoStrings.somethingWentWrong
//                print(errorMessage)
//
//                self?.arrayOfConversation = []
//                self?.showConversationsTableView?.reloadData()
//                return
//            }
//
//            let fetchAllConversationCacheData = self?.fetchAllConversationCache() ?? []
//            if !fetchAllConversationCacheData.isEmpty{
//                self?.filterConversationArr(conversationArr: fetchAllConversationCacheData)
//            }
//
//            self?.showConversationsTableView.reloadData()
//            if self?.conversationChatType == .openChat{
//                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
//            }else if self?.conversationChatType == .closeChat{
//                self?.view_NewConversationBtn.isHidden = true
//            }else{}
//            if let result = self?.handleIntialCustomerForm(), result {
//                return
//            } else if self?.arrayOfConversation.count == 0 {
//                if HippoConfig.shared.shouldOpenDefaultChannel{
//                    self?.openDefaultChannel()
//                    return
//                }
//
//                if self?.ongoingConversationArr.count == 0 && self?.closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{ self?.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//                }else if self?.ongoingConversationArr.count == 0 && self?.closedConversationArr.count == 0{ self?.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
//                }else{ self?.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
//                }
//            }
//        })
//
//    }
//}
//
//extension ALLViewController: UITableViewDelegate, UITableViewDataSource {
//
//    // MARK: - UITableViewDataSource
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrayOfConversation.count
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCellCustom", for: indexPath) as? ConversationView else {
//            return UITableViewCell()
//        }
//
//
//        let convObj = arrayOfConversation[indexPath.row]
//        cell.configureConversationCell(resetProperties: true, conersationObj: convObj)
//        return cell
//    }
//
//    // MARK: - UITableViewDelegate
//    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
//        cell.selectionView?.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1)
//        cell.bgView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
//    }
//
//    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
//        cell.selectionView?.backgroundColor = .white
//        cell.bgView.backgroundColor = .white
//    }
//
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UIView.tableAutoDimensionHeight
//    }
//
//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 30
//    }
//
////    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
////
////        tableView.isScrollEnabled = true
////        guard arrayOfConversation.count > 0 else {
////            tableView.isScrollEnabled = false
////            return tableView.frame.height
////        }
////
////        return 0
////    }
////
////    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
////        let footerView = UIView()
////        footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: tableView.frame.size.height)
////
////        let footerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: (tableView.frame.height / 2) - 90, width: tableView.frame.width, height: 90))
////        footerLabel.textAlignment = NSTextAlignment.center
////        footerLabel.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
////        footerLabel.numberOfLines = 0
////        footerLabel.font = UIFont.regular(ofSize: 16.0)
////
////        footerLabel.text = tableViewDefaultText
////
////        footerView.addSubview(footerLabel)
////
////        let emptyAction = UITapGestureRecognizer(target: self, action: #selector(headerEmptyAction(_:)))
////        footerView.addGestureRecognizer(emptyAction)
////
////        return footerView
////    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        tableView.isUserInteractionEnabled = false
//        fuguDelay(1) {
//            tableView.isUserInteractionEnabled = true
//        }
//
//        let conversationObj = arrayOfConversation[indexPath.row]
//        let fullconversationObj = arrayOfFullConversation.filter{$0.channelId == arrayOfConversation[indexPath.row].channelId}
//        moveToChatViewController(chatObj: conversationObj)
//        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
//            resetPushCount()
//            conversationObj.unreadCount = 0
//            fullconversationObj.first?.unreadCount = 0
//            saveConversationsInCache()
//            pushTotalUnreadCount()
//            showConversationsTableView.reloadRows(at: [indexPath], with: .none)
//        }
//    }
//
//}
//
//extension ALLViewController: HippoDataCollectorControllerDelegate {
//    func userUpdated() {
//        fuguDelay(0.4) {
//            self.putUserDetails()
//        }
//    }
//}
//
//extension ALLViewController: NewChatSentDelegate{
//    func updateConversationWith(conversationObj: FuguConversation) {
//
//        var chatObj: FuguConversation?
//
//        for rawChat in arrayOfConversation {
//            guard let channelId = rawChat.channelId,
//                  channelId > 0 else {
//                      continue
//                  }
//            if conversationObj.channelId == channelId {
//                chatObj = rawChat
//                break
//            }
//        }
//
//        chatObj?.unreadCount = conversationObj.unreadCount
//        chatObj?.lastMessage = conversationObj.lastMessage
//
//        let obj = arrayOfFullConversation.filter{$0.channelId == conversationObj.channelId}.first
//        obj?.unreadCount = 0
//        resetPushCount()
//        saveConversationsInCache()
//        pushTotalUnreadCount()
//
//        guard isViewLoaded else {
//            return
//        }
//        showConversationsTableView.reloadData()
//    }
//}
