//
//  ConversationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/9/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import Photos

class LeadDataTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

protocol NewChatSentDelegate: class {
    func updateConversationWith(conversationObj: FuguConversation)
}


class ConversationsViewController: HippoConversationViewController {//}, UIGestureRecognizerDelegate {
    
    //MARK: Constants
    var createConversationOnStart = false
    var hideBackButton: Bool = false
    
    var consultNowInfoDict = [String: Any]()
    var isComingFromConsultNowButton = false
    var createTicketVM = CreateTicketVM()
    var popover : LCPopover?
    
    // MARK: -  IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var audioCAllButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var navigationBackgroundView: UIView!
    //   @IBOutlet var navigationTitleLabel: UILabel!
    //   @IBOutlet var backButton: UIButton!
    
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageTextView: UITextView!
    //   @IBOutlet weak var errorContentView: UIView!
    //   @IBOutlet var errorLabel: UILabel!
    @IBOutlet var textViewBgView: UIView!
    @IBOutlet var placeHolderLabel: UILabel!
    @IBOutlet var addFileButtonAction: UIButton!{
        didSet{
            addFileButtonAction.imageView?.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet var seperatorView: UIView!
    @IBOutlet weak var loaderView: So_UIImageView!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var audioCallButton: UIBarButtonItem!
    @IBOutlet weak var videoButton: UIBarButtonItem!
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    
    //   @IBOutlet weak var hieghtOfNavigationBar: NSLayoutConstraint!
    
    @IBOutlet weak var loadMoreActivityTopContraint: NSLayoutConstraint!
    @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var suggestionContainerView: UIView!
    
    //New conversation view
    @IBOutlet weak var newConversationContainer: So_UIView!
    @IBOutlet weak var newConversationLabel: So_CustomLabel!
    @IBOutlet weak var newConversationShadow: So_UIView!
    @IBOutlet weak var newConversationCountButton: UIButton!
    @IBOutlet weak var retryLabelView: UIView!
    @IBOutlet weak var retryLabelViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chatScreenTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var retryLoader: UIActivityIndicatorView!
    @IBOutlet weak var labelViewRetryButton: UIButton!{
        didSet{
            let attributedString = NSAttributedString(string: HippoConfig.shared.theme.chatListRetryBtnText == nil ? HippoStrings.retry : HippoConfig.shared.theme.chatListRetryBtnText ?? "", attributes:[
                NSAttributedString.Key.font : UIFont.bold(ofSize: 15.0),
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.underlineStyle:1.0
            ])
            labelViewRetryButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    @IBOutlet weak var collectionViewOptions: UICollectionView!
    @IBOutlet weak var attachmentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var label_slowInternet : UILabel!{
        didSet{
            label_slowInternet.font = UIFont.regular(ofSize: 15.0)
            label_slowInternet.text = HippoStrings.slowInternet
        }
    }
    @IBOutlet weak var Button_CancelEdit : UIButton!{
        didSet{
            Button_CancelEdit.imageView?.tintColor = .black
            Button_CancelEdit.setImage(HippoConfig.shared.theme.cancelIcon, for: .normal)
        }
    }
    @IBOutlet weak var Button_EditMessage : UIButton!{
        didSet{
            Button_EditMessage.imageView?.tintColor = .black
            Button_EditMessage.setImage(UIImage(named: "tick_green", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    var suggestionCollectionView = SuggestionView()
    var suggestionList: [String] = []
    
    var transparentView = UIView()
    var lineLabel = UILabel()
    var customTableView = UITableView()
    //    let height: CGFloat = 175//125//250
    //    var actionSheetTitleArr = ["Photo & Video Library","Camera","Document"]
    //    var actionSheetImageArr = ["Library","Camera","Library"]
    
    var hieghtOfNavigationBar: CGFloat = 0
    var messageInEditing : HippoMessage?
    var editingMessageIndex : IndexPath?
    //    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    // MARK: - Computed Properties
    var localFilePath: String {
        get {
            let existingImageCounter = FuguDefaults.totalImagesInImagesFlder() + 1
            guard
                let documentImageUrl = FuguDefaults.fuguImagesDirectory(),
                existingImageCounter > 0
                else { return "" }
            return documentImageUrl.appendingPathComponent("\(existingImageCounter).jpg").path
        }
    }

   
    deinit {
        HippoChannel.botMessageMUID = nil
        NotificationCenter.default.removeObserver(self)
        HippoConfig.shared.notifiyDeinit()
    }
   
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view_Navigation.call_button.addTarget(self, action: #selector(audiCallButtonClicked(_:)), for: .touchUpInside)
        view_Navigation.video_button.addTarget(self, action: #selector(videoButtonClicked(_:)), for: .touchUpInside)
        
        collectionViewOptions?.delegate = self
        collectionViewOptions?.dataSource = self
        customTableView.isScrollEnabled = false//true
        customTableView.separatorStyle = .none
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        
        self.setTitleForCustomNavigationBar()
        //super.viewDidLoad()
        addObserver()
        setNavBarHeightAccordingtoSafeArea()
        configureChatScreen()
        setThemeForBusiness()
        HippoConfig.shared.notifyDidLoad()
        
        guard channel != nil else {
            if createConversationOnStart {
                
                if directChatDetail != nil {
//                    HippoChannel.get(withFuguChatAttributes: directChatDetail!) { [weak self] (r) in
                    HippoChannel.get(withFuguChatAttributes: directChatDetail!, isComingFromConsultNow: isComingFromConsultNowButton, methodIsOnlyCallForChannelAvailableInLocalOrNot: true) { [weak self] (r) in
                        let result = r
                        if result.isChannelAvailableLocallay{
                            if result.channel != nil, let chnl = result.channel{
                                self?.channel = chnl
                                self?.channel.delegate = self
                                self?.populateTableViewWithChannelData()
                                self?.fetchMessagesFrom1stPage()
                                HippoConfig.shared.notifyDidLoad()
                            }else{
                                self?.startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
                                    guard success else {
                                        return
                                    }
                                    if self?.isComingFromConsultNowButton == true  && !(result?.channel?.chatDetail?.agentAlreadyAssigned ?? false) { // checked
                                        self?.isComingFromConsultNowButton = false
                                        self?.callAssignAgentApi(completion: { [weak self] (success) in
                                            guard success == true else {
                                                return
                                            }
                                            self?.populateTableViewWithChannelData()
                                            self?.fetchMessagesFrom1stPage()
                                        })
                                    } else {
                                        self?.populateTableViewWithChannelData()
                                        self?.fetchMessagesFrom1stPage()
                                    }
                                })
                            }
                        }else{
                            self?.startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
                                guard success else {
                                    return
                                }
                                if self?.isComingFromConsultNowButton == true  && !(result?.channel?.chatDetail?.agentAlreadyAssigned ?? false) { // checked
                                    self?.isComingFromConsultNowButton = false
                                    self?.callAssignAgentApi(completion: { [weak self] (success) in
                                        guard success == true else {
                                            return
                                        }
                                        self?.populateTableViewWithChannelData()
                                        self?.fetchMessagesFrom1stPage()
                                    })
                                } else {
                                    self?.populateTableViewWithChannelData()
                                    self?.fetchMessagesFrom1stPage()
                                }
                            })
                        }
                    }
                } else {
                    startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
                        guard success else {
                            return
                        }
                        if self?.isComingFromConsultNowButton == true  && !(result?.channel?.chatDetail?.agentAlreadyAssigned ?? false) { // checked
                            self?.isComingFromConsultNowButton = false
                            self?.callAssignAgentApi(completion: { [weak self] (success) in
                                guard success == true else {
                                    return
                                }
                                self?.populateTableViewWithChannelData()
                                self?.fetchMessagesFrom1stPage()
                            })
                        } else {
                            self?.populateTableViewWithChannelData()
                            self?.fetchMessagesFrom1stPage()
                        }
                    })
                }
            } else {
                fetchMessagesFrom1stPage()
            }
            return
        }
        
        channel.delegate = self
        if !channel.isSubscribed(){
            channel?.subscribe()
        }
        populateTableViewWithChannelData()
        fetchMessagesFrom1stPage()
        //HippoConfig.shared.notifyDidLoad()//
        
    }
    
    override func startEditing(with message : HippoMessage, indexPath : IndexPath){
        self.editingMessageIndex = indexPath
        self.messageEditingStarted(with: message)
    }
    
    func clearp2pdata(){
        if self.channel?.chatDetail?.chatType == .p2p{
            // * save data for p2punread count if transaction id is saved in local
            if let data = P2PUnreadData.shared.getData(with: self.directChatDetail?.transactionId ?? ""){
                let id = ((self.directChatDetail?.transactionId ?? "") + "-" + (self.directChatDetail?.otherUniqueKey?.first ?? ""))
                if data.id == id{
                    P2PUnreadData.shared.updateChannelId(transactionId: self.directChatDetail?.transactionId ?? "", channelId: self.channelId, count: 0, otherUserUniqueKey: self.directChatDetail?.otherUniqueKey?.first)
                }
            }
        }
    }
    
    //    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    //        let touchPoint = sender.location(in: self.view?.window)
    //        let percent = max(sender.translation(in: view).x, 0) / view.frame.width
    //        let velocity = sender.velocity(in: view).x
    //
    //        if sender.state == UIGestureRecognizer.State.began {
    //            initialTouchPoint = touchPoint
    //        } else if sender.state == UIGestureRecognizer.State.changed {
    //            if touchPoint.x - initialTouchPoint.x > 0 {
    //                self.view.frame = CGRect(x: touchPoint.x - initialTouchPoint.x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    //            }
    //        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
    //
    //            if percent > 0.5 || velocity > 1000 {
    //                navigationController?.popViewController(animated: true)
    //            } else {
    //                UIView.animate(withDuration: 0.3, animations: {
    //                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    //                })
    //            }
    //        }
    //    }
    
    
    
   override  func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
     HippoConfig.shared.hideTabbar?(true)
      tableViewChat.contentInset.top = 12
      messageTextView.contentInset.top = 8
      self.navigationController?.isNavigationBarHidden = true
        tableViewChat.allowsSelection = false
    checkNetworkConnection()
//        if transparentView != nil{
//            onClickTransparentView()
//        }
        onClickTransparentView()
    
      handleVideoIcon()
      handleAudioIcon()
      HippoConfig.shared.notifyDidLoad()
    
   }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaderView.isHidden {
            startLoaderAnimation()
        }
        reloadVisibleCellsToStartActivityIndicator()
        HippoConfig.shared.notifyDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        
        //hide
//        self.tabBarController?.hidesBottomBarWhenPushed = true
//        self.tabBarController?.tabBar.isHidden = true
//        self.tabBarController?.tabBar.layer.zPosition = -1
 //       HippoConfig.shared.hideTabbar?(true)
    }

    override func closeKeyBoard() {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
    }
   
    override func addRemoveShadowInTextView(toAdd: Bool) {
      guard isViewLoaded else {
         return
      }
      
      self.seperatorView.isHidden = true
      self.seperatorView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.9294117647, alpha: 1)
      if toAdd {
         self.seperatorView.isHidden = false
      }
   }
    
    override func reloadVisibleCellsToStartActivityIndicator() {
      let visibleCellsIndexPath = tableViewChat.visibleCells
      
      for cell in visibleCellsIndexPath {
         if let outImageCell = cell as? OutgoingImageCell, !outImageCell.customIndicator.isHidden {
            outImageCell.startIndicatorAnimation()
         }
         
         if let inImageCell = cell as? IncomingImageCell, !inImageCell.customIndicator.isHidden {
            inImageCell.startIndicatorAnimation()
         }
         
      }
   }
      
