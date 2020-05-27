//
//  AgentListViewController.swift
//  Fugu
//
//  Created by Gagandeep Arora on 22/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class AgentListViewController: UIViewController {
    
    @IBOutlet weak var tableViewAgent: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var channelId = -1
    var agentList = [Agent]()
    var agentListForSearch = [Agent]()
    var channelInfo: ChatDetail!
    var titleLabel : UILabel?
    var titleSearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterAgentList()
        setUpAgentListScreen()
        setTheme()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.searchBar.resignFirstResponder()
        self.titleSearchBar.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeBtnAction(_ sender: UIBarButtonItem) {
        self.searchBar.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setTheme() {
        let theme = HippoConfig.shared.theme
        tableViewAgent.backgroundColor = UIColor.white //theme.systemBackgroundColor.secondary
        self.view.backgroundColor = theme.backgroundColor
    }
    class func get(channelInfo: ChatDetail) -> AgentListViewController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AgentListViewController") as? AgentListViewController else {
            return nil
        }
        vc.channelInfo = channelInfo
        vc.channelId = channelInfo.channelId
        return vc
    }
    
}
//MARK: - UITableView Delegate And DataSource Methods
extension AgentListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agentList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isAgentActive(indexRow: indexPath.row) == false {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AgentListTableViewCell", for: indexPath) as? AgentListTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        return cell.configureAgentCell(resetProperties: true, agentObject: agentList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showOptionAlert(title: "", message: "Are you sure you want to assign this chat?", preferredStyle: .alert, successButtonName: "YES", successComplete: { (_) in
            self.assignChatToAgent(agent: self.agentList[indexPath.row])
        }, failureButtonName: "NO", failureComplete: nil)
    }
    
//    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? AgentListTableViewCell else { return }
//        cell.mainContentView.backgroundColor = UIColor.clear
//        cell.verticalSelectionLine.isHidden = false
//        cell.verticalSelectionLine.backgroundColor = UIColor.themeColor
//        cell.nameLabel.textColor = UIColor.themeColor
//        cell.layoutIfNeeded()
//    }
    
//    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? AgentListTableViewCell else { return }
//
//        cell.mainContentView.backgroundColor = UIColor.veryLightBlue
//        cell.verticalSelectionLine.isHidden = true
//        cell.nameLabel.textColor = UIColor.black
//        cell.layoutIfNeeded()
//    }
}

//MARK: - HELPERS
extension AgentListViewController {
    func setUpAgentListScreen() {
        setupNavigationBar()
        self.setUpSearchBar()
        let bundle = FuguFlowManager.bundle
        tableViewAgent.register(UINib(nibName: "AgentListTableViewCell", bundle: bundle), forCellReuseIdentifier: "AgentListTableViewCell")
    }
    
    func setupNavigationBar() {
        //titleOfNavigationItem(barTitle: "Assign Conversation")
        setCustomTitle(barTitle: "Assign Conversation")
//        setupCustomThemeOnNavigationBar(hideNavigationBar: false)
        navigationItem.hidesBackButton = false
    }
    
    func setCustomTitle(barTitle: String) {
        let label = UILabel()
        label.text = ""
//        label.font = UIFont.boldTitilium(withSize: 17)
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textAlignment = .center
        
        titleLabel = label
        titleLabel?.isUserInteractionEnabled = false
        navigationItem.titleView?.isUserInteractionEnabled = true
        
        
        //        titleOfNavigationItem(barTitle: barTitle)
        titleLabel?.text = barTitle
        titleLabel?.textColor = UIColor.black
        titleLabel?.sizeToFit()
        
        navigationItem.titleView = titleLabel
        
        
    }
    
    func isAgentActive(indexRow: Int) -> Bool {
        if indexRow < agentList.count, let agentStatus = agentList[indexRow].status, agentStatus == 0 {
            return false
        }
        return true
    }
    
