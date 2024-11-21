//
//  NewAllConversationViewController.swift
//  Hippo
//
//  Created by Neha on 20/11/24.
//

import Foundation
import UIKit



class NewAllConversationViewController: UIViewController, NewChatSentDelegate {

    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var view_NavigationBar: NavigationBar!
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet weak var height_ErrorLabel : NSLayoutConstraint!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var openChatButton: UIButton!
    @IBOutlet weak var closeChatButton: UIButton!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var buttonContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var width_NewConversation : NSLayoutConstraint!
    @IBOutlet weak var view_NewConversationBtn : UIView!
    @IBOutlet weak var otherBottomLineView: UIView!
    @IBOutlet weak var newConversationButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    var arrayOfFullConversation = [FuguConversation]()
    var arrayOfConversation = [FuguConversation]()
    var ongoingConversationArr = [FuguConversation]()
    var closedConversationArr = [FuguConversation]()
    var config: AllConversationsConfig = AllConversationsConfig.defaultConfig
    var conversationChatType: ConversationChatType = .openChat
    var shouldHideBackBtn : Bool = false
    var isPutUserFailed = false
    
    override func viewDidLoad() {
        addObservers()
        setViewUI()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllConversations()
        self.height_ErrorLabel.constant = 0
        checkNetworkConnection()
        HippoConfig.shared.hideTabbar?(false)
        self.navigationController?.isNavigationBarHidden = true
        
        if #available(iOS 13.0, *) {
            self.view.overrideUserInterfaceStyle = .light
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.updateNewConversationBtnUI(isSelected: true)
        })
    }
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: HippoVariable.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForground), name: HippoVariable.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        checkNetworkConnection()
//        saveConversationsInCache()
    }
    
    @objc func appMovedToForground() {
        checkNetworkConnection()
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
    
    func setTableView() {
        let bundle = FuguFlowManager.bundle
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConversationView", bundle: bundle), forCellReuseIdentifier: "ConversationCellCustom")
    }
    
    func setNavigation(){
        view_NavigationBar.title = config.title ?? HippoConfig.shared.theme.headerText
        view_NavigationBar.isLeftButtonHidden = shouldHideBackBtn
        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        view_NavigationBar.leftButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
        view_NavigationBar.leftButton.tintColor = .black
        view_NavigationBar.image_back.isHidden = true
    }
    
    func setViewUI(){
        self.openChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        self.closeChatButton.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
        self.openChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        self.closeChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.openChatButton.setTitle(HippoProperty.current.currentBtnText ?? HippoStrings.ongoing, for: .normal)
        self.closeChatButton.setTitle(HippoProperty.current.pastBtnText ?? HippoStrings.past, for: .normal)
        self.bottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
        otherBottomLineView.backgroundColor = .clear
        if HippoConfig.shared.hasChannelTabs == true{
            self.buttonContainerViewHeightConstraint.constant = 45
            self.openChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
            self.closeChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
        }else{
            self.buttonContainerViewHeightConstraint.constant = 0
            self.openChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
            self.closeChatButton.isHidden = !HippoConfig.shared.hasChannelTabs
        }

        updateErrorLabelView(isHiding: true)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        setTableView()
        setNavigation()
        tableView.backgroundView = refreshControl
        let theme = HippoConfig.shared.theme
         if self.conversationChatType == .openChat{
            view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
        }else if self.conversationChatType == .closeChat{
            view_NewConversationBtn.isHidden = true
        }else{}
        newConversationButton.backgroundColor = theme.themeColor
        view_NewConversationBtn.backgroundColor = theme.themeColor
        view_NewConversationBtn.layer.cornerRadius = newConversationButton.bounds.height / 2
        view_NewConversationBtn.layer.masksToBounds = true
        newConversationButton.titleLabel?.font = theme.newConversationButtonFont
        newConversationButton.isSelected = false
        self.updateNewConversationBtnUI(isSelected: false)
        newConversationButton.setTitleColor(theme.customColorforNewConversation, for: .normal)
        tableView.contentInset.bottom = 70
    }
    
    func updateNewConversationBtnUI(isSelected : Bool){

            let chatImage = UIImage(named: "chat", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            self.newConversationButton.setImage(chatImage, for: .normal)
            self.newConversationButton.setTitle("  " + (HippoProperty.current.newConverstationButtonTitle ?? HippoConfig.shared.strings.newConversation), for: .normal)
            self.newConversationButton.tintColor = HippoConfig.shared.theme.customColorforNewConversation
            self.newConversationButton.backgroundColor = HippoConfig.shared.theme.themeColor

    }
    
    func updateErrorLabelView(isHiding: Bool) {
        if isHiding{
            self.height_ErrorLabel?.constant = 0
            errorLabel.text = ""
        }else{
            self.height_ErrorLabel?.constant = 20
        }
    }
    
    
    func showErrorMessageInTopErrorLabel(withMessage message: String) {
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            return
        }
        self.updateErrorLabelView(isHiding: false)
        self.errorLabel?.text = message
        self.updateErrorLabelView(isHiding: true)
    }
    
    
    func getAllConversations() {
        arrayOfConversation = []
        
        FuguConversation.getAllConversationFromServer(config: config) { [weak self] (result) in
            self?.refreshControl.endRefreshing()
            resetPushCount()
            pushTotalUnreadCount()
          
            guard result.isSuccessful else {
                let errorMessage = result.error?.localizedDescription ?? HippoStrings.somethingWentWrong
                self?.showErrorMessageInTopErrorLabel(withMessage: errorMessage)
                return
            }
            
            var conversation = result.conversations!
            if self?.config.isStaticRemoveConversation ?? false, let status = self?.config.enabledChatStatus, !status.isEmpty {
                let lastChannelId = self?.config.lastChannelId ?? -12
                conversation = conversation.filter({ (con) -> Bool in
                    return (status.contains(con.channelStatus) && lastChannelId != con.channelId)
                })
            }
            
            
            self?.arrayOfConversation = conversation
            self?.arrayOfFullConversation = conversation
            let conversationData = conversation
            if !conversationData.isEmpty{
                self?.filterConversationArr(conversationArr: conversationData)
            }
            
            self?.tableView.reloadData()
            if self?.conversationChatType == .openChat{
                self?.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
            }else if self?.conversationChatType == .closeChat{
                self?.view_NewConversationBtn.isHidden = true
            }else{}
            
        }
    }
    
    func showOpenChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.ongoingConversationArr
        self.tableView.reloadData()
        if self.arrayOfConversation.count > 0{
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func showcloseChatData(){
        self.arrayOfConversation.removeAll()
        self.arrayOfConversation = self.closedConversationArr
        self.tableView.reloadData()
        if self.arrayOfConversation.count > 0{
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
      
    }
    
    func filterConversationArr(conversationArr:[FuguConversation]){
        var tempArrayOfConversation = [FuguConversation]()
        tempArrayOfConversation = conversationArr
        
        self.ongoingConversationArr.removeAll()
        self.ongoingConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 1}
        
        self.closedConversationArr.removeAll()
        self.closedConversationArr = tempArrayOfConversation.filter{$0.channelStatus.rawValue == 2}
        
        if self.conversationChatType == .openChat{
            self.showOpenChatData()
        }else if self.conversationChatType == .closeChat{
            self.showcloseChatData()
        }else{}
        
        if ongoingConversationArr.count == 0 && closedConversationArr.count == 0 && HippoConfig.shared.theme.shouldShowBtnOnChatList == true{
//            self.noConversationFound(true,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else if ongoingConversationArr.count == 0 && closedConversationArr.count == 0{
//            self.noConversationFound(false,HippoConfig.shared.theme.noOpenAndcloseChatError == nil ? HippoStrings.noChatStarted : HippoConfig.shared.theme.noOpenAndcloseChatError ?? "")
        }else{
            
//            self.noConversationFound(false,HippoConfig.shared.theme.noChatUnderCatagoryError == nil ? HippoStrings.noChatInCatagory : HippoConfig.shared.theme.noChatUnderCatagoryError ?? "")
        }
        
    }
    
    func moveToChatViewController(chatObj: FuguConversation) {
        HippoConfig.shared.notifyDidLoad()
        let conversationVC = ConversationsViewController.getWith(conversationObj: chatObj, allConversationConfig: config)
        conversationVC.delegate = self
        conversationVC.hidesBottomBarWhenPushed = true
        HippoConfig.shared.hideTabbar?(true)
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    func updateConversationWith(conversationObj: FuguConversation) {
        
        var chatObj: FuguConversation?
        
        for rawChat in arrayOfConversation {
            guard let channelId = rawChat.channelId,
                  channelId > 0 else {
                      continue
                  }
            if conversationObj.channelId == channelId {
                chatObj = rawChat
                break
            }
        }
        
        if chatObj?.lastMessage?.messageUniqueID != conversationObj.lastMessage?.messageUniqueID{
            self.getAllConversations()
        }
        
        chatObj?.unreadCount = conversationObj.unreadCount
        chatObj?.lastMessage = conversationObj.lastMessage
        chatObj?.channelType = conversationObj.channelType
        
        let obj = arrayOfFullConversation.filter{$0.labelId == conversationObj.labelId}.first
        obj?.unreadCount = 0
        resetPushCount()
//        saveConversationsInCache()
        pushTotalUnreadCount()
        
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }
    
    // MARK: - UIRefreshControl
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        getAllConversations()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
//        saveConversationsInCache()
        HippoConfig.shared.notifiyDeinit()
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func newConversationButtonClicked(_ sender: UIButton) {
        
        guard isPutUserFailed == false else {return}
        if HippoConfig.shared.newChatCallback != nil{
            
            let arrayOfConvo = arrayOfFullConversation
            let chatsAlready = arrayOfConvo.filter { convo in
                return !((convo.channelId ?? 0) <= 0 && convo.labelId != nil)
            }
            
            if let (maxChats, closeHippo) = HippoConfig.shared.newChatCallback?(chatsAlready.count), let maxChats = maxChats{
                if maxChats <= chatsAlready.count {
                    if closeHippo ?? false{
                        self.dismiss(animated: true)
                    }
                    return
                }
            }
        }
        var fuguNewChatAttributes = FuguNewChatAttributes(transactionId: "", userUniqueKey: HippoConfig.shared.userDetail?.userUniqueKey, otherUniqueKey: nil, tags: nil, channelName: nil, preMessage: "", groupingTag: nil)
        
        HippoConfig.shared.log.debug(("bodID******* \(HippoProperty.current.newconversationBotGroupId ?? "")"), level: .info)
        if let botID = HippoProperty.current.newconversationBotGroupId, botID != ""{
            fuguNewChatAttributes.botGroupId = botID
        }
        
        let conversation = ConversationsViewController.getWith(chatAttributes: fuguNewChatAttributes)
        conversation.createConversationOnStart = true
        self.navigationController?.pushViewController(conversation, animated: true)
        self.updateNewConversationBtnUI(isSelected: sender.isSelected)
    }
    
    @IBAction func openChatButtonClicked(_ sender: UIButton) {
        guard conversationChatType != .openChat else {
            return
        }
        self.openChatButton.titleLabel?.font = UIFont.bold(ofSize: 15)
        self.closeChatButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        self.view_NewConversationBtn.isHidden = !HippoProperty.current.enableNewConversationButton
        conversationChatType = .openChat
        otherBottomLineView.backgroundColor = .clear
        bottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
        self.showOpenChatData()
    }
    
    @IBAction func closeChatButtonClicked(_ sender: Any) {
        guard conversationChatType != .closeChat else {
            return
        }
        self.openChatButton.titleLabel?.font = UIFont.regular(ofSize: 16)
        self.closeChatButton.titleLabel?.font = UIFont.bold(ofSize: 16)
        self.view_NewConversationBtn.isHidden = true
        conversationChatType = .closeChat
        bottomLineView.backgroundColor = .clear
        otherBottomLineView.backgroundColor = HippoConfig.shared.theme.themeColor
        self.showcloseChatData()
    }
}


// MARK: - UITableViewDataSource

extension NewAllConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
  
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfConversation.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCellCustom", for: indexPath) as? ConversationView else {
            return UITableViewCell()
        }
        
        
        let convObj = arrayOfConversation[indexPath.row]
        cell.configureConversationCell(resetProperties: true, conersationObj: convObj)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return arrayOfConversation.count < 0 ? tableView.frame.height : 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        let footerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: (tableView.frame.height / 2) - 90, width: tableView.frame.width, height: 90))
        footerLabel.textAlignment = NSTextAlignment.center
        footerLabel.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
        footerLabel.numberOfLines = 0
        footerLabel.font = UIFont.regular(ofSize: 16.0)
        
//        footerLabel.text = tableViewDefaultText
        
        footerView.addSubview(footerLabel)
        
//        let emptyAction = UITapGestureRecognizer(target: self, action: #selector(headerEmptyAction(_:)))
//        footerView.addGestureRecognizer(emptyAction)
        
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.isUserInteractionEnabled = false
        fuguDelay(1) {
            tableView.isUserInteractionEnabled = true
        }
        
        let conversationObj = arrayOfConversation[indexPath.row]
        let fullconversationObj = arrayOfFullConversation.filter{$0.channelId == arrayOfConversation[indexPath.row].channelId}
        moveToChatViewController(chatObj: conversationObj)
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            resetPushCount()
            conversationObj.unreadCount = 0
            fullconversationObj.first?.unreadCount = 0
//            saveConversationsInCache()
            pushTotalUnreadCount()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