   override  func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    
   }
   
    override func didSetChannel() {
        channel?.delegate = self
        if !channel.isSubscribed(){
            channel?.subscribe()
        }
    }
    
    func navigationSetUp() {
        /*navigationBackgroundView.layer.shadowColor = UIColor.black.cgColor
        navigationBackgroundView.layer.shadowOpacity = 0.25
        navigationBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        navigationBackgroundView.layer.shadowRadius = 4
        
        navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor*/
        //      navigationTitleLabel.textColor = HippoConfig.shared.theme.headerTextColor
        //
        //      if HippoConfig.shared.theme.headerTextFont  != nil {
        //         navigationTitleLabel.font = HippoConfig.shared.theme.headerTextFont
        //      }
        
        if HippoConfig.shared.theme.sendBtnIcon != nil {
            
            if let tintColor = HippoConfig.shared.theme.sendBtnIconTintColor {
                sendMessageButton.imageView?.tintColor = tintColor
            }else{
                sendMessageButton.imageView?.tintColor = HippoConfig.shared.theme.themeColor
            }
            sendMessageButton.setImage(HippoConfig.shared.theme.sendBtnIcon, for: .normal)
            sendMessageButton.setTitle("", for: .normal)
        } else { sendMessageButton.setTitle(HippoStrings.send, for: .normal) }
        
        if HippoConfig.shared.theme.addButtonIcon != nil {
            
            if let tintColor = HippoConfig.shared.theme.addBtnTintColor {
                addFileButtonAction.imageView?.tintColor = tintColor
            }else{
                addFileButtonAction.imageView?.tintColor = HippoConfig.shared.theme.themeColor
            }
            addFileButtonAction.setImage(HippoConfig.shared.theme.addButtonIcon, for: .normal)
            addFileButtonAction.setTitle("", for: .normal)
        } else { addFileButtonAction.setTitle("ADD", for: .normal) }
        
        
        handleBackButton()
        if let businessName = userDetailData["business_name"] as? String, label.isEmpty {
            label = businessName
        }
        setTitleForCustomNavigationBar()
//      }

   }
    
    func setUpSuggestionsDataAndUI(){
        if HippoConfig.shared.isSuggestionNeeded == false{
            suggestionContainerView.isHidden = true
            return
        }
        if self.messagesGroupedByDate.count > 0 {
            let givenMessagesArray = self.messagesGroupedByDate[self.messagesGroupedByDate.count - 1]
            if givenMessagesArray.count >= HippoConfig.shared.maxSuggestionCount {
                suggestionContainerView.isHidden = true
                return
            }
        }
        suggestionContainerView.isHidden = false
        prepareSuggestionArray()
        prepareSuggestionUI()
    }
    
    func prepareSuggestionArray() {
        checkAutoSuggestions()
    }
    
    private func checkAutoSuggestions() {
        if messagesGroupedByDate.count == 0{
            updateData(id: -1)
            return
        //}else if let lastMessage = getLastMessage(), lastMessage.type == MessageType.normal{
        }else if let lastMessage = getLastMessage(), lastMessage.type == MessageType.normal && isSentByMe(senderId: lastMessage.senderId) == false{
           //try {
            if let id = HippoConfig.shared.questions[lastMessage.message]{
                if id > -1 {
                    suggestionContainerView.isHidden = false
                    updateData(id: id)
                    return
                }
            }else{
                suggestionContainerView.isHidden = true
            }
            //} catch (Exception e) {
            //    print("Exception")
            //}
        }else{
            suggestionContainerView.isHidden = true
        }
        
//        if HippoConfig.shared.isSuggestionNeeded {
//            //HippoConfig.shared.isSuggestionNeeded = false
//            updateData(id: 0)
//        }
        
    }
    
    private func updateData(id: Int) {
        var data = [String]()
        var ids = [Int]()
        
        if let suggestionsIdsArr = HippoConfig.shared.mapping[id]{
            ids = suggestionsIdsArr
            if ids.count > 0{
                for i in 0..<ids.count{
                    if let suggestionsStr = HippoConfig.shared.suggestions[ids[i]] {
                        data.append(suggestionsStr)
                    }
                }
            }
        }
        
        suggestionList.removeAll()
        suggestionList = data
    
    }
    
    func prepareSuggestionUI() {
        let theme = HippoConfig.shared.theme
        self.suggestionContainerView.addSubview(suggestionCollectionView)
        suggestionCollectionView.backgroundColor = theme.themeColor
        let bundle = FuguFlowManager.bundle
        suggestionCollectionView.register(UINib(nibName: "SuggestionCell", bundle: bundle) , forCellWithReuseIdentifier: "SuggestionCell")
        suggestionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let suggestionTopToViewTopMargin = NSLayoutConstraint(item: suggestionCollectionView, attribute: .top, relatedBy: .equal, toItem: self.suggestionContainerView, attribute: .topMargin, multiplier: 1, constant: 0)
        let suggestionLeadingToViewLeading = NSLayoutConstraint(item: suggestionCollectionView, attribute: .leading, relatedBy: .equal, toItem: self.suggestionContainerView, attribute: .leading, multiplier: 1, constant: 0)
        let suggestionTrailingToViewTrailing = NSLayoutConstraint(item: suggestionCollectionView, attribute: .trailing, relatedBy: .equal, toItem: self.suggestionContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        //let suggestionHeight = NSLayoutConstraint(item: suggestionCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let suggestionBottomToViewBottomMargin = NSLayoutConstraint(item: suggestionCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self.suggestionContainerView, attribute: .bottom, multiplier: 1, constant: 0)
        self.suggestionContainerView.addConstraints([suggestionTopToViewTopMargin, suggestionLeadingToViewLeading, suggestionTrailingToViewTrailing, suggestionBottomToViewBottomMargin])//suggestionHeight])//
        
        //suggestionCollectionView.frame = suggestionContainerView.frame
        
        suggestionCollectionView.customDataSource?.update(suggestions: suggestionList, nextURL: nil)
        suggestionCollectionView.customDelegate?.update(vc: self)
        
        suggestionCollectionView.reloadData()
        
    }
    
//    func getMessage() -> HippoMessage?{
//        if self.messagesGroupedByDate.count > 0 {
//            let givenMessagesArray = self.messagesGroupedByDate[self.messagesGroupedByDate.count - 1]
//            if givenMessagesArray.count > 0 {
//                let message = givenMessagesArray[givenMessagesArray.count - 1]
//                let messageType = message.type
//                return message
//            }
//            return nil
//        }
//        return nil
//    }
   
    func handleBackButton() {
        let hideBackButton = (directChatDetail?.hideBackButton ?? false) || self.hideBackButton
        self.titleForNavigation?.setBackButton(hide: hideBackButton)
    }
    func addObserver() {
        guard HippoUserDetail.fuguEnUserID == nil else {
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(putUserSuccess), name: .putUserSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putUserFail), name: .putUserFailure, object: nil)
    }
    @objc func putUserSuccess() {
        stopLoaderAnimation()
        setThemeForBusiness()
        
        guard channel != nil else {
          if createConversationOnStart {
              startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
                  guard success else {
                      return
                  }
                
                //self?.populateTableViewWithChannelData()
                //self?.fetchMessagesFrom1stPage()
//                if self?.isComingFromConsultNowButton == true{
                if self?.isComingFromConsultNowButton == true && !(result?.channel?.chatDetail?.agentAlreadyAssigned ?? false) {
                    self?.isComingFromConsultNowButton = false
                    self?.callAssignAgentApi(completion: { [weak self] (success) in
                        guard success == true else {
                            return
                        }
                        self?.populateTableViewWithChannelData()
                        self?.fetchMessagesFrom1stPage()
                    })
                }else{
                    self?.populateTableViewWithChannelData()
                    self?.fetchMessagesFrom1stPage()
                }
                
              })
          } else {
              fetchMessagesFrom1stPage()
          }
          return
         }
        
        channel.delegate = self
        if !channel.isSubscribed(){
            channel?.subscribe()
        }
        populateTableViewWithChannelData()
        fetchMessagesFrom1stPage()
        HippoConfig.shared.notifyDidLoad()
    }
    @objc func putUserFail() {
        stopLoaderAnimation()
    }
    
    func setKeyboardType(message:HippoMessage)
    {
        
        switch message.keyboardType {
        case .none:
            disableSendingReply(withOutUpdate: true)
            break
        case .numberKeyboard:
            enableSendingReply(withOutUpdate: true)
            messageTextView.keyboardType = .decimalPad
            
            break
        case .defaultKeyboard :
            enableSendingReply(withOutUpdate: true)
            messageTextView.keyboardType = .default
            
            break
        default:
            enableSendingReply(withOutUpdate: true)
            messageTextView.keyboardType = .default
           
        }
        
        messageTextView.reloadInputViews()
    }
    
    
