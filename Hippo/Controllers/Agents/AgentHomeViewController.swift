//
//  AgentHomeViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit
import NotificationCenter

class AgentHomeViewController: HippoHomeViewController {
    
    //MARK: Varibles
    fileprivate var conversationList = [AgentConversation]()
    fileprivate var conversationType: ConversationType = .myChat
    var refreshControl = UIRefreshControl()
    fileprivate var isMoreToLoad = false
    fileprivate var allowPagination = true
    
    //MARK: Outlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var height_ErrorLabel : NSLayoutConstraint!
    @IBOutlet weak var paginationActivityLoader: UIActivityIndicatorView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var broadCastButton: UIButton!
    @IBOutlet weak var myChatButton: UIButton!
    @IBOutlet weak var allChatButton: UIButton!
    @IBOutlet weak var p2pChatButton : UIButton!
    @IBOutlet weak var supportChatButton : UIButton!
    @IBOutlet weak var tabScrollView: UIScrollView!
    @IBOutlet weak var tabStackView: UIStackView!
    @IBOutlet weak var buttonContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var agentStatus: UISwitch!
    @IBOutlet weak var loaderContainer: UIView!
    @IBOutlet weak var noChatsFoundImageView: So_UIImageView!
    @IBOutlet weak var centerErrorButton: UIButton!
    @IBOutlet weak var loaderImage: So_UIImageView!
//    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var view_NavigationBar : NavigationBar!
    @IBOutlet weak var width_bottomLineView : NSLayoutConstraint!
    
    /// Tabs currently on screen, in display order. Drives the tab bar layout,
    /// the underline geometry and which stores are fetched.
    private var visibleTabs: [ConversationType] = []
    /// Tabs whose first page has already been requested this session.
    private var fetchedTabs: Set<ConversationType> = []
    /// Guards the underline re-layout in viewDidLayoutSubviews against re-entry.
    private var lastLaidOutTabWidth: CGFloat = 0
    
    private func button(for tab: ConversationType) -> UIButton? {
        switch tab {
        case .myChat:
            return myChatButton
        case .allChat:
            return allChatButton
        case .p2pChat:
            return p2pChatButton
        case .supportChat:
            return supportChatButton
        case .historyChat:
            return nil
        }
    }
    
    private func title(for tab: ConversationType) -> String {
        switch tab {
        case .myChat:
            return HippoConfig.shared.theme.myChatBtnText ?? HippoStrings.myChats
        case .allChat:
            return HippoConfig.shared.theme.allChatBtnText ?? HippoStrings.allChats
        case .p2pChat:
            return HippoConfig.shared.theme.p2pChatBtnText ?? HippoStrings.p2pChats
        case .supportChat:
            return HippoConfig.shared.theme.supportChatBtnText ?? HippoStrings.supportChats
        case .historyChat:
            return ""
        }
    }
    
