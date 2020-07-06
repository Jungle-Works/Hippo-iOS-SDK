//
//  ListDescriptionViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import NotificationCenter

class ListDescriptionViewController: UIViewController {
    
    //MARK: variables
    var listObject = HippoSupportList()
    var isObserverAdded = false
    var lastOffset: CGPoint!
    var isApiHitInProgress = false
    let min_height_textview: CGFloat = 50
    let max_height_textview: CGFloat = 120
    
    @IBOutlet weak var loaderView: So_UIImageView!
    @IBOutlet weak var errorContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewOutlet: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var textViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatButtonView: UIView!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var submitButtonView: UIView!
    @IBOutlet weak var callButtonView: UIView!
    
    @IBOutlet weak var submitButttonHeightConstrais: NSLayoutConstraint!
    @IBOutlet weak var chatButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var callButtonHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupScreen()
        setTextView()
        setData()
    }
    override func viewWillAppear(_ animated: Bool) {
        addObserver()
        checkNetworkConnection()
    }
    deinit {
        print("deinit")
        if !HippoSupportList.currentPathArray.isEmpty {
            HippoSupportList.currentPathArray.removeLast()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func checkNetworkConnection() {
        if FuguNetworkHandler.shared.isNetworkConnected {
            handleErrorLabel(with: "", isForceShow: false)
        } else {
            handleErrorLabel(with: HippoStrings.noNetworkConnection, isForceShow: true)
        }
    }
    func handleErrorLabel(with errorMessage: String, isForceShow: Bool) {
        if isForceShow {
            errorContainerTopConstraint.constant = 0
            errorContainerView.backgroundColor = UIColor.red
            errorLabel.text = errorMessage
        } else {
            errorContainerTopConstraint.constant = -20
            errorContainerView.backgroundColor = UIColor.clear
            errorLabel.text = ""
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.errorContainerView.layoutIfNeeded()
        })
    }
    
    func addObserver() {
        removeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetworkObserver), name: .internetConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetworkObserver), name: .internetDisconnected, object: nil)
    }
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleNetworkObserver() {
        checkNetworkConnection()
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        self.textViewOutlet.resignFirstResponder()
        self.submitButton.startLoading()
        if !FuguNetworkHandler.shared.isNetworkConnected {
            checkNetworkConnection()
            self.submitButton.stopLoading()
            return
        }
        let message = getMessage(useTextView: true)
        
        if !isApiHitInProgress {
            sendMessagesAndPop(with: message)
        }
    }
    @IBAction func callButtonClicked(_ sender: Any) {
        makeACall()
    }
    
    @IBAction func chatButtonClicked(_ sender: Any) {
        let message = getMessage(useTextView: false)
        presentChatScreen(with: message)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if let controllers = self.navigationController?.viewControllers, controllers.count <= 1  {
            self.dismiss(animated: true, completion: nil)
            HippoSupportList.currentPathArray.removeAll()
            return
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    class func get(with object: HippoSupportList) -> ListDescriptionViewController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ListDescriptionViewController") as? ListDescriptionViewController else {
            return nil
        }
        vc.listObject = object
        return vc
    }
    func setTextView() {
        
        textViewOutlet.delegate = self
        
        guard !isObserverAdded else {
            return
        }
        let inputView = FrameObserverAccessaryView(frame: textViewOutlet!.bounds)
        inputView.isUserInteractionEnabled = false
        
        textViewOutlet?.inputAccessoryView = inputView
        isObserverAdded = true
        inputView.changeKeyboardFrame { [weak self] (keyboardVisible, keyboardFrame) in
            guard self != nil else {
                return
            }
            let value = UIScreen.main.bounds.height - keyboardFrame.minY - UIView.safeAreaInsetOfKeyWindow.bottom
            let maxValue = max(0, value)
            self?.scrollView.contentInset.bottom = maxValue
            
            
            guard keyboardVisible else {
                self!.scrollView.contentOffset = self!.lastOffset
                return
            }
            // move if keyboard hide input field
            let distanceToBottom = self!.scrollView.frame.size.height - self!.textViewContainer.frame.origin.y - self!.textViewContainer.frame.size.height
            let collapseSpace = keyboardFrame.height - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self!.scrollView.contentOffset = CGPoint(x: self!.lastOffset.x, y: collapseSpace)
            })
        }
    }
    func popToRootVC() {
        self.navigationController?.popToRootViewController(animated: true)
        let message = listObject.content.responseText.isEmpty ? listObject.content.defaultText : listObject.content.responseText
        showAlertWith(message: message, action: {
            
        })
    }
    func sendMessagesAndPop(with message: String) {
        
        isApiHitInProgress = true
        let transctionId = getTransactionId()
        
        let channelName = listObject.title + " #" + transctionId
        //        let tags = [HippoSupportList.FAQName]
        let uniqueKey = HippoConfig.shared.userDetail?.userUniqueKey ?? "-1"
        
        var attributes = FuguNewChatAttributes(transactionId: transctionId, userUniqueKey: uniqueKey, otherUniqueKey: nil, tags: nil, channelName: channelName, preMessage: message)
        attributes.isInAppChat = true
        
        var customAttributes = self.getCustomAttributes()
        customAttributes["Query"] = textViewOutlet.text
        attributes.customAttributes = customAttributes
        attributes.isCustomAttributesRequired = true
        var params = HippoChannel.getParamsToStartConversation(fuguAttributes: attributes)
        params["tags"] = [["tag_name": HippoSupportList.FAQName]]
        
        HippoChannel.createNewConversationForTicket(params: params, completion: {(result) in
            self.submitButton.stopLoading()
            self.isApiHitInProgress = false
            if result.isSuccessful {
                self.popToRootVC()
            } else {
                let message = result.error?.localizedDescription ?? HippoStrings.somethingWentWrong
                self.handleErrorLabel(with: message, isForceShow: true)
            }
        })
    }
    func getMessage(useTextView: Bool) -> String {
        var message = ""
        if let userId = HippoConfig.shared.userDetail?.userUniqueKey {
            message += "[User ID: \(userId)]"
        }
        if HippoConfig.shared.ticketDetails.transactionId != nil {
            message += "\n" + "[Transaction ID: \(HippoConfig.shared.ticketDetails.transactionId!)]"
        }
        if !message.isEmpty {
            message += "\n"
        }
        message += "[Request type: \(HippoSupportList.FAQName)]"
        
        if !message.isEmpty {
            message += "\n"
        }
        
        message += "[Request] "
        
        if textViewOutlet.text.isEmpty || !useTextView {
            message += listObject.title
            if !listObject.content.subHeading.isEmpty {
                message += "-> " + listObject.content.subHeading
            }
        } else {
            message += textViewOutlet.text
        }
        return message
    }
    
    func presentChatScreen(with message: String) {
        guard let id = HippoConfig.shared.userDetail?.userUniqueKey else {
            return
        }
        
        let transactionId = getTransactionId()
        
        let channelName = listObject.title + " #" + transactionId
        let tags = [HippoSupportList.FAQName]
        HippoConfig.shared.checkForIntialization { (success, error) in
            guard success else {
                return
            }
            
            var hippoChat = FuguNewChatAttributes(transactionId: transactionId, userUniqueKey: id, otherUniqueKey: nil, tags: tags, channelName: channelName, preMessage: message)
            hippoChat.customAttributes = self.getCustomAttributes()
            hippoChat.isCustomAttributesRequired = true
            hippoChat.isInAppChat = true
            FuguFlowManager.shared.showFuguChat(hippoChat)

        }
        
    }
    func startLoaderAnimation() {
        loaderView.startRotationAnimation()
    }
    
    func stopLoaderAnimation() {
        loaderView.stopRotationAnimation()
    }
    func getTransactionId() -> String {
        var transctionId = HippoConfig.shared.ticketDetails.transactionId ?? ""
        
        guard let id = HippoConfig.shared.userDetail?.userUniqueKey else {
            return transctionId
        }
        if transctionId.isEmpty {
            transctionId = id + "_" + "\(listObject.id)"
        } else {
            transctionId += "_\(listObject.id)"
        }
        return transctionId
    }
    func getCustomAttributes() -> [String: Any] {
        var customAttributes = [String: Any]()
        
        if let userId = HippoConfig.shared.userDetail?.userUniqueKey {
            customAttributes["user_id"] = userId
        }
        if let phoneNo = HippoConfig.shared.userDetail?.phoneNumber, phoneNo != "" {
            customAttributes["phone_number"] = phoneNo
        }
        customAttributes["transaction_id"] = getTransactionId()
        customAttributes["path"] = getPath()
        
        
        return customAttributes
    }
    func getPath() -> String {
        var text = ""
        
        text = HippoSupportList.FAQName +  " -> "
        
        for (index, each) in HippoSupportList.currentPathArray.enumerated() {
            text = text + each.title
            
            if index <  HippoSupportList.currentPathArray.count - 1 {
                text += " -> "
            }
        }
        return text
    }
    
    func setupScreen() {
        callButtonView.isHidden = !listObject.content.callButton.isEnabled
        submitButtonView.isHidden = !listObject.content.submitButton.isEnabled
        chatButton.isHidden = !listObject.content.chatButton.isEnabled
        
        callButtonHeightConstraint.constant = listObject.content.callButton.isEnabled ? 66 : 0
        submitButttonHeightConstrais.constant = listObject.content.submitButton.isEnabled ? 66 : 0
        chatButtonHeightConstraint.constant = listObject.content.chatButton.isEnabled ? 66 : 0
        
        textViewOutlet.layer.borderWidth = 1
        textViewOutlet.layer.borderColor = UIColor.black.cgColor
        textViewOutlet.layer.cornerRadius = 5
        
        callButton.layer.cornerRadius = 6
        chatButton.layer.cornerRadius = 6
        submitButton.layer.cornerRadius = 6
        
        callButton.setTitle(listObject.content.callButton.text, for: .normal)
        chatButton.setTitle(listObject.content.chatButton.text, for: .normal)
        submitButton.setTitle(listObject.content.submitButton.text, for: .normal)
        
        textViewContainerHeightConstraint.constant = listObject.content.isQueryFormEnabled ? min_height_textview + 25 : 0
        textViewOutlet.isHidden = !listObject.content.isQueryFormEnabled
        textViewOutlet.delegate = self
        textViewOutlet.text = listObject.content.textViewText
        updateHeightOf(textView: textViewOutlet)
        
        setViewAsPerTheme()
    }
    
    func setData() {
        subHeadingLabel.text = listObject.content.subHeading
        descTextView.text = listObject.content.description
    }
    func setViewAsPerTheme() {
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        self.callButton.backgroundColor = HippoConfig.shared.theme.supportTheme.supportButtonThemeColor
        self.chatButton.backgroundColor = HippoConfig.shared.theme.supportTheme.supportButtonThemeColor
        self.submitButton.backgroundColor = HippoConfig.shared.theme.supportTheme.supportButtonThemeColor
        
        self.callButton.setTitleColor(HippoConfig.shared.theme.supportTheme.supportButtonTitleColor, for: .normal)
        self.callButton.titleLabel?.font = HippoConfig.shared.theme.supportTheme.supportButtonTitleFont
        
        self.chatButton.setTitleColor(HippoConfig.shared.theme.supportTheme.supportButtonTitleColor, for: .normal)
        self.chatButton.titleLabel?.font = HippoConfig.shared.theme.supportTheme.supportButtonTitleFont
        
        self.submitButton.setTitleColor(HippoConfig.shared.theme.supportTheme.supportButtonTitleColor, for: .normal)
        self.submitButton.titleLabel?.font = HippoConfig.shared.theme.supportTheme.supportButtonTitleFont
        
        self.subHeadingLabel.font = HippoConfig.shared.theme.supportTheme.supportDescSubHeadingFont
        self.subHeadingLabel.textColor = HippoConfig.shared.theme.supportTheme.supportDescSubHeadingColor
        
        self.descLabel.font = HippoConfig.shared.theme.supportTheme.supportDescriptionFont
        self.descLabel.textColor = HippoConfig.shared.theme.supportTheme.supportDescriptionColor
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.title = " " + HippoConfig.shared.theme.leftBarButtonText
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.image = HippoConfig.shared.theme.leftBarButtonImage
            }
        }
        
        
    }
    
    func makeACall() {
        if let url = URL(string: "tel://\(listObject.content.callButton.number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
extension ListDescriptionViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        lastOffset = self.scrollView.contentOffset
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        updateHeightOf(textView: textView)
    }
    func updateHeightOf(textView: UITextView) {
        
        guard !textView.isHidden else {
            self.textViewContainerHeightConstraint.constant = 0
            return
        }
        var heightOfTextView = textView.contentSize.height - (textView.frame.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom)
        if heightOfTextView != 0 {
            heightOfTextView = textView.contentSize.height + textView.textContainerInset.top + textView.textContainerInset.bottom
        }
        
        if heightOfTextView < min_height_textview {
            heightOfTextView = min_height_textview
        } else if heightOfTextView > max_height_textview {
            heightOfTextView = max_height_textview
        }
        self.textViewContainerHeightConstraint.constant = heightOfTextView + 25
        self.view.layoutIfNeeded()
    }
}
extension ListDescriptionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