// MARK: - UIButton Actions
    
    @IBAction func actionButtonClicked(_ sender: Any) {
//        presentActionsForCustomer(sender: self.view)
    }
    @IBAction func audiCallButtonClicked(_ sender: Any) {
        startAudioCall()
    }
    @IBAction func videoButtonClicked(_ sender: Any) {
     startVideoCall()
   }
    
    @IBAction func addAttachmentButtonAction(_ sender: UIButton) {
        attachmentViewHeightConstraint.constant = attachmentViewHeightConstraint.constant == 128 ? 0 : 128
        
    }
    
   @IBAction func addImagesButtonAction(_ sender: UIButton) {
      if channel != nil, !channel.isSubscribed() {
        buttonClickedOnNetworkOff()
        return
      }
    
    //attachmentButtonclicked(sender)
    closeKeyBoard()
    actionSheetTitleArr.removeAll()
    actionSheetImageArr.removeAll()
    actionSheetTitleArr = [HippoStrings.photoLibrary,HippoStrings.camera,HippoStrings.document]
    actionSheetImageArr = ["Library","Camera","Library"]
    heightForActionSheet = CGFloat((actionSheetTitleArr.count * 60))
    isProceedToPayActionSheet = false
    self.openCustomSheet()
    
   }
    
    @IBAction func newConversationCountButtonAction(_ sender: Any) {
        //        newConversationLabel.text = nil
        //        newConversationLabel.isHidden = true
        //        newConversationCounter  = 0
        scrollTableViewToBottom(true)
    }
    
    //MARK:- IBAction for retryBtn on label
    @IBAction func retryLabelButtonTapped(_ sender: Any) {
        chatScreenTableViewTopConstraint.constant = 0
        
        retryLoader.isHidden = false
        labelViewRetryButton.isHidden = true
        fuguDelay(2.0) {
            self.fetchMessagesFrom1stPage()
        }
        
    }

    func buttonClickedOnNetworkOff() {
        guard !FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        messageTextView.resignFirstResponder()
        showAlertForNoInternetConnection()
    }
    
    override func openCustomSheet(){
        
        HippoConfig.shared.HideJitsiView()
        
        self.customTableView.reloadData()
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let screenSize = UIScreen.main.bounds.size
        transparentView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        window?.addSubview(transparentView)
        
        customTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: heightForActionSheet)
        customTableView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            customTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            //Fallback on earlier versions
        }
        window?.addSubview(customTableView)
        
        lineLabel.frame = CGRect(x: (screenSize.width/2) - ((screenSize.width/5)/2) , y: screenSize.height, width: screenSize.width/5, height: 6)
        lineLabel.backgroundColor = .white
        lineLabel.layer.masksToBounds = true
        lineLabel.layer.cornerRadius = 4
        window?.addSubview(lineLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        transparentView.addGestureRecognizer(swipeDown)
        
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.customTableView.frame = CGRect(x: 0, y: screenSize.height - self.heightForActionSheet, width: screenSize.width, height: self.heightForActionSheet)
            self.lineLabel.frame = CGRect(x: (screenSize.width/2) - ((screenSize.width/5)/2) , y: (screenSize.height - self.heightForActionSheet) - 20, width: screenSize.width/5, height: 6)
        }, completion: nil)
    }
    @objc func onClickTransparentView() {
        HippoConfig.shared.UnhideJitsiView()
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.customTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.heightForActionSheet)
            self.lineLabel.frame = CGRect(x: (screenSize.width/2) - ((screenSize.width/5)/2) , y: screenSize.height, width: screenSize.width/5, height: 6)
        }, completion: nil)
    }
    
    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
        self.sendMessageButtonAction(messageTextStr: messageTextView.text)
    }
    
    func sendMessageButtonAction(messageTextStr: String){

        if storeResponse?.restrictPersonalInfo ?? false && channel?.chatDetail?.chatType == .other{
            if messageTextStr.isValidPhoneNumber() || messageTextStr.isValidEmail(){
                showErrorMessage(messageString: HippoStrings.donotAllowPersonalInfo)
                updateErrorLabelView(isHiding: true)
                return
            }

        }
        
        if channel != nil, !channel.isSubscribed()  {
            channel.subscribe()
        }
        
        if FuguNetworkHandler.shared.isNetworkConnected == false || SocketClient.shared.isConnected() == false{
            return
        }
        
        if isMessageInvalid(messageText: messageTextStr) {
            return
        }
        let trimmedMessage = messageTextStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let message = HippoMessage(message: trimmedMessage, type: .normal, uniqueID: String.generateUniqueId(), chatType: channel?.chatDetail?.chatType)
        
        // Check if we have quick reply pending action
        sendQuickReplyReposeIfRequired()
        
        channel?.unsentMessages.append(message)
        if channel != nil {
            addMessageToUIBeforeSending(message: message)
            self.sendMessage(message: message)
        } else {
            //TODO: - Loader animation
            let replyMessage = botGroupID != nil ? message : nil
            
            var checkBoolForApiHit = false
            if isDefaultChannel() {
                if replyMessage == nil{
                    checkBoolForApiHit = true
                }else{
                    checkBoolForApiHit = false
                }
            } else{
                checkBoolForApiHit = false
            }
            
            startNewConversation(replyMessage: replyMessage, completion: { [weak self] (success, result) in
                guard success else {
                    return
                }
                self?.populateTableViewWithChannelData()
                
                let isReplyMessageSent = result?.isReplyMessageSent ?? false
                let isGetMessageIsSuccess: Bool = result?.isGetMesssagesSuccess ?? false
                
                if !isGetMessageIsSuccess {
                    self?.addMessageToUIBeforeSending(message: message)
                } else {
                    self?.messageTextView.text = ""
                }
                
                if !isReplyMessageSent {
                    self?.sendMessage(message: message)
                    
                    if checkBoolForApiHit == true{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            // your code hear
                            self?.getMessagesAfterCreateConversation(callback: { (success) in
                                //print(success)
                                checkBoolForApiHit = false
                            })
                        })
                    }
                }
                
            })
        }
    }
   
    override func callGetMessagesApi(){
        self.getMessagesAfterCreateConversation(callback: { (success) in
        })
    }
    
    func sendQuickReplyReposeIfRequired() {
        guard self.channel != nil else {
            return
        }
        guard let quickReplyMessage = self.getMessageForQuickReply(messages: self.channel.messages), quickReplyMessage.values.isEmpty, !quickReplyMessage.content.actionId.isEmpty else {
            return
        }
        var selectedActionId = quickReplyMessage.defaultActionId ?? ""
        if !quickReplyMessage.content.buttonTitles.isEmpty, selectedActionId.isEmpty {
            selectedActionId = quickReplyMessage.content.actionId[0]
        }
        quickReplyMessage.selectedActionId = selectedActionId
        let index = quickReplyMessage.content.actionId.firstIndex(of: selectedActionId) ?? 0
        self.sendQuickMessage(shouldSendButtonTitle: false, chat: quickReplyMessage, buttonIndex: index)
    }
    
    override func addMessageToUIBeforeSending(message: HippoMessage) {
      self.updateMessagesArrayLocallyForUIUpdation(message)
      self.messageTextView.text = ""
      self.newScrollToBottom(animated: false)
   }
   
   
   
   @IBAction func backButtonAction(_ sender: UIButton) {
       backButtonClicked()
   }
    func setThemeForBusiness() {
        let isMultiChannelLabelMapping = BussinessProperty.current.multiChannelLabelMapping && !forceHideActionButton
            
     //   actionButton.title = nil
//        actionButton.image = isMultiChannelLabelMapping ? HippoConfig.shared.theme.actionButtonIcon : nil
//        actionButton.tintColor = HippoConfig.shared.theme.actionButtonIconTintColor
    }
    
   override func backButtonClicked() {
         HippoConfig.shared.hideTabbar?(false)
        super.backButtonClicked()
        backNavigationDataSaving()
        if self.navigationController == nil {
            HippoConfig.shared.notifiyDeinit()
            dismiss(animated: true, completion: nil)
        } else {
            if self.navigationController!.viewControllers.count > 1 {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                HippoConfig.shared.notifiyDeinit()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
   }
    
    func backNavigationDataSaving(){
        messageTextView.resignFirstResponder()
        
        channel?.send(message: HippoMessage.stopTyping, completion: {})
        let rawLabelID = self.labelId == -1 ? nil : self.labelId
        let channelID = self.channel?.id ?? -1
        
        clearUnreadCountForChannel(id: channelID)
        if let lastMessage = getLastMessage(), let conversationInfo = FuguConversation(channelId: channelID, unreadCount: 0, lastMessage: lastMessage, labelID: rawLabelID) {
            
            delegate?.updateConversationWith(conversationObj: conversationInfo)
        }
        
        //if chat delegate is not set , it doesnot exist in allconversation
        if delegate == nil{
            for controller in self.navigationController?.viewControllers ?? [UIViewController](){
                if controller is AllConversationsViewController{
                    (controller as? AllConversationsViewController)?.getAllConversations()
                    break
                }
            }
        }
        
        if channel != nil {
            self.channel.saveMessagesInCache()
            self.channel.deinitObservers()
        }
    }
    
 override func clearUnreadCountForChannel(id: Int) {
        
        let channelRaw: [String: Any] = ["channel_id": id]
        resetForChannel(pushInfo: channelRaw)
        
        var chats = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] ?? [[:]]
        let index = chats.firstIndex { (o) -> Bool in
            return (o["channel_id"] as? Int) ?? -2 == id
        }
        
        if index != nil {
            var obj = chats[index!]
            obj["unread_count"] = 0
            chats[index!] = obj
            FuguDefaults.set(value: chats, forKey: DefaultName.conversationData.rawValue)
            pushTotalUnreadCount()
        }
    }

    func disableSendingReply(withOutUpdate: Bool = false) {
        if !withOutUpdate {
            self.channel?.isSendingDisabled = true
        }
        self.view.endEditing(true)
        self.textViewBottomConstraint.constant = 0
        self.textViewBottomConstraint.constant = -self.textViewBgView.frame.height
        self.textViewBgView.isHidden = true
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    func enableSendingReply(withOutUpdate: Bool = false) {
        if !withOutUpdate {
            self.channel?.isSendingDisabled = false
        }
       
        let isSendingDisabled =  self.channel?.isSendingDisabled ?? false
        if isSendingDisabled && withOutUpdate {
            return
        }
        if self.textViewBottomConstraint.constant < 0 {
        self.textViewBottomConstraint.constant = 0
        }
//        self.textViewBottomConstraint.constant = self.textViewBgView.frame.height
        self.textViewBgView.isHidden = false
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    func getLastMessage() -> HippoMessage? {
        
        for groupedMessages in messagesGroupedByDate.reversed() {
            for tempMessage in groupedMessages.reversed() {
               
                if tempMessage.senderId == getSavedUserId {
                    if tempMessage.status != .none {
                        return tempMessage
                    }
                    continue
                }
                
                return tempMessage
            }
        }
        
        return nil
    }
   
   
    override func adjustChatWhenKeyboardIsOpened(withHeight keyboardHeight: CGFloat) {
        // TODO: - Refactor
        guard tableViewChat.contentSize.height + keyboardHeight > UIScreen.main.bounds.height - hieghtOfNavigationBar else {
            print("return****")
            return
        }
        
        let diff = ((tableViewChat.contentSize.height + keyboardHeight) - (UIScreen.main.bounds.height - hieghtOfNavigationBar))
        
        let keyboardHeightNew = keyboardHeight - textViewBgView.frame.height - UIView.safeAreaInsetOfKeyWindow.bottom
        
        let mini = min(diff, keyboardHeightNew)
        
        var newOffSetY = tableViewChat.contentOffset.y + mini
        if !shouldShiftUpWithThis(newOffsetY: newOffSetY) {
            newOffSetY = getMaxScrollableOffset()
        }
        
        let newOffSet = CGPoint(x: 0, y: newOffSetY)
        tableViewChat.setContentOffset(newOffSet, animated: false)
    }
    
//    override func checkNetworkConnection() {
//        errorLabel.backgroundColor = UIColor.red
//        if FuguNetworkHandler.shared.isNetworkConnected {
//            errorLabelTopConstraint.constant = -20
//            updateErrorLabelView(isHiding: true)
//        } else {
//            errorLabelTopConstraint.constant = -20
//            errorLabel.text = HippoStrings.noNetworkConnection
//            updateErrorLabelView(isHiding: false)
//        }
//    }
   
    func isPaginationInProgress() -> Bool {
        return loadMoreActivityTopContraint.constant == 10
    }
    override func startLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.startRotationAnimation()
        }
    }
    
    override func stopLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.stopRotationAnimation()
        }
    }
    
   // MARK: - SERVER HIT
    override func getMessagesBasedOnChannel(fromMessage pageStart: Int, pageEnd: Int?, completion: ((_ success: Bool) -> Void)?) {
      guard channel != nil else {
         completion?(false)
         return
      }
      
      if FuguNetworkHandler.shared.isNetworkConnected == false {
         checkNetworkConnection()
         completion?(false)
         return
      }
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         showHideActivityIndicator()
         completion?(false)
         return
      }
      
      if pageStart == 1, channel.messages.count == 0 {
         startLoaderAnimation()
         disableSendingNewMessages()
      } else if !isPaginationInProgress() {
//            startGettingNewMessages()
       }
        let request = MessageStore.messageRequest(pageStart: pageStart, showLoader: false, pageEnd: pageEnd, channelId: channel.id, labelId: -1)
        
        storeRequest = request
        storeResponse = nil
        clearp2pdata()
        MessageStore.getMessages(requestParam: request, ignoreIfInProgress: false) {[weak self] (response, isCreateConversationRequired)  in
            
            self?.hideErrorMessage()
            self?.enableSendingNewMessages()
            self?.stopLoaderAnimation()
            self?.showHideActivityIndicator(hide: true)
            self?.isGettingMessageViaPaginationInProgress = false
            
            guard let result = response, result.isSuccessFull, let weakself = self else {
                completion?(false)
                if HippoConfig.shared.shouldShowSlowInternetBar ?? true{
                  self?.goForApiRetry()
                }
                return
            }
            weakself.storeResponse = result
            weakself.hideRetryLabelView()
            weakself.handleSuccessCompletionOfGetMessages(result: result, request: request, completion: completion)
        }
   }
   
    func handleSuccessCompletionOfGetMessages(result: MessageStore.ChannelMessagesResult, request: MessageStore.messageRequest, completion: ((_ success: Bool) -> Void)?) {
        
        var messages = result.newMessages
        let newMessagesHashMap = result.newMessageHashmap

        label = result.channelName
        userImage = result.chatDetail?.channelImageUrl
        channel?.chatDetail = result.chatDetail
        
        setTitleForCustomNavigationBar()
        handleVideoIcon()
        handleAudioIcon()
        
        if request.pageStart == 1 && messages.count > 0 {
            filterMessages(newMessagesHashMap: newMessagesHashMap, lastMessage: messages.last!)
        } else if messages.count > 0 {
            messages = filterForMultipleMuid(newMessages: messages, newMessagesHashMap: newMessagesHashMap)
        }
        
        updateMessagesInLocalArrays(messages: messages)
        
        if channel != nil {
            self.channel.saveMessagesInCache()
        }
        if (messages.count > 0)
        {
            self.setKeyboardType(message: messages.last!)
        }
        
        
        let contentOffsetBeforeNewMessages = tableViewChat.contentOffset.y
        let contentHeightBeforeNewMessages = tableViewChat.contentSize.height
        tableViewChat.reloadData()
        
        if request.pageStart > 1 {
            keepTableViewWhereItWasBeforeReload(oldContentHeight: contentHeightBeforeNewMessages, oldYOffset: contentOffsetBeforeNewMessages)
        }
        if result.isSendingDisabled || forceDisableReply || checkIfShouldDisableReplyForCreateTicket(messages: messages){
            disableSendingReply()
        }
        if request.pageStart == 1, request.pageEnd == nil {
            newScrollToBottom(animated: true)
            sendReadAllNotification()
        }
        
        willPaginationWork = result.isMoreDataToLoad
        
        completion?(true)
    }
    
    private func checkIfShouldDisableReplyForCreateTicket(messages: [HippoMessage]) -> Bool{
        if let message = messages.last, message.type == .createTicket{
            let completedArr = message.leadsDataArray.filter{$0.isCompleted == true}
            if completedArr.count == message.leadsDataArray.count{
                return false
            }else{
                return true
            }
        }
        return false
    }
    
    func handleVideoIcon() {
        setTitleButton()
        
        //image icon name = tiny-video-symbol
        
        if isDirectCallingEnabledFor(type: .video) {
            
            view_Navigation.video_button.tintColor = HippoConfig.shared.theme.headerTextColor
            view_Navigation.video_button.isEnabled = true
            view_Navigation.video_button.setImage(HippoConfig.shared.theme.videoCallIcon, for: .normal)
            view_Navigation.video_button.isHidden = false
        } else {
            view_Navigation.video_button.isHidden = true
            view_Navigation.video_button.setImage(UIImage(), for: .normal)
            view_Navigation.video_button.isEnabled = false
        }
    }
    func handleAudioIcon() {
        setTitleButton()
        
        //image icon name = audioCallIcon
        
        if isDirectCallingEnabledFor(type: .audio) {
            view_Navigation.call_button.tintColor = HippoConfig.shared.theme.headerTextColor
            view_Navigation.call_button.isEnabled = true
            view_Navigation.call_button.setImage(HippoConfig.shared.theme.audioCallIcon, for: .normal)
            view_Navigation.call_button.isHidden = false
        } else {
            view_Navigation.call_button.setImage(UIImage(), for: .normal)
            view_Navigation.call_button.isEnabled = false
            view_Navigation.call_button.isHidden = true
        }
        
        
    }
   
   func keepTableViewWhereItWasBeforeReload(oldContentHeight: CGFloat, oldYOffset: CGFloat) {
      let newContentHeight = tableViewChat.contentSize.height
      let differenceInContentSizes = newContentHeight - oldContentHeight
      
      let oldYPosition = differenceInContentSizes + oldYOffset
      
      let newContentOffset = CGPoint(x: 0, y: oldYPosition)
      
      tableViewChat.setContentOffset(newContentOffset, animated: false)
      
   }
   
//    func updateMessagesGroupedByDate(_ chatMessagesArray: [HippoMessage]) {
//
//        for message in chatMessagesArray {
//
//            guard let latestDateTime = getDateTimeStringOfLatestStoredMessage() else {
//                addMessageToNewGroup(message: message)
//                continue
//            }
//
//            let comparisonResult = Calendar.current.compare(latestDateTime, to: message.creationDateTime, toGranularity: .day)
//
//            switch comparisonResult {
//            case .orderedSame:
//                var latestMessageGroup = messagesGroupedByDate.last ?? []
//                latestMessageGroup.append(message)
//                messagesGroupedByDate[messagesGroupedByDate.count - 1] = latestMessageGroup
//            default:
//               addMessageToNewGroup(message: message)
//            }
//        }
//    }
    
//    func getDateTimeStringOfLatestStoredMessage() -> Date? {
//        guard !messagesGroupedByDate.isEmpty else {
//            return nil
//        }
//        guard var latestMessageGroup = messagesGroupedByDate.last, latestMessageGroup.count > 0 else {
//                return nil
//        }
//
//      let groupsFirstMessage = latestMessageGroup[0]
//
//        return groupsFirstMessage.creationDateTime
//    }
   
