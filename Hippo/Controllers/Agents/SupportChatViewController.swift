//
//  SupportChatViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 16/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SupportChatViewController: HippoHomeViewController, InformationViewDelegate {
    
    //MARK: Variables
    var supportChatVM : SupportChatViewModel?
    var refreshControl: UIRefreshControl!
    var setRefreshControl : Bool? {
        didSet {
            refreshControl = UIRefreshControl()
            refreshControl.backgroundColor = UIColor.clear
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl.addTarget(self, action:#selector(refreshTable), for: UIControl.Event.valueChanged)
        }
    }
    var page = 0
    var informationView: InformationView?
    
    //MARK:- IBOutlets
    @IBOutlet var tableView_SupportChat : UITableView!{
        didSet{
            tableView_SupportChat.register(UINib(nibName: "AgentHomeConversationCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "AgentHomeConversationCell")
            setRefreshControl = true
            tableView_SupportChat.refreshControl = refreshControl
        }
    }
    @IBOutlet weak var view_NavigationBar : NavigationBar!
    @IBOutlet weak var image_Loader : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Set Navigation Bar
        view_NavigationBar.title = HippoConfig.shared.theme.headerText
        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        view_NavigationBar.rightButton.isHidden = false
        setFilterButtonIcon()
        
        supportChatVM = SupportChatViewModel()
        supportChatVM?.responseRecieved = {[weak self]() in
            DispatchQueue.main.async {
                self?.noConversationFound(errorMessage: HippoStrings.noConversationFound)
                self?.tableView_SupportChat.reloadData()
            }
        }
        supportChatVM?.startLoading = {[weak self](isLoading) in
            DispatchQueue.main.async {
                if isLoading{
                    self?.startLoaderAnimation()
                }else{
                    self?.stopLoaderAnimation()
                }
            }
        }
        
        supportChatVM?.endRefreshClausre = {[weak self]() in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
        
        self.supportChatVM?.isRefreshing = false
        supportChatVM?.isLoading = false
        supportChatVM?.getListing = true
    }

    //MARK: Override functions
    override func didSetUserChannel() {
        super.didSetUserChannel()
        AgentUserChannel.shared?.delegate = self
    }
    
    override func deleteConversation(channelId: Int) {
        let supportChannelIndex = supportChatVM?.conversationList.firstIndex(where: {
            $0.channel_id == channelId
        })
        if let supportIndex = supportChannelIndex, supportIndex < supportChatVM?.conversationList.count ?? 0{
           supportChatVM?.conversationList.remove(at: supportIndex)
           self.tableView_SupportChat.reloadData()
        }
    }
    
    //MARK:- Private Functions
    
    private func startLoaderAnimation() {
        self.tableView_SupportChat.isHidden = true
        image_Loader.startRotationAnimation()
    }
    
    private func stopLoaderAnimation() {
        self.tableView_SupportChat.isHidden = false
        image_Loader.stopRotationAnimation()
    }
    
    private func setFilterButtonIcon(){
        if HippoConfig.shared.supportChatFilter != nil {
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
    
    private func moveToConversationWith(_ conversationObject: AgentConversation) {
        let vc = AgentConversationViewController.getWith(conversationObj: conversationObject)
        vc.agentConversationDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func refreshTable() {
        supportChatVM?.isRefreshing = true
        supportChatVM?.getListing = true
    }
    
    private func noConversationFound(errorMessage : String){
        if (self.supportChatVM?.conversationList.count ?? 0) <= 0{
            if informationView == nil {
                informationView = InformationView.loadView(self.tableView_SupportChat.bounds, delegate: self)
            }
            self.informationView?.informationLabel.text = errorMessage
            self.informationView?.informationImageView.image = HippoConfig.shared.theme.noChatImage
            self.informationView?.isButtonInfoHidden = true
            self.informationView?.isHidden = false
            self.tableView_SupportChat.addSubview(informationView!)
            self.tableView_SupportChat.layoutSubviews()
        }else{
            for view in tableView_SupportChat.subviews{
                if view is InformationView{
                     view.removeFromSuperview()
                }
            }
            self.tableView_SupportChat.layoutSubviews()
            self.informationView?.isHidden = true
        }
    }
}
extension SupportChatViewController : AgentUserChannelDelegate {
    
    func readAllNotificationFor(channelID: Int) {
        let supportChannelIndex = supportChatVM?.conversationList.firstIndex(where: {
            $0.channel_id == channelID
        })
        
        guard let supportIndex = supportChannelIndex else{
         return
        }
        if supportIndex >= 0 && supportIndex < (supportChatVM?.conversationList.count ?? 0) {
            supportChatVM?.conversationList[supportIndex].unreadCount = 0
        }
        self.tableView_SupportChat.reloadData()
    }
    
    
    func handleAssignmentNotification(with conversation: AgentConversation, channelID: Int) {
        let supportChannelIndex = supportChatVM?.conversationList.firstIndex(where: {
            $0.channel_id == channelID
        })
        guard let supportIndex = supportChannelIndex else{
            return
        }
        if supportIndex >= 0 && supportIndex < (supportChatVM?.conversationList.count ?? 0) {
            let existingConversation = supportChatVM?.conversationList[supportIndex]
            existingConversation?.update(newConversation: conversation)
        }else{
            conversation.update(newConversation: conversation)
            supportChatVM?.conversationList.insert(conversation, at: 0)
        }
        self.tableView_SupportChat.reloadData()
    }
    
    func insertNewConversation(with newConversation: AgentConversation) {
        supportChatVM?.conversationList.insert(newConversation, at: 0)
        self.tableView_SupportChat.reloadData()
    }
    
    func newConversationRecieved(_ newConversation: AgentConversation, channelID: Int) {
      
        if !(newConversation.chatType == .o2o && newConversation.channel_type == channelType.SUPPORT_CHAT_CHANNEL.rawValue){
            return
        }
        if AgentConversation.isAssignmentNotification(for: newConversation) {
            handleAssignmentNotification(with: newConversation, channelID: channelID)
            return
        }
        let supportChannelIndex = supportChatVM?.conversationList.firstIndex(where: {
            $0.channel_id == newConversation.channel_id
        })
        guard let supportIndex = supportChannelIndex else{
            newConversation.unreadCount = 1
            if let vc = getLastVisibleController() as? AgentConversationViewController,let id = vc.channel?.id, id == channelID {
                newConversation.unreadCount = 0
            }else if newConversation.lastMessage?.senderId == currentUserId(){
                newConversation.unreadCount = 0
            }
            insertNewConversation(with: newConversation)
            return
        }
        
        if supportIndex >= 0 && supportIndex < (supportChatVM?.conversationList.count ?? 0){
            let conversation = supportChatVM?.conversationList[supportIndex]
            conversation?.update(newConversation: newConversation)
            if supportIndex != 0 {
                supportChatVM?.conversationList.remove(at: supportIndex)
                supportChatVM?.conversationList.insert(conversation ?? AgentConversation(), at: 0)
                self.tableView_SupportChat.reloadData()
            } else if conversation?.messageUpdated == nil {
                self.tableView_SupportChat.reloadData()
            }
        }
        
    }
    
}



//MARK:- UIScrollViewDelegate
extension SupportChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentBottom = scrollView.contentOffset.y + tableView_SupportChat.frame.height
        let maxBottom = scrollView.contentSize.height - 30

        guard currentBottom > maxBottom else {
            return
        }
        
        self.loadMore()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentBottom = scrollView.contentOffset.y + tableView_SupportChat.frame.height
        let maxBottom = scrollView.contentSize.height - 30
        
        guard currentBottom > maxBottom else {
            return
        }
        
        self.loadMore()
    }
    
    func loadMore() {
        if supportChatVM?.isLoadMoreRequired ?? false {
            page = supportChatVM?.page ?? 1
            let exp = supportChatVM?.conversationList.count ?? 0
            let upcomingPage = supportChatVM?.conversationList.count == 0 ? 1 : exp
            if page != upcomingPage{
                self.page = upcomingPage
                self.supportChatVM?.isRefreshing = false
                self.supportChatVM?.isLoading = true
                self.supportChatVM?.getListing = true
            }else{
                return
            }
        }
    }
}

extension SupportChatViewController : AgentChatDeleagate{
    func updateConversationWith(channelId: Int, lastMessage: HippoMessage, unreadCount: Int) {
        
        guard channelId > 0 else {
            return
        }
        let supportChannelIndex = supportChatVM?.conversationList.firstIndex(where: {
            $0.channel_id == channelId
        })
        guard let supportIndex = supportChannelIndex else{
            return
        }

        if supportIndex < supportChatVM?.conversationList.count ?? 0{
            let chatObj = supportChatVM?.conversationList[supportIndex]
            chatObj?.update(channelId: channelId, unreadCount: unreadCount, lastMessage: lastMessage)
            self.tableView_SupportChat.reloadData()
        }
        
    }
}

extension SupportChatViewController{
    //MARK:- IBAction
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
        if let vc = SupportChatFilterViewController.getNewInstance(){
            let navVC = UINavigationController(rootViewController: vc)
            vc.filterApplied = {[weak self]() in
                DispatchQueue.main.async {
                    self?.supportChatVM?.isRefreshing = false
                    self?.supportChatVM?.conversationList.removeAll()
                    self?.supportChatVM?.isLoading = false
                    self?.supportChatVM?.getListing = true
                    self?.setFilterButtonIcon()
                }
            }
            self.present(navVC, animated: true, completion: nil)
        }
    }
}

extension SupportChatViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportChatVM?.conversationList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "AgentHomeConversationCell", for: indexPath) as? AgentHomeConversationCell else {
             return UITableViewCell()
         }
         cell.setupCell(cellInfo: supportChatVM?.conversationList[indexPath.row] ?? AgentConversation())
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        fuguDelay(1) {
            tableView.isUserInteractionEnabled = true
        }
        let conversationObj = supportChatVM?.conversationList[indexPath.row]
        conversationObj?.channel_type = channelType.SUPPORT_CHAT_CHANNEL.rawValue
        moveToConversationWith(conversationObj ?? AgentConversation())
        if let unreadCount = conversationObj?.unreadCount, unreadCount > 0 {
            supportChatVM?.conversationList[indexPath.row].unreadCount = 0
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
}