    //MARK: ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addObservers()
        setUpView()
        setAgentStatusForToggle()
        ConversationStore.shared.fetchAllCachedConversation()
        setData()
        if HippoConfig.shared.agentDetail?.id == -1 || HippoConfig.shared.agentDetail?.id == nil{
            HippoChecker.checkForAgentIntialization { (success, error) in
                guard success else {
                    return
                }
                AgentConversationManager.getAllData()
            }
        }else{
            AgentConversationManager.getAllData()
        }
        Business.shared.restoreAllSavedInfo()
        setUpButtonContainerView()
        openAlertIfNotificationsNotAllowed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let selected = button(for: conversationType), !selected.isHidden else {
            return
        }
        // Only act when the geometry actually changed, otherwise the constraint
        // update would retrigger layout indefinitely.
        guard selected.frame.size.width != lastLaidOutTabWidth || bottomViewLeadingConstraint.constant != selected.frame.origin.x else {
            return
        }
        lastLaidOutTabWidth = selected.frame.size.width
        bottomViewLeadingConstraint.constant = selected.frame.origin.x
        width_bottomLineView.constant = selected.frame.size.width
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = false
        reloadrefreshData(refreshCtrler: UIRefreshControl())
    }
    
    func setDataForViewDidAppear(){
        AgentConversationManager.getAllData()
        Business.shared.restoreAllSavedInfo()
        setFilterButtonIcon()
    }
    
    //MARK: Actions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        saveConversationsInCache()
        resetPushCount()
        pushTotalUnreadCount()
        HippoConfig.shared.notifiyDeinit()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func agentStatusToggle(_ sender: Any) {
        agentStatusChanged()
    }

    @IBAction func myChatButtonClicked(_ sender: UIButton) {
        selectTab(.myChat)
    }
    
    @IBAction func p2pChatButtonClicked(_ sender: Any) {
        selectTab(.p2pChat)
    }
    
    @IBAction func supportChatButtonClicked(_ sender: Any) {
        selectTab(.supportChat)
    }
    
    /// Single entry point for switching tabs — keeps title styling, the underline,
    /// the filter button and the lazy fetch in one place instead of one copy per tab.
    func selectTab(_ tab: ConversationType) {
        guard conversationType != tab else {
            return
        }
        reloadrefreshData(refreshCtrler: UIRefreshControl())
        conversationType = tab
        updateTabTitleStyles()
        updateFilterButtonVisibility()
        animateBottomLineView()
        fetchInitialDataIfRequired(for: tab)
        setData()
        tableView.reloadData()
    }
    
    private func updateTabTitleStyles() {
        for tab in visibleTabs {
            button(for: tab)?.titleLabel?.font = tab == conversationType ? UIFont.bold(ofSize: 15) : UIFont.regular(ofSize: 15)
        }
    }
    
    private func updateFilterButtonVisibility() {
        // Every tab has a filter; support chats use their own filter screen.
        view_NavigationBar.rightButton.isHidden = false
    }
    
    /// P2P and Support are not prefetched by getAllData(), so pull their first
    /// page the first time the agent opens that tab.
    private func fetchInitialDataIfRequired(for tab: ConversationType) {
        guard !fetchedTabs.contains(tab) else {
            return
        }
        switch tab {
        case .p2pChat:
            fetchedTabs.insert(tab)
            AgentConversationManager.getP2PChats { [weak self] in
                DispatchQueue.main.async {
                    guard self?.conversationType == .p2pChat else { return }
                    self?.setData()
                    self?.tableView.reloadData()
                }
            }
        case .supportChat:
            fetchedTabs.insert(tab)
            AgentConversationManager.getSupportChats { [weak self] in
                DispatchQueue.main.async {
                    guard self?.conversationType == .supportChat else { return }
                    self?.setData()
                    self?.tableView.reloadData()
                }
            }
        case .myChat, .allChat, .historyChat:
            break
        }
    }
    
    @IBAction func broadcastButtonClicked(_ sender: UIButton) {
        guard let vc = BroadCastViewController.get() else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func allChatButtonClicked(_ sender: Any) {
        selectTab(.allChat)
    }
    
    
    @IBAction func filterBtnAction(_ sender: Any) {
//        let navVC = FilterViewController.getFilterStoryboardRoot()
//        self.present(navVC, animated: true, completion: nil)
        
        // Support chats have their own filter model (HippoConfig.supportChatFilter),
        // so they get their own filter screen rather than FilterViewController.
        if conversationType == .supportChat {
            presentSupportChatFilter()
            return
        }
        
        if let vc = FilterViewController.getNewInstance(){
            vc.filterScreenButtonsDelegate = self
            vc.currentSelectedConvoType = self.conversationType
            vc.homeController = self
            let navVC = UINavigationController(rootViewController: vc)
//        navVC.setupCustomThemeOnNavigationController(hideNavigationBar: false)
//            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    private func presentSupportChatFilter() {
        guard let vc = SupportChatFilterViewController.getNewInstance() else {
            return
        }
        vc.filterApplied = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                ConversationStore.shared.supportChats.removeAll()
                AgentConversationManager.getSupportChats {
                    DispatchQueue.main.async {
                        guard self.conversationType == .supportChat else { return }
                        self.setData()
                        self.tableView.reloadData()
                    }
                }
                self.setFilterButtonIcon()
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        HippoConfig.shared.log.debug("-------\nERROR\nDeinit AgentHome\n--------", level: .info)
    }
    
    //Class methods
    class func get() -> UINavigationController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguAgentNavigationController") as? UINavigationController else {
            return nil
        }
        return navigationController
    }
    class func getController() -> UIViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AgentHomeViewController") as? AgentHomeViewController
        return vc
    }
    //MARK: Override functions
    override func didSetUserChannel() {
        super.didSetUserChannel()
        AgentUserChannel.shared?.delegate = self
    }
    
    override func deleteConversation(channelId: Int) {
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelId)
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelId)
        
        if myChatIndex != nil {
            ConversationStore.shared.myChats.remove(at: myChatIndex!)
        }
        if allChatIndex != nil {
            ConversationStore.shared.allChats.remove(at: allChatIndex!)
        }
        setData()
        tableView.reloadData()
    }
}

//MARK: Methods
extension AgentHomeViewController {

    func agentStatusChanged() {
//        AgentConversationManager.agentStatusUpdate(newStatus: self.agentStatus.isOn ? AgentStatus.available : AgentStatus.away) {[weak self] (success) in
    AgentConversationManager.agentStatusUpdate(newStatus: view_NavigationBar.rightSwitchButton.isOn ? AgentStatus.available : AgentStatus.away) {[weak self] (success) in
            guard success, let _ = self else {
                return
            }
        AgentConversationManager.getAgentsList(showLoader: false) { _ in
            }
        }
    }
    