//   func addMessageToNewGroup(message: HippoMessage) {
//      self.messagesGroupedByDate.append([message])
//   }
   
    func handleRequestForCreateConersationForGetMessages(error: MessageStore.GetMessagesError?, completion: ((_ success: Bool) -> Void)?) {
        guard let result = error, result.isCreateConversationRequired, HippoConfig.shared.userDetail?.userUniqueKey != nil else {
            completion?(false)
            return
        }

        channel?.delegate = nil
        channel = nil
        messagesGroupedByDate = []
        labelId = -1
        tableViewChat.reloadData()
        
        directChatDetail = FuguNewChatAttributes.defaultChat
        label = (userDetailData["business_name"] as? String) ?? HippoStrings.support
        userImage = nil
        setTitleForCustomNavigationBar()
        
        completion?(false)
        startNewConversation(replyMessage: nil, completion: { [weak self] (success, result) in
            if success {
                
                //self?.populateTableViewWithChannelData()
                //self?.fetchMessagesFrom1stPage()
//                if self?.isComingFromConsultNowButton == true{
                if self?.isComingFromConsultNowButton == true && !(result?.channel?.chatDetail?.agentAlreadyAssigned ?? false) {
                    self?.isComingFromConsultNowButton = false
                    self?.callAssignAgentApi(completion: { [weak self] (success) in
                        guard success == true else {
                            return
                        }
                        self?.populateTableViewWithChannelData()
                        self?.fetchMessagesFrom1stPage()
                    })
                }else{
                    self?.populateTableViewWithChannelData()
                    self?.fetchMessagesFrom1stPage()
                }
                
            }
        })
    }
    
    override func getMessagesWith(labelId: Int, completion: ((_ success: Bool) -> Void)?) {
      
    startLoaderAnimation()//
        
      if FuguNetworkHandler.shared.isNetworkConnected == false {
        stopLoaderAnimation()//
         checkNetworkConnection()
         completion?(false)
         return
      }
      
      if HippoConfig.shared.appSecretKey.isEmpty {
        stopLoaderAnimation()//
         completion?(false)
         return
      }
        
      if channel?.messages.count == 0  || channel == nil {
        stopLoaderAnimation()//
         startLoaderAnimation()
      } else if !isPaginationInProgress() {
        stopLoaderAnimation()//
//         startGettingNewMessages()
      }

     let request = MessageStore.messageRequest(pageStart: 1, showLoader: false, pageEnd: nil, channelId: -1, labelId: labelId)
     storeRequest = request
     storeResponse = nil
     MessageStore.getMessagesByLabelID(requestParam: request, ignoreIfInProgress: false) {[weak self] (response, error)  in
        
        if self?.storeRequest?.id == request.id {
          self?.stopLoaderAnimation()
        }
        self?.hideErrorMessage()
        
        guard error == nil else {
            self?.handleRequestForCreateConersationForGetMessages(error: error, completion: completion)
            return
        }
        
        guard let result = response, result.isSuccessFull, let weakSelf = self else {
            completion?(false)
            self?.goForApiRetry()
            return
        }
        weakSelf.storeResponse = result
        weakSelf.labelId = result.labelID
        weakSelf.botGroupID = result.botGroupID
        
        if result.channelID > 0 {
            weakSelf.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: result.channelID)
            weakSelf.channel.delegate = self
            if !weakSelf.channel.isSubscribed(){
                weakSelf.channel?.subscribe()
            }
            weakSelf.populateTableViewWithChannelData()
        }
        
        if ((result.channelID < 0) && (result.createNewChannel == true)){
            weakSelf.startNewConversation(replyMessage: nil, completion: nil)
        }
        
        weakSelf.handleSuccessCompletionOfGetMessages(result: result, request: request, completion: completion)
    }
    
    }
   
    func callAssignAgentApi(completion: ((_ success: Bool) -> Void)?) {
        
        guard let authorEmail = consultNowInfoDict["authorEmail"] as? String else {
            return
        }
        var dict = [String : Any]()
        dict["agent_email"] = authorEmail
        dict["app_secret_key"] = HippoConfig.shared.appSecretKey
        dict["en_user_id"] = HippoUserDetail.fuguEnUserID ?? "-1"
        dict["channel_id"] = self.channel?.id ?? -1
        //dict["access_token"] = ""
        //dict["user_id"] = ""
        
        HippoChannel.callAssignAgentApi(withParams: dict) { [weak self] (bool) in
            completion?(bool)
        }
        
    }
    
    override func startNewConversation(replyMessage: HippoMessage?, completion: ((_ success: Bool, _ result: HippoChannelCreationResult?) -> Void)?) {
      
        guard HippoUserDetail.fuguEnUserID != nil else {
            startLoaderAnimation()
            completion?(false, nil)
            return
        }
      disableSendingNewMessages()
      if FuguNetworkHandler.shared.isNetworkConnected == false {
         errorMessage = HippoStrings.noNetworkConnection
         showErrorMessage()
         disableSendingNewMessages()
//         return
      }
      
      startLoaderAnimation()
      
      if HippoConfig.shared.appSecretKey.isEmpty {
         return
      }
      
      if isDefaultChannel() {
        let request = CreateConversationWithLabelId(replyMessage: replyMessage, botGroupId: botGroupID, labelId: labelId, initalMessages: getAllLocalMessages(), channelName: label)
        HippoChannel.get(request: request) { [weak self] (r) in
            var result = r
            if result.isSuccessful, request.shouldSendInitalMessages(), request.replyMessage != nil {
                result.isReplyMessageSent = true
            }
            if !r.isChannelAvailableLocallay {
               HippoChannel.botMessageMUID = nil
            }
            self?.enableSendingNewMessages()
            self?.channelCreatedSuccessfullyWith(result: result)
            
            self?.getMessagesAfterCreateConversation(callback: { (sucess) in
                result.isGetMesssagesSuccess = sucess
                completion?(result.isSuccessful, result)
            })
         }
      } else if directChatDetail != nil {
//         HippoChannel.get(withFuguChatAttributes: directChatDetail!) { [weak self] (r) in
        HippoChannel.get(withFuguChatAttributes: directChatDetail!, isComingFromConsultNow: self.isComingFromConsultNowButton) { [weak self] (r) in
            var result = r
    
            result.isReplyMessageSent = false
            self?.enableSendingNewMessages()
            self?.channelCreatedSuccessfullyWith(result: result)
            
            if self?.channel?.chatDetail?.chatType == .p2p{
                // * save data for p2punread count if transaction id is saved in local
                if let data = P2PUnreadData.shared.getData(with: self?.directChatDetail?.transactionId ?? ""){
                    let id = ((self?.directChatDetail?.transactionId ?? "") + "-" + (self?.directChatDetail?.otherUniqueKey?.first ?? ""))
                    if ((data.channelId ?? -1) < 0 && (data.id == id)){
                        P2PUnreadData.shared.updateChannelId(transactionId: self?.directChatDetail?.transactionId ?? "", channelId: result.channel?.id ?? -1, count: 0, otherUserUniqueKey: self?.directChatDetail?.otherUniqueKey?.first)
                    }
                }
            }
            completion?(result.isSuccessful, result)
         }
      } else {
         enableSendingNewMessages()
         stopLoaderAnimation()
      }
   }
    func getAllLocalMessages() -> [HippoMessage] {
        var messages: [HippoMessage] = [HippoMessage]()
        for each in messagesGroupedByDate {
            messages.append(contentsOf: each)
        }
        
        return messages
    }
    func getMessagesAfterCreateConversation(callback: @escaping ((_ success: Bool) -> Void)) {
        guard shouldHitGetMessagesAfterCreateConversation() else {
            callback(false)
            return
        }
        
        getMessagesBasedOnChannel(fromMessage: 1, pageEnd: nil) {(sucess) in
            callback(sucess)
        }
    }
    func shouldHitGetMessagesAfterCreateConversation() -> Bool {
        let formCount = channel?.messages.filter({ (h) -> Bool in
            return (h.type == MessageType.leadForm || h.type == MessageType.createTicket || h.type == .consent)
        }).count ?? 0
        
        let isFormPresent = formCount > 0 ? true : false
        let botMessageMUID = HippoChannel.botMessageMUID ?? ""
        return (isFormPresent && botMessageMUID.isEmpty) || isDefaultChannel()
    }
   func enableSendingNewMessages() {
      addFileButtonAction.isUserInteractionEnabled = true
      messageTextView.isEditable = true
      //sendMessageButton.isEnabled = true
   }
   
   func disableSendingNewMessages() {
      addFileButtonAction.isUserInteractionEnabled = false
      messageTextView.isEditable = false
      sendMessageButton.isEnabled = false
   }
      
    func channelCreatedSuccessfullyWith(result: HippoChannelCreationResult) {
        if let error = result.error, !result.isSuccessful {
            errorMessage = error.localizedDescription
            showErrorMessage()
            updateErrorLabelView(isHiding: true)
        }
        
        guard result.isSuccessful else {
            stopLoaderAnimation()
            return
        }
        userImage = result.channel?.chatDetail?.channelImageUrl
        channel = result.channel
        channel.delegate = self
        if !channel.isSubscribed(){
            channel?.subscribe()
        }
        setTitleForCustomNavigationBar()
        
        let (sentMessage, unsentMessage) = getMessageFromGrouped(messages: messagesGroupedByDate)
        channel?.sentMessages = sentMessage
        channel?.unsentMessages = unsentMessage
        self.updateMessagesInLocalArrays(messages: [])
        tableViewChat.reloadData()
        
        sendReadAllNotification()
        
        stopLoaderAnimation()
    }
   
    func updateChatInfoWith(chatObj: FuguConversation, allConversationConfig: AllConversationsConfig) {
      
      if let channelId = chatObj.channelId, channelId > 0 {
         self.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
      } else {
        self.labelId = chatObj.labelId ?? -1
      }
      channel?.chatDetail?.chatType = chatObj.chatType
      
      self.label = chatObj.label ?? ""
      self.userImage = chatObj.channelImageUrl
        
      self.forceDisableReply = allConversationConfig.forceDisableReply
      self.forceHideActionButton = allConversationConfig.forceHideActionButton
   }
   
   // MARK: - Type Methods
    class func getWith(conversationObj: FuguConversation, allConversationConfig: AllConversationsConfig) -> ConversationsViewController {
      let vc = getNewInstance()
        vc.updateChatInfoWith(chatObj: conversationObj, allConversationConfig: allConversationConfig)
      return vc
   }
   
   class func getWith(labelId: String) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.labelId = Int(labelId) ?? -1
      return vc
   }
   
   class func getWith(chatAttributes: FuguNewChatAttributes) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.directChatDetail = chatAttributes
      vc.label = chatAttributes.channelName ?? ""
      return vc
    
    /* testing:
//    HippoConfig.shared.notifyDidLoad()
//    let conversationVC = ConversationsViewController.getWith(conversationObj: chatObj)
//    conversationVC.delegate = self
//    self.navigationController?.pushViewController(conversationVC, animated: true)
//
//    if let channelId = chatObj.channelId, channelId > 0 {
//        self.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelId)
//    }
//    channel?.chatDetail?.chatType = chatObj.chatType
//    self.labelId = chatObj.labelId ?? -1
//    self.label = chatObj.label ?? ""
//    self.userImage = chatObj.channelImageUrl
    */
    
   }
   
   class func getWith(channelID: Int, channelName: String) -> ConversationsViewController {
      let vc = getNewInstance()
      vc.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
      vc.label = channelName
      return vc
   }
   
   private class func getNewInstance() -> ConversationsViewController {
      let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
      let vc = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
      return vc
   }
}
extension ConversationsViewController: CreateTicketAttachmentHelperDelegate {
   
}

// MARK: - HELPERS
extension ConversationsViewController {
   
    func returnRetryCancelButtonHeight(chatMessageObject: HippoMessage) -> CGFloat {
        if chatMessageObject.wasMessageSendingFailed, chatMessageObject.type != MessageType.imageFile, chatMessageObject.status == ReadUnReadStatus.none, isSentByMe(senderId: chatMessageObject.senderId) {
            return 40
        }
        return 0
    }
   
    func configureChatScreen() {
        
        navigationSetUp()
        tableViewSetUp()
        configureFooterView()
        addTapGestureInTableView()
        
        if HippoConfig.shared.theme.chatbackgroundImage != nil      {
            tableViewChat.backgroundColor = .white//.clear
            backgroundImageView.image = HippoConfig.shared.theme.chatbackgroundImage
            backgroundImageView.contentMode = .scaleToFill
        }
//        self.messageTextView.textAlignment = .left
        self.messageTextView.font = HippoConfig.shared.theme.typingTextFont
        self.messageTextView.textColor = HippoConfig.shared.theme.typingTextColor
        self.messageTextView.backgroundColor = .clear
        self.messageTextView.tintColor = HippoConfig.shared.theme.messageTextViewTintColor//
        
        placeHolderLabel.text = HippoConfig.shared.theme.messagePlaceHolderText == nil ? HippoStrings.messagePlaceHolderText : HippoConfig.shared.theme.messagePlaceHolderText
        
        errorLabel.text = ""
        if errorLabelTopConstraint != nil {
            errorLabelTopConstraint.constant = -20
        }
        
        sendMessageButton.isEnabled = false
        
        if (channel != nil && channel?.isSendingDisabled == true) || forceDisableReply {
            disableSendingReply()
        }
        
        self.newConversationCountButton.roundCorner(cornerRect: [.topLeft, .bottomLeft], cornerRadius: 5)
        self.newConversationShadow.layer.cornerRadius = 5
        self.newConversationShadow.showShadow(shadowSideAngles: ShadowSideView(topSide: true, leftSide: true, bottomSide: true))
        //        self.newConversationShadow.showShadow(shadowSideAngles: ShadowSideView(topSide: true, leftSide: true, bottomSide: true, rightSide: true))
        //        self.updateNewConversationCountButton(animation: false)
        
        //        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        //        navigationController?.interactivePopGestureRecognizer?.delegate = self
        //        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        //        view.addGestureRecognizer(panGesture)
        
        if fetchAddedPaymentGatewaysData() != nil, let getArr = fetchAddedPaymentGatewaysData(){
            self.addedPaymentGatewaysArr = getArr
        }
        
    }
   
   func addTapGestureInTableView() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ConversationsViewController.dismissKeyboard(sender:)))
      tapGesture.cancelsTouchesInView = false
      tableViewChat.addGestureRecognizer(tapGesture)
   }
   
    @objc func dismissKeyboard(sender: UIGestureRecognizer) {
      
      guard messageTextView.isFirstResponder else {
         self.view.endEditing(true)//
         return
      }
      
      //Delayed so that tableview gets correct touch event to run didselect
      let currentOffsetY = self.tableViewChat.contentOffset.y
      var newOffsetY = max(0, currentOffsetY - self.getKeyboardHeight())
      
      fuguDelay(0.1) {
         self.messageTextView.resignFirstResponder()
         
         if !self.shouldShiftUpWithThis(newOffsetY: newOffsetY) {
            newOffsetY = self.getMaxScrollableOffset()
         }
         
         let newOffset = CGPoint(x: 0, y: newOffsetY)
         self.tableViewChat.setContentOffset(newOffset, animated: true)
      }
   }
   
   func getKeyboardHeight() -> CGFloat {
      let screenHeight = backgroundView.bounds.height
      let tableViewEnd = tableViewChat.frame.maxY + UIView.safeAreaInsetOfKeyWindow.bottom
      
      let keyboardHeight = screenHeight - tableViewEnd - textViewBgView.frame.height
      
      return messageTextView.isFirstResponder ? keyboardHeight : 0
   }
   
   func getLastVisibleYCoordinateOfTableView() -> CGFloat {
      let tableViewHeight = tableViewChat.frame.height
      let tableViewYOffset = tableViewChat.contentOffset.y
      
      return tableViewYOffset + tableViewHeight
   }
   
   func setNavBarHeightAccordingtoSafeArea() {
      let topInset = UIView.safeAreaInsetOfKeyWindow.top == 0 ? 20 : UIView.safeAreaInsetOfKeyWindow.top
      hieghtOfNavigationBar = 44 + topInset
   }
   
   func configureFooterView() {
       textViewBgView.backgroundColor = .white
      if isObserverAdded == false {
         textViewBgView.layoutIfNeeded()
         let inputView = FrameObserverAccessaryView(frame: textViewBgView.bounds)
         inputView.isUserInteractionEnabled = false

         messageTextView.inputAccessoryView = inputView

         inputView.changeKeyboardFrame { [weak self] (keyboardVisible, keyboardFrame) in
            let value = UIScreen.main.bounds.height - keyboardFrame.minY - UIView.safeAreaInsetOfKeyWindow.bottom
            let maxValue = max(0, value)
            self?.textViewBottomConstraint.constant = maxValue

            self?.view.layoutIfNeeded()
         }
         isObserverAdded = true
      }
   }
   
   
   func shouldShiftUpWithThis(newOffsetY: CGFloat) -> Bool {
      let tableHeight = tableViewChat.frame.height
      let tableContentHeight = tableViewChat.contentSize.height
      
      return newOffsetY + tableHeight < tableContentHeight + 10
   }
   
   func getMaxScrollableOffset() -> CGFloat {
      let tableHeight = tableViewChat.frame.height
      let tableContentHeight = tableViewChat.contentSize.height
      
      if tableContentHeight > tableHeight {
         return tableContentHeight - tableHeight + 3
      } else {
         return 0
      }
   }
   
   
    
    func getTopDistanceOfCell(atIndexPath indexPath: IndexPath) -> CGFloat {
        
        let row = indexPath.row
        
        guard row != 0 else {
            return 5
        }
        
        let groupedArray = messagesGroupedByDate[indexPath.section]
        
        let previousMessage = groupedArray[row-1]
        let currentMessage = groupedArray[row]
        
        if previousMessage.senderId == currentMessage.senderId {
            return 1
        } else {
            return 0.01
        }
    }
    
    
    func updateTopBottomSpace(cell: UITableViewCell, indexPath: IndexPath) {

        let topConstraint = getTopDistanceOfCell(atIndexPath: indexPath)
        if let editedCell = cell as? SelfMessageTableViewCell {
            //editedCell.topConstraint.constant = topConstraint
        } else if let editedCell = cell as? SupportMessageTableViewCell {
            //editedCell.topConstraint.constant = topConstraint
        }
        else if let editedCell = cell as? IncomingImageCell {
            editedCell.topConstraint.constant = topConstraint + 2
        } else if let editedCell = cell as? OutgoingImageCell {
            editedCell.topConstraint.constant = topConstraint + 2
        }
    }
   
   func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
      sender.view?.removeFromSuperview()
   }
   
    @objc func watcherOnTextView() {
      if textInTextField == messageTextView.text,
         typingMessageValue == TypingMessage.stopTyping.rawValue,
         channel != nil {
         
         channel?.send(message: HippoMessage.stopTyping, completion: {})
         self.typingMessageValue = TypingMessage.startTyping.rawValue
      } else {
         textInTextField = messageTextView.text
      }
   }
    
    func showHideActivityIndicator(hide: Bool = true) {
        if hide {
            if self.loadMoreActivityTopContraint.constant == 10 {
                    self.loadMoreActivityTopContraint.constant = -30
                
//                    UIView.animate(withDuration: 0.2, animations: {
                                    self.view.layoutIfNeeded()
//                    }, completion: {_ in
                        self.loadMoreActivityIndicator.stopAnimating()
                        self.errorLabel.isHidden = false
//                    } )
            }
            return
        }
        
        if loadMoreActivityTopContraint != nil && loadMoreActivityTopContraint.constant != 10 {
            self.loadMoreActivityTopContraint.constant = 10
            self.loadMoreActivityIndicator.startAnimating()
            self.errorLabel.isHidden = true
//            UIView.animate(withDuration: 0.2, animations: {
               self.view.layoutIfNeeded()
               
//            })
        }
        
    }

    func getMessageFromGrouped(messages: [[HippoMessage]]) -> (sentMessage: [HippoMessage], unsentMessages: [HippoMessage]) {
        var sentMessages: [HippoMessage] = []
        var unSentMessages: [HippoMessage] = []
        
        for messageArray in messages {
            for message in messageArray {
                switch message.status {
                case .none:
                    unSentMessages.append(message)
                default:
                    sentMessages.append(message)
                }
            }
        }
        return (sentMessages, unSentMessages)
    }
   
   func internetIsBack() {
//      getMessagesBasedOnChannel(fromMessage: 1, completion: nil)
   }
   
    func expectedHeight(OfMessageObject chatMessageObject: HippoMessage) -> CGFloat {
        let isProfileImageEnabled: Bool = channel?.chatDetail?.chatType.isImageViewAllowed ?? (labelId > 0)
        
        let isOutgoingMsg = isSentByMe(senderId: chatMessageObject.senderId) && chatMessageObject.type != .card
        
        var availableWidthSpace = FUGU_SCREEN_WIDTH - CGFloat(60 + 10) - CGFloat(10 + 5)
        availableWidthSpace -= (isProfileImageEnabled && !isOutgoingMsg) ? 35 : 0
        
        let availableBoxSize = CGSize(width: availableWidthSpace,
       height: CGFloat.greatestFiniteMagnitude)
        
        
        
        var cellTotalHeight: CGFloat = 5 + 2.5 + 3.5 + 12 + 7 + 23
      
        if isOutgoingMsg == true {
            
            let messageString = chatMessageObject.message
            
            #if swift(>=4.0)
            var attributes: [NSAttributedString.Key: Any]?
            attributes = [NSAttributedString.Key.font: HippoConfig.shared.theme.inOutChatTextFont]
            
            if messageString.isEmpty == false {
                cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
            }
            
            #else
            var attributes: [String: Any]?
            if let applicableFont = HippoConfig.shared.theme.inOutChatTextFont {
                attributes = [NSFontAttributeName: applicableFont]
            }
            
            if messageString.isEmpty == false {
                cellTotalHeight += messageString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
            }
            #endif
            
        } else {
            let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: chatMessageObject)
            cellTotalHeight += incomingAttributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size.height
        }
        
        return cellTotalHeight
    }
    
