//
//  AgentDirectViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 27/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class AgentDirectViewController: HippoHomeViewController {
    
    //MARK: Variables
    var conversationList: [AgentConversation] = []
    var refreshControl = UIRefreshControl()
    
    //MARK: Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderImage: So_UIImageView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var navigationBar : NavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setupTableView()
        AgentConversationManager.getUserUnreadCount()
        setupRefreshController()
        addGestureToErrorLabel()
    }
    @IBAction func generalChatClicked(_ sender: Any) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let showLoader = !(conversationList.count > 0)
        checkAgentAndGetData(showLoader: showLoader)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        HippoConfig.shared.notifiyDeinit()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func homeButtonAction(_ sender: Any) {
        guard let vc = AgentHomeViewController.getController() else {
            return
        }
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    class func get() -> UINavigationController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FuguAgentDirectNavigationController") as? UINavigationController else {
            return nil
        }
        return navigationController
    }
    //MARK: Override functions
    override func didSetUserChannel() {
        super.didSetUserChannel()
        AgentUserChannel.shared?.delegate = self
    }
    override func deleteConversation(channelId: Int) {
        let myChatIndex = AgentConversation.getIndex(in: conversationList, for: channelId)
        
        if myChatIndex != nil {
            ConversationStore.shared.myChats.remove(at: myChatIndex!)
        }
        tableView.reloadData()
    }
}

extension AgentDirectViewController {
    internal func checkAgentAndGetData(showLoader: Bool = true) {
        if showLoader {
            hideError()
            startLoaderAnimation()
        }
        
        HippoChecker.checkForAgentIntialization { (success, error) in
            guard success else {
                self.showError()
                self.stopLoaderAnimation()
                return
            }
            self.getData(showLoader: showLoader)
        }
    }
    
    
    internal func getData(showLoader: Bool = true) {
        if showLoader {
            hideError()
            startLoaderAnimation()
        }
        
        AgentConversationManager.getConversationForSearchUser() {[weak self] (result) in
            self?.stopLoaderAnimation()
            self?.refreshControl.endRefreshing()
            guard result.isSuccessful, let conversation = result.conversations, self != nil else {
                self?.showError()
                self?.conversationList = []
                return
            }
            self?.hideError()
            self?.conversationList = conversation
            if conversation.isEmpty {
                self?.startDirectChat()
                return
            }
            if conversation.count == 1  {
                self?.moveToConversationWith(conversation[0], animation: false)
                return
            }
            self?.tableView.reloadData()
        }
    }
    