    func setData() {
        guard conversationType != .historyChat else {
            return
        }
        conversationList = ConversationStore.shared.conversations(for: conversationType)
//        setAgentStatus()
        
        updatePaginationData()
        showLoaderIfRequired()
    }

//    func setAgentStatus() {
//        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
//            return
//        }
//        //self.agentStatus.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//        //self.agentStatus.contentHorizontalAlignment = .center
//        self.agentStatus.isOn = agent.status == .available ? true : false
//    }

    func setUpButtonContainerView(){
        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            return
        }
        
        // Which tabs the agent is allowed to see. All Chats is the only one the
        // backend can currently switch off (hide_all_chat_tab, admins excepted).
        let hideAllChat = agent.agentUserType != .admin && (BussinessProperty.current.hideAllChat ?? false)
        visibleTabs = [.myChat, .allChat, .p2pChat, .supportChat].filter { tab in
            tab != .allChat || !hideAllChat
        }
        
        for tab in [ConversationType.myChat, .allChat, .p2pChat, .supportChat] {
            guard let button = self.button(for: tab) else { continue }
            let isVisible = visibleTabs.contains(tab)
            button.isHidden = !isVisible
            button.setTitle(title(for: tab), for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: tabHorizontalPadding, bottom: 0, right: tabHorizontalPadding)
        }
        
        let hasTabs = !visibleTabs.isEmpty
        buttonContainerViewHeightConstraint.constant = hasTabs ? 50 : 0
        bottomLineView.isHidden = !hasTabs
        
        // If the selected tab got hidden, fall back to the first visible one.
        if hasTabs, !visibleTabs.contains(conversationType) {
            conversationType = visibleTabs[0]
            setData()
            tableView.reloadData()
        }
        