//    func scrollTableViewToBottom(animated: Bool = false) {
//
//        DispatchQueue.main.async {
//            if self.messagesGroupedByDate.count > 0 {
//                let givenMessagesArray = self.messagesGroupedByDate[self.messagesGroupedByDate.count - 1]
//                if givenMessagesArray.count > 0 {
//                    let indexPath = IndexPath(row: givenMessagesArray.count - 1, section: self.messagesGroupedByDate.count - 1)
//                    self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
//                }
//            }
//        }
//    }
    func scrollTableViewToBottom(_ animation: Bool = false) {
        
        DispatchQueue.main.async {
            
            var numberOfSections = -1
            if self.tableViewChat.numberOfSections > 1 {
                numberOfSections = self.tableViewChat.numberOfSections - 1
            } else {
                numberOfSections = self.tableViewChat.numberOfSections
            }
            
            guard numberOfSections > 0 else {
                return
            }
            
            if self.messagesGroupedByDate.count > 0, let lastIndex = self.messagesGroupedByDate.last, lastIndex.count > 0 {
                
                let max = self.tableViewChat.numberOfRows(inSection: self.messagesGroupedByDate.count - 1)
                let min = lastIndex.count - 1
                
                let row = min < max ? min : max - 1
                guard numberOfSections >= self.messagesGroupedByDate.count - 1 else {
                    return
                }
                let indexPath = IndexPath(row: row, section: self.messagesGroupedByDate.count - 1)
                
                self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: animation)
                self.newConversationContainer.isHidden = true
            }
        }
    }
    
//    func updateNewConversationCountButton(animation: Bool) {
//        if newConversationCounter > 0 {
//            newConversationLabel.text = "\(newConversationCounter)"
//            newConversationLabel.isHidden = false
//            newConversationContainer.isHidden = false
//        } else {
//            newConversationLabel.isHidden = true
//        }
//    }
    
    func hideRetryLabelView() {
        chatScreenTableViewTopConstraint.constant = 0
        labelViewRetryButton.isHidden = false
        retryLoader.isHidden = true
        retryLabelView.isHidden = true
    }
    
    func goForApiRetry(){
        if FuguNetworkHandler.shared.isNetworkConnected{
            chatScreenTableViewTopConstraint.constant = 25
            retryLabelView.isHidden = false
            retryLoader.isHidden = true
            labelViewRetryButton.isHidden = false
        }
    }

    func fetchAddedPaymentGatewaysData() -> [PaymentGateway]? {
        if let addedPaymentGatewaysData = FuguDefaults.object(forKey: DefaultName.addedPaymentGatewaysData.rawValue) as? [[String: Any]]{
            let addedPaymentGatewaysArr = PaymentGateway.parse(addedPaymentGateways: addedPaymentGatewaysData)
            return addedPaymentGatewaysArr
        }else{
            return nil
        }
    }
    

    
}

// MARK: - UIScrollViewDelegate
extension ConversationsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      if self.tableViewChat.contentOffset.y < -5.0 && self.willPaginationWork, FuguNetworkHandler.shared.isNetworkConnected {
         
         guard !isGettingMessageViaPaginationInProgress, channel != nil else {
            return
         }
         showHideActivityIndicator(hide: false)
         isGettingMessageViaPaginationInProgress = true
        
         self.getMessagesBasedOnChannel(fromMessage: self.channel.sentMessages.count + 1, pageEnd: nil, completion: { [weak self]  (success) in
            self?.showHideActivityIndicator(hide: true)
            self?.isGettingMessageViaPaginationInProgress = false
         })
      }
//        if shouldRecognizeScroll {
        if scrollView.contentOffset.y < (tableViewChat.contentSize.height - tableViewChat.frame.height - 180) {
            newConversationContainer.isHidden = false
        } else {
//                if newConversationCounter == 0 {
            newConversationContainer.isHidden = true
//                }
        }
//
//        if scrollView.contentOffset.y > (tableViewChat.contentSize.height - tableViewChat.frame.height - 10) {
//            newConversationCounter = 0
//            updateNewConversationCountButton(animation: true)
//        }
//    }
   }
    
}

// MARK: - UITableView Delegates
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == customTableView{
            return 1
        }else{
            if !isTypingLabelHidden {
                return self.messagesGroupedByDate.count + 1
            }
            return self.messagesGroupedByDate.count
        }
   }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == customTableView{
            return actionSheetTitleArr.count
        }else{
            if section < self.messagesGroupedByDate.count {
                return messagesGroupedByDate[section].count
            } else {
                return isTypingLabelHidden ? 0 : 1
            }
        }
        
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
     if tableView == customTableView{
         
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else {fatalError("Unable to deque cell")}
         cell.selectionStyle = .none
         cell.lbl.text = actionSheetTitleArr[indexPath.row]
         if isProceedToPayActionSheet == true{
             cell.settingImage.tintColor = nil
             if let url = URL(string: actionSheetImageArr[indexPath.row]) {
                 let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
                 cell.settingImage.kf.setImage(with: url, placeholder: placeHolderImage)
             }else{
                 cell.settingImage.image = nil
             }
         }else{
             cell.settingImage.tintColor = .black
             let renderingMode: UIImage.RenderingMode = isProceedToPayActionSheet == true ? .alwaysOriginal : .alwaysTemplate
             if let img = UIImage(named: actionSheetImageArr[indexPath.row], in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(renderingMode){
                 cell.settingImage.image = img
             }else{
                 cell.settingImage.image = nil
             }
         }
         return cell
         
     }else{
         
       switch indexPath.section {
       case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
          
          let cell = tableView.dequeueReusableCell(withIdentifier: "TypingViewTableViewCell", for: indexPath) as! TypingViewTableViewCell
          
          cell.backgroundColor = .clear
          cell.selectionStyle = .none
          cell.bgView.isHidden = false
          cell.gifImageView.image = nil
          cell.bgView.backgroundColor = .clear
          cell.gifImageView.layer.cornerRadius = 15.0
          
          let imageBundle = FuguFlowManager.bundle ?? Bundle.main
          if let getImagePath = imageBundle.path(forResource: "typingImage", ofType: ".gif") {
             cell.gifImageView.image = UIImage.animatedImageWithData(try! Data(contentsOf: URL(fileURLWithPath: getImagePath)))!
          }
          
          return cell
       case let chatSection where chatSection < self.messagesGroupedByDate.count:
          var messagesArray = messagesGroupedByDate[chatSection]
          
          if messagesArray.count > indexPath.row {
             let message = messagesArray[indexPath.row]
             let messageType = message.type
             let isOutgoingMsg = isSentByMe(senderId: message.senderId) && messageType != .card
             
             guard messageType.isMessageTypeHandled() && !message.isInValidMessage() else {
                 return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
             }
             
             switch messageType {
             case MessageType.imageFile:
                if isOutgoingMsg == true {
                    guard
                        let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingImageCell", for: indexPath) as? OutgoingImageCell
                    else {
                        let cell = UITableViewCell()
                        cell.backgroundColor = .clear
                        return cell
                    }
                    cell.messageLongPressed = {[weak self](message) in
                        DispatchQueue.main.async {
                            self?.longPressOnMessage(message: message, indexPath: indexPath)
                        }
                    }
                    cell.delegate = self
                    cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath)
                    return cell
                } else {
                     guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingImageCell", for: indexPath) as? IncomingImageCell
                         else {
                             let cell = UITableViewCell()
                             cell.backgroundColor = .clear
                             return cell
                     }
                     cell.delegate = self
                     return cell.configureIncomingCell(resetProperties: true, channelId: channel.id, chatMessageObject: message, indexPath: indexPath)
                 }
             case .feedback:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackTableViewCell") as? FeedbackTableViewCell else {
                     return UITableViewCell()
                 }
                 var param = FeedbackParams(title: message.message, indexPath: indexPath, messageObj: message)
                 param.showSendButton = true
                 cell.setData(params: param)
                 cell.delegate = self
                 cell.backgroundColor = .clear
                 if let muid = message.messageUniqueID {
                     heightForFeedBackCell["\(muid)"] = cell.alertContainer.bounds.height
                 }
                 //                print("-----\(cell.alertContainer.bounds.height)")
                 return cell
             case .botText:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMessageTableViewCell", for: indexPath) as? SupportMessageTableViewCell
                     else {
                         let cell = UITableViewCell()
                         cell.backgroundColor = .clear
                         return cell
                 }
                 let bottomSpace = getBottomSpaceOfMessageAt(indexPath: indexPath, message: message)
                 cell.updateBottomConstraint(bottomSpace)
                let incomingAttributedString = message.attributtedMessage.attributedMessageString
                 return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel?.id ?? labelId, chatMessageObject: message)
             case .leadForm, .createTicket:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeadTableViewCell", for: indexPath) as? LeadTableViewCell else {
                     return UITableViewCell()
                 }
                 cell.delegate = self
                 cell.setData(indexPath: indexPath, arr: message.leadsDataArray, message: message)
                 return cell
             case .quickReply:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "BotOutgoingMessageTableViewCell", for: indexPath) as? BotOutgoingMessageTableViewCell
                     else {
                         let cell = UITableViewCell()
                         cell.backgroundColor = .clear
                         return cell
                 }
                 cell.delegate = self
                 let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: message)
                 return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: channel.id, chatMessageObject: message)
             case .call:
                 if isOutgoingMsg {
                     guard let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingVideoCallMessageTableViewCell", for: indexPath) as? OutgoingVideoCallMessageTableViewCell else {
                         let cell = UITableViewCell()
                         cell.backgroundColor = .clear
                         return cell
                     }
                     let peerName = channel?.chatDetail?.peerName ?? "   "
                     let isCallingEnabled = isDirectCallingEnabledFor(type: message.callType)
                     cell.setCellWith(message: message, otherUserName: peerName, isCallingEnabled: isCallingEnabled)
                     
                     cell.delegate = self
                     return cell
                 } else {
                     guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingVideoCallMessageTableViewCell", for: indexPath) as? IncomingVideoCallMessageTableViewCell else {
                         let cell = UITableViewCell()
                         cell.backgroundColor = .clear
                         return cell
                     }
                     let isCallingEnabled = isDirectCallingEnabledFor(type: message.callType)
                     cell.setCellWith(message: message, isCallingEnabled: isCallingEnabled)
                     cell.delegate = self
                     return cell
                 }
             case .actionableMessage, .hippoPay:
                 
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableMessageTableViewCell", for: indexPath) as? ActionableMessageTableViewCell else {
                     let cell = UITableViewCell()
                     cell.backgroundColor = .clear
                     return cell
                 }
                 //cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message)
                 cell.timeLabel.text = ""
                 cell.rootViewController = self
                 cell.setUpData(messageObject: message, isIncomingMessage: !isOutgoingMsg)
                 cell.layoutIfNeeded()
                 cell.layoutSubviews()

                 tableView.layoutIfNeeded()
