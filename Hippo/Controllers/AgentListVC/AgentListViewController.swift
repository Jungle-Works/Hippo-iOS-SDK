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
//    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var view_NavigationBar: NavigationBar!
    
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
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
         self.searchBar.resignFirstResponder()
         self.navigationController?.popViewController(animated: true)
    }
    
    func setTheme() {
        let theme = HippoConfig.shared.theme
        tableViewAgent.backgroundColor = UIColor.white //theme.systemBackgroundColor.secondary
        self.view.backgroundColor = theme.backgroundColor
    }
    class func get(channelInfo: ChatDetail) -> AgentListViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
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
        let messageToShow = agentList[indexPath.row].userId == currentUserId() ? HippoStrings.reasignChatToYou : HippoStrings.reasignChat
        
        
        self.showOptionAlert(title: "", message: messageToShow, preferredStyle: .alert, successButtonName: HippoStrings.yes.capitalized, successComplete: { (_) in
            self.assignChatToAgent(agent: self.agentList[indexPath.row])
        }, failureButtonName: HippoStrings.no, failureComplete: nil)
    }
    
//    func tableView(_ tableView: UITableView, didHighlightRowAt i.ndexPath: IndexPath) {
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
//        //titleOfNavigationItem(barTitle: "Assign Conversation")
////        setCustomTitle(barTitle: "Assign Conversation")
////        setupCustomThemeOnNavigationBar(hideNavigationBar: false)
////        navigationItem.hidesBackButton = false
//        self.navigationController?.setTheme()
//        self.navigationController?.isNavigationBarHidden = false
//
//        self.navigationItem.title = "Assign Conversation"
//        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
//        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
//            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
//            if HippoConfig.shared.theme.leftBarButtonFont != nil {
//                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
//            }
//            backButton.setTitleColor(HippoConfig.shared.theme.leftBarButtonTextColor, for: .normal)
//        } else {
//            if HippoConfig.shared.theme.leftBarButtonArrowImage != nil {
//                backButton.setImage(HippoConfig.shared.theme.leftBarButtonArrowImage, for: .normal)
//                backButton.tintColor = HippoConfig.shared.theme.headerTextColor
//            }
//        }
        self.navigationController?.isNavigationBarHidden = true
        view_NavigationBar.title = HippoStrings.assignConversation
        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        view_NavigationBar.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        view_NavigationBar.view.layer.shadowRadius = 2.0
        view_NavigationBar.view.layer.shadowOpacity = 0.5
        view_NavigationBar.view.layer.masksToBounds = false
        view_NavigationBar.view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                                        y: view_NavigationBar.bounds.maxY - view_NavigationBar.layer.shadowRadius,
                                                                        width: view_NavigationBar.bounds.width,
                                                                        height: view_NavigationBar.layer.shadowRadius)).cgPath
    }
    
//    func setCustomTitle(barTitle: String) {
//        let label = UILabel()
//        label.text = ""
////        label.font = UIFont.boldTitilium(withSize: 17)
//        label.font = UIFont.systemFont(ofSize: 17.0)
//        label.textAlignment = .center
//
//        titleLabel = label
//        titleLabel?.isUserInteractionEnabled = false
//        navigationItem.titleView?.isUserInteractionEnabled = true
//
//
//        //        titleOfNavigationItem(barTitle: barTitle)
//        titleLabel?.text = barTitle
//        titleLabel?.textColor = UIColor.black
//        titleLabel?.sizeToFit()
//
//        navigationItem.titleView = titleLabel
//
//    }
    
    func isAgentActive(indexRow: Int) -> Bool {
        if indexRow < agentList.count, let agentStatus = agentList[indexRow].status, agentStatus == 0 {
            return false
        }
        return true
    }
    
    func setUpSearchBar() {
        searchBar.sizeToFit()
        
        searchBar.placeholder = HippoStrings.search
        searchBar.barTintColor = HippoConfig.shared.theme.searchBarBackgroundColor//HippoConfig.shared.theme.backgroundColor//
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        searchBar.tintColor = UIColor.black//HippoConfig.shared.theme.searchBarBackgroundColor//HippoConfig.shared.theme.backgroundColor//
        searchBar.backgroundColor = UIColor.white//UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)//
        searchBar.backgroundImage = UIImage()
        
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = HippoConfig.shared.theme.searchBarBackgroundColor//HippoConfig.shared.theme.backgroundColor//
        
        titleSearchBar.sizeToFit()
        titleSearchBar.placeholder = HippoStrings.search
        titleSearchBar.barTintColor = HippoConfig.shared.theme.searchBarBackgroundColor//HippoConfig.shared.theme.backgroundColor//
        titleSearchBar.returnKeyType = .done
        titleSearchBar.delegate = self
        titleSearchBar.frame = searchBar.frame
        
        let textFieldInsideSearchBar1 = titleSearchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar1?.backgroundColor = HippoConfig.shared.theme.searchBarBackgroundColor//HippoConfig.shared.theme.backgroundColor//
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
        var agentArr = Business.shared.agents
        if let info = channelInfo {
            
            //remove owner from list
            if info.chatType == .o2o{
                let index = agentArr.firstIndex(where: {$0.userId == channelInfo.customerID})
                if let index = index , index >= 0 , index < agentArr.count{
                    agentArr.remove(at: index)
                }
            }
            
            let assignedAgentId = info.assignedAgentID
            if assignedAgentId == -1 || assignedAgentId != currentUserId() {
                filteredArray = agentArr.filter() { $0.userId == currentUserId()}
            } else if assignedAgentId == currentUserId() {
                
            }
        }
        self.agentList = agentArr
        self.agentListForSearch = agentArr
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
                    showAlertWith(message: error?.localizedDescription ?? "", action: nil)
                    return
            }
          
            self.handleAgentAssignmentSuccess(for: agent)
            
        }
    }
    func handleAgentAssignmentSuccess(for agent: Agent) {
        var isAgentHomeViewController : UIViewController?
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HippoHomeViewController.self) {
                isAgentHomeViewController = controller
                break
            }
        }
        if isAgentHomeViewController != nil{
            self.navigationController!.popToViewController(isAgentHomeViewController!, animated: true)
        }else{
//            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        
    }

}
