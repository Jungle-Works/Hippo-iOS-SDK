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
    case channelActions = 3
    case chatInfo = 2
    case media = 1
    case userInfo = 0
}

class AgentChatInfoViewController: UIViewController {
    
    //MARK: Variables
    var actionArray = [ChatInfoCell]()
    var channelDetail: ChatDetail?
    var tagsArray = [TagDetail]()
    var userImage : String?
    var botAttributes : [String:Any]?
    var agentChatInfoSections = [AgentChatInfoSections]()
    var navigationCon: UINavigationController?
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var view_NavigationBar: NavigationBar!
    @IBOutlet weak var loaderView: So_UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setUpView()
        getAgentInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationCon?.isNavigationBarHidden = true
    }
    
    func getAgentInfo(){
        let params = generateGetAgentInfoParams()
        self.startLoaderAnimation()
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.getAgentInfo.rawValue) { (responseObject, error, tag, statusCode) in
            self.stopLoaderAnimation()
            if error == nil{
                if let response = responseObject as? [String : Any], let data = (response["data"] as? [[String : Any]])?.first{
                    self.channelDetail?.customerEmail = data["email"] as? String ?? ""
                    self.channelDetail?.customerName = data["full_name"] as? String ?? ""
                    self.channelDetail?.customerContactNumber = data["phone_number"] as? String ?? ""
                    self.userImage = data["user_image"] as? String
                    self.botAttributes = data["bot_attributes"] as? [String:Any]
                    self.fillData()
                    self.setupTableView()
                    //self.tableView.reloadData()
                }
            }else{
                
            }
           
        }
    }
    
    func generateGetAgentInfoParams() -> [String : Any]{
        var params = [String : Any]()
        params["user_id"] = channelDetail?.customerID
        params["channel_id"] = channelDetail?.channelId
        params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        return params
    }
    
    func startLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.startRotationAnimation()
        }
    }
    func stopLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.stopRotationAnimation()
        }
    }
    
   func hideUserInfo() -> Bool{
        if (self.channelDetail?.isBotInProgress == true){
              return true
        }else if (self.channelDetail?.channelId != -1 && botAttributes?.count ?? 0 > 0){
            return true
      }
        return false
    }
    
    //MARK: Class methods
    class func get(tags: [TagDetail], chatDetail: ChatDetail, userImage : String?) -> AgentChatInfoViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AgentChatInfoViewController") as? AgentChatInfoViewController
        vc?.tagsArray = tags
        vc?.channelDetail = chatDetail
        vc?.userImage = userImage
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
            actionArray.append(ChatInfoCell(infoImage: reopenImage, nameOfCell: HippoStrings.reopenChat))
        }
    }
    
    func setUpView() {
//        view_NavigationBar.title = HippoStrings.info
//        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
//        view_NavigationBar.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
//        view_NavigationBar.view.layer.shadowRadius = 2.0
//        view_NavigationBar.view.layer.shadowOpacity = 0.5
//        view_NavigationBar.view.layer.masksToBounds = false
//        view_NavigationBar.view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
//                                                                        y: view_NavigationBar.bounds.maxY - view_NavigationBar.layer.shadowRadius,
//                                                                        width: view_NavigationBar.bounds.width,
//                                                                        height: view_NavigationBar.layer.shadowRadius)).cgPath
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
        if hideUserInfo(){
            self.agentChatInfoSections = [.media, .chatInfo, .channelActions]
        }else{
            self.agentChatInfoSections = [.userInfo,.media, .chatInfo, .channelActions]
        }
    }
    
    func getPopupMessage() -> String {
        var message = ""
        guard channelDetail != nil else {
            return message
        }
        if channelDetail!.channelStatus == .open {
            message = HippoStrings.closeChatPopup
        } else {
            message = HippoStrings.reopenChatPopup
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
        guard let controllers = self.navigationCon?.viewControllers else {
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
        guard let controllers = self.navigationCon?.viewControllers else {
            self.navigationCon?.popToRootViewController(animated: true)
            return
        }
        for each in controllers {
            if each as? HippoHomeViewController != nil {
                self.navigationCon?.popToRootViewController(animated: true)
                return
            }
            if let vc = each as? AgentDirectViewController, vc.conversationList.count > 1 {
                self.navigationCon?.popToRootViewController(animated: true)
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
//        guard let value = AgentChatInfoSections(rawValue: section) else {
//            return nil
//        }
        var sectionHeaderName = ""
        switch agentChatInfoSections[section] {
        case .channelActions:
            sectionHeaderName = HippoStrings.actions
        case .chatInfo:
            sectionHeaderName = HippoStrings.channelInfo
        case .userInfo:
            sectionHeaderName = HippoStrings.userProfile
        case .media:
            sectionHeaderName = "Media"
        }
        return ChatInfoHeader.configureSectionHeader(headerInfo: ChatInfoCell(infoImage: nil, nameOfCell: sectionHeaderName))
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard let value = AgentChatInfoSections(rawValue: section) else {
//            return 0
//        }
//
        switch agentChatInfoSections[section] {
        case .userInfo:
            return 0
        default:
            return 32
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let value = AgentChatInfoSections(rawValue: indexPath.section) else {
//            return
//        }
        switch agentChatInfoSections[indexPath.section] {
        case .channelActions:
            channelActionClicked()
        case .chatInfo:
            switch indexPath.row {
            case 0: //For agent info
                pushToAgentAssignmentList()
                break
//            case 1: //for channel tags
//                print("case 1")
            default:
                break
            }
        case .media:
            let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
            if let vc = storyboard.instantiateViewController(withIdentifier: "SharedMediaViewController") as? SharedMediaViewController{
                vc.channelId = channelDetail?.channelId
                self.navigationCon?.pushViewController(vc, animated: true)
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
            self.navigationCon?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: TableViewDataSource
extension AgentChatInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let chatType = channelDetail?.chatType ?? .other
        switch chatType {
        case .o2o:
            if HippoConfig.shared.agentDetail?.agentUserType == .admin{
                return agentChatInfoSections.count
            }
            return 1
        default:
            return agentChatInfoSections.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.agentChatInfoSections[section] {
        case .channelActions:
            return actionArray.count
        case .chatInfo:
            if let tags = channelDetail?.channelTags, tags.isEmpty {
                return 1
            }
            return 2
        case .userInfo:
            return 1
        case .media:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let value = AgentChatInfoSections(rawValue: indexPath.section) else {
//            return UITableViewCell()
//        }
        switch self.agentChatInfoSections[indexPath.section] {
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
        case .media:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.regular(ofSize: 14.0)
            cell.textLabel?.text = HippoStrings.sharedMediaTitle
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
            return cell
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
        cell.contentView.backgroundColor = .white
        cell.delegate = self
        cell.setupCellData(tagsArray: tagsArray)
        return cell
    }
    
    func returnUserInfoCell(indexPath: IndexPath) ->  ChatProfileTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatProfileTableViewCell", for: indexPath) as? ChatProfileTableViewCell, channelDetail != nil else {
            return ChatProfileTableViewCell()
        }
        cell.setupCell(with: channelDetail!)
        if let url = URL(string: self.userImage ?? ""){
            cell.userImage.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.userPlaceHolderImage, options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            cell.userImage.image = HippoConfig.shared.theme.userPlaceHolderImage
        }
    
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

extension AgentChatInfoViewController: ChatInfoTagDelegate {
    func addNewTag() {
        guard let info = channelDetail else {
            return
        }
        let vc = AddLabelsViewController.get(channelId: info.channelId, existingTags: tagsArray)
        vc.delegate = self
        self.navigationCon?.pushViewController(vc, animated: true)
    }
}

extension AgentChatInfoViewController: AddLabelProtocol {
    func addLabelAction(tagsArray: [TagDetail]) {
        self.tagsArray = tagsArray
        self.tableView.reloadData()
    }
    
    func cancelAction() {
        
    }
}
