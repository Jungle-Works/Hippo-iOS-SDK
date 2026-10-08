//
//  ConversationsViewController.swift
//  Fugu
//
//  Created by CL-macmini-88 on 5/9/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class LeadDataTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

protocol NewChatSentDelegate: AnyObject {
    func updateConversationWith(conversationObj: FuguConversation)
}

class ConversationsViewController: HippoConversationViewController {//}, UIGestureRecognizerDelegate {
    
    //MARK: Constants
    var createConversationOnStart = false
    var hideBackButton: Bool = false
    var isFirst : Bool = false
    var consultNowInfoDict = [String: Any]()
    var isComingFromConsultNowButton = false
    var createTicketVM = CreateTicketVM()
    var popover : LCPopover?
    var original_transaction_id : String?
    var preMessage = ""

    // MARK: -  IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
   
    @IBOutlet weak var pleaseSelectOptionView: UIView!
    @IBOutlet weak var pleaseSelectOptionLabel: UILabel!
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
    
    @IBOutlet private var button_Recording : RecordButton!
    @IBOutlet private var viewRecord : RecordView!
    @IBOutlet private var stackViewButton : UIStackView!

    // MARK: Voice recording (tap-to-toggle) - see the extension near the bottom of this file.
    var voiceRecordingState: VoiceRecordingState = .idle
    private var recordingElapsedTimer: Timer?
    private var recordingStartDate: Date?
    lazy var recordingBar: RecordingBarView = {
        let bar = RecordingBarView()
        bar.isHidden = true
        return bar
    }()
    @IBOutlet var buttonCalendar : UIButton!{
        didSet{
            buttonCalendar.imageView?.tintColor = HippoConfig.shared.theme.themeColor
            buttonCalendar.setImage(UIImage(named: "Datetime", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var firstLineLbl: UILabel!
    @IBOutlet weak var walletBgView: UIView!
    @IBOutlet weak var secondLineLbl: UILabel!
    
    var suggestionCollectionView = SuggestionView()
    var suggestionList: [String] = []

    /// Drives the composer's height so it grows with typed lines between a 42pt
    /// floor and an 80pt cap; past the cap the text view stays at 80pt and scrolls
    /// its content instead of collapsing.
    private var composerHeightConstraint: NSLayoutConstraint?
    private let composerMinHeight: CGFloat = 42
    private let composerMaxHeight: CGFloat = 80

    /// How much of `tableViewChat.contentInset.bottom` is currently padding for the
    /// composer/keyboard covering the table - see `updateChatInsetForComposerOverlap()`.
    private var composerOverlapInset: CGFloat = 0

    /// The bot form the user is filling in. While set, every chat reload re-focuses its next
    /// field (see focusActiveFormField). Cleared when the user dismisses the keyboard by
    /// tapping the chat, starts typing in the composer, or the form is finished.
    private weak var activeFormMessage: HippoMessage?

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
        timer.invalidate()
        HippoChannel.botMessageMUID = nil
        NotificationCenter.default.removeObserver(self)
        HippoConfig.shared.notifiyDeinit()
    }
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Captured before anything below can create a channel: `createConversationOnStart`
        // creates one inside this very method, so "does a channel exist now" is not a
        // usable answer to "did the user open a new chat".
        openedAsNewConversation = (channel == nil)
        if HippoConfig.shared.isFromPantherFirstChat == true{
            showWallet()
        }else{
            hideWallet()
        }
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.edges = .left
        view.addGestureRecognizer(swipeGesture)
        messageTextView.text = preMessage
        updateComposerHeight()
        // Voice messages are tap-to-toggle now, not hold-to-record: disable
        // iRecordView's press/pan gestures and drive RecordingHelper from a
        // plain tap on the mic button. viewRecord (the slide-to-cancel overlay)
        // stays hidden for good.
        button_Recording.recordView = viewRecord
        button_Recording.listenForRecord = false
        viewRecord.isHidden = true
        button_Recording.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        setupRecordingBar()
        if preMessage.isEmpty{
            button_Recording.isHidden = !HippoConfig.shared.isRecordingButtonEnabled
            sendMessageButton.isEnabled = false
        }else{
            self.sendMessageButton.isHidden = false
            self.sendMessageButton.isEnabled = true
            self.button_Recording.isHidden = true
        }
//        button_Recording.isHidden = !HippoConfig.shared.isRecordingButtonEnabled
        
        view_Navigation.call_button.addTarget(self, action: #selector(audiCallButtonClicked(_:)), for: .touchUpInside)
        view_Navigation.video_button.addTarget(self, action: #selector(videoButtonClicked(_:)), for: .touchUpInside)
        handleInfoIcon()
        pleaseSelectOptionLabel.text = HippoProperty.current.pleaseSelectOptionText ?? HippoStrings.pleaseSelectAnOption
        collectionViewOptions?.delegate = self
        collectionViewOptions?.dataSource = self
        customTableView.isScrollEnabled = false//true
        customTableView.separatorStyle = .none
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.backgroundColor = .white
        customTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        
        self.setTitleForCustomNavigationBar()
        //super.viewDidLoad()
        addObserver()
        setNavBarHeightAccordingtoSafeArea()
        configureChatScreen()
        setThemeForBusiness()
        HippoConfig.shared.notifyDidLoad()

        pleaseSelectOptionView.isHidden = true
        pleaseSelectOptionLabel.isHidden = true
        //Commented because we dont want to hit api just after 
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
    
    /// One-time wiring for the nav bar's overflow menu. Visibility is deliberately
    /// not set here - it changes over the screen's life and is owned by
    /// `updateInfoIconVisibility()`. Calling this more than once would stack a
    /// duplicate `addTarget` on the button.
    func handleInfoIcon() {
        setTitleButton()
        view_Navigation.info_button.setImage(HippoConfig.shared.theme.mediaIcon, for: .normal)
        view_Navigation.info_button.addTarget(self, action:  #selector(openSharedMedia), for: UIControl.Event.touchUpInside)
        view_Navigation.info_button.tintColor = HippoConfig.shared.colorConfig.hippoIconAccent
        view_Navigation.info_button.isEnabled = true
        updateInfoIconVisibility()
    }

    /// Insets that put the composer's text where the pill's shape says it should be,
    /// on both axes.
    ///
    /// Horizontally, two things have to move together: `messageTextView` draws typed
    /// text at `textContainerInset.left + textContainer.lineFragmentPadding`, while
    /// `placeHolderLabel` is a sibling pinned to the text view's leading edge by a
    /// storyboard constraint. Shifting only one makes the placeholder and the text
    /// the user types start at different x positions.
    ///
    /// Vertically, the caret and glyphs are centred by deriving the inset from the
    /// font rather than hard-coding one: a single line then sits dead centre in the
    /// `composerMinHeight` pill, matching `placeHolderLabel`'s own centreY
    /// constraint, and multi-line growth keeps the same top gap.
    private func applyComposerTextInsets() {
        let horizontalPadding: CGFloat = 9

        messageTextView.textContainerInset.left = horizontalPadding
        messageTextView.textContainerInset.right = horizontalPadding

        // `contentInset` shifts content on top of `textContainerInset` but is invisible
        // to `sizeThatFits`, so the two disagree about where a line sits. Vertical
        // placement is owned by `textContainerInset` alone.
        messageTextView.contentInset.top = 0
        messageTextView.contentInset.bottom = 0

        let lineHeight = (messageTextView.font ?? UIFont.systemFont(ofSize: 15)).lineHeight
        let verticalInset = max(0, (composerMinHeight - lineHeight) / 2)
        messageTextView.textContainerInset.top = verticalInset
        messageTextView.textContainerInset.bottom = verticalInset

        // Where glyphs actually land, which is what the placeholder has to match.
        let textLeadingInset = horizontalPadding + messageTextView.textContainer.lineFragmentPadding

        let placeholderLeading = messageTextView.superview?.constraints.first { constraint in
            constraint.firstItem === placeHolderLabel
                && constraint.firstAttribute == .leading
                && constraint.secondItem === messageTextView
        }
        placeholderLeading?.constant = textLeadingInset
    }

    /// True when this screen was opened as a brand-new chat rather than on an
    /// existing conversation - the default channel for a first-timer, the New
    /// Conversation button, or any `createConversationOnStart` entry.
    private var openedAsNewConversation = false

    /// The menu only makes sense once there is a real conversation behind it - its
    /// Shared Media option is keyed on `channelId`, and there is nothing shared yet
    /// on a chat the user hasn't spoken in.
    ///
    /// A channel alone is not enough: `createConversationOnStart` creates one during
    /// `viewDidLoad`, before the user has typed a word. So for a screen opened as a
    /// new chat the menu stays hidden until the user actually sends something; a
    /// screen opened on an existing conversation shows it right away.
    func updateInfoIconVisibility() {
        let isRealConversation = channelId > 0
            && (!openedAsNewConversation || threadContainsMyMessage())
        view_Navigation.info_button.isHidden = !isRealConversation
    }

    /// Whether the loaded thread carries a message sent by this user. Bot and agent
    /// messages don't count - they arrive on a new chat before the user has engaged.
    private func threadContainsMyMessage() -> Bool {
        for group in messagesGroupedByDate.reversed() {
            for message in group.reversed() where message.senderId == getSavedUserId {
                return true
            }
        }
        return false
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
        self.navigationController?.isNavigationBarHidden = true
        tableViewChat.allowsSelection = false
        checkNetworkConnection()
        //        if transparentView != nil{
        //            onClickTransparentView()
        //        }
        onClickTransparentView()
        
        handleVideoIcon()
        handleAudioIcon()
        updateInfoIconVisibility()
        HippoConfig.shared.notifyDidLoad()
        

        
        if #available(iOS 13.0, *) {
            self.view.overrideUserInterfaceStyle = .light
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaderView.isHidden {
            startLoaderAnimation()
        }
        reloadVisibleCellsToStartActivityIndicator()
        HippoConfig.shared.notifyDidLoad()
        
        textViewBgView.isUserInteractionEnabled = shouldEnableMessageSendingView()
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
        
//        self.seperatorView.isHidden = true
//        self.seperatorView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.9294117647, alpha: 1)
        if toAdd {
//            self.seperatorView.isHidden = false
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
        timer.invalidate()
        cancelVoiceRecording()
    }
    
    override func didSetChannel() {
        channel?.delegate = self
        if !(channel?.isSubscribed() ?? false){
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
                // sendBtnIcon is a single template-rendered asset (circle + triangle baked
                // into one shape), so this tint paints the whole button — reads the accent
                // token instead of the legacy green customColorforIcons.
                sendMessageButton.imageView?.tintColor = HippoConfig.shared.colorConfig.hippoAccent
            }
            sendMessageButton.setImage(HippoConfig.shared.theme.sendBtnIcon, for: .normal)
            sendMessageButton.setTitle("", for: .normal)
        } else { sendMessageButton.setTitle(HippoStrings.send, for: .normal) }
        
        if HippoConfig.shared.theme.addButtonIcon != nil {
            
            addFileButtonAction.imageView?.tintColor = HippoConfig.shared.colorConfig.hippoIconAccent
            addFileButtonAction.setImage(HippoConfig.shared.theme.addButtonIcon, for: .normal)
            addFileButtonAction.setTitle("", for: .normal)
        } else { addFileButtonAction.setTitle("ADD", for: .normal) }
        // Bundled mic glyph (Assets.xcassets/FileIcons/mic.imageset). Its asset is
        // 36pt vs the add-file icon's 25pt, so scale it down to match; template-
        // rendered so it still takes the accent tint.
        let addIconSize = HippoConfig.shared.theme.addButtonIcon?.size
            ?? addFileButtonAction.currentImage?.size
            ?? CGSize(width: 25, height: 25)
        // Mic reads a touch small next to the add-file glyph - bump it 4pt.
        let micTarget = CGSize(width: addIconSize.width + 4, height: addIconSize.height + 4)
        let micIcon = UIImage(named: "mic", in: FuguFlowManager.bundle, compatibleWith: nil)?
            .aspectFitted(to: micTarget)
            .withRenderingMode(.alwaysTemplate)
        button_Recording.setImage(micIcon, for: .normal)
        button_Recording.imageView?.contentMode = .scaleAspectFit
        button_Recording.tintColor = HippoConfig.shared.colorConfig.hippoIconAccent
       
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
        self.suggestionContainerView.addSubview(suggestionCollectionView)
        // Blend the suggestion strip into the chat thread rather than the composer bar.
        self.suggestionContainerView.backgroundColor = HippoConfig.shared.colorConfig.hippoSurfaceBackground
        suggestionCollectionView.backgroundColor = .clear//theme.themeColor
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
    @objc func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            backButtonClicked()
        }
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
    
    func setKeyboardType(message:HippoMessage){
        
        switch message.keyboardType {
        case .none:
            disableSendingReply(withOutUpdate: true)
            break
        case .numberKeyboard:
            showComposerIfAllowed()
            messageTextView.keyboardType = .decimalPad
            break
        case .defaultKeyboard :
            if let lastMessage = getLastMessage(){
                if isFirst == false{
                    if lastMessage.type == MessageType.consent{
                        fuguDelay(0.5) {
                            self.isFirst = true
                            self.disableSendingReply(withOutUpdate: true)

                        }
                    }
                }else{
                    showComposerIfAllowed()
                }
            }

            messageTextView.keyboardType = .default
            break
            
        }
        
        messageTextView.reloadInputViews()
    }
    
    func hideWallet(){
        okBtn.isHidden = true
        firstLineLbl.isHidden = true
        walletBgView.isHidden = true
        secondLineLbl.isHidden = true
    }
    
    func showWallet(){
        okBtn.isHidden = false
        firstLineLbl.isHidden = false
        walletBgView.isHidden = false
        secondLineLbl.isHidden = false
        self.firstLineLbl.font = HippoConfig.shared.theme.typingTextFont
        self.secondLineLbl.font = HippoConfig.shared.theme.typingTextFont
        walletBgView.layer.cornerRadius = 20
        okBtn.layer.cornerRadius = 6
       
    }
    
    // MARK: - UIButton Actions
    @IBAction func wallectOkPressed(_ sender: Any) {
        hideWallet()
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        //        presentActionsForCustomer(sender: self.view)
    }
    
    @IBAction func audiCallButtonClicked(_ sender: Any) {
        startAudioCall(transactionId: self.original_transaction_id)
    }
    
    @IBAction func videoButtonClicked(_ sender: Any) {
        startVideoCall(transactionId: self.original_transaction_id)
    }
    
    @IBAction func openSharedMedia(_ sender: Any) {
        // Shared Media is the only option here, so open it directly instead of
        // routing through a single-row bottom sheet.
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SharedMediaViewController") as? SharedMediaViewController {
            vc.channelId = self.channelId
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
        actionSheetTitleArr = [HippoStrings.photoLibrary,HippoStrings.camera,HippoStrings.document,"Send Current Location"]
        actionSheetImageArr = ["AttachGallery","Camera","Media","location"]
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
        let window = UIApplication.shared.currentKeyWindow
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
            self.customTableView.frame = CGRect(x: 0, y: screenSize.height - self.heightForActionSheet - UIView.safeAreaInsetOfKeyWindow.bottom, width: screenSize.width, height: self.heightForActionSheet + UIView.safeAreaInsetOfKeyWindow.bottom)
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

        // While recording, the send button means "send the voice message".
        if voiceRecordingState == .recording {
            finishVoiceRecordingAndSend()
            return
        }

        // The field is about to be cleared as part of sending, so reset the
        // composer buttons to the empty-field state.
        updateInputButtonsForText(hasText: false)

        if let message = messagesGroupedByDate.last?.last as? HippoActionMessage {
            if message.type == .dateTime {
                sendDateMessage()
                return
            }else if message.type == .address {
                sendAddress()
                return
            }
        }
        
        self.sendMessageButtonAction(messageTextStr: messageTextView.text)
    }
    
    private func sendAddress() {
        guard let message = messagesGroupedByDate.last?.last as? HippoActionMessage else {
            return
        }
        message.responseMessage = HippoMessage(message: messageTextView.text, type: .normal, senderName: message.repliedBy, senderId: message.repliedById, chatType: chatType)
        message.responseMessage?.userType = .customer
        message.documentType = nil
        message.selectBtnWith(btnId: "")
        DispatchQueue.main.async {
            self.tableViewChat.reloadData()
        }
        self.sendMessage(message: message)
        messageTextView.text = ""
        updateComposerHeight()
        updateInputButtonsForText()
    }
    
    private func sendDateMessage() {
        if channel != nil, !channel.isSubscribed()  {
            channel.subscribe()
        }
        
        if FuguNetworkHandler.shared.isNetworkConnected == false || SocketClient.shared.isConnected() == false{
            return
        }
        
        if isMessageInvalid(messageText: messageTextView.text.trimWhiteSpacesAndNewLine()) {
            return
        }
        
        if let message = messagesGroupedByDate.last?.last as? HippoActionMessage{
            var dic = [[String : Any]]()
            var dateDic = [String : Any]()
            dateDic["date_time"] = messageTextView.text
            dateDic["date_time_message"] = messageTextView.text
            dateDic["time_zone"] = TimeZone.current.secondsFromGMT()
            dic.append(dateDic)
            message.contentValues = dic
            message.selectBtnWith(btnId: "")
            DispatchQueue.main.async {
                self.tableViewChat.reloadData()
            }
            self.sendMessage(message: message)
            messageTextView.text = ""
            updateComposerHeight()
            updateInputButtonsForText()
            //                responseMessage?.userType = .customer
            //                responseMessage?.creationDateTime = self.creationDateTime
            //                responseMessage?.status = status
            //                cellDetail?.actionHeight = nil
            
            //            addMessageToUIBeforeSending(message: dateTimeMessage)
            //            self.sendMessage(message: dateTimeMessage)
        }
    }
    

    
    func sendMessageButtonAction(messageTextStr: String){
        if storeResponse?.restrictPersonalInfo ?? false && channel?.chatDetail?.chatType == .other{
            if messageTextStr.trimmingCharacters(in: .whitespaces).matches(for: phoneRegex).count > 0 || messageTextStr.isValidEmail() || messageTextStr.isValidUrl() || messageTextStr.matches(for: urlRegex).count > 0{
                showErrorMessage(messageString: HippoStrings.donotAllowPersonalInfo)
                updateErrorLabelView(isHiding: true)
                return
            }
        }
        
        if channel != nil, !channel.isSubscribed()  {
            channel.subscribe()
        }
        
        if FuguNetworkHandler.shared.isNetworkConnected == false {
            return
        }
        
        if SocketClient.shared.isConnected() == false {
            SocketClient.shared.connect()
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
                    self?.updateComposerHeight()
                    self?.updateInputButtonsForText()
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
        self.updateComposerHeight()
        // Text was just cleared (also for media sends) - swap send back to mic.
        self.updateInputButtonsForText()
        self.newScrollToBottom(animated: false)
    }
    
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        backButtonClicked()
    }
    
    func setThemeForBusiness() {
        //        let isMultiChannelLabelMapping = BussinessProperty.current.multiChannelLabelMapping && !forceHideActionButton
        
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
    
    func disableSendingReply(withOutUpdate: Bool = false, message: String? = nil) {
        setComposerAreaCollapsed(false)
        self.pleaseSelectOptionView.isHidden = false
        self.pleaseSelectOptionLabel.isHidden = false
        self.pleaseSelectOptionLabel.text = message ?? (HippoProperty.current.pleaseSelectOptionText ?? HippoStrings.pleaseSelectAnOption)
        if !withOutUpdate {
            self.channel?.isSendingDisabled = true
        }
        // Only the composer is being hidden. view.endEditing would also close a bot form
        // field's keyboard - and this runs on every socket push while a form is active.
        self.messageTextView.resignFirstResponder()
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
        setComposerAreaCollapsed(false)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
        self.pleaseSelectOptionView.isHidden = true
        self.pleaseSelectOptionLabel.isHidden = true
    }

    /// True while an unanswered bot widget (lead form / create ticket) owns the
    /// input. Sticky on purpose: a channel-update or typing push may set it, but
    /// only a real message push is allowed to clear it.
    var isBotInputMode = false

    /// Message types whose widget owns the input while it still has unanswered
    /// questions - 17 (lead form) and 29 (create ticket).
    private var botInputMessageTypes: [MessageType] {
        return [.leadForm, .createTicket]
    }

    /// Entry point for every socket push on this channel.
    ///
    /// A push with no `message_type` key is not a message push (read receipt,
    /// channel ping) and must leave the composer exactly as the last
    /// message-bearing push left it. The check is for key *presence* - defaulting
    /// a missing key to 0 would make a receipt look like "some other message" and
    /// re-open the composer on top of a live form.
    func updateComposerVisibility(forSocketPush dict: [String: Any]) {
        guard let rawMessageType = dict["message_type"] as? Int else {
            return
        }
        let messageType = MessageType(rawValue: rawMessageType) ?? .none
        let isTyping = (dict["is_typing"] as? Int ?? 0) != 0
        // `type` 100 is a channel-update push. It echoes the previous message's
        // message_type and races with the real widget push, so it may hide the
        // composer but must never re-show it. Same for typing indicators.
        let isChannelUpdate = (dict["type"] as? Int) == 100

        if botInputMessageTypes.contains(messageType) {
            isBotInputMode = true
        } else if !isTyping, !isChannelUpdate {
            isBotInputMode = isLatestMessageActiveBotForm()
        }

        showComposerIfAllowed()
    }

    /// The single funnel every "show the composer" has to go through. Scattered
    /// unconditional shows are what let a late REST response force the composer
    /// back open over a live bot form.
    func showComposerIfAllowed() {
        // A hard block (chat closed, reply disabled) always wins.
        guard !isReplyHardDisabled else {
            return
        }

        if isBotInputMode || isLatestMessageActiveBotForm() {
            isBotInputMode = true
            hideComposerForBotInput()
            return
        }

        enableSendingReply(withOutUpdate: true)
    }

    private var isReplyHardDisabled: Bool {
        return forceDisableReply
            || (channel?.isSendingDisabled ?? false)
            || (channel?.chatDetail?.disableReply ?? false)
    }

    /// Hides the composer *without* setting `channel.isSendingDisabled`. That flag
    /// gates `HippoChannel.sendMessage`, so setting it here would silently drop the
    /// widget's own answer while the composer is hidden.
    private func hideComposerForBotInput() {
        disableSendingReply(withOutUpdate: true, message: "")
        pleaseSelectOptionView.isHidden = true
        pleaseSelectOptionLabel.isHidden = true
        setComposerAreaCollapsed(true)
    }

    /// The storyboard's fixed 58pt height on the "please select an option" bar. It sits between
    /// the message list and the bottom guide with required constraints, so hiding it still
    /// reserves its space. Held strongly so its original constant can be restored.
    private lazy var pleaseSelectOptionHeightConstraint: NSLayoutConstraint? =
        pleaseSelectOptionView.constraints.first { $0.firstAttribute == .height && $0.secondItem == nil }
    private lazy var pleaseSelectOptionDefaultHeight: CGFloat = pleaseSelectOptionHeightConstraint?.constant ?? 58

    /// Collapsed while a bot form owns the input (no composer, no bar): the list runs down
    /// to the bottom instead of leaving an empty band with a separator line above it.
    private func setComposerAreaCollapsed(_ collapsed: Bool) {
        _ = pleaseSelectOptionDefaultHeight
        pleaseSelectOptionHeightConstraint?.constant = collapsed ? 0 : pleaseSelectOptionDefaultHeight
        seperatorView.isHidden = collapsed
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            self.updateChatInsetForComposerOverlap()
        }
    }

    /// Walks the thread backwards to the newest message and reports whether it is a
    /// bot widget still waiting on answers. Date separators are section boundaries
    /// in `messagesGroupedByDate`, not rows, so there is nothing to skip here.
    func isLatestMessageActiveBotForm() -> Bool {
        for group in messagesGroupedByDate.reversed() {
            for message in group.reversed() {
                guard botInputMessageTypes.contains(message.type) else {
                    return false
                }
                let questionCount = message.content.questionsArray.count
                let answeredCount = message.content.values.count
                return questionCount == 0 || answeredCount < questionCount
            }
        }
        return false
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
        updateInfoIconVisibility()
        if HippoConfig.shared.isFromPantherCallBtn == true{
            HippoConfig.shared.isFromPantherCallBtn = false
            startAudioCall()
           
        }else{
            
        }
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
        if result.isSendingDisabled || forceDisableReply {
            disableSendingReply(message: HippoStrings.cannotReplyToConversation)
        }
        
        if checkIfShouldDisableReplyForCreateTicket(messages: messages) {
            button_Recording.isEnabled = false
            disableSendingNewMessages()
        }

        showComposerIfAllowed()

        if let message = messages.last {
            if message.type == .dateTime {
                self.updateUIForCalendar(message: message)
            }else if message.type == .address {
                setUIForAddress()
            }else if message.type == .botAttachment {
                setUIForBotAttachment()
            }
        }
        
        if request.pageStart == 1, request.pageEnd == nil {
            newScrollToBottom(animated: true)
            sendReadAllNotification()
            // Chat opened on an unfinished bot form - put the user on its next field.
            activateFormIfLastMessage(getLastMessage())
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

            view_Navigation.video_button.tintColor = HippoConfig.shared.colorConfig.hippoIconAccent
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
            view_Navigation.call_button.tintColor = HippoConfig.shared.colorConfig.hippoIconAccent
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
        DispatchQueue.main.async {
            self.tableViewChat.reloadData()
        }
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
        
        HippoChannel.callAssignAgentApi(withParams: dict) { (bool) in
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
        if !isDefaultChannel() {
            startLoaderAnimation()
        }
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
    
    /// Single source of truth for the mic vs. send button swap in the composer.
    /// Derives visibility from whether the field has text so callers that are not
    /// text-input events (e.g. a received message re-enabling the composer) can't
    /// desync the two buttons. Pass `hasText` when the textview's own text is not
    /// yet updated (e.g. from `shouldChangeTextIn`).
    func updateInputButtonsForText(hasText: Bool? = nil) {
        // Recording owns the button layout while it's active - don't let text or
        // incoming-message events flip mic/send back.
        if voiceRecordingState == .recording {
            button_Recording.isHidden = true
            sendMessageButton.isHidden = false
            sendMessageButton.isEnabled = true
            return
        }

        let hasText = hasText ?? messageTextView.hasText

        if messageInEditing != nil {
            button_Recording.isHidden = true
            sendMessageButton.isHidden = true
            sendMessageButton.isEnabled = hasText
            return
        }

        guard HippoConfig.shared.isRecordingButtonEnabled else {
            button_Recording.isHidden = true
            sendMessageButton.isHidden = false
            sendMessageButton.isEnabled = hasText
            return
        }

        sendMessageButton.isHidden = !hasText
        sendMessageButton.isEnabled = hasText
        button_Recording.isHidden = hasText
    }

    func enableSendingNewMessages() {
        addFileButtonAction.isUserInteractionEnabled = true
        messageTextView.isEditable = true
        messageTextView.isUserInteractionEnabled = true
        button_Recording.isEnabled = true

        updateInputButtonsForText()
    }
    
    func disableSendingNewMessages() {
        addFileButtonAction.isUserInteractionEnabled = false
        messageTextView.isUserInteractionEnabled = false
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
        // The chat just became a real conversation, so the menu can appear. Handled
        // here rather than only in the get-messages response because
        // `shouldHitGetMessagesAfterCreateConversation()` skips that call for some
        // new-chat paths.
        updateInfoIconVisibility()
        
        let (sentMessage, unsentMessage) = getMessageFromGrouped(messages: messagesGroupedByDate)
        channel?.sentMessages = sentMessage
        channel?.unsentMessages = unsentMessage
        self.updateMessagesInLocalArrays(messages: [])
        DispatchQueue.main.async {
            self.tableViewChat.reloadData()
        }
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
        vc.original_transaction_id = conversationObj.original_transaction_id
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
        vc.original_transaction_id = chatAttributes.transactionId
        vc.preMessage = chatAttributes.preMessage
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
    
    class func getWith(channelID: Int, channelName: String, transactionId: String? = nil) -> ConversationsViewController {
        let vc = getNewInstance()
        vc.channel = FuguChannelPersistancyManager.shared.getChannelBy(id: channelID)
        vc.label = channelName
        vc.original_transaction_id = transactionId
        return vc
    }
    
    private class func getNewInstance() -> ConversationsViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
        return vc
    }
}

extension ConversationsViewController : SearchAddressControllerProtocol {
    func addressSelected(address: Address) {
        messageTextView.text = address.address ?? ""
        updateComposerHeight()
        sendMessageButton.isEnabled = true
        sendMessageButton.isHidden = false
        button_Recording.isHidden = true
        var dic = [[String : Any]]()
        let obj = ["address": address.address ?? "", "latitude": address.lat ?? 0.0, "longitude": address.lng ?? 0.0] as [String : Any]
        dic.append(obj)
        guard let message = messagesGroupedByDate.last?.last as? HippoActionMessage else {
            return
        }
        message.contentValues = dic
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
        // Rounded pill fill on the text field itself only — textViewBgView spans the whole
        // composer row (media + mic buttons included), so it can't be the rounded element.
        self.messageTextView.backgroundColor = HippoConfig.shared.colorConfig.hippoSurfaceInput
        self.messageTextView.layer.cornerRadius = 18
        self.applyComposerTextInsets()
        // placeHolderLabel is a sibling that sits behind messageTextView in the storyboard's
        // subview order — with a .clear text view background that was invisible, but the
        // opaque pill fill above now paints over it. Bring it back in front; the real typed
        // text is unaffected since that's drawn inside messageTextView's own layer.
        self.messageTextView.superview?.bringSubviewToFront(self.placeHolderLabel)
        self.messageTextView.clipsToBounds = true
        self.messageTextView.tintColor = HippoConfig.shared.theme.messageTextViewTintColor//

        // Auto-growing composer: scrolling stays off so the intrinsic content size
        // drives height between the 42pt floor and the 120pt cap; no scroll bars.
        self.messageTextView.isScrollEnabled = false
        self.messageTextView.showsVerticalScrollIndicator = false
        self.messageTextView.showsHorizontalScrollIndicator = false
        if composerHeightConstraint == nil {
            // Required: this is the single source of truth for the pill height, so it
            // must never be the constraint UIKit breaks when the layout gets tight
            // (that was the "collapse back to 42pt" bug once scrolling kicked in).
            let heightC = messageTextView.heightAnchor.constraint(equalToConstant: composerMinHeight)
            heightC.priority = .required
            heightC.isActive = true
            composerHeightConstraint = heightC
        }
        updateComposerHeight()

        placeHolderLabel.text = HippoConfig.shared.theme.messagePlaceHolderText == nil ? HippoStrings.messagePlaceHolderText : HippoConfig.shared.theme.messagePlaceHolderText
        
        errorLabel.text = ""
        if errorLabelTopConstraint != nil {
            errorLabelTopConstraint.constant = -20
        }
        

        
        if (channel != nil && channel?.isSendingDisabled == true) || forceDisableReply {
            disableSendingReply(message: HippoStrings.cannotReplyToConversation)
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
        // This recognizer sits on the whole table with cancelsTouchesInView = false, so it also
        // fires for taps on controls inside cells - e.g. a bot form's submit arrow, where closing
        // the keyboard would undo the move to the next field. Leave those taps to the control.
        if tapLandedOnControl(sender) {
            return
        }
        activeFormMessage = nil

        guard messageTextView.isFirstResponder else {
            self.view.endEditing(true)//
            return
        }
        
        //Delayed so that tableview gets correct touch event to run didselect.
        //The table offset follows the keyboard via updateChatInsetForComposerOverlap().
        fuguDelay(0.1) {
            self.messageTextView.resignFirstResponder()
        }
    }
    
    private func tapLandedOnControl(_ gesture: UIGestureRecognizer) -> Bool {
        var view = tableViewChat.hitTest(gesture.location(in: tableViewChat), with: nil)
        while let current = view, current !== tableViewChat {
            if current is UIControl { return true }
            view = current.superview
        }
        return false
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
        relaxComposerTopAnchors()
        if isObserverAdded == false {
            textViewBgView.layoutIfNeeded()
            let inputView = FrameObserverAccessaryView(frame: textViewBgView.bounds)
            inputView.isUserInteractionEnabled = false
            
            messageTextView.inputAccessoryView = inputView
            
            inputView.changeKeyboardFrame { [weak self] (keyboardVisible, keyboardFrame) in
                guard let self = self else { return }
                let value = FUGU_SCREEN_HEIGHT - keyboardFrame.minY - UIView.safeAreaInsetOfKeyWindow.bottom
                let maxValue = max(0, value)
                // Keep whatever sits just above the composer there while the keyboard
                // opens or closes, however the table's frame/insets end up changing.
                let gapToBottom = self.chatDistanceFromBottom()
                self.textViewBottomConstraint.constant = maxValue

                self.view.layoutIfNeeded()
                self.updateChatInsetForComposerOverlap()
                self.restoreChatDistanceFromBottom(gapToBottom)
            }
            isObserverAdded = true
        }
    }

    /// The composer (`textViewBgView`) is pinned in the storyboard at BOTH ends:
    /// its top to the message-list chain (`= WCe/seperatorView.bottom`, required) and
    /// its bottom, via `textViewBottomConstraint`, to the fixed bottom layout guide.
    /// When the keyboard raises the bottom pin and the table can't shrink enough to
    /// compensate, the composer gets crushed instead of translated — UIKit breaks
    /// `messageTextView`'s `height >= 50` and the input pill collapses (observed:
    /// 42pt -> 26.67pt on keyboard open).
    ///
    /// Dropping the top pins below required lets the composer stay content-sized
    /// (honouring `height >= 50`) and bottom-anchored, so it floats up above the
    /// keyboard rather than being compressed. 999 keeps them effective in every
    /// non-conflicting state (normal docking below the list).
    /// Resizes `messageTextView` to fit its content, clamped to
    /// `composerMinHeight...composerMaxHeight`. Once the text needs more than the
    /// cap, scrolling is turned on so the overflow stays reachable.
    func updateComposerHeight() {
        guard let heightC = composerHeightConstraint else { return }
        let width = messageTextView.bounds.width
        guard width > 0 else { return }
        let fitting = messageTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        let clamped = min(max(composerMinHeight, ceil(fitting)), composerMaxHeight)
        // Once the content is taller than the cap, hold the pill at the cap and let
        // the text view scroll — new lines push older text up instead of resizing.
        messageTextView.isScrollEnabled = fitting > composerMaxHeight
        if abs(heightC.constant - clamped) > 0.5 {
            heightC.constant = clamped
            view.layoutIfNeeded()
            updateChatInsetForComposerOverlap()
        }
        if messageTextView.isScrollEnabled {
            messageTextView.scrollRangeToVisible(messageTextView.selectedRange)
        }
    }

    /// `tableViewChat`'s bottom is pinned (through the suggestion stack and the fixed
    /// 58pt "please select an option" strip) to the screen bottom, not to the
    /// composer. So when the keyboard lifts the composer — or the composer grows for
    /// multi-line text — the table keeps its full height and its last rows end up
    /// behind the composer and keyboard.
    ///
    /// Pad the table's bottom inset by exactly that overlap so its scrollable area
    /// ends at the composer's top edge, and move the offset by the same amount so
    /// whatever was visible at the bottom stays visible (keyboard up and down).
    func updateChatInsetForComposerOverlap() {
        guard isViewLoaded, textViewBgView.superview === tableViewChat.superview else { return }
        let overlap = textViewBgView.isHidden ? 0 : max(0, tableViewChat.frame.maxY - textViewBgView.frame.minY)
        let delta = overlap - composerOverlapInset
        guard abs(delta) > 0.5 else { return }
        composerOverlapInset = overlap

        tableViewChat.contentInset.bottom += delta
        tableViewChat.verticalScrollIndicatorInsets.bottom += delta

        let insets = tableViewChat.adjustedContentInset
        let minOffsetY = -insets.top
        let maxOffsetY = max(minOffsetY, tableViewChat.contentSize.height + insets.bottom - tableViewChat.bounds.height)
        let newOffsetY = min(max(tableViewChat.contentOffset.y + delta, minOffsetY), maxOffsetY)
        tableViewChat.contentOffset = CGPoint(x: tableViewChat.contentOffset.x, y: newOffsetY)
    }

    /// How far the visible area is from the end of the chat content (0 = at the bottom).
    private func chatDistanceFromBottom() -> CGFloat {
        let insets = tableViewChat.adjustedContentInset
        let maxOffsetY = max(-insets.top, tableViewChat.contentSize.height + insets.bottom - tableViewChat.bounds.height)
        return max(0, maxOffsetY - tableViewChat.contentOffset.y)
    }

    private func restoreChatDistanceFromBottom(_ distance: CGFloat) {
        let insets = tableViewChat.adjustedContentInset
        let minOffsetY = -insets.top
        let maxOffsetY = max(minOffsetY, tableViewChat.contentSize.height + insets.bottom - tableViewChat.bounds.height)
        let newOffsetY = min(max(maxOffsetY - distance, minOffsetY), maxOffsetY)
        guard abs(newOffsetY - tableViewChat.contentOffset.y) > 0.5 else { return }
        tableViewChat.contentOffset = CGPoint(x: tableViewChat.contentOffset.x, y: newOffsetY)
    }

    private func relaxComposerTopAnchors() {
        guard let host = textViewBgView.superview else { return }
        for constraint in host.constraints where constraint.priority == .required
            && constraint.firstAttribute == .top
            && (constraint.firstItem as? UIView) === textViewBgView {
            constraint.priority = UILayoutPriority(999)
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
        if let _ = cell as? SelfMessageTableViewCell {
            //editedCell.topConstraint.constant = topConstraint
        } else if let _ = cell as? SupportMessageTableViewCell {
            //editedCell.topConstraint.constant = topConstraint
        }else if let editedCell = cell as? IncomingImageCell {
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
        
        fuguDelay(0.0) {
            
            var numberOfSections = -1
            if self.tableViewChat.numberOfSections > 1 {
                numberOfSections = self.tableViewChat.numberOfSections - 1
            } else {
                numberOfSections = self.tableViewChat.numberOfSections
            }
            
            guard numberOfSections > 0 else { return }
            
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
                // Attachment-sheet glyphs (Gallery / Camera / Media / location) ride the
                // same icon token as the composer and header icons.
                cell.settingImage.tintColor = HippoConfig.shared.colorConfig.hippoIconAccent
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
                
                if let imageBundle = FuguFlowManager.bundle, let getImagePath = imageBundle.path(forResource: "typingImage", ofType: ".gif") {
                    do {
                        try cell.gifImageView.image = UIImage.gif(data: Data(contentsOf: URL(fileURLWithPath: getImagePath)))
                    } catch let error {
                        HippoConfig.shared.log.debug(("-------\nERROR\nimage decoding error\n--------" , error), level: .error)
                    }
                    
                    //                    cell.gifImageView.image = UIImage.animatedImageWithData(try! Data(contentsOf: URL(fileURLWithPath: getImagePath)))!
                }
                
                return cell
            case let chatSection where chatSection < self.messagesGroupedByDate.count:
                let messagesArray = messagesGroupedByDate[chatSection]
                
                if messagesArray.count > indexPath.row {
                    let message = messagesArray[indexPath.row]
                    let messageType = message.type
                    let isOutgoingMsg = isSentByMe(senderId: message.senderId) && messageType != .card
                    
                    guard messageType.isMessageTypeHandled() && !message.isInValidMessage() else {
                        return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath, comingFrom: "")
                    }
                    
                    switch messageType {
                        //             case MessageType.dateTime:
                        //                if message.senderId != currentUserId() || message.userType == .system {
                        //                    return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: false, message: message, indexPath: indexPath)
                        //                }else {
                        //                    return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: true, message: message, indexPath: indexPath)
                        //                }
                        //
                    case MessageType.imageFile:
                        if isOutgoingMsg == true {
                            let outgoingImageIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingImageCell" : "OutgoingImageCell"
                            guard
                                let cell = tableView.dequeueReusableCell(withIdentifier: outgoingImageIdentifier, for: indexPath) as? OutgoingImageCell
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
                            let incomingImageIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingImageCell" : "IncomingImageCell"
                            guard let cell = tableView.dequeueReusableCell(withIdentifier: incomingImageIdentifier, for: indexPath) as? IncomingImageCell
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
                        let botTextIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerSupportMessageTableViewCell" : "SupportMessageTableViewCell"
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: botTextIdentifier, for: indexPath) as? SupportMessageTableViewCell
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
                            let outgoingCallIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingVideoCallMessageTableViewCell" : "OutgoingVideoCallMessageTableViewCell"
                            guard let cell = tableView.dequeueReusableCell(withIdentifier: outgoingCallIdentifier, for: indexPath) as? OutgoingVideoCallMessageTableViewCell else {
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
                            let incomingCallIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingVideoCallMessageTableViewCell" : "IncomingVideoCallMessageTableViewCell"
                            guard let cell = tableView.dequeueReusableCell(withIdentifier: incomingCallIdentifier, for: indexPath) as? IncomingVideoCallMessageTableViewCell else {
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
                            case .audio:
                                let outgoingAudioIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingAudioTableViewCell" : "OutgoingAudioTableViewCell"
                                let cell = tableView.dequeueReusableCell(withIdentifier: outgoingAudioIdentifier, for: indexPath) as! OutgoingAudioTableViewCell
                                cell.setData(message: message)
                                cell.delegate = self
                                return cell
                            default:
                                let outgoingDocumentIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingDocumentTableViewCell" : "OutgoingDocumentTableViewCell"
                                let cell = tableView.dequeueReusableCell(withIdentifier: outgoingDocumentIdentifier) as! OutgoingDocumentTableViewCell
                                cell.messageLongPressed = {[weak self](message) in
                                    DispatchQueue.main.async {
                                        self?.longPressOnMessage(message: message, indexPath: indexPath)
                                    }
                                }
                                cell.setCellWith(message: message, comingFrom: message.senderFullName)
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
                            case .audio:
                                let incomingAudioIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingAudioTableViewCell" : "IncomingAudioTableViewCell"
                                let cell = tableView.dequeueReusableCell(withIdentifier: incomingAudioIdentifier, for: indexPath) as! IncomingAudioTableViewCell
                                cell.setData(message: message)
                                return cell

                            default:
                                let incomingDocumentIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingDocumentTableViewCell" : "IncomingDocumentTableViewCell"
                                let cell = tableView.dequeueReusableCell(withIdentifier: incomingDocumentIdentifier) as! IncomingDocumentTableViewCell
                                cell.setCellWith(message: message)
                                cell.actionDelegate = self
                                cell.nameLabel.isHidden = false
                                return cell
                            }
                        }
                    case .consent, .dateTime, .address, .botAttachment:
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
                        if ((message.fileUrl != nil || (message.isMessageWithImage ?? false) && messageType == .normal) && message.messageState != .MessageDeleted) {
                            return self.getCellForMessageWithAttachment(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath)
                        }
                        return getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMsg, message: message, indexPath: indexPath, comingFrom: "")
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
            
        }
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
                        return (message.message == "" || message.message.lowercased() == "image") ? 288 : UITableView.automaticDimension
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
                            // A received video's caption sits on its own line under the
                            // video (IncomingVideoTableViewCell), so it self-sizes.
                            let hasCaption = !message.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            return hasCaption && !isSentByMe(senderId: message.senderId) ? UITableView.automaticDimension : 234
                        default:
                            // A file sent with a caption has to self-size so the
                            // caption isn't clipped - same as .imageFile above.
                            return message.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 80 : UITableView.automaticDimension
                        }
                        
                    case MessageType.actionableMessage, MessageType.hippoPay:
                        return UIView.tableAutoDimensionHeight > -1 ? UIView.tableAutoDimensionHeight : self.getHeightOfActionableMessageAt(indexPath: indexPath, chatObject: message) + 20
                        
                    case MessageType.feedback:
                        
                        //                    guard let muid = message.messageUniqueID, var rowHeight: CGFloat = heightForFeedBackCell["\(muid)"] else {
                        //                        return 0.001
                        //                    }
                        //   rowHeight += 7 //Height for bottom view
                        return UIView.tableAutoDimensionHeight
                        
                    case .consent, .dateTime, .address, .botAttachment:
                        //return UIView.tableAutoDimensionHeight
                        return ((message.cellDetail?.cellHeight ?? 0.01) + 20)
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
            let widthIs: CGFloat = CGFloat((dateLabel.text ?? "").boundingRect(with: dateLabel.frame.size, options: .usesLineFragmentOrigin, attributes: [.font: dateLabel.font as Any], context: nil).size.width) + 10
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
        var errorRowCount = 0
        for lead in message.leadsDataArray {
            if lead.isShow  && lead.type != .button {
                count += 1
                if lead.isErrorEnabled {
                    errorRowCount += 1
                }
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
        // Matches LeadTableViewCell's per-row error padding, so the error line isn't clipped.
        height += LeadDataTableViewCell.errorHeight * CGFloat(errorRowCount)
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
                        }
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
        
        if lastVisibleIndexPath.section == (messagesGroupedByDate.count - 1) && lastVisibleIndexPath.row < ((messagesGroupedByDate.last?.count ?? 0) - 1) {
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
    
    func getCellForMessageWithAttachment(tableView: UITableView, isOutgoingMessage: Bool, message: HippoMessage, indexPath: IndexPath) -> UITableViewCell{
        if message.documentType == .image {
            if isOutgoingMessage {
                let outgoingImageIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingImageCell" : "OutgoingImageCell"
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: outgoingImageIdentifier, for: indexPath) as? OutgoingImageCell
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
            }else {
                let incomingImageIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingImageCell" : "IncomingImageCell"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: incomingImageIdentifier, for: indexPath) as? IncomingImageCell
                else {
                    let cell = UITableViewCell()
                    cell.backgroundColor = .clear
                    return cell
                }
                cell.delegate = self
                return cell.configureIncomingCell(resetProperties: true, channelId: channel.id, chatMessageObject: message, indexPath: indexPath)
            }
        }else {
            if isOutgoingMessage {
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
                case .audio:
                    let outgoingAudioIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingAudioTableViewCell" : "OutgoingAudioTableViewCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: outgoingAudioIdentifier, for: indexPath) as! OutgoingAudioTableViewCell
                    cell.setData(message: message)
                    cell.delegate = self
                    return cell
                default:
                    let outgoingDocumentIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingDocumentTableViewCell" : "OutgoingDocumentTableViewCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: outgoingDocumentIdentifier) as! OutgoingDocumentTableViewCell
                    cell.messageLongPressed = {[weak self](message) in
                        DispatchQueue.main.async {
                            self?.longPressOnMessage(message: message, indexPath: indexPath)
                        }
                    }
                    cell.setCellWith(message: message, comingFrom: message.senderFullName)
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
                case .audio:
                    let incomingAudioIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingAudioTableViewCell" : "IncomingAudioTableViewCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: incomingAudioIdentifier, for: indexPath) as! IncomingAudioTableViewCell
                    cell.setData(message: message)
                    return cell

                default:
                    let incomingDocumentIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerIncomingDocumentTableViewCell" : "IncomingDocumentTableViewCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: incomingDocumentIdentifier) as! IncomingDocumentTableViewCell
                    cell.setCellWith(message: message)
                    cell.actionDelegate = self
                    cell.nameLabel.isHidden = false
                    return cell
                }
            }
        }
    }
}

// MARK: - UITextViewDelegates
extension ConversationsViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.hasText
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if placeHolderLabel.text == HippoStrings.selectDate ||  placeHolderLabel.text == HippoStrings.selectTime {
            self.actionCalendar()
            return false
        }else if placeHolderLabel.text == HippoStrings.selectAddress {
            self.openSearchAddress()
            return false
        }
        
        self.addRemoveShadowInTextView(toAdd: true)
        activeFormMessage = nil
        
        placeHolderLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 0.8)
        textInTextField = textView.text
        textViewBgView.backgroundColor = .white
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.watcherOnTextView()
        }
        
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
        updateComposerHeight()
        updateInputButtonsForText(hasText: !textView.text.isEmpty)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimWhiteSpacesAndNewLine() == ""{
            self.sendMessageButton.isEnabled = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = ((textView.text as NSString?)?.replacingCharacters(in: range, with: text))!
        if newText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
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
            if typingMessageValue == TypingMessage.startTyping.rawValue, channel != nil {
                sendTypingStatusMessage(isTyping: TypingMessage.startTyping)
                self.typingMessageValue = TypingMessage.stopTyping.rawValue
            }
        }
        
        updateInputButtonsForText(hasText: newText != "")

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
    func socketPushReceived(dict: [String: Any]) {
        updateComposerVisibility(forSocketPush: dict)
    }

    func closeChatActionFromRefreshChannel() {
        self.backButtonClicked()
    }
    
    func channelDataRefreshed() {
        label = channel?.chatDetail?.channelName ?? label
        userImage = channel?.chatDetail?.channelImageUrl
        
        if channel?.chatDetail?.disableReply == true{
            //disableSendingReply(withOutUpdate: true)
            disableSendingReply(message: HippoStrings.cannotReplyToConversation)
        }

        showComposerIfAllowed()

        setTitleForCustomNavigationBar()
        handleAudioIcon()
        handleVideoIcon()
        updateInfoIconVisibility()
        // The server echo of a bot form lands here with freshly parsed fields.
        reloadChatKeepingFormFocus()
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
    
    private func updateUIForCalendar(message : HippoMessage) {
        buttonCalendar.isHidden = false
        addFileButtonAction.isHidden = true
        placeHolderLabel.text = message.actionableMessage?.botResponseType == .time ? HippoStrings.selectTime : HippoStrings.selectDate
    }
    
    private func setUIForAddress() {
        buttonCalendar.isHidden = true
        addFileButtonAction.isHidden = false
        addFileButtonAction.isEnabled = false
        self.messageTextView.resignFirstResponder()
        self.placeHolderLabel.text = HippoStrings.selectAddress
    }
    
    private func setUIForBotAttachment() {
        buttonCalendar.isHidden = true
        addFileButtonAction.isEnabled = true
        self.messageTextView.isUserInteractionEnabled = false
        self.placeHolderLabel.text = HippoStrings.chooseFile
    }
    
    @IBAction func actionCalendar() {
        let dateTimePicker = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle).instantiateViewController(withIdentifier: "DateTimePicker") as! DateTimePicker
        if let message = self.messagesGroupedByDate.last?.last {
            dateTimePicker.message = message
        }
        dateTimePicker.modalPresentationStyle = .overFullScreen
        dateTimePicker.delegate = self
        self.present(dateTimePicker, animated: true, completion: nil)
    }
    
    private func openSearchAddress() {
        let vc = SearchAddressController.getNewInstance()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func newMessageReceived(newMessage message: HippoMessage) {
        enableSendingNewMessages()
        if message.type != .dateTime && message.type != .address {
            buttonCalendar.isHidden = true
            addFileButtonAction.isHidden = false
            addFileButtonAction.isEnabled = true
            placeHolderLabel.text = HippoStrings.messagePlaceHolderText
        }
        
        guard !isSentByMe(senderId: message.senderId) || message.type.isBotMessage  else {
            HippoConfig.shared.log.debug("Yahaa se nahi nikla", level: .custom)
            return
        }
        
        self.setKeyboardType(message: message)
        
        
        isTypingLabelHidden = message.typingStatus != .startTyping
        switch message.type {
        case .botAttachment:
            setUIForBotAttachment()
        case .address:
            setUIForAddress()
        case .dateTime:
            self.messageTextView.resignFirstResponder()
            self.updateUIForCalendar(message: message)
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
        if message.type == .leadForm || message.type == .createTicket {
            // Queued after updateMessagesArrayLocallyForUIUpdation's async insert.
            DispatchQueue.main.async {
                self.activateFormIfLastMessage(self.getLastMessage())
            }
        }
        
        if message.type == MessageType.createTicket{
            button_Recording.isEnabled = false
            disableSendingNewMessages()
        }
        
        if message.type == MessageType.consent{
            self.isFirst = true
            self.disableSendingReply(withOutUpdate: true)
        }

        showComposerIfAllowed()
        updateInfoIconVisibility()
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

extension ConversationsViewController : DateTimePickerDelegate{
    func dateSelected(selectedDate: String) {
        sendMessageButton.isEnabled = true
        sendMessageButton.isHidden = false
        button_Recording.isHidden = true
        self.messageTextView.text = selectedDate
        updateComposerHeight()
        sendMessageButton.isEnabled = true
    }
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
        
        popover = LCPopover(for: sender, title: "") { [weak self] tuple in
            // Use of the selected tuple
            guard let value = tuple else { return }
            sender.text = value
            // Picking an option answers the menu field - submit it and move on.
            self?.formFieldCell(containing: sender)?.submitAnswer()
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
        guard let indexPath = formIndexPath(for: cell) else {
            return
        }
        guard indexPath.section < self.messagesGroupedByDate.count else {
            return
        }
        let message = messagesGroupedByDate[indexPath.section][indexPath.row]
        message.leadsDataArray = data
        activeFormMessage = isSkipAction ? nil : message
        if isSkipAction {
            DispatchQueue.main.async {
                self.reloadChatKeepingFormFocus()
            }
        } else {
            // Synchronous on purpose: the form's own reload has just taken focus off the field.
            // Re-focusing in the same run-loop turn keeps the keyboard up; deferring it let the
            // keyboard start to close before the next field took over.
            reloadChatKeepingFormFocus()
        }
        var count = 0
        for message in data {
            if message.isShow == true {
                count += 1
            }
        }
        guard let _ = cell.tableView.cellForRow(at: IndexPath(row: 0, section: count - 1)) as? LeadDataTableViewCell, !isSkipAction else {
            return
        }
        
    }
    
    // MARK: Bot form focus
    //
    // The next field to answer is derived from the form data (HippoMessage.nextFormFieldIndex:
    // first shown, uncompleted field), not remembered in a cell - so it survives every reload,
    // including the server echo that rebuilds the form's fields.

    /// Full reload (always resizes the form row correctly), then puts the user back on the
    /// active form's next field. Text being typed is saved first so a reload can't wipe it.
    func reloadChatKeepingFormFocus() {
        let answerBeingEdited = answeredFormFieldBeingEdited()
        saveTypedFormDraft()
        tableViewChat.reloadData()
        // Re-bind the visible cells now: sendReply / cellUpdated look the form up from its cell,
        // and right after reloadData a cell has no index path until the next layout.
        tableViewChat.layoutIfNeeded()
        if let edit = answerBeingEdited, restoreEditOfAnsweredField(edit) {
            return
        }
        focusActiveFormField()
    }

    /// An answered, editable field (pencil) the user is changing right now, with what they've
    /// typed - so a reload (e.g. from a socket push) doesn't throw them to the next field.
    private func answeredFormFieldBeingEdited() -> (message: HippoMessage, section: Int, text: String)? {
        for case let formCell as LeadTableViewCell in tableViewChat.visibleCells {
            for case let fieldCell as LeadDataTableViewCell in formCell.tableView.visibleCells
            where fieldCell.valueTextfield.isFirstResponder {
                guard let message = formCell.message,
                      let data = fieldCell.boundData, data.isCompleted,
                      let section = formCell.filterFileArray.firstIndex(where: { $0 === data }) else { return nil }
                return (message, section, fieldCell.valueTextfield.text ?? "")
            }
        }
        return nil
    }

    private func restoreEditOfAnsweredField(_ edit: (message: HippoMessage, section: Int, text: String)) -> Bool {
        guard let indexPath = indexPathOfMessage(edit.message),
              let formCell = tableViewChat.cellForRow(at: indexPath) as? LeadTableViewCell,
              let fieldCell = formCell.fieldCell(forSection: edit.section),
              let data = fieldCell.boundData, data.isCompleted, data.shouldBeEditable else { return false }
        fieldCell.valueTextfield.text = edit.text
        if edit.text != data.value {
            // After setData's deferred styling, which would put the pencil back.
            DispatchQueue.main.async { [weak fieldCell] in
                guard let fieldCell = fieldCell, fieldCell.boundData === data else { return }
                fieldCell.showSubmitIcon()
            }
        }
        if !fieldCell.valueTextfield.isFirstResponder {
            fieldCell.valueTextfield.becomeFirstResponder()
        }
        return true
    }

    /// Makes `message` the active form if it's the last message and still has a field to
    /// answer, then focuses that field - for a form that just arrived or was loaded with the chat.
    func activateFormIfLastMessage(_ message: HippoMessage?) {
        guard let message = message, message === getLastMessage(), message.nextFormFieldIndex != nil else { return }
        activeFormMessage = message
        DispatchQueue.main.async {
            self.focusActiveFormField()
        }
    }

    /// Text field -> keyboard. Menu -> option list, no keyboard. Attachment -> keyboard closed,
    /// user taps it. Each is scrolled into view; nothing left to answer -> keyboard closed.
    func focusActiveFormField() {
        guard let message = activeFormMessage, let indexPath = indexPathOfMessage(message) else { return }
        guard let next = message.nextFormFieldIndex else {
            activeFormMessage = nil
            view.endEditing(true)
            return
        }
        tableViewChat.layoutIfNeeded()
        if tableViewChat.cellForRow(at: indexPath) == nil {
            tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
            tableViewChat.layoutIfNeeded()
        }
        guard let formCell = tableViewChat.cellForRow(at: indexPath) as? LeadTableViewCell,
              let fieldCell = formCell.fieldCell(forSection: next) else { return }

        switch message.leadsDataArray[next].fieldKind {
        case .text:
            // Scroll first, then focus: the keyboard manager lifts the field above the keyboard.
            scrollFormFieldIntoView(fieldCell, animated: false)
            if !fieldCell.valueTextfield.isFirstResponder {
                fieldCell.valueTextfield.becomeFirstResponder()
            }
        case .menu:
            scrollFormFieldIntoView(fieldCell, animated: true)
            guard !(presentedViewController is LCPopover) else { return }
            view.endEditing(true)
            // After the scroll and any closing popover settle - a popover can't present over
            // another one. Focusing a menu field loads its options and shows the list.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self, weak fieldCell] in
                guard let self = self, let fieldCell = fieldCell, fieldCell.window != nil,
                      self.activeFormMessage === message, self.presentedViewController == nil,
                      !fieldCell.valueTextfield.isFirstResponder else { return }
                fieldCell.valueTextfield.becomeFirstResponder()
            }
        case .attachment:
            view.endEditing(true)
            scrollFormFieldIntoView(fieldCell, animated: true)
        }
    }

    private func scrollFormFieldIntoView(_ fieldCell: UIView, animated: Bool) {
        let rect = fieldCell.convert(fieldCell.bounds, to: tableViewChat).insetBy(dx: 0, dy: -12)
        tableViewChat.scrollRectToVisible(rect, animated: animated)
    }

    /// Copies what the user is typing into the field's draftValue, which LeadDataTableViewCell
    /// shows after a reload.
    private func saveTypedFormDraft() {
        guard let message = activeFormMessage, let next = message.nextFormFieldIndex,
              let indexPath = indexPathOfMessage(message),
              let formCell = tableViewChat.cellForRow(at: indexPath) as? LeadTableViewCell,
              let fieldCell = formCell.fieldCell(forSection: next),
              fieldCell.valueTextfield.isFirstResponder else { return }
        message.leadsDataArray[next].draftValue = fieldCell.valueTextfield.text ?? ""
    }

    /// Where a form cell's message is. Falls back to the cell's bound message when the table
    /// can't place the cell (e.g. between a reload and the next layout) - otherwise a submit
    /// could be dropped without ever reaching the server.
    private func formIndexPath(for cell: LeadTableViewCell) -> IndexPath? {
        if let indexPath = tableViewChat.indexPath(for: cell) {
            return indexPath
        }
        guard let message = cell.message else { return nil }
        return indexPathOfMessage(message)
    }

    private func indexPathOfMessage(_ message: HippoMessage) -> IndexPath? {
        for (section, messages) in messagesGroupedByDate.enumerated() {
            if let row = messages.firstIndex(where: { $0 === message || ($0.messageUniqueID != nil && $0.messageUniqueID == message.messageUniqueID) }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }

    private func formFieldCell(containing view: UIView) -> LeadDataTableViewCell? {
        var current = view.superview
        while let candidate = current {
            if let cell = candidate as? LeadDataTableViewCell { return cell }
            current = candidate.superview
        }
        return nil
    }

    func sendReply(forCell cell: LeadTableViewCell, data: [FormData]) {
        guard let indexPath = formIndexPath(for: cell) else {
            return
        }
        guard indexPath.section < self.messagesGroupedByDate.count else {
            return
        }
        let message = messagesGroupedByDate[indexPath.section][indexPath.row]
        print("[BotForm] sendReply resolved form=\(message.messageUniqueID ?? "nil") type=\(message.type.rawValue) cellForm=\(cell.message?.messageUniqueID ?? "nil")")
        
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
                print("[BotForm] sendFormValues form=\(message.messageUniqueID ?? "nil") type=\(message.type.rawValue) values=\(message.leadsDataArray.prefix(while: { !$0.value.isEmpty }).map { $0.value })")
                self?.channel?.sendFormValues(message: message, completion: {
                    message.botFormMessageUniqueID =  nil
                    // Don't go through `cell` here: by the time the ack arrives it may have been
                    // reused for another form. The reload re-applies Skip visibility from data.
                    self?.reloadChatKeepingFormFocus()
                    
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
                            self?.enableSendingNewMessages()
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
            let messagesArray = messagesGroupedByDate[chatSection]
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
        guard (self.navigationController?.viewControllers.count ?? 0) > 1 else { return false }
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
        //self.sendMessageButton.isHidden = true
        self.button_Recording.isHidden = true
        self.Button_CancelEdit.isHidden = false
        self.Button_EditMessage.isHidden = false
        self.messageTextView.text = message.message
        self.messageTextView.becomeFirstResponder()
    }
    
    func messageEditingStopped(){
        self.messageInEditing = nil
        self.addFileButtonAction.isHidden = false
        //self.sendMessageButton.isHidden = false
        self.button_Recording.isHidden = false
        self.Button_CancelEdit.isHidden = true
        self.Button_EditMessage.isHidden = true
        self.messageTextView.text = ""
        self.updateComposerHeight()
        self.tableViewChat.deselectRow(at: editingMessageIndex ?? IndexPath(), animated: true)
        self.messageTextView.resignFirstResponder()
    }
    
    func fetchAllConversationCache() -> [FuguConversation] {
        guard let convCache = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]] else {
            return []
        }
        
        let arrayOfConversation = FuguConversation.getConversationArrayFrom(json: convCache)
        return arrayOfConversation
    }
    
    func shouldEnableMessageSendingView() -> Bool{
        guard HippoConfig.shared.newChatCallback != nil && (self.channelId <= 0 && self.labelId != -1) else {return true}
        let alreadyActiveChannel = getAlreadyCreatedChannels()
        
        if let (maxChats, _) = HippoConfig.shared.newChatCallback?(alreadyActiveChannel), let maxChats = maxChats{
            if maxChats <= alreadyActiveChannel {
                return false
            }
        }
        return true
    }
    
    func getAlreadyCreatedChannels() -> Int{
        let convo = fetchAllConversationCache()
        let count = convo.filter { con in
            return con.channelStatus.rawValue == 1 && !((con.channelId ?? 0) <= 0 && con.labelId != nil)
        }
        return count.count
    }
    
}

// MARK: - Voice recording (tap the mic to start, tap send to send, tap trash to discard)

extension ConversationsViewController {

    enum VoiceRecordingState {
        case idle
        case recording
    }

    private func setupRecordingBar() {
        guard recordingBar.superview == nil else { return }
        textViewBgView.addSubview(recordingBar)
        NSLayoutConstraint.activate([
            recordingBar.leadingAnchor.constraint(equalTo: textViewBgView.leadingAnchor),
            recordingBar.topAnchor.constraint(equalTo: textViewBgView.topAnchor),
            recordingBar.bottomAnchor.constraint(equalTo: textViewBgView.bottomAnchor),
            recordingBar.trailingAnchor.constraint(equalTo: stackViewButton.leadingAnchor, constant: -4),
        ])
        recordingBar.onTrashTapped = { [weak self] in self?.cancelVoiceRecording() }
    }

    @objc func micButtonTapped() {
        guard voiceRecordingState == .idle else { return }
        requestMicPermission { [weak self] granted in
            guard let self = self else { return }
            guard granted else { self.showMicPermissionDeniedAlert(); return }
            self.beginVoiceRecording()
        }
    }

    private func beginVoiceRecording() {
        setupRecordingBar()
        messageTextView.resignFirstResponder()
        guard recordingHelper.startRecording() else { return }
        voiceRecordingState = .recording

        // Swap the composer into the recording layout.
        recordingBar.backgroundColor = textViewBgView.backgroundColor ?? .white
        textViewBgView.bringSubviewToFront(recordingBar)
        recordingBar.isHidden = false
        recordingBar.reset()
        addFileButtonAction.isHidden = true
        messageTextView.isHidden = true
        placeHolderLabel.isHidden = true
        button_Recording.isHidden = true
        sendMessageButton.isHidden = false
        sendMessageButton.isEnabled = true

        recordingStartDate = Date()
        recordingElapsedTimer?.invalidate()
        recordingElapsedTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.recordingStartDate else { return }
            self.recordingBar.setElapsed(Date().timeIntervalSince(start))
        }
    }

    private func finishVoiceRecordingAndSend() {
        guard voiceRecordingState == .recording else { return }
        endRecordingTimers()
        // RecordingHelper sends via recordingFinished(url:), or shows the
        // "too short" alert via recordingTooShort() for clips under 1s.
        recordingHelper.finishRecording(success: true)
        exitVoiceRecordingUI()
    }

    func cancelVoiceRecording() {
        guard voiceRecordingState == .recording else { return }
        endRecordingTimers()
        recordingHelper.finishRecording(success: false)
        exitVoiceRecordingUI()
    }

    private func endRecordingTimers() {
        recordingElapsedTimer?.invalidate()
        recordingElapsedTimer = nil
        recordingStartDate = nil
        recordingBar.stopDotBlink()
    }

    private func exitVoiceRecordingUI() {
        voiceRecordingState = .idle
        recordingBar.isHidden = true
        addFileButtonAction.isHidden = false
        messageTextView.isHidden = false
        placeHolderLabel.isHidden = messageTextView.hasText
        updateInputButtonsForText()
    }

    private func requestMicPermission(_ completion: @escaping (Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        @unknown default:
            completion(false)
        }
    }

    private func showMicPermissionDeniedAlert() {
        let alert = UIAlertController(title: nil,
                                     message: HippoStrings.microphoneAccessMessage,
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: HippoStrings.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: HippoStrings.openSettings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
}
