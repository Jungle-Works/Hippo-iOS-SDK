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
    
    //MARK: Screen Constants
    private let maxErrorViewHeight: CGFloat = 25
    private let minErrorViewHeight: CGFloat = 0
    private var isInitalLoad = false
    private let defaultSelectedOption = ConversationType.myChat
    fileprivate let allChatIndexPath = IndexPath(row: 1, section: 0)
    fileprivate let myChatIndexPath = IndexPath(row: 0, section: 0)
    
    let rows: [ConversationType] = [ConversationType.myChat, ConversationType.allChat]
    
    //MARK: Varibles
    fileprivate var conversationList = [AgentConversation]()
    fileprivate var conversationType: ConversationType = .myChat
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var isMoreToLoad = false
    fileprivate var allowPagination = true
    
    //MARK: Outlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var paginationActivityLoader: UIActivityIndicatorView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var broadCastButton: UIButton!
    @IBOutlet weak var myChatButton: UIButton!
    @IBOutlet weak var allChatButton: UIButton!
    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var agentStatus: UISwitch!

    @IBOutlet weak var loaderContainer: UIView!
    @IBOutlet weak var centerErrorButton: UIButton!
    @IBOutlet weak var loaderImage: So_UIImageView!
    
    
    //MARK: ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addObservers()
        setUpView()
        setData()
        
        ConversationStore.shared.fetchAllCachedConversation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isInitalLoad = false
        AgentConversationManager.getAllData()
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
        guard conversationType != .myChat else {
            return
        }
        conversationType = .myChat
        animateBottomLineView()
        setData()
        tableView.reloadData()
    }
    
    @IBAction func broadcastButtonClicked(_ sender: UIButton) {
        guard let vc = BroadCastViewController.get() else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func allChatButtonClicked(_ sender: Any) {
        guard conversationType != .allChat else {
            return
        }
        conversationType = .allChat
        animateBottomLineView()
        setData()
        tableView.reloadData()
    }


    deinit {
        print("Deinit AgentHome.....")
    }
    
    //Class methods
    class func get() -> UINavigationController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguAgentNavigationController") as? UINavigationController else {
            return nil
        }
        return navigationController
    }
    class func getController() -> UIViewController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
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
        AgentConversationManager.agentStatusUpdate(newStatus: self.agentStatus.isOn ? AgentStatus.available : AgentStatus.away)
    }
    
    func setData() {
        switch conversationType {
        case .allChat:
            conversationList = ConversationStore.shared.allChats
        case .myChat:
            conversationList = ConversationStore.shared.myChats
        }
        setAgentStatus()
        updatePaginationData()
        showLoaderIfRequired()
    }

    func setAgentStatus() {
        guard let agent = HippoConfig.shared.agentDetail, agent.id > 0 else {
            return
        }
        self.agentStatus.isOn = agent.status == .available ? true : false
    }


    
    func checkForAnyError() {
        guard !AgentConversationManager.isConversationApiOnGoing() else {
            return
        }
        var message = ""
        var enableButton = false
        if  HippoConfig.shared.agentDetail == nil || HippoConfig.shared.agentDetail!.oAuthToken.isEmpty {
            message = "Auth token is not found or found Empty"
        } else if !AgentConversationManager.isAnyApiOnGoing() && conversationList.isEmpty {
            message = "No chat found for your business."
            enableButton = true
        }
        
        if let error = AgentConversationManager.errorMessage {
            message = error
            enableButton = true
        }
        guard !message.isEmpty, conversationList.isEmpty, !AgentConversationManager.isAnyApiOnGoing() else {
            buttonContainerView.isHidden = false
            centerErrorButton.isHidden = true
            return
        }
        loaderImage.isHidden = true
        loaderContainer.isHidden = true
        centerErrorButton.isHidden = false
        centerErrorButton.setTitle(message, for: .normal)
        centerErrorButton.isEnabled = enableButton
    }
    

    func animateBottomLineView() {
        let leading = conversationType == .myChat ? 0 : myChatButton.bounds.width
        bottomViewLeadingConstraint.constant = leading
        
        UIView.animate(withDuration: 0.4) {
            self.buttonContainerView.layoutIfNeeded()
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
            hideErrorLabelView()
        } else {
            errorLabel.text = HippoConfig.shared.strings.noNetworkConnection
            showErrorLabelView()
        }
    }
    
    func hideErrorLabelView() {
        guard errorLabelTopConstraint.constant > -20 else {
            return
        }
        
        DispatchQueue.main.async {
            self.errorLabelTopConstraint.constant = -20
            UIView.animate(withDuration: 0.2) {
                self.errorView.layoutIfNeeded()
            }
        }
    }
    
    func showErrorLabelView() {
        guard errorLabelTopConstraint.constant < 0 else {
            return
        }
        
        DispatchQueue.main.async {
            self.errorLabelTopConstraint.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.errorView.layoutIfNeeded()
            }
        }
    }
    func setUpView() {
        setupRefreshController()
        
        self.navigationController?.setTheme()
        
        self.navigationItem.title = HippoConfig.shared.theme.headerText
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
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
        
        //Configuring BroadcastButton
        broadCastButton.setTitle("", for: .normal)
        broadCastButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.broadcastBarButtonText.count > 0 {
            broadCastButton.setTitle((" " + HippoConfig.shared.theme.broadcastBarButtonText), for: .normal)
            if HippoConfig.shared.theme.broadcastBarButtonFont != nil {
                broadCastButton.titleLabel?.font = HippoConfig.shared.theme.homeBarButtonFont
            }
            broadCastButton.setTitleColor(HippoConfig.shared.theme.broadcastBarButtonTextColor, for: .normal)
        } else {
            if HippoConfig.shared.theme.broadcastBarButtonImage != nil {
                broadCastButton.setImage(HippoConfig.shared.theme.broadcastBarButtonImage, for: .normal)
                broadCastButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
        broadCastButton.isHidden = !HippoConfig.shared.isBroadcastEnabled
    }
    internal func setupRefreshController() {
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .themeColor
        tableView.backgroundView = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
    }
    @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
        if (AgentConversationManager.isAllChatInProgress && conversationType == .allChat) ||  (AgentConversationManager.isMyChatInProgress && conversationType == .myChat) {
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
    
    @objc func loginDataUpdated() {
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
    
    func showLoaderIfRequired() {
        guard (!AgentConversationManager.isAllChatInProgress && conversationType == .allChat) ||  (!AgentConversationManager.isMyChatInProgress && conversationType == .myChat) else {
            stopLoading()
            checkForAnyError()
            return
        }
        guard conversationList.isEmpty else {
            stopLoading()
            checkForAnyError()
            return
        }
        startLoading()
        checkForAnyError()
    }
    func startLoading() {
        
        guard loaderContainer.isHidden else {
            return
        }
        loaderContainer.isHidden = false
        loaderContainer.alpha = 0
        centerErrorButton.isHidden = true
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
    }
    
}


extension AgentHomeViewController: UIScrollViewDelegate {
    func updatePaginationData() {
        switch self.conversationType {
        case .allChat:
            self.isMoreToLoad = ConversationStore.shared.isMoreAllChatToLoad
        case .myChat:
            self.isMoreToLoad = ConversationStore.shared.isMoreMyChatToLoad
        }
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
        print(">>>>>>>>>\(currentBottom)")
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
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "AgentHomeConversationCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AgentHomeConversationCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension AgentHomeViewController: AgentHomeCollectionViewCellDelegate {
    func placholderButtonClicked() {
        AgentConversationManager.updateAgentChannel()
    }
    
    func moveToConversationWith(_ conversationObject: AgentConversation) {
        let vc = AgentConversationViewController.getWith(conversationObj: conversationObject)
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
        
        if allChatIndex != nil {
            let chatObj = ConversationStore.shared.allChats[allChatIndex!]
            chatObj.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
        }
        
        if myChatIndex != nil {
            let chatObj = ConversationStore.shared.myChats[myChatIndex!]
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
        
        newConversation.unreadCount = newConversation.updateUnreadCountBy
        
        ConversationStore.shared.myChats.insert(newConversation, at: 0)
        
        if conversationType == .myChat {
            setData()
            tableView.reloadData()
        }
    }
    func handleALLChatInsertion(with newConversation: AgentConversation) {
        newConversation.unreadCount = newConversation.updateUnreadCountBy
        ConversationStore.shared.allChats.insert(newConversation, at: 0)
        
        if conversationType == .allChat {
            setData()
            tableView.reloadData()
        }
    }
    
    func newConversationRecieved(_ newConversation: AgentConversation, channelID: Int) {
        if AgentConversation.isAssignmentNotification(for: newConversation) {
            handleAssignmentNotification(with: newConversation, channelID: channelID)
            return
        }
        
        let myChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.myChats, for: channelID)
        let allChatIndex = AgentConversation.getIndex(in: ConversationStore.shared.allChats, for: channelID)
        
        
        
        guard myChatIndex != nil || allChatIndex != nil else {
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

}