    func setUpSearchBar() {
        searchBar.sizeToFit()
        
        searchBar.placeholder = "Search"
        searchBar.barTintColor = HippoConfig.shared.theme.backgroundColor//HippoTheme.current.searchBarBackgroundColor
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        searchBar.tintColor = HippoConfig.shared.theme.backgroundColor//HippoTheme.current.searchBarBackgroundColor
        searchBar.backgroundColor = UIColor.white
        searchBar.backgroundImage = UIImage()
        
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = HippoConfig.shared.theme.backgroundColor//HippoTheme.current.searchBarBackgroundColor
        
        titleSearchBar.sizeToFit()
        titleSearchBar.placeholder = "Search"
        titleSearchBar.barTintColor = HippoConfig.shared.theme.backgroundColor//HippoTheme.current.searchBarBackgroundColor
        titleSearchBar.returnKeyType = .done
        titleSearchBar.delegate = self
        titleSearchBar.frame = searchBar.frame
        
        let textFieldInsideSearchBar1 = titleSearchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar1?.backgroundColor = HippoConfig.shared.theme.backgroundColor//HippoTheme.current.searchBarBackgroundColor
    }
    
}

extension AgentListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterList(searchString: searchText.lowercased())
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    func filterList(searchString: String) {
        
        if searchString.isEmpty {
            agentList = agentListForSearch
            self.tableViewAgent.reloadData()
            return
        }
        
        let tempArr = agentListForSearch.filter { (c) -> Bool in
            let tagName =  (c.fullName ?? "").lowercased()
            return tagName.contains(searchString)
        }
        
        agentList = tempArr
        self.tableViewAgent.reloadData()
    }
}

//MARK: - APIs
extension AgentListViewController {
    
    func filterAgentList() {
        if currentUserId() == -1{
            self.agentList = Business.shared.agents
            self.agentListForSearch = Business.shared.agents
            return
        }
        
        var filteredArray = [Agent]()
        if let info = channelInfo {
//            let assignedAgentId = info.agentId
            let assignedAgentId = info.assignedAgentID
            if assignedAgentId == -1 || assignedAgentId != currentUserId() {
                filteredArray = Business.shared.agents.filter() { $0.userId == currentUserId()}
            } else if assignedAgentId == currentUserId() {
                
            }
        }
        self.agentList = Business.shared.agents
        self.agentListForSearch = Business.shared.agents
        let onlineAgents = agentList.filter() { $0.onlineStatus == AgentStatus.available.rawValue && $0.userId != currentUserId() }
        let offlineAgents = agentList.filter() { ($0.onlineStatus == AgentStatus.offline.rawValue || $0.onlineStatus == AgentStatus.away.rawValue) && $0.userId != currentUserId() }
        let newSortedArray = onlineAgents.sorted() { $0.name < $1.name }
        let tempArray = offlineAgents.sorted() { $0.name < $1.name }
        filteredArray = filteredArray + newSortedArray + tempArray
        agentList = filteredArray
        agentListForSearch = filteredArray
        self.tableViewAgent.reloadData()
    }
    
    func assignChatToAgent(agent: Agent) {
        guard let accessToken = HippoConfig.shared.agentDetail?.fuguToken, let userId = agent.userId else {
            return
        }
        let params: [String : Any] = ["access_token": accessToken,
                                      "channel_id": channelId,
                                      "user_id": userId]
        HippoConfig.shared.log.debug("API_AssignAgent.....\(params)", level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.assignAgent.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    HippoConfig.shared.log.debug("API_AssignAgent ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    return
            }
          
            self.handleAgentAssignmentSuccess(for: agent)
            
        }
    }
    func handleAgentAssignmentSuccess(for agent: Agent) {
//        guard let mainNavigationController = appNavigationController else {
//            return
//        }
//        if let vc = mainNavigationController.isControllerExist(controller: ChannelInfoViewController.self) as? ChannelInfoViewController, !channelInfo.isFirstLevel {
//            mainNavigationController.popToViewController(vc, animated: true)
//            delay(0.1, completion: {
//                vc.chatHistoryController?.manuallyReassignChat(user: agent, channelId: self.channelId)
//            })
//        } else if let homeVC = mainNavigationController.isControllerExist(controller: HomeViewController.self) as? HomeViewController {
//            mainNavigationController.popToViewController(homeVC, animated: true)
//            delay(0.1, completion: {
//                homeVC.manuallyReassignChat(user: agent, channelId: self.channelId)
//            })
//        } else {
//            mainNavigationController.popViewController(animated: true)
//        }
        self.navigationController?.popViewController(animated: true)
    }
}