//                 cell.actionableMessageTableView.reloadData()
//                 cell.tableViewHeightConstraint.constant = self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message)
                 cell.backgroundColor = UIColor.clear
                 return cell
             case .attachment:
                 if isOutgoingMsg {
                     switch message.concreteFileType! {
                     case .video:
                         let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingVideoTableViewCell", for: indexPath) as! OutgoingVideoTableViewCell
                        cell.messageLongPressed = {[weak self](message) in
                            DispatchQueue.main.async {
                                self?.longPressOnMessage(message: message, indexPath: indexPath)
                            }
                        }
                         cell.setCellWith(message: message)
                         cell.retryDelegate = self
                         cell.delegate = self
                         return cell
                     default:
                         let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingDocumentTableViewCell") as! OutgoingDocumentTableViewCell
                        cell.messageLongPressed = {[weak self](message) in
                            DispatchQueue.main.async {
                                self?.longPressOnMessage(message: message, indexPath: indexPath)
                            }
                        }
                         cell.setCellWith(message: message)
                         cell.actionDelegate = self
                         cell.delegate = self
                         cell.nameLabel.isHidden = true
                         return cell
                     }
                 } else {
                     switch message.concreteFileType! {
                     case .video:
                         let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingVideoTableViewCell", for: indexPath) as! IncomingVideoTableViewCell
                         cell.setCellWith(message: message)
                         cell.delegate = self
                         return cell
                     default:
                         let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingDocumentTableViewCell") as! IncomingDocumentTableViewCell
                         cell.setCellWith(message: message)
                         cell.actionDelegate = self
                         cell.nameLabel.isHidden = false
                         return cell
                     }
                 }
             case .consent:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableView", for: indexPath) as? ActionTableView, let actionMessage = message as? HippoActionMessage else {
                     return UITableView.defaultCell()
                 }
                 cell.delegate = self
                 cell.setCellData(message: actionMessage)
                 return cell
             case .card:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardMessageTableViewCell", for: indexPath) as? CardMessageTableViewCell else {
                     return UITableView.defaultCell()
                 }
                 cell.delegate = self
                 cell.set(message: message)
                 return cell
             case .paymentCard:
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMessageCell", for: indexPath) as? PaymentMessageCell else {
                     return UITableView.defaultCell()
                 }
                 cell.delegate = self
                 cell.set(message: message)
                 return cell
                 
             case .multipleSelect :
                 
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultiSelectTableViewCell", for: indexPath) as? MultiSelectTableViewCell else {
                     return UITableView.defaultCell()
                 }
                 cell.submitButtonDelegate = self
                 cell.set(message: message)
                 return cell
                 
             case .embeddedVideoUrl :
                 
                 let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingVideoTableViewCell", for: indexPath) as! IncomingVideoTableViewCell
                 cell.setCellWith(message: message)
                 cell.delegate = self
                 return cell
                 
             default:
                 return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
             }
          }
       default:
          let cell = UITableViewCell()
          cell.backgroundColor = .clear
          return cell
       }
       
       let cell = UITableViewCell()
       cell.backgroundColor = .clear
       return cell
         
     }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == customTableView{
            
            onClickTransparentView()
            
            if isProceedToPayActionSheet == true{
                if addedPaymentGatewaysArr.count > 0{
                    for i in 0..<addedPaymentGatewaysArr.count{
                        if let gatewayName = addedPaymentGatewaysArr[i].gateway_name {
                            if gatewayName == actionSheetTitleArr[indexPath.row]{
                                if let message = proceedToPayMessage{
                                    if let selectedCard = proceedToPaySelectedCard{
                                        if let chnl = proceedToPayChannel{
                                            generatePaymentUrlWithSelectedPaymentGateway(for: message, card: selectedCard, selectedPaymentGateway: addedPaymentGatewaysArr[i], proceedToPayChannel: chnl)
                                        }
                                    }
                                }
                                break
                            }
                        }
                    }
                }
            }else{
                self.attachmentButtonclickedOfCustomSheet(self.view, openType: actionSheetTitleArr[indexPath.row])
            }

        }else{}
    }

     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == customTableView{
        }else{
//            guard let message = getMessageAt(indexPath: indexPath) else { return  }
//            if let selfCell = cell as? SelfMessageTableViewCell {
//               let bottomSpace = getBottomSpaceOfMessageAt(indexPath: indexPath, message: message)
//                selfCell.updateBottomConstraint(bottomSpace)
//            } else if let supportCell = cell as? SupportMessageTableViewCell{
//                let bottomSpace = getBottomSpaceOfMessageAt(indexPath: indexPath, message: message)
//                supportCell.updateBottomConstraint(bottomSpace)
//            }
            updateTopBottomSpace(cell: cell, indexPath: indexPath)
        }
    }
   
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == customTableView{
            return 50
        }else{
        
        
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            let messagesArray = self.messagesGroupedByDate[chatSection]
            if messagesArray.count > indexPath.row {
                let message = messagesArray[indexPath.row]
                let messageType = message.type
                
                guard messageType.isMessageTypeHandled() && !message.isInValidMessage() else {
                    var rowHeight = expectedHeight(OfMessageObject: message)
                    
                    rowHeight += returnRetryCancelButtonHeight(chatMessageObject: message)
                    rowHeight += getTopDistanceOfCell(atIndexPath: indexPath)
                    return rowHeight
                }
                
                switch messageType {
                case MessageType.imageFile:
                    return 288
//                case MessageType.botText:
//                    var rowHeight = expectedHeight(OfMessageObject: message)
//
//                    rowHeight += returnRetryCancelButtonHeight(chatMessageObject: message)
//                    rowHeight += getTopDistanceOfCell(atIndexPath: indexPath)
//                    return rowHeight
//
                case MessageType.normal, MessageType.botText:
                    return UIView.tableAutoDimensionHeight
                case MessageType.quickReply:
                    var rowHeight: CGFloat = 0
                    if message.values.count > 0 {
                        return rowHeight
                    }
                    if message.isQuickReplyEnabled {
                        rowHeight = rowHeight + 50
                    }
                    return rowHeight
                case MessageType.leadForm, MessageType.createTicket:
                    if message.content.questionsArray.count == 0 {
                        return 0.001
                    }
                    //TODO: Change it later on
                    //let count = chatMessageObject.content.values.count == chatMessageObject.content.questionsArray.count ? chatMessageObject.content.values.count : chatMessageObject.content.values.count + 1
                    return getHeightForLeadFormCell(message: message)
                case .attachment:
                    switch message.concreteFileType! {
                    case .video:
                        return 234
                    default:
                        return 80
                    }

                case MessageType.actionableMessage, MessageType.hippoPay:
                    return UIView.tableAutoDimensionHeight > -1 ? UIView.tableAutoDimensionHeight : self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message) + 20

                case MessageType.feedback:
                    
//                    guard let muid = message.messageUniqueID, var rowHeight: CGFloat = heightForFeedBackCell["\(muid)"] else {
//                        return 0.001
//                    }
                 //   rowHeight += 7 //Height for bottom view
                    return UIView.tableAutoDimensionHeight
                case .consent:
                    return message.cellDetail?.cellHeight ?? 0.01
                case MessageType.call:
                    return UIView.tableAutoDimensionHeight
                case .card:
                    if (message.isSearchFlow && (message.selectedCardId ?? "") == ""){
                     return 50
                    }
                    return 230
                case .paymentCard:
                    return message.calculatedHeight ?? 0.1
                case .multipleSelect:
                   return message.calculatedHeight ?? 0.01
                case .embeddedVideoUrl:
                    return 234
                default:
                    return 0.01
                    
                }
            }
        default: break
        }
        return UIView.tableAutoDimensionHeight
        
    }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == customTableView{
            return 50
        }else{
        switch indexPath.section {
        case let typingSection where typingSection == self.messagesGroupedByDate.count && !isTypingLabelHidden:
            return 34
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            let messageGroup = messagesGroupedByDate[indexPath.section]
            let message = messageGroup[indexPath.row]
            
            switch message.type {
            case .call:
                return 85
            case .card:
                if (message.isSearchFlow && (message.selectedCardId ?? "") == ""){
                    return 50
                }
                return 190

            case .actionableMessage, .hippoPay:

                return 100
            default:
                return self.tableView(tableView, heightForRowAt: indexPath)
            }
            
        default:
            return 0
        }
    }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == customTableView{
            return 10
        }else{
            if section < self.messagesGroupedByDate.count {
                
                if section == 0 && channel == nil {
                    return 0
                }
                return 28
            }
            return 0
        }
   }
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == customTableView{
            return UIView()
        }else{
            let labelBgView = UIView()
            
            labelBgView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 28)
            labelBgView.backgroundColor = .clear
            
            let dateLabel = UILabel()
            dateLabel.layer.masksToBounds = true
            
            dateLabel.text = ""
            dateLabel.layer.cornerRadius = 10
            dateLabel.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
            dateLabel.textAlignment = .center
            dateLabel.font = UIFont.bold(ofSize: 12)//UIFont.boldSystemFont(ofSize: 12.0)
            dateLabel.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
            dateLabel.layer.borderColor = #colorLiteral(red: 0.862745098, green: 0.8784313725, blue: 0.9019607843, alpha: 1).cgColor
            dateLabel.layer.borderWidth = 0.5
            if section < self.messagesGroupedByDate.count {
                let localMessagesArray = self.messagesGroupedByDate[section]
                if  localMessagesArray.count > 0,
                    let dateTime = localMessagesArray.first?.creationDateTime {
                    dateLabel.text = changeDateToParticularFormat(dateTime,
                                                                  dateFormat: "MMM d, yyyy",
                                                                  showInFormat: false).capitalized
                }
            }
            #if swift(>=4.0)
            let widthIs: CGFloat = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: dateLabel.font], context: nil).size.width) + 10
            
            #else
            let widthIs: CGFloat = CGFloat(dateLabel.text!.boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: dateLabel.font], context: nil).size.width) + 10
            #endif
            let dateLabelHeight = CGFloat(24)
            dateLabel.frame = CGRect(x: (UIScreen.main.bounds.size.width / 2) - (widthIs/2), y: (labelBgView.frame.height - dateLabelHeight)/2, width: widthIs + 10, height: dateLabelHeight)
            labelBgView.addSubview(dateLabel)
            
            return labelBgView

        }
    }

func getHeighOfButtonCollectionView(actionableMessage: FuguActionableMessage) -> CGFloat {
    
    let collectionViewDividerHeight = CGFloat(1)
        if  (actionableMessage.actionButtonsArray.count) > 0 {
            var numberOfRows = 0
            if (actionableMessage.actionButtonsArray.count) < 4 {
                numberOfRows = 1
            } else {
                numberOfRows = (actionableMessage.actionButtonsArray.count)/2
                let extraRow = (actionableMessage.actionButtonsArray.count)%2
                numberOfRows += extraRow
                
            }
            
            return CGFloat((40 * numberOfRows)) + collectionViewDividerHeight
            
        }
        return 0
    }
    func getHeightForLeadFormCell(message: HippoMessage) -> CGFloat {
        var count = 0
        var buttonAction: [FormData] = []
        var announcementHeight = 0
        for lead in message.leadsDataArray {
            if lead.isShow  && lead.type != .button {
                count += 1
            }
            if lead.type == .button {
                buttonAction.append(lead)
            }
            if lead.attachmentUrl.count > 0{
                announcementHeight = lead.attachmentUrl.count * 40
            }
        }
        var height = LeadDataTableViewCell.rowHeight * CGFloat(count)
        height += CGFloat(announcementHeight)
        if count > 1 {
            height -= CGFloat(5*(count))
        }
        // Check if count is more than or equal to 2
        if (count - 2) >= 0 {
            // Check if last visible cell value is submitted
            if message.leadsDataArray[count - 2].isCompleted {
                // Check if last cell is visible.
                if count == message.leadsDataArray.count {
                    // Check if last cell value is submitted.
                    if message.leadsDataArray[count - 1].isCompleted {
                        height -= CGFloat(10 * (count))
                    } else {
                        height -= CGFloat(10 * (count - 1))
                    }
                } else {
                    height -= CGFloat(10 * (count - 1))
                }
            }
        }
        let buttonHeight: CGFloat = CGFloat(buttonAction.count * 30)
        let skipButtonHeight: CGFloat = message.shouldShowSkipButton() ? LeadTableViewCell.skipButtonHeightConstant : 0
        if height > 0 {
            return CGFloat(height) + buttonHeight + skipButtonHeight + 2
        }
        return 0.001
    }
    
    func getHeightOfActionableMessageAt(indexPath: IndexPath, chatObject: HippoMessage)-> CGFloat {
        if let cell = tableViewChat.cellForRow(at: indexPath) as? ActionableMessageTableViewCell{
            return cell.tableViewHeightConstraint.constant
        }
        
        let chatMessageObject = chatObject
        var cellHeight = CGFloat(0)
        let bottomSpace = CGFloat(15)
        
//        let marginBetweenHeaderAndDescription = CGFloat(2.5)
        let marginBetweenHeaderAndDescription = CGFloat(3)

        let margin = CGFloat(5)
        
        
        let headerFont = HippoConfig.shared.theme.actionableMessageHeaderTextFont
        let descriptionFont = HippoConfig.shared.theme.actionableMessageDescriptionFont
        let priceFont = HippoConfig.shared.theme.actionableMessagePriceBoldFont
        let senderNameFont = HippoConfig.shared.theme.senderNameFont
        
        
        
        
        if chatMessageObject.senderFullName.isEmpty == false {
            let titleText = chatMessageObject.senderFullName
            let heightOfContent = (titleText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: senderNameFont)) + bottomSpace + margin
            cellHeight += heightOfContent
        }
        
        
        if chatMessageObject.actionableMessage?.messageImageURL.isEmpty == false {
            cellHeight += CGFloat(heightOfActionableMessageImage)
            cellHeight += bottomSpace
        }
        
        if chatMessageObject.actionableMessage?.messageTitle.isEmpty == false {
            let titleText = chatMessageObject.actionableMessage?.messageTitle
            let heightOfContent = (titleText?.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: headerFont!))! + margin + marginBetweenHeaderAndDescription +  bottomSpace + 1
            cellHeight += heightOfContent
        }
        
        if chatMessageObject.actionableMessage?.titleDescription.isEmpty == false {
            let titleText = chatMessageObject.actionableMessage?.titleDescription
            let heightOfContent = (titleText?.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20), font: descriptionFont!))!
            cellHeight += heightOfContent
        }
        let collectionViewHeight = self.getHeighOfButtonCollectionView(actionableMessage: chatMessageObject.actionableMessage!)
        cellHeight += collectionViewHeight
        
        if chatMessageObject.actionableMessage?.descriptionArray != nil, (chatMessageObject.actionableMessage?.descriptionArray.count)! > 0 {

//            let itemWidthConstant = (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 10 - 10 - 10 - 10 - 10) / 2
            let itemWidthConstant = (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 10 - 10 - 10 - 10 - 10) / 2

            for info in (chatMessageObject.actionableMessage?.descriptionArray)! {
                if let messageInfo = info as? [String: Any] {
                    if let priceText = messageInfo["content"] as? String {
                        
//                        let heightOFPriceLabel = priceText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 20 ), font: priceFont!)
//                        let heightOFPriceLabel = priceText.height(withConstrainedWidth: itemWidthConstant , font: priceFont!)
                        let heightOFPriceLabel = priceText.height(withConstrainedWidth: itemWidthConstant , font: priceFont!)
                        
//                        let widthOfPriceLabel = priceText.width(withConstraintedHeight: heightOFPriceLabel, font: priceFont!)
                        
                        if let headerText = messageInfo["header"] as? String {

//                            let heightOfContent = priceText.height(withConstrainedWidth: (FUGU_SCREEN_WIDTH - actionableMessageRightMargin - 10 - widthOfPriceLabel), font: descriptionFont!) + marginBetweenHeaderAndDescription + (margin)
//                            cellHeight += heightOfContent
                            
//                            let heightOfContent = headerText.height(withConstrainedWidth: (itemWidthConstant), font: descriptionFont!)
                            let heightOfContent = headerText.height(withConstrainedWidth: (itemWidthConstant), font: descriptionFont!)
                            cellHeight += max(heightOfContent, heightOFPriceLabel)
                            cellHeight += marginBetweenHeaderAndDescription + margin
                            print("$$$$$$$---\(max(heightOfContent, heightOFPriceLabel))")
                        } else {
                            print("$$$$$$$---2")
                        }
                        
                    } else {
                    print("$$$$$$$")
                    }
                }
            }
        }
        
        return cellHeight - 3
    }
}

