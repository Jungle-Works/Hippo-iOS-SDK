//
//  AgentChatInfoViewController.swift
//  SDKtags1
//
//  Created by Vishal on 19/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//



import UIKit


struct ChatInfoCell {
    var infoImage: UIImage?
    var nameOfCell: String
    
    init(infoImage: UIImage?, nameOfCell: String) {
        self.infoImage = infoImage
        self.nameOfCell = nameOfCell
    }
}

enum AgentChatInfoSections: Int, CaseCountable {
    case channelActions = 2
    case chatInfo = 1
    case userInfo = 0
}

class AgentChatInfoViewController: UIViewController {
    
    //MARK: Variables
    var actionArray = [ChatInfoCell]()
    var channelDetail: ChatDetail?

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var view_NavigationBar: NavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillData()
//        self.navigationController?.setTheme()
        setUpView()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Class methods
    class func get(chatDetail: ChatDetail) -> AgentChatInfoViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AgentChatInfoViewController") as? AgentChatInfoViewController
        vc?.channelDetail = chatDetail
        return vc
    }
}

extension AgentChatInfoViewController {
    
    func fillData() {
        guard channelDetail != nil else {
            return
        }
        let closeImage = HippoConfig.shared.theme.closeChatImage
        let reopenImage = HippoConfig.shared.theme.chatReOpenIconWithTemplateMode
        if channelDetail?.channelStatus == .open {
            actionArray.append(ChatInfoCell(infoImage: closeImage, nameOfCell: HippoStrings.closeChat))
        } else {
            actionArray.append(ChatInfoCell(infoImage: reopenImage, nameOfCell: "Reopen Chat"))
        }
    }
    