        updateTabTitleStyles()
        layoutTabBar()
    }
    
    private var tabHorizontalPadding: CGFloat { return 16 }
    
    /// Tabs size to their titles and scroll horizontally when they overflow. When
    /// they all fit, spread them across the full width so they don't bunch left.
    private func layoutTabBar() {
        guard !visibleTabs.isEmpty else {
            width_bottomLineView.constant = 0
            return
        }
        
        tabStackView.layoutIfNeeded()
        let intrinsicWidth = visibleTabs.reduce(CGFloat(0)) { total, tab in
            guard let button = self.button(for: tab) else { return total }
            let titleWidth = button.titleLabel?.intrinsicContentSize.width ?? 0
            return total + titleWidth + (tabHorizontalPadding * 2)
        }
        
        let fitsOnScreen = intrinsicWidth <= view.frame.size.width
        tabStackView.distribution = fitsOnScreen ? .fillEqually : .fill
        tabScrollView.isScrollEnabled = !fitsOnScreen
        tabScrollView.showsHorizontalScrollIndicator = false
        
        // The underline is positioned from real button frames once autolayout has
        // run — see viewDidLayoutSubviews().
        view.setNeedsLayout()
    }
    
    func checkForAnyError() {
        guard !AgentConversationManager.isConversationApiOnGoing() else {
            return
        }
        var message = ""
        var enableButton = false
        if  HippoConfig.shared.agentDetail == nil || HippoConfig.shared.agentDetail!.oAuthToken.isEmpty {
           // message = "Auth token is not found or found Empty"
        } else if !AgentConversationManager.isAnyApiOnGoing() && conversationList.isEmpty {
            message =  HippoStrings.noConversationFound//"No chat found for your business."
            enableButton = true
        }
        
        if let _ = AgentConversationManager.errorMessage {
            //message = error
            enableButton = true
        }
        guard !message.isEmpty, conversationList.isEmpty, !AgentConversationManager.isAnyApiOnGoing() else {
            buttonContainerView.isHidden = false
            centerErrorButton.isHidden = true
            noChatsFoundImageView.isHidden = true
            return
        }
        loaderImage.isHidden = true
        loaderContainer.isHidden = true
        centerErrorButton.isHidden = false
        noChatsFoundImageView.isHidden = false
        centerErrorButton.setTitle(message, for: .normal)
        centerErrorButton.isEnabled = enableButton
    }
    

    func animateBottomLineView(animated: Bool = true) {
        guard let selected = button(for: conversationType), !selected.isHidden else {
            return
        }
        
        // Underline tracks the selected button's real frame, so tabs are free to
        // differ in width.
        bottomViewLeadingConstraint.constant = selected.frame.origin.x
        width_bottomLineView.constant = selected.frame.size.width
        
        let updates = { self.buttonContainerView.layoutIfNeeded() }
        if animated {
            UIView.animate(withDuration: 0.4, animations: updates)
        } else {
            updates()
        }
        
        // Pull a partially-visible tab into view.
        if tabScrollView.isScrollEnabled {
            tabScrollView.scrollRectToVisible(selected.frame, animated: animated)
        }
    }
        
        
        @objc func appMovedToBackground() {
            saveConversationsInCache()
        }
        
        @objc func appMovedToForground() {
            checkNetworkConnection()
        }
        
        func saveConversationsInCache() {
            ConversationStore.shared.storeConversationToCache()
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
        
        func updateErrorLabelView(isHiding: Bool) {
            if isHiding{
                UIView.animate(withDuration: 0.2) {
                    self.height_ErrorLabel.constant = 0
                    self.errorView.layoutIfNeeded()
                }
                errorLabel.text = ""
            }else{
                UIView.animate(withDuration: 0.2) {
                    self.height_ErrorLabel.constant = 20
                    self.errorView.layoutIfNeeded()
                }
            }
        }
        
        func setUpView() {
            setupRefreshController()
            
            //        self.navigationController?.setTheme()
            //
            //        self.navigationItem.title = HippoConfig.shared.theme.headerText
            //        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
            //
            //        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            //        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            //            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
            //            if HippoConfig.shared.theme.leftBarButtonFont != nil {
            //                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            //            }
            //            backButton.setTitleColor(HippoConfig.shared.theme.leftBarButtonTextColor, for: .normal)
            //        } else {
            //            if HippoConfig.shared.theme.leftBarButtonImage != nil {
            //                backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
            //                backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            //            }
            //        }
            //
            ////        backButton.setTitle((" " + "trea"), for: .normal)
            ////        if HippoConfig.shared.theme.leftBarButtonFont != nil {
            ////            backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            ////        }
            ////        backButton.setTitleColor(.black, for: .normal)
            ////        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            ////            backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
            ////            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            ////        }
            //
            //        //Configuring FilterButton
            //        filterButton.setTitle("", for: .normal)
            //        filterButton.tintColor = HippoConfig.shared.theme.headerTextColor
            //        if HippoConfig.shared.theme.filterBarButtonText.count > 0 {
            //            filterButton.setTitle((" " + HippoConfig.shared.theme.filterBarButtonText), for: .normal)
            //            if HippoConfig.shared.theme.filterBarButtonFont != nil {
            //                filterButton.titleLabel?.font = HippoConfig.shared.theme.filterBarButtonFont
            //            }
            //            filterButton.setTitleColor(HippoConfig.shared.theme.filterBarButtonTextColor, for: .normal)
            //        } else {
            //            if HippoConfig.shared.theme.filterBarButtonImage != nil {
            //                filterButton.setImage(HippoConfig.shared.theme.filterBarButtonImage, for: .normal)
            //                filterButton.tintColor = HippoConfig.shared.theme.headerTextColor
            //            }
            //        }
            //
            //        //Configuring BroadcastButton
            //        broadCastButton.setTitle("", for: .normal)
            //        broadCastButton.tintColor = HippoConfig.shared.theme.headerTextColor
            //        if HippoConfig.shared.theme.broadcastBarButtonText.count > 0 {
            //            broadCastButton.setTitle((" " + HippoConfig.shared.theme.broadcastBarButtonText), for: .normal)
            //            if HippoConfig.shared.theme.broadcastBarButtonFont != nil {
            //                broadCastButton.titleLabel?.font = HippoConfig.shared.theme.homeBarButtonFont
            //            }
            //            broadCastButton.setTitleColor(HippoConfig.shared.theme.broadcastBarButtonTextColor, for: .normal)
            //        } else {
            //            if HippoConfig.shared.theme.broadcastBarButtonImage != nil {
            //                broadCastButton.setImage(HippoConfig.shared.theme.broadcastBarButtonImage, for: .normal)
            //                broadCastButton.tintColor = HippoConfig.shared.theme.headerTextColor
            //            }
            //        }
            //        broadCastButton.isHidden = !HippoConfig.shared.isBroadcastEnabled
            
            self.myChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
            self.allChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
            self.myChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
            self.allChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
            self.myChatButton.setTitle(HippoConfig.shared.theme.myChatBtnText == nil ? HippoStrings.myChats : HippoConfig.shared.theme.myChatBtnText, for: .normal)
            self.allChatButton.setTitle(HippoConfig.shared.theme.allChatBtnText == nil ? HippoStrings.allChats : HippoConfig.shared.theme.allChatBtnText, for: .normal)
            self.bottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
            self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
            view_NavigationBar.title = HippoConfig.shared.theme.headerText
            view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
            //Configuring FilterButton
            view_NavigationBar.rightButton.setTitle("", for: .normal)
            view_NavigationBar.rightButton.tintColor = HippoConfig.shared.theme.headerTextColor
            if HippoConfig.shared.theme.filterBarButtonText.count > 0 {
                view_NavigationBar.rightButton.setTitle((" " + HippoConfig.shared.theme.filterBarButtonText), for: .normal)
                if HippoConfig.shared.theme.filterBarButtonFont != nil {
                    view_NavigationBar.rightButton.titleLabel?.font = UIFont.regular(ofSize: 14)//HippoConfig.shared.theme.filterBarButtonFont
                }
                view_NavigationBar.rightButton.setTitleColor(HippoConfig.shared.theme.filterBarButtonTextColor, for: .normal)
            } else {
                setFilterButtonIcon()
            }
            view_NavigationBar.rightButton.addTarget(self, action: #selector(filterBtnAction(_:)), for: .touchUpInside)
            //Configuring SwitchButton
            view_NavigationBar.rightSwitchButtonContainerView.isHidden = false
            view_NavigationBar.rightSwitchButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            view_NavigationBar.rightSwitchButton.contentHorizontalAlignment = .center
            view_NavigationBar.rightSwitchButton.addTarget(self, action: #selector(agentStatusToggle(_:)), for: .touchUpInside)
            
        }
        internal func setupRefreshController() {
            refreshControl.backgroundColor = .clear
            //        refreshControl.tintColor = .themeColor
            if HippoConfig.shared.theme.themeColor == UIColor.white || HippoConfig.shared.theme.themeColor == UIColor.clear{
                refreshControl.tintColor = HippoConfig.shared.theme.themeTextcolor
            }else{
                refreshControl.tintColor = .themeColor
            }
            tableView.backgroundView = refreshControl
            refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
        }
        @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
            if (AgentConversationManager.isAllChatInProgress && conversationType == .allChat) ||  (AgentConversationManager.isMyChatInProgress && conversationType == .myChat) || (AgentConversationManager.isp2pChatInProgress && conversationType == .p2pChat) || (AgentConversationManager.isSupportChatInProgress && conversationType == .supportChat){
                refreshControl.endRefreshing()
                return
            }
            let type = GetConversationRequestParam.RequestType(conversationType: conversationType)
            let request = GetConversationRequestParam.init(pageStart: 1, pageEnd: nil, showLoader: false, type: type, identifier: String.generateUniqueId())
            AgentConversationManager.getConversations(with: request) {[weak self] (result) in
                self?.refreshControl.endRefreshing()
                self?.setData()
                self?.tableView.reloadData()
            }
        }
        
        func addObservers() {
            NotificationCenter.default.removeObserver(self)
            #if swift(>=4.2)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForground), name: UIApplication.willEnterForegroundNotification, object: nil)
            #else
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            #endif
            
            NotificationCenter.default.addObserver(self, selector: #selector(allChatDataUpdated), name: .allChatDataUpdated, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(myChatDataUpated), name: .myChatDataUpdated, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: .allAndMyChatDataUpdated, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(loginDataUpdated), name: .agentLoginDataUpated, object: nil)
        }
        
        //    @objc func loginDataUpdated() {
        //        self.tableView.reloadData()
        //    }
        @objc func loginDataUpdated() {
            self.setAgentStatusForToggle()
            self.tableView.reloadData()
        }
        
        @objc func reloadCollectionView() {
            setData()
            self.tableView.reloadData()
        }
        @objc func allChatDataUpdated() {
            setData()
            
            self.tableView.reloadData()
        }
        @objc func myChatDataUpated() {
            setData()
            
            self.tableView.reloadData()
        }
        
        func setAgentStatusForToggle(){
            if BussinessProperty.current.agentStatusForToggle == AgentStatus.available.rawValue {
                //            self.agentStatus.isOn = true
                view_NavigationBar.rightSwitchButton.isOn = true
            }else{
                //            self.agentStatus.isOn = false
                view_NavigationBar.rightSwitchButton.isOn = false
            }
        }
        
        func setFilterButtonIcon(){
            if BussinessProperty.current.isFilterApplied == true {
                if HippoConfig.shared.theme.filterSelectedBarButtonImage != nil {                view_NavigationBar.rightButton.setImage(HippoConfig.shared.theme.filterSelectedBarButtonImage, for: .normal)
                    view_NavigationBar.rightButton.tintColor = HippoConfig.shared.theme.headerTextColor
                }
            }else{
                if HippoConfig.shared.theme.filterUnselectedBarButtonImage != nil {                view_NavigationBar.rightButton.setImage(HippoConfig.shared.theme.filterUnselectedBarButtonImage, for: .normal)
                    view_NavigationBar.rightButton.tintColor = HippoConfig.shared.theme.headerTextColor
                }
            }
        }
        
        func showLoaderIfRequired() {
            guard (!AgentConversationManager.isAllChatInProgress && conversationType == .allChat) || (!AgentConversationManager.isMyChatInProgress && conversationType == .myChat) else {
                stopLoading()
                checkForAnyError()
                return
            }
            guard conversationList.isEmpty else {
                stopLoading()
                checkForAnyError()
                return
            }
            stopLoading()
            checkForAnyError()
        }
        func startLoading() {
            
            guard loaderContainer.isHidden else {
                return
            }
            loaderContainer.isHidden = false
            loaderContainer.alpha = 0
            centerErrorButton.isHidden = true
            noChatsFoundImageView.isHidden = true
            loaderImage.isHidden = false
            loaderImage.startRotationAnimation()
            UIView.animate(withDuration: 0.3) {
                self.loaderContainer.alpha = 1
            }
        }
        
        func stopLoading() {
            loaderContainer.alpha = 1
            loaderImage.stopAnimating()
            
            UIView.animate(withDuration: 0.3) {
                self.loaderContainer.alpha = 0
            }
            loaderImage.isHidden = true
            loaderContainer.isHidden = true
            centerErrorButton.isHidden = true
            noChatsFoundImageView.isHidden = true
        }
        
    }


extension AgentHomeViewController: UIScrollViewDelegate {
    func updatePaginationData() {
        guard self.conversationType != .historyChat else {
            return
        }
        self.isMoreToLoad = ConversationStore.shared.isMoreToLoad(for: self.conversationType)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (AgentConversationManager.isAllChatInProgress && conversationType == .allChat) ||  (AgentConversationManager.isMyChatInProgress && conversationType == .myChat) {
            return
        }
        
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        
        let currentBottom = scrollView.contentOffset.y + tableView.frame.height
        let maxBottom = scrollView.contentSize.height - 30
        
        
        guard currentBottom > maxBottom else {
            return
        }
        guard isMoreToLoad, allowPagination else {
            return
        }
        allowPagination = false
        isMoreToLoad = false
        startLoadingMore()
        callApi()
    }
    
    
    func callApi(){
        let count = conversationList.count + 1
        let type = GetConversationRequestParam.RequestType(conversationType: conversationType)
        
        let request = GetConversationRequestParam(pageStart: count, pageEnd: nil, showLoader: false, type: type, identifier: String.generateUniqueId())
        
        AgentConversationManager.getConversations(with: request) {[weak self] (result) in
            guard self != nil else {
                return
            }
            self?.stopLoadingMore()
            self?.setData()
            self?.tableView.reloadData()
            self?.allowPagination = true
        }
    }
    
    
    func startLoadingMore() {
        paginationActivityLoader.startAnimating()
    }
    
    func stopLoadingMore() {
        paginationActivityLoader.stopAnimating()
    }
}

//MARK: TableView DataSource and delegate
extension AgentHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AgentHomeConversationCell", for: indexPath) as? AgentHomeConversationCell else {
            return UITableViewCell()
        }
        cell.setupCell(cellInfo: conversationList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (conversationList[indexPath.row].unreadCount ?? 0) > 0{
            removeChannelForUnreadCount(conversationList[indexPath.row].channel_id ?? -1)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        fuguDelay(1) {
            tableView.isUserInteractionEnabled = true
        }
        let conversationObj = conversationList[indexPath.row]
        moveToConversationWith(conversationObj)
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            resetPushCount()
            conversationObj.unreadCount = 0
            pushTotalUnreadCount()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if conversationList[indexPath.row].status == 1{
           return true
        }else{
           return false
        }
        
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let status = conversationList[indexPath.row].status, status == 1 else {
            return nil
        }
        let closeAction = UIContextualAction(style: .destructive, title: HippoStrings.closeChat) { [weak self] _, _, done in
            self?.showOptionAlert(title: "", message: HippoStrings.closeChatPopup, preferredStyle: .alert, successButtonName: HippoStrings.yes, successComplete: { _ in
                self?.updateChannelStatus(for: indexPath.row)
            }, failureButtonName: HippoStrings.no.capitalized, failureComplete: nil)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [closeAction])
    }

    func updateChannelStatus(for row: Int) {
        if let channelId = conversationList[row].channel_id, let status = conversationList[row].status {
            let newStatus = status == 1 ? 2 : 1
            self.startLoading()
            AgentConversationManager.updateChannelStatus(for: channelId, newStatus: newStatus) { (result) in
                guard result.isSuccessful else {
                    self.stopLoading()
                    showAlertWith(message: HippoStrings.somethingWentWrong, action: nil)
                    return
                }
                guard let controllers = self.navigationController?.viewControllers else {
                    self.stopLoading()
                    return
                }
                for each in controllers {
                    if let _ = each as? HippoHomeViewController {
//                        vc.channelStatusChanged(channelId: channelId, newStatus: ChatStatus(rawValue: newStatus) ?? ChatStatus.open)
                        self.stopLoading()
                        self.deleteConversation(channelId: channelId)
                        break
                    }
                    self.stopLoading()
                    if let vc = each as? AgentDirectViewController, vc.conversationList.count > 1 {
                        break
                    }
                }
            }
        }

    }
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "AgentHomeConversationCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AgentHomeConversationCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension AgentHomeViewController: AgentHomeCollectionViewCellDelegate {
    func placholderButtonClicked() {
        AgentConversationManager.updateAgentChannel { (error,response)  in
            
        }
    }
    
    func moveToConversationWith(_ conversationObject: AgentConversation) {
        let vc = AgentConversationViewController.getWith(conversationObj: conversationObject)
        vc.agentConversationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func moveToConversationWith(_ conversationData: SearchCustomerData){
        let vc = AgentConversationViewController.getWith(conversationObj: conversationData)
        vc.agentConversationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AgentHomeViewController: AgentChatDeleagate {
    func updateConversationWith(channelId: Int, lastMessage: HippoMessage, unreadCount: Int) {
        guard channelId > 0 else {
            return
        }
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelId)
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelId)
        let p2pChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.p2pChats, for: channelId)
        let supportChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.supportChats, for: channelId)
        
        if allChatIndex != nil {
            let chatObj = ConversationStore.shared.allChats[allChatIndex!]
            chatObj.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
        }
        
        if myChatIndex != nil {
            let chatObj = ConversationStore.shared.myChats[myChatIndex!]
            chatObj.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
        }
        
        if let index = p2pChatIndex, index < ConversationStore.shared.p2pChats.count{
            let chatObj = ConversationStore.shared.p2pChats[index]
            chatObj.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
        }
        
        if let index = supportChatIndex, index < ConversationStore.shared.supportChats.count{
            let chatObj = ConversationStore.shared.supportChats[index]
            chatObj.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
        }
        
//        setData()
//        tableView.reloadData()
    }
    
    func newChatStartedDelgegate(isChatUpdated: Bool) {
       
    }
}