extension ConversationsViewController{
    func openSearchAgentScreen(){
        let vc = SearchAgentViewController.getNewInstance()
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
}

extension ConversationsViewController {
    
    
   func shouldScrollToBottomInCaseOfSomeoneElseTyping() -> Bool {
      guard let visibleIndexPaths = tableViewChat.indexPathsForVisibleRows,
         visibleIndexPaths.count > 0,
         messagesGroupedByDate.count > 0 else {
            return false
      }
      
      let lastVisibleIndexPath = visibleIndexPaths.last!
      
      guard lastVisibleIndexPath.section >= (messagesGroupedByDate.count - 1) else {
            return false
      }
      
      if lastVisibleIndexPath.section == (messagesGroupedByDate.count - 1) && lastVisibleIndexPath.row < (messagesGroupedByDate.last!.count - 1) {
         return false
      }
      
      return true
   }
   
//   func isSentByMe(senderId: Int) -> Bool {
//      return getSavedUserId == senderId
//   }
   
   
   func sendNotificaionAfterReceivingMsg(senderUserId: Int) {
    if senderUserId != getSavedUserId {
        sendReadAllNotification()
    }
   }
   
   func sendReadAllNotification() {
      channel?.send(message: HippoMessage.readAllNotification, completion: {})
    
    setUpSuggestionsDataAndUI()//
    
   }
}

// MARK: - UITextViewDelegates
extension ConversationsViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
      placeHolderLabel.isHidden = textView.hasText
   }
   
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      self.addRemoveShadowInTextView(toAdd: true)
      
      placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.8)
      textInTextField = textView.text
      textViewBgView.backgroundColor = .white
      timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.watcherOnTextView), userInfo: nil, repeats: true)
      
      return true
   }
   
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
      textViewBgView.backgroundColor = UIColor.white
      placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.5)
      
      timer.invalidate()
      return true
   }
   
    func textViewDidBeginEditing(_ textView: UITextView) {
      typingMessageValue = TypingMessage.startTyping.rawValue
   }
   
    func textViewDidChange(_ textView: UITextView) {

   }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimWhiteSpacesAndNewLine() == ""{
             self.sendMessageButton.isEnabled = false
        }
   }
   
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = ((textView.text as NSString?)?.replacingCharacters(in: range,
                                                                         with: text))!
        if newText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.sendMessageButton.isEnabled = false
            
            if text == "\n" {
                textView.resignFirstResponder()
            }
            if channel != nil {
                self.typingMessageValue = TypingMessage.stopTyping.rawValue
                sendTypingStatusMessage(isTyping: TypingMessage.stopTyping)
                self.typingMessageValue = TypingMessage.startTyping.rawValue
            }
            if text == " " {
                return false
            }
        } else {
            self.sendMessageButton.isEnabled = true
            if typingMessageValue == TypingMessage.startTyping.rawValue, channel != nil {
                sendTypingStatusMessage(isTyping: TypingMessage.startTyping)
                self.typingMessageValue = TypingMessage.stopTyping.rawValue
            }
        }
        return true
    }
}

// MARK: - UIImagePicker Delegates
extension ConversationsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   func doesImageExistsAt(filePath: String) -> Bool {
      return UIImage.init(contentsOfFile: filePath) != nil
   }
    
}

//// MARK: - SelectImageViewControllerDelegate Delegates
//extension ConversationsViewController: SelectImageViewControllerDelegate {
//   func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage) {
//      selectedImageVC.dismiss(animated: false) {
//         self.imagePicker.dismiss(animated: false) {
//            self.sendConfirmedImage(image: selectedImage, mediaType: .imageType)
//         }
//      }
//   }
//
//   func goToConversationViewController() {}
//}

// MARK: - ImageCellDelegate Delegates
extension ConversationsViewController: ImageCellDelegate {
   func retryUploadForImage(message: HippoMessage) {
      if message.imageUrl == nil {
        uploadFileFor(message: message) {(success) in
            if success {
               self.sendMessage(message: message)
            }
         }
      } else {
         sendMessage(message: message)
      }
   }
    
    func reloadCell(withIndexPath indexPath: IndexPath) {
        if self.tableViewChat.numberOfSections >= indexPath.section, tableViewChat.numberOfRows(inSection: indexPath.section) >= indexPath.row {
            tableViewChat.reloadRows(at: [indexPath], with: .automatic)
        }
    }
   
    func showImageFor(message: HippoMessage) {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
        openSelectedImage(for: message)
    }

}

extension ConversationsViewController: HippoChannelDelegate {
    func closeChatActionFromRefreshChannel() {
        self.backButtonClicked()
    }
    
    func channelDataRefreshed() {
        label = channel?.chatDetail?.channelName ?? label
        userImage = channel?.chatDetail?.channelImageUrl
        
        if channel?.chatDetail?.disableReply == true{
            //disableSendingReply(withOutUpdate: true)
            disableSendingReply()
        }

        setTitleForCustomNavigationBar()
        handleAudioIcon()
        handleVideoIcon()
        tableViewChat.reloadData()
    }
    
    func cancelSendingMessage(message: HippoMessage, errorMessage: String?,errorCode : SocketClient.SocketError?) {
        self.cancelMessage(message: message)
        
        if let message = errorMessage {
            showErrorMessage(messageString: message)
            updateErrorLabelView(isHiding: true)
        }
        
        if errorCode == SocketClient.SocketError.personalInfoSharedError{
            self.messageTextView.text = message.message
        }
    }
    
    func typingMessageReceived(newMessage: HippoMessage) {
        guard !newMessage.isSentByMe() else {
            return
        }
        isTypingLabelHidden = newMessage.typingStatus != .startTyping
        if isTypingLabelHidden {
            deleteTypingLabelSection()
        } else {
            insertTypingLabelSection()
            return
        }
    }
    
    func sendingFailedFor(message: HippoMessage) {
        
    }
    
    func newMessageReceived(newMessage message: HippoMessage) {
        guard !isSentByMe(senderId: message.senderId) || message.type.isBotMessage  else {
            HippoConfig.shared.log.debug("Yahaa se nahi nikla", level: .custom)
            return
        }
        
        
        self.setKeyboardType(message: message)
        
        
        isTypingLabelHidden = message.typingStatus != .startTyping
        switch message.type {
        case .paymentCard:
            if (message.cards ?? []).isEmpty {
                return
            }
            let selectedCardId =  message.selectedCardId?.trimWhiteSpacesAndNewLine() ?? ""
            if !selectedCardId.isEmpty {
                self.tableViewChat.reloadData()
                return
            }
        default:
            break
        }
        if isTypingLabelHidden {
            deleteTypingLabelSection()
        } else {
            insertTypingLabelSection()
            return
        }
        
        guard !message.isANotification() else {
            return
        }
        
        if !message.is_rating_given || message.type == .hippoPay || message.type == .paymentCard {
            updateMessagesArrayLocallyForUIUpdation(message)
            newScrollToBottom(animated: true)
        }
        //TODO: - Scrolling Logic
        
        // NOTE: Keep "shouldScroll" method and action different, should scroll method should only detect whether to scroll or not
        sendNotificaionAfterReceivingMsg(senderUserId: message.senderId)
        
        if (message.type == MessageType.normal || message.type == .imageFile) &&  message.typingStatus == .messageRecieved {
            sendQuickReplyReposeIfRequired()
        }
        
        if message.type == MessageType.leadForm {
            self.replaceLastQuickReplyIncaseofBotForm()
        }
        if message.type == MessageType.createTicket {
            self.disableSendingReply()
        }
        
    }
    func getMessageForQuickReply(messages: [HippoMessage]) -> HippoMessage? {
        var quickReplyMessage: HippoMessage?
        for message in messages.reversed() {
            if message.type == MessageType.quickReply && message.isQuickReplyEnabled {
                quickReplyMessage = message
                break
            }
        }
        return quickReplyMessage
    }
    
    
    func replaceLastQuickReplyIncaseofBotForm() {
        if self.messagesGroupedByDate.count > 0 {
            let section = self.messagesGroupedByDate.count - 1
            let groupedArray = self.messagesGroupedByDate[section]
            var quickReplyMessage: HippoMessage?
            var row: Int = 0
            for (index, message) in groupedArray.enumerated().reversed() {
                if message.type == MessageType.quickReply {
                    quickReplyMessage = message
                    row = index
                    break
                } else {
                    continue
                }
            }
            guard let message = quickReplyMessage else {
                return
            }
            guard message.values.isEmpty else {
                return
            }
            self.messagesGroupedByDate[section][row].isQuickReplyEnabled = false
            self.tableViewChat.reloadRows(at: [IndexPath(row: row, section: section)], with: .fade)
        }
    }
   
   func insertTypingLabelSection() {
      guard !isTypingLabelHidden, !isTypingSectionPresent() else {
         return
      }
      let typingSectionIndex = IndexSet([tableViewChat.numberOfSections])
      tableViewChat.insertSections(typingSectionIndex, with: .none)
      
      if shouldScrollToBottomInCaseOfSomeoneElseTyping(), let lastMessageIndexPath = getLastMessageIndexPath() {
         let newIndexPath = IndexPath(row: 0, section: lastMessageIndexPath.section + 1)
         scroll(toIndexPath: newIndexPath, animated: false)
      }
   }
   
    func deleteTypingLabelSection() {
        guard isTypingLabelHidden, isTypingSectionPresent() else {
            return
        }
        if tableViewChat.numberOfSections == 1{
            return
        }
        
        let typingSectionIndex = IndexSet([tableViewChat.numberOfSections - 1])
        tableViewChat.deleteSections(typingSectionIndex, with: .none)
    }
   
   func isTypingSectionPresent() -> Bool {
      return self.messagesGroupedByDate.count < tableViewChat.numberOfSections
   }
    
//    func checkScrollerPostion() {
//        let contentHeight = tableViewChat.contentSize.height
//        let tableHeight = tableViewChat.bounds.height
//        let offset = tableViewChat.contentOffset.y
//
//
//        if offset > (contentHeight - tableHeight - 10) {
//            self.newConversationCounter = 0
//            scrollTableViewToBottom(false)
//        } else if contentHeight > tableHeight {
//            self.newConversationCounter += 1
//        }
//        self.updateNewConversationCountButton(animation: true)
//    }
    
}
// MARK: Bot Form Cell Delegates
extension ConversationsViewController: LeadTableViewCellDelegate {
    func reloadDataOnAttachmentRemove(){
        self.tableViewChat.reloadData()
    }
    
    func priorityTypeStartEditing(textfield: UITextField) {
        HippoKeyboardManager.shared.enable = true
        setupvm(textfield: textfield)
        createTicketVM.erpSearch(type: .issuePriority, text: textfield.text ?? "")
    }
    