    internal func showError() {
        var message = ""
        
        if  HippoConfig.shared.agentDetail == nil || HippoConfig.shared.agentDetail!.oAuthToken.isEmpty {
            message = "Auth token is not found or found Empty"
        } else {
            message = "Loading chat's tap to retry."
        }
        if let error = AgentConversationManager.errorMessage {
            message = error
        }
        errorLabel.isUserInteractionEnabled = true
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    internal func addGestureToErrorLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(errorLabelClicked))
        errorLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc internal func errorLabelClicked() {
        getData()
    }
    internal func hideError() {
        errorLabel.isUserInteractionEnabled = false
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    
    internal func setUpView() {
        navigationBar.title = HippoConfig.shared.theme.directChatHeader
        navigationBar.leftButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        navigationBar.rightButton.setTitle("", for: .normal)
        navigationBar.rightButton.tintColor = HippoConfig.shared.theme.headerTextColor
        navigationBar.rightButton.setImage(HippoConfig.shared.theme.homeBarButtonImage, for: .normal)
        navigationBar.rightButton.addTarget(self, action: #selector(homeButtonAction(_:)), for: .touchUpInside)
        
//        self.navigationController?.setTheme()
//
//        self.navigationItem.title = HippoConfig.shared.theme.directChatHeader
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
//        //Configuring homeButton
//        homeButton.setTitle("", for: .normal)
//        homeButton.tintColor = HippoConfig.shared.theme.headerTextColor
//        if HippoConfig.shared.theme.homeBarButtonText.count > 0 {
//            homeButton.setTitle((" " + HippoConfig.shared.theme.homeBarButtonText), for: .normal)
//            if HippoConfig.shared.theme.homeBarButtonFont != nil {
//                homeButton.titleLabel?.font = HippoConfig.shared.theme.homeBarButtonFont
//            }
//            homeButton.setTitleColor(HippoConfig.shared.theme.homeBarButtonTextColor, for: .normal)
//        } else {
//            if HippoConfig.shared.theme.homeBarButtonImage != nil {
//                homeButton.setImage(HippoConfig.shared.theme.homeBarButtonImage, for: .normal)
//                homeButton.tintColor = HippoConfig.shared.theme.headerTextColor
//            }
//        }
    }
    internal func setupRefreshController() {
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .themeColor
        tableView.backgroundView = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
    }
    @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
       checkAgentAndGetData(showLoader: false)
    }
    
    internal func setupTableView() {
        let nib = UINib(nibName: "AgentHomeConversationCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AgentHomeConversationCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func startLoaderAnimation() {
        loaderView.isHidden = false
        loaderImage.startRotationAnimation()
    }
    
    func stopLoaderAnimation() {
        loaderView.isHidden = true
        loaderImage.stopRotationAnimation()
    }
    func moveToConversationWith(_ conversationObject: AgentConversation, animation: Bool = true) {
        
        let keys = conversationObject.customerUserUniqueKeys
        if keys.count > 0, let count = conversationObject.unreadCount {
            UnreadCount.decreaseUnreadCount(for: keys, by: count)
        }
        
        
        let vc = AgentConversationViewController.getWith(conversationObj: conversationObject)
        vc.agentConversationDelegate = self
        vc.isSingleChat = !animation
        self.navigationController?.pushViewController(vc, animated: animation)
    }
    func startDirectChat() {
        guard !AgentConversationManager.searchUserUniqueKeys.isEmpty else {
            return
        }
        let attributes = AgentDirectChatAttributes(otherUserUniqueKey: AgentConversationManager.searchUserUniqueKeys[0], channelName: nil)
        let vc = AgentConversationViewController.getWith(chatAttributes: attributes)
        vc.isSingleChat = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension AgentDirectViewController: UITableViewDelegate {
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
        resetPushCount()
        
        
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            conversationObj.unreadCount = 0
            pushTotalUnreadCount()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}

extension AgentDirectViewController: UITableViewDataSource {
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
}
extension AgentDirectViewController: AgentChatDeleagate {
    
    func updateConversationWith(channelId: Int, lastMessage: HippoMessage, unreadCount: Int) {
        guard channelId > 0 else {
            return
        }
        guard  let index = AgentConversation.getIndex(in: conversationList, for: channelId) else {
            return
        }
        let obj = conversationList[index]
        obj.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
        conversationList[index] = obj
        
        tableView.reloadData()
    }
}

extension AgentDirectViewController: AgentUserChannelDelegate {
    func readAllNotificationFor(channelID: Int) {
        let chatIndex = AgentConversation.getIndex(in: conversationList, for: channelID)
        
        if chatIndex != nil {
            let conversation = conversationList[chatIndex!]
            let userUniqueKeys = conversation.customerUserUniqueKeys
            UnreadCount.decreaseUnreadCount(for: userUniqueKeys, by: conversation.unreadCount ?? 0)
            conversation.unreadCount = 0
        }
        
        
    }
    
    func validate(userId: Int) -> Bool {
        guard !AgentConversationManager.searchUserUniqueKeys.isEmpty else {
            return false
        }
        guard let obj = UnreadCount.unreadCountList[AgentConversationManager.searchUserUniqueKeys[0]] else {
            return false
        }
        return obj.hippoId == userId
    }
    
    
    func newConversationRecieved(_ newConversation: AgentConversation, channelID: Int) {
        let chatIndex = AgentConversation.getIndex(in: conversationList, for: channelID)
        let id = newConversation.user_id ?? -1
        
        if chatIndex != nil {
            let conversation = conversationList[chatIndex!]
            conversation.update(newConversation: newConversation)
            
            if chatIndex != 0 {
                conversationList.remove(at: chatIndex!)
                conversationList.insert(conversation, at: 0)
                tableView.reloadData()
            } else if conversation.messageUpdated == nil {
               tableView.reloadData()
            }
            return
//            tableView.reloadData()
        }
        
        guard id > 0, validate(userId: id), chatIndex == nil else {
            return
        }
        newConversation.unreadCount = 1
        
        if let vc = getLastVisibleController() as? AgentConversationViewController,let id = vc.channel?.id, id == channelID {
            newConversation.unreadCount = 0
        }else if newConversation.lastMessage?.senderId == currentUserId(){
            newConversation.unreadCount = 0
        }
        
        conversationList.insert(newConversation, at: 0)
        tableView.reloadData()
        
    }
}
