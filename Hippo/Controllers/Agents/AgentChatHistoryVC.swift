//
//  AgentChatHistoryVC.swift
//  Hippo
//
//  Created by soc-admin on 11/05/22.
//

import UIKit

class AgentChatHistoryVC: HippoHomeViewController {
    
    //MARK: Varibles
    fileprivate var conversationList = [AgentConversation]()
    fileprivate var conversationType: ConversationType = .historyChat
    var refreshControl = UIRefreshControl()
    fileprivate var canPaginate = true
    fileprivate var pageNum = 1
    fileprivate var isLoading = false
    var navController: UINavigationController?
    var visitorId: Int = 0
    var excludedChannelid: [Int] = []
    
    //MARK: Outlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var height_ErrorLabel : NSLayoutConstraint!
    @IBOutlet weak var paginationActivityLoader: UIActivityIndicatorView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChatsFoundImageView: So_UIImageView!
    
    //MARK: ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setUpView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadrefreshData(refreshCtrler: refreshControl)
        checkNetworkConnection()
    }
    
    
    deinit {
        print("Deinit Agent History view controller.....")
    }
    
    class func getController() -> AgentChatHistoryVC? {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AgentChatHistoryVC") as? AgentChatHistoryVC
        return vc
    }
}

//MARK: Methods
extension AgentChatHistoryVC {
    
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
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
    }
    
    internal func setupRefreshController() {
        refreshControl.backgroundColor = .clear
        if HippoConfig.shared.theme.themeColor == UIColor.white || HippoConfig.shared.theme.themeColor == UIColor.clear{
            refreshControl.tintColor = HippoConfig.shared.theme.themeTextcolor
        }else{
            refreshControl.tintColor = .themeColor
        }
        tableView.backgroundView = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
    }
    
    @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
        getConversations(isFrstPage: true)
    }
    
    func getConversations(isFrstPage: Bool){
        self.isLoading = true
        let page = isFrstPage ? 1 : pageNum+20
        AgentConversationManager.getHistoryChats(pageNum: page, showLoader: isFrstPage, visitorId: visitorId, excludedChannelId: self.excludedChannelid) { [weak self] (result) in
            guard result.isSuccessful else{
                print(result.error ?? "")
                self?.refreshControl.endRefreshing()
                return
            }
            
            if let convo = result.conversations{
                isFrstPage ? (self?.conversationList = convo) : self?.conversationList.append(contentsOf: convo)
            }
            
            self?.tableView.reloadData()
            self?.canPaginate = result.conversations?.count == 20
            self?.isLoading = false
            self?.pageNum = page
            self?.noChatsFoundImageView.isHidden = self?.conversationList.count != 0
            self?.refreshControl.endRefreshing()
            self?.stopLoadingMore()
        }
    }
}


extension AgentChatHistoryVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard FuguNetworkHandler.shared.isNetworkConnected, canPaginate, !isLoading, conversationList.count >= 20  else {
            return
        }
        
        let currentBottom = scrollView.contentOffset.y + tableView.frame.height
        let maxBottom = scrollView.contentSize.height - 30
        
        
        guard currentBottom > maxBottom else {
            return
        }
        guard canPaginate, !isLoading else {
            return
        }
        isLoading = true
        
        startLoadingMore()
        getConversations(isFrstPage: false)
    }
    
    func startLoadingMore() {
        paginationActivityLoader?.startAnimating()
    }
    
    func stopLoadingMore() {
        paginationActivityLoader?.stopAnimating()
    }
}

//MARK: TableView DataSource and delegate
extension AgentChatHistoryVC: UITableViewDelegate, UITableViewDataSource {
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
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        fuguDelay(1) {
            tableView.isUserInteractionEnabled = true
        }
        let conversationObj = conversationList[indexPath.row]
        moveToConversationWith(conversationObj)
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "AgentHomeConversationCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AgentHomeConversationCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func moveToConversationWith(_ conversationObject: AgentConversation) {
        let vc = AgentConversationViewController.getWith(conversationObj: conversationObject)
        vc.isFirstLevel = false
        self.navController?.pushViewController(vc, animated: true)
    }
}