extension AgentHomeViewController: AgentUserChannelDelegate {
    func readAllNotificationFor(channelID: Int) {
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelID)
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelID)
        
        if myChatIndex != nil {
            ConversationStore.shared.myChats[myChatIndex!].unreadCount = 0
        }
        
        if allChatIndex != nil {
            ConversationStore.shared.allChats[allChatIndex!].unreadCount = 0
        }
        setData()
        self.tableView.reloadData()
    }
    
    
    func handleAssignmentNotification(with conversation: AgentConversation, channelID: Int) {
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelID)
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelID)
        
        let isAssignedToMe = AgentConversation.isAssignedToMe(for: conversation)
        
        //Handling case for my chats
        if myChatIndex != nil, !isAssignedToMe {
            ConversationStore.shared.myChats.remove(at: myChatIndex!)
        } else if  myChatIndex != nil, isAssignedToMe {
             let existingConversation = ConversationStore.shared.myChats[myChatIndex!]
             existingConversation.update(newConversation: conversation)
            
            if let index = myChatIndex, index > 0 {
                ConversationStore.shared.myChats.remove(at: index)
                ConversationStore.shared.myChats.insert(existingConversation, at: 0)
            }
            
        } else if myChatIndex == nil, isAssignedToMe {
            conversation.update(newConversation: conversation)
            ConversationStore.shared.myChats.insert(conversation, at: 0)
        }
        
        
        
        //Handling case for all cahts
        if allChatIndex == nil {
            conversation.update(newConversation: conversation)
            ConversationStore.shared.allChats.insert(conversation, at: 0)
        } else {
            let existingConversation = ConversationStore.shared.allChats[allChatIndex!]
            existingConversation.update(newConversation: conversation)
            
            if let index = allChatIndex, index > 0 {
                ConversationStore.shared.allChats.remove(at: index)
                ConversationStore.shared.allChats.insert(existingConversation, at: 0)
            }
        }
        setData()
        self.tableView.reloadData()
    }
    
    func insertNewConversation(with newConversation: AgentConversation) {
        handleMyChatInsertion(with: newConversation)
        handleALLChatInsertion(with: newConversation)
    }
    
    func handleMyChatInsertion(with newConversation: AgentConversation) {
        guard newConversation.agent_id == nil || newConversation.agent_id == 0 || newConversation.agent_id == -1 || newConversation.agent_id == currentUserId() || newConversation.isMyChat == true else {
            return
        }
        
        //newConversation.unreadCount = 1
        
        ConversationStore.shared.myChats.insert(newConversation, at: 0)
        
        if conversationType == .myChat {
            setData()
            tableView.reloadData()
        }
    }
    func handleALLChatInsertion(with newConversation: AgentConversation) {
        //newConversation.unreadCount = 1
        ConversationStore.shared.allChats.insert(newConversation, at: 0)
        
        if conversationType == .allChat {
            setData()
            tableView.reloadData()
        }
    }
    
    func channelRefresh(chatDetail : ChatDetail, _ channelId : Int){
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelId)
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelId)
        guard myChatIndex != nil || allChatIndex != nil else {
            return
        }
        if let mychatIndex = myChatIndex, mychatIndex < ConversationStore.shared.myChats.count{
            ConversationStore.shared.myChats[mychatIndex].isBotInProgress = chatDetail.isBotInProgress
        }
        if let allChatIndex = allChatIndex, allChatIndex < ConversationStore.shared.allChats.count{
            ConversationStore.shared.allChats[allChatIndex].isBotInProgress = chatDetail.isBotInProgress
        }
        setData()
        self.tableView.reloadData()
    }
    
    
    func newConversationRecieved(_ newConversation: AgentConversation, channelID: Int) {
        if AgentConversation.isAssignmentNotification(for: newConversation) {
            if newConversation.chatType == .p2p || newConversation.channel_type == channelType.SUPPORT_CHAT_CHANNEL.rawValue{
                return
            }
            handleAssignmentNotification(with: newConversation, channelID: channelID)
            return
        }
        
        if newConversation.channel_type == channelType.SUPPORT_CHAT_CHANNEL.rawValue {
            handleInsertion(of: newConversation, channelID: channelID, into: .supportChat)
            return
        }
        
        if newConversation.chatType == .p2p {
            handleInsertion(of: newConversation, channelID: channelID, into: .p2pChat)
            return
        }
        
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelID)
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelID)
        
        //donot append rating message after chat close if closed filter is not applied
        if newConversation.chatStatus == 2 && (FilterManager.shared.chatStatusArray.filter{$0.id == 2}.first?.isSelected == false){
            return
        }
        //
        guard myChatIndex != nil || allChatIndex != nil else {
            newConversation.unreadCount = 1
            if let vc = getLastVisibleController() as? AgentConversationViewController,let id = vc.channel?.id, id == channelID {
                newConversation.unreadCount = 0
            }else if newConversation.lastMessage?.senderId == currentUserId(){
                newConversation.unreadCount = 0
            }
            insertNewConversation(with: newConversation)
            return
        }
        
        if myChatIndex != nil {
            let conversation = ConversationStore.shared.myChats[myChatIndex!]
    
            conversation.update(newConversation: newConversation)
            
            if myChatIndex != 0 {
                ConversationStore.shared.myChats.remove(at: myChatIndex!)
                ConversationStore.shared.myChats.insert(conversation, at: 0)
                
                if conversationType == .myChat {
                    setData()
                    self.tableView.reloadData()
                }
            } else if conversation.messageUpdated == nil {
                tableView.reloadData()
            }
        } else {
            handleMyChatInsertion(with: newConversation)
        }
        
        if allChatIndex != nil {
            let conversation = ConversationStore.shared.allChats[allChatIndex!]
            conversation.update(newConversation: newConversation)
            
            if allChatIndex != 0 {
                ConversationStore.shared.allChats.remove(at: allChatIndex!)
                ConversationStore.shared.allChats.insert(conversation, at: 0)
                
                if conversationType == .allChat {
                    setData()
                    self.tableView.reloadData()
                }
            } else if conversation.messageUpdated == nil {
                tableView.reloadData()
            }
        } else {
            handleALLChatInsertion(with: newConversation)
        }
        
    }

    /// Moves an incoming conversation to the top of the store backing `tab`,
    /// inserting it if it isn't there yet.
    func handleInsertion(of newConversation: AgentConversation, channelID: Int, into tab: ConversationType) {
        let store = ConversationStore.shared
        var chats = store.conversations(for: tab)
        
        if let index = AgentConversation.getIndex(in: chats, for: channelID), index < chats.count {
            let conversation = chats[index]
            conversation.update(newConversation: newConversation)
            
            guard index != 0 else {
                if conversation.messageUpdated == nil {
                    tableView.reloadData()
                }
                return
            }
            chats.remove(at: index)
            chats.insert(conversation, at: 0)
        } else {
            chats.insert(newConversation, at: 0)
        }
        
        switch tab {
        case .p2pChat:
            store.p2pChats = chats
        case .supportChat:
            store.supportChats = chats
        case .myChat, .allChat, .historyChat:
            return
        }
        
        if conversationType == tab {
            setData()
            tableView.reloadData()
        }
    }
    
}