    func issueTypeValueChanged(textfield: UITextField) {
        HippoKeyboardManager.shared.enable = true
        setupvm(textfield: textfield)
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2) {
            self.createTicketVM.erpSearch(type: .issueType, text: textfield.text ?? "")
        }
    }
    
    func priorityTypeValueChanged(textfield: UITextField) {
        HippoKeyboardManager.shared.enable = true
        setupvm(textfield: textfield)
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2) {
            self.createTicketVM.erpSearch(type: .issuePriority, text: textfield.text ?? "")
        }
    }
    
    func issueTypeStartEditing(textfield: UITextField) {
        HippoKeyboardManager.shared.enable = true
        setupvm(textfield: textfield)
        createTicketVM.erpSearch(type: .issueType, text: textfield.text ?? "")
    }
    
    func setupvm(textfield: UITextField){
        createTicketVM.searchDataUpdated = {[weak self](type) in
            DispatchQueue.main.async {
                if type == .issueType && ((textfield.isFirstResponder) == true){
                    if textfield.text == ""{
                        if self?.popover == nil || (getLastVisibleController() != self?.popover){
                            self?.setupCustomPopover(for: textfield, data: self?.createTicketVM.initialIssueTypeData ?? [String]())
                        }else{
                            self?.popover?.dataList = self?.createTicketVM.initialIssueTypeData ?? [String]()
                            self?.popover?.reloadData()
                        }
                    }else{
                        if self?.popover == nil || (getLastVisibleController() != self?.popover){
                            self?.setupCustomPopover(for: textfield, data: self?.createTicketVM.issueTypeData ?? [String]())
                        }else{
                            self?.popover?.dataList = self?.createTicketVM.issueTypeData ?? [String]()
                            self?.popover?.reloadData()
                        }
                    }
                }else if type == .issuePriority && ((textfield.isFirstResponder) == true){
                    if textfield.text == ""{
                        if self?.popover == nil || (getLastVisibleController() != self?.popover){
                            self?.setupCustomPopover(for: textfield, data: self?.createTicketVM.initialPriorityData ?? [String]())
                        }else{
                            self?.popover?.dataList = self?.createTicketVM.initialPriorityData ?? [String]()
                            self?.popover?.reloadData()
                        }
                    }else{
                        if self?.popover == nil || (getLastVisibleController() != self?.popover){
                            self?.setupCustomPopover(for: textfield , data: self?.createTicketVM.priorityTypeData ?? [String]())
                        }else{
                            self?.popover?.dataList = self?.createTicketVM.priorityTypeData ?? [String]()
                            self?.popover?.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func setupCustomPopover(for sender: UITextField, data : [String]) {
        // Init a popover with a callback closure after selecting data
        if data.count == 0{
            return
        }
        
        popover = LCPopover(for: sender, title: "") { tuple in
            // Use of the selected tuple
            guard let value = tuple else { return }
            sender.text = value
        }
        
        guard let popover = popover else {
            return
        }
        
        // Assign data to the dataList
        popover.dataList = data
        
        // Set popover properties
        popover.size = CGSize(width: Int(sender.frame.size.width), height: (popover.dataList.count * 45) < 200 ? (popover.dataList.count * 45) : 200)
        popover.arrowDirection = .unknown
        popover.barHeight = 0
        popover.borderWidth = 0.5
        popover.borderColor = .black
        popover.textFont = UIFont.regular(ofSize: 14)
        popover.textColor = .black
        
        // Present the popover
        present(popover, animated: true, completion: nil)
    }

    
    
    func actionAttachmentClick(data: FormData) {
        if data.attachmentUrl.count == 5{
            showAlert(title: nil, message: "Cannot add more than 5 attachments", actionComplete: nil)
            return
        }
        attachmentObj.delegate = self
        attachmentObj.urlUploaded = {[weak self](ticket) in
            var isValueChanged : Bool = false
            for (index, value) in data.attachmentUrl.enumerated(){
                if value.name == ticket.name{
                    data.attachmentUrl[index].isUploaded = ticket.isUploaded
                    data.attachmentUrl[index].url = ticket.url
                    isValueChanged = true
                }
            }
            if !isValueChanged{
                data.attachmentUrl.append(ticket)
            }
            DispatchQueue.main.async {
                self?.tableViewChat.reloadData()
            }
        }
        attachmentObj.openAttachment = true
    }
    
    func leadSkipButtonClicked(message: HippoMessage, cell: LeadTableViewCell) {
        message.isSkipBotEnabled = false
        message.isSkipEvent = true
        
        let replyMessage = botGroupID != nil ? message : nil
        if replyMessage?.messageUniqueID == nil {
            replyMessage?.messageUniqueID = String.generateUniqueId()
        }
        
        createChannelIfRequiredAndContinue(replyMessage: replyMessage) { (success, result) in
            let isReplyMessageSent = result?.isReplyMessageSent ?? false
            if !isReplyMessageSent {
                self.channel?.sendFormValues(message: message, completion: {
                    
                })
            }
        }
        cell.disableSkipButton()
    }
    
    
    func textfieldShouldBeginEditing(textfield: UITextField) {
        if self.messageTextView.isFirstResponder {
            self.messageTextView.resignFirstResponder()
        }
    }
    
    func textfieldShouldEndEditing(textfield: UITextField) {
        HippoKeyboardManager.shared.enable = false
    }
    
    func cellUpdated(for cell: LeadTableViewCell, data: [FormData], isSkipAction: Bool) {
        guard let indexPath = self.tableViewChat.indexPath(for: cell) else {
            return
        }
        guard indexPath.section < self.messagesGroupedByDate.count else {
            return
        }
        messagesGroupedByDate[indexPath.section][indexPath.row].leadsDataArray = data
        DispatchQueue.main.async {
            self.tableViewChat.reloadData()
        }
        var count = 0
        for message in data {
            if message.isShow == true {
                count += 1
            }
        }
        guard let cell = cell.tableView.cellForRow(at: IndexPath(row: 0, section: count - 1)) as? LeadDataTableViewCell, !isSkipAction else {
            return
        }
       
    }
    
    func sendReply(forCell cell: LeadTableViewCell, data: [FormData]) {
        guard let indexPath = self.tableViewChat.indexPath(for: cell) else {
            return
        }
        guard indexPath.section < self.messagesGroupedByDate.count else {
            return
        }
        let message = messagesGroupedByDate[indexPath.section][indexPath.row]
        
        ///*change editable status if we are sending description*/
        if message.type == .createTicket{
            if let index = data.lastIndex(where: {$0.isCompleted == true}), index < data.count , data[index].paramId == CreateTicketFields.description.rawValue{
                data.forEach{$0.shouldBeEditable = false}
                
                ///*Call function to create customer if we are sending description/
                if index == message.content.questionsArray.count - 1{
                    // if description is last question wait for creating customer before publishing
                    self.createCustomer(shouldWaitForData: true, data: data){(status) in
                        self.startSendingLeadForm(forCell: cell, message: message, data: data)
                    }
                }else{
                    //call api in background thread
                    self.createCustomer(shouldWaitForData: false, data: data){(status) in
                        self.startSendingLeadForm(forCell: cell, message: message, data: data)
                    }
                }
                
            }else{
                self.startSendingLeadForm(forCell: cell, message: message, data: data)
            }
        }else{
            self.startSendingLeadForm(forCell: cell, message: message, data: data)
        }
       
    }
    
    private func createCustomer(shouldWaitForData: Bool, data: [FormData], completion: @escaping (Bool) -> Void){
        var name = ""
        var email = ""
        for value in data{
            if value.paramId == CreateTicketFields.name.rawValue {
                name = value.value
            }else if value.paramId == CreateTicketFields.email.rawValue {
                email = value.value
            }
            if name != "" && email != ""{
                break
            }
        }
        if shouldWaitForData{
            createTicketVM.checkAndCreateCustomer(name: name, email: email, completion: completion)
        }else{
            completion(true)
            //call in background thread, donot disturb UI
            DispatchQueue.global().async {
                self.createTicketVM.checkAndCreateCustomer(name: name, email: email)
            }
        }
    }
    
    private func startSendingLeadForm(forCell cell: LeadTableViewCell, message: HippoMessage, data: [FormData]){
        message.content.erpCustomerName = self.createTicketVM.customerName
        message.leadsDataArray = data
        HippoChannel.botMessageMUID = message.messageUniqueID ?? String.generateUniqueId()
        message.messageUniqueID = HippoChannel.botMessageMUID
        
        createChannelIfRequiredAndContinue(replyMessage: message) {[weak self] (success, result) in
            if let botMessageID = result?.botMessageID {
                message.messageId = Int(botMessageID)
            }
            message.messageUniqueID = HippoChannel.botMessageMUID
            message.botFormMessageUniqueID = HippoChannel.botMessageMUID
            HippoChannel.botMessageMUID = nil
            
            let isReplyMessageSent = result?.isReplyMessageSent ?? false
            
            if !isReplyMessageSent {
                self?.channel?.sendFormValues(message: message, completion: {
                    message.botFormMessageUniqueID =  nil
                    cell.checkAndDisableSkipButton()
                    
                    self?.cellUpdated(for: cell, data: data, isSkipAction: false)
                    
                    if message.type == .createTicket{
                        var arrayOfMessages: [String] = []
                        for lead in message.leadsDataArray {
                            if lead.value.isEmpty {
                                break
                            }
                            arrayOfMessages.append(lead.value)
                        }
                        if arrayOfMessages.count == message.content.questionsArray.count{
                            self?.createTicketVM.isCustomerCreated = false
                            self?.enableSendingReply()
                        }
                    }
                })
            }
        }
    }
    
}

// MARK: Bot Outgoing Cell Delegates
extension ConversationsViewController: BotOtgoingMessageCellDelegate {
    func didTapQuickReply(atIndex index: Int, forCell cell: BotOutgoingMessageTableViewCell) {
        self.messageTextView.resignFirstResponder()
        guard let indexPath = self.tableViewChat.indexPath(for: cell) else {
            return
        }
        switch indexPath.section {
        case let chatSection where chatSection < self.messagesGroupedByDate.count:
            var messagesArray = messagesGroupedByDate[chatSection]
            let chat = messagesArray[indexPath.row]
            chat.selectedActionId = chat.content.actionId[index]
            self.sendQuickMessage(shouldSendButtonTitle: true, chat: chat, buttonIndex: index)
        default:
            return
        }
    }
    
    func sendQuickMessage(shouldSendButtonTitle: Bool, chat: HippoMessage, buttonIndex: Int) {
        let replyMessage = botGroupID != nil ? chat : nil
        
        if replyMessage?.messageUniqueID == nil {
            replyMessage?.messageUniqueID = String.generateUniqueId()
        }
        
        createChannelIfRequiredAndContinue(replyMessage: replyMessage) {[weak self] (success, result) in
            if shouldSendButtonTitle {
                self?.sendQuickReplyMessage(with: chat.content.buttonTitles[buttonIndex])
                fuguDelay(0.2, completion: {
                    self?.channel?.sendFormValues(message: chat, completion: {
                        chat.isQuickReplyEnabled = false
                        self?.tableViewChat.reloadData()
                    })
                })
            } else {
                self?.channel?.sendFormValues(message: chat, completion: {
                    chat.isQuickReplyEnabled = false
                    self?.tableViewChat.reloadData()
                    
                })
            }
        }
        
    }
    
    func sendQuickReplyMessage(with message: String) {
        let message = HippoMessage(message: message, type: .normal, uniqueID: String.generateUniqueId(), chatType: channel?.chatDetail?.chatType)
        channel?.unsentMessages.append(message)
        if channel != nil {
            addMessageToUIBeforeSending(message: message)
            self.sendMessage(message: message)
        }
    }
}
// MARK: Feedback Table Cell Delegates
extension ConversationsViewController: FeedbackTableViewCellDelegate {
    
    func cellTextViewEndEditing(data: FeedbackParams) {
    }
    func cellTextViewBeginEditing(textView: UITextView, data: FeedbackParams) {
        
    }
    
    func submitButtonClicked(with data: FeedbackParams) {
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            return
        }
        let mess = data.messageObject!
        mess.is_rating_given = true
        mess.total_rating = 5
        mess.rating_given = data.selectedIndex
        mess.comment = data.cellTextView.text.trimWhiteSpacesAndNewLine()
        mess.senderId = data.messageObject?.senderId ?? -1
        
        self.channel.send(message: mess) {
            self.channel.upateFeedbackStatus(newMessage: mess)
            DispatchQueue.main.async {
                self.tableViewChat.reloadData()
            }
        }
    }
    
    func updateHeightForCell(at data: FeedbackParams, textView: UITextView) {
        tableViewChat.beginUpdates()
        tableViewChat.cellForRow(at: data.indexPath!)?.updateConstraintsIfNeeded()
        tableViewChat.endUpdates()
    }
}

extension ConversationsViewController: chatViewDelegateProtocol {
    func selectedSuggestion(indexPath: IndexPath) {
        //tableList.append(suggestionList[indexPath.row])
        self.sendMessageButtonAction(messageTextStr: suggestionList[indexPath.row])
        suggestionList.remove(at: indexPath.row)
        if suggestionList.count <= 0{
            suggestionContainerView.isHidden = true
        }
        suggestionCollectionView.customDataSource?.update(suggestions: suggestionList, nextURL: nil)
        UIView.animate(withDuration: 0.2) {
            //self.tableView.reloadData()
            self.suggestionCollectionView.reloadData()
        }
    }
}

//Action Sheet for Customer options
extension ConversationsViewController {
    func presentActionsForCustomer(sender: UIView) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let logoutOption = UIAlertAction(title: HippoStrings.logoutTitle, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.logoutOptionClicked()
        })
        let chatHistory = UIAlertAction(title: HippoStrings.chatHistory, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pushToChatHistory()
        })
        
        let cancelAction = UIAlertAction(title: HippoStrings.cancel, style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        actionSheet.addAction(chatHistory)
        actionSheet.addAction(logoutOption)
        
        actionSheet.addAction(cancelAction)

        
        actionSheet.popoverPresentationController?.sourceRect = sender.frame
        actionSheet.popoverPresentationController?.sourceView = sender
        
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func pushToChatHistory() {
        let config = AllConversationsConfig(enabledChatStatus: [ChatStatus.close], title: HippoStrings.chatHistory, shouldUseCache: false, shouldHandlePush: false, shouldPopVc: true, forceDisableReply: true, forceHideActionButton: true, isStaticRemoveConversation: true, lastChannelId: channel?.id, disbaleBackButton: false)
        guard let vc = AllConversationsViewController.get(config: config) else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func logoutOptionClicked() {
        HippoConfig.shared.clearHippoUserData { (s) in
            HippoUserDetail.clearAllData()
            HippoConfig.shared.delegate?.hippoUserLogOut()
        }
    }
}

extension ConversationsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(self.navigationController?.interactivePopGestureRecognizer) else{ return true }
        messageTextView.resignFirstResponder()
        channel?.send(message: HippoMessage.stopTyping, completion: {})
        let rawLabelID = self.labelId == -1 ? nil : self.labelId
        let channelID = self.channel?.id ?? -1
        if let lastMessage = getLastMessage(), let conversationInfo = FuguConversation(channelId: channelID, unreadCount: 0, lastMessage: lastMessage, labelID: rawLabelID) {
            delegate?.updateConversationWith(conversationObj: conversationInfo)
        }
        
        //if chat delegate is not set , it doesnot exist in allconversation
        if delegate == nil {
            for controller in self.navigationController?.viewControllers ?? [UIViewController](){
                if controller is AllConversationsViewController{
                    (controller as? AllConversationsViewController)?.getAllConversations()
                    break
                }
            }
        }
        return true
    }
}
extension ConversationsViewController{
    
    @IBAction func action_CancelEditMessage(){
        messageEditingStopped()
    }
    
    @IBAction func action_SendEditedMessage(){
        if messageInEditing?.message == messageTextView.text{
            self.messageEditingStopped()
            return
        }
        messageInEditing?.message = messageTextView.text
        guard let message = messageInEditing else {
            return
        }
        
        self.apiHitToEditDeleteMsg(message: message, isDeleted: false) { (status) in
            if status{
                self.messageEditingStopped()
            }
        }
    }
    
    func messageEditingStarted(with message : HippoMessage){
        self.messageInEditing = message
        self.addFileButtonAction.isHidden = true
        self.sendMessageButton.isHidden = true
        self.Button_CancelEdit.isHidden = false
        self.Button_EditMessage.isHidden = false
        self.messageTextView.text = message.message
        self.messageTextView.becomeFirstResponder()
       
    }
    
    func messageEditingStopped(){
        self.messageInEditing = nil
        self.addFileButtonAction.isHidden = false
        self.sendMessageButton.isHidden = false
        self.Button_CancelEdit.isHidden = true
        self.Button_EditMessage.isHidden = true
        self.messageTextView.text = ""
        self.tableViewChat.deselectRow(at: editingMessageIndex ?? IndexPath(), animated: true)
        self.messageTextView.resignFirstResponder()
    }
    
}