    func setUpView() {
//        self.navigationItem.title = "Info"
//
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
        view_NavigationBar.title = HippoStrings.info
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
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        var nib = UINib(nibName: "ChatInfoActionCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "ChatInfoActionCell")
        nib = UINib(nibName: "ChatProfileTableViewCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "ChatProfileTableViewCell")
        nib = UINib(nibName: "ChatInfoAgentTableViewCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "ChatInfoAgentTableViewCell")
        nib = UINib(nibName: "ChatInfoTagViewCell", bundle: FuguFlowManager.bundle)
        tableView.register(nib, forCellReuseIdentifier: "ChatInfoTagViewCell")
    }
    
    func getPopupMessage() -> String {
        var message = ""
        guard channelDetail != nil else {
            return message
        }
        if channelDetail!.channelStatus == .open {
            message = "Are you sure, you want to Close this conversation?"
        } else {
            message = "Are you sure, you want to Reopen this conversation?"
        }
        return message
    }
    func channelActionClicked() {
        guard channelDetail != nil else {
            return
        }
        guard let channelId = channelDetail?.channelId else {
            return
        }
        let message = getPopupMessage()
        let status = channelDetail!.channelStatus == .open ? ChatStatus.close : ChatStatus.open
        
        showOptionAlert(title: "", message: message, preferredStyle: .alert, successButtonName: HippoStrings.yes.capitalized, successComplete: { (_) in
            self.changeChannelStatus(channelId: channelId, status: status)
        }, failureButtonName: HippoStrings.no.capitalized, failureComplete: nil)
    }
    func changeChannelStatus(channelId: Int, status: ChatStatus) {
        AgentConversationManager.updateChannelStatus(for: channelId, newStatus: status.rawValue) {[weak self] (result) in
            guard self != nil, result.isSuccessful else {
                showAlertWith(message: HippoStrings.somethingWentWrong, action: nil)
                return
            }
            self?.updateHomeView(channelId: channelId, status: status)
            self?.popToHomeIfExist()
        }
    }
    func updateHomeView(channelId: Int, status: ChatStatus) {
        guard let controllers = self.navigationController?.viewControllers else {
            return
        }
        for each in controllers {
            if let vc = each as? HippoHomeViewController {
                vc.channelStatusChanged(channelId: channelId, newStatus: status)
                break
            }
            if let vc = each as? AgentDirectViewController, vc.conversationList.count > 1 {
                break
            }
        }
    }
    
    func popToHomeIfExist() {
        guard let controllers = self.navigationController?.viewControllers else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        for each in controllers {
            if each as? AgentHomeViewController != nil {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
            if let vc = each as? AgentDirectViewController, vc.conversationList.count > 1 {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        HippoConfig.shared.notifiyDeinit()
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: TableView delegates
extension AgentChatInfoViewController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let value = AgentChatInfoSections(rawValue: section) else {
            return nil
        }
        var sectionHeaderName = ""
        switch value {
        case .channelActions:
            sectionHeaderName = HippoStrings.actions
        case .chatInfo:
            sectionHeaderName = HippoStrings.channelInfo
        case .userInfo:
            sectionHeaderName = HippoStrings.userProfile
        }
        return ChatInfoHeader.configureSectionHeader(headerInfo: ChatInfoCell(infoImage: nil, nameOfCell: sectionHeaderName))
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let value = AgentChatInfoSections(rawValue: section) else {
            return 0
        }
        
        switch value {
        case .userInfo:
            return 0
        default:
            return 32
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = AgentChatInfoSections(rawValue: indexPath.section) else {
            return
        }
        switch value {
        case .channelActions:
            channelActionClicked()
        case .chatInfo:
            switch indexPath.row {
            case 0: //For agent info
                pushToAgentAssignmentList()
                break
            case 1: //for channel tags
                print("case 1")
            default:break
            }
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func pushToAgentAssignmentList() {
        guard channelDetail != nil else {
            return
        }
        if let vc = AgentListViewController.get(channelInfo: channelDetail!){
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
//MARK: TableViewDataSource
extension AgentChatInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let chatType = channelDetail?.chatType ?? .other
        switch chatType {
        case .o2o:
            return 1
        default:
            return AgentChatInfoSections.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = AgentChatInfoSections(rawValue: section) else {
            return 0
        }
        switch value {
        case .channelActions:
            return actionArray.count
        case .chatInfo:
            if let tags = channelDetail?.channelTags, tags.isEmpty {
                return 1
            }
            return 2
        case .userInfo:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let value = AgentChatInfoSections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch value {
        case .channelActions:
            return returnActionViewCell(indexPath: indexPath)
        case .chatInfo:
            if indexPath.row == 0 {
                return returnAgentInfoCell(indexPath: indexPath) //For agent info
            } else if indexPath.row == 1 {
                return returnTagView(indexPath: indexPath) //for channel tags
            }
        case .userInfo:
            return returnUserInfoCell(indexPath: indexPath)
        }
        return UITableViewCell()
    }
    
    func returnActionViewCell(indexPath: IndexPath) -> ChatInfoActionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoActionCell", for: indexPath) as? ChatInfoActionCell else {
            return ChatInfoActionCell()
        }
        cell.selectionStyle = .none//.default
        cell.closeReopenChatTapButton.tag = indexPath.row
        cell.closeReopenChatTapButton.addTarget(self, action: #selector(closeReopenChatTapButtonPressed(_:)), for: .touchUpInside)
        return cell.configureCellOfChatInfo(resetProperties: true, chatInfo: actionArray[indexPath.row])
    }
    
    @objc func closeReopenChatTapButtonPressed(_ sender:UIButton) {
////        let row = sender.tag
////        let values = data[row]
////        let indexpath = IndexPath(row: row, section: 0)
////        guard let cell = self.tableView.cellForRow(at: indexpath) as? ChatInfoActionCell else { return }
//        channelActionClicked()
    }
    
    func returnTagView(indexPath: IndexPath) -> ChatInfoTagViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoTagViewCell", for: indexPath) as? ChatInfoTagViewCell,  channelDetail != nil  else {
            return ChatInfoTagViewCell()
        }
        cell.selectionStyle = .none
        cell.setupCellData(tagsArray: channelDetail!.channelTags)
        return cell
    }
    
    func returnUserInfoCell(indexPath: IndexPath) ->  ChatProfileTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatProfileTableViewCell", for: indexPath) as? ChatProfileTableViewCell, channelDetail != nil else {
            return ChatProfileTableViewCell()
        }
        cell.setupCell(with: channelDetail!)
        cell.containerViewForStatus.isHidden = true
        cell.selectionStyle = .none
        return cell
    }
    
    func returnAgentInfoCell(indexPath: IndexPath) ->  ChatInfoAgentTableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoAgentTableViewCell", for: indexPath) as? ChatInfoAgentTableViewCell, channelDetail != nil  else {
            return ChatInfoAgentTableViewCell()
        }
        return cell.setUpData(agentId: channelDetail!.assignedAgentID, agentName: channelDetail!.assignedAgentName)
    }
    
}


