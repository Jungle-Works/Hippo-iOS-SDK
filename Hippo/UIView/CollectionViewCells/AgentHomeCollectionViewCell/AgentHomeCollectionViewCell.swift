//
//  AgentHomeCollectionViewCell.swift
//  SDKDemo1
//
//  Created by Vishal on 18/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol AgentHomeCollectionViewCellDelegate: class {
    func moveToConversationWith(_ conversationObject: AgentConversation)
    func placholderButtonClicked()
}

class AgentHomeCollectionViewCell: UICollectionViewCell {
    
    //MARK: Variables
    var conversationList = [AgentConversation]()
    var refreshControl = UIRefreshControl()
    var conversationType = ConversationType.myChat
    weak var delegate: AgentHomeCollectionViewCellDelegate? = nil
    var isMoreToLoad = false
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var placeHolderButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var activityContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellView()
        setupTableView()
        setupRefreshController()
        stopLoadingMore()
    }
    
    func setCellData(type: ConversationType) {
        self.conversationType = type
        switch type {
        case .allChat:
            conversationList = ConversationStore.shared.allChats
        case .myChat:
            conversationList = ConversationStore.shared.myChats
        case .o2oChat:
            conversationList = ConversationStore.shared.o2oChats
         }
        setupCellView()
        self.tableView.reloadData()
        fuguDelay(1.5, completion: {
            self.updatePaginationData()
        })
    }
    
    @IBAction func placeHolderButtonClicked(_ sender: UIButton) {
        delegate?.placholderButtonClicked()
    }
}

//MARK: Methods
extension AgentHomeCollectionViewCell {
    
    func updatePaginationData() {
        switch self.conversationType {
        case .allChat:
            self.isMoreToLoad = ConversationStore.shared.isMoreAllChatToLoad
        case .myChat:
            self.isMoreToLoad = ConversationStore.shared.isMoreMyChatToLoad
        case .o2oChat:
            self.isMoreToLoad = ConversationStore.shared.isMoreo2oChatToLoad
        }
    }
    func setupCellView() {
        var message = ""
        var enableButton = false
        if (AgentConversationManager.isAllChatInProgress && conversationType == .allChat) ||  (AgentConversationManager.isMyChatInProgress && conversationType == .myChat) {
            message = HippoStrings.loading
        } else if  HippoConfig.shared.agentDetail == nil || HippoConfig.shared.agentDetail!.oAuthToken.isEmpty {
            message = "Auth token is not found or found Empty"
        } else if HippoConfig.shared.agentDetail!.id <= 0 {
            message = "Getting Conversation..."
        } else {
            message = "You have no chats"//"No chat found for your business."
            enableButton = true
        }
        if let error = AgentConversationManager.errorMessage {
            message = error
            enableButton = true
        }
        
        if conversationList.isEmpty {
            errorView.isHidden = false
            placeHolderButton.isEnabled = enableButton
            placeHolderLabel.text = message
        } else {
            errorView.isHidden = true
            placeHolderButton.isEnabled = false
            placeHolderLabel.text = ""
        }
    }
    
    internal func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "AgentHomeConversationCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AgentHomeConversationCell")
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
//        AgentConversationManager.getConversationsForAgent(type: conversationType) {[weak self] (result) in
//            self?.refreshControl.endRefreshing()
//            self?.setCellData(type: self!.conversationType)
//        }
    }
}


//MARK: TableView delegates
extension AgentHomeCollectionViewCell: UITableViewDelegate {
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
        delegate?.moveToConversationWith(conversationObj)
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            resetPushCount()
            conversationObj.unreadCount = 0
            pushTotalUnreadCount()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}
//MARK: TableViewDataSource
extension AgentHomeCollectionViewCell: UITableViewDataSource {
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

//MARK: Scrollviewdelegate
extension AgentHomeCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if (AgentConversationManager.isAllChatInProgress && conversationType == .allChat) ||  (AgentConversationManager.isMyChatInProgress && conversationType == .myChat) {
            return
        }
        
        let currentBottom = scrollView.contentOffset.y + tableView.frame.height
        let maxBottom = scrollView.contentSize.height - 30
        
        
        guard currentBottom > maxBottom else {
            return
        }
        guard isMoreToLoad else {
            return
        }
        isMoreToLoad = false
        startLoadingMore()
//        AgentConversationManager.getConversationsForAgent(isInitialLoading: false, type: self.conversationType) {[weak self] (result) in
//            guard self != nil else {
//                return
//            }
//            self?.stopLoadingMore()
//            self?.setCellData(type: self!.conversationType)
//
//        }
    }
    
    
    func startLoadingMore() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityContainer.isHidden = false
        activityContainerBottomConstraint.constant = 0
    }
    
    func stopLoadingMore() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        activityContainer.isHidden = true
        activityContainerBottomConstraint.constant = -30
    }
}