extension AgentHomeViewController : FilterScreenButtonsDelegate{
    func cancelButtonPressed() {
        //code
    }

    
    func resetButtonPressed() {
        self.setDataForViewDidAppear()
    }

    func applyButtonPressed() {
        startLoading()
        self.setDataForViewDidAppear()
    }
}

extension AgentHomeViewController{
    // MARK: - Show alert if user didn't provide permission for notifications
    fileprivate func openAlertForNotification() {
        self.showOptionAlert(title: "Turn on notifications", message: "This way you will be notified when anyone send you message or call instantly.\nPlease allow permission from settings app.", successButtonName: "Setings", successComplete: { action in
            if let bundle = Bundle.main.bundleIdentifier,
               let settings = URL(string: UIApplication.openSettingsURLString + bundle) {
                if UIApplication.shared.canOpenURL(settings) {
                    UIApplication.shared.open(settings)
                }
            }
        }, failureButtonName: "Cancel") { action in }
    }
    
    func openAlertIfNotificationsNotAllowed(){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized && !HippoUserDetail.NotificationNotAllowedAlert{
                // Notifications are not allowed
                fuguDelay(0.0) {
                    self.openAlertForNotification()
                    HippoUserDetail.NotificationNotAllowedAlert = true
                }
            }
        }
    }
}
