//
//  BroadCastViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

enum BroadCastScreenRow: Int, CaseCountable {
    case header = 0
    case selectTeam
    case selectAgent
    case showAgent
    case broadcastTitle
    case broadcastMessage
    case buttonCell
}

class BroadCastViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorConatinerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK: Variables
    var broadcaster = HippoBroadcaster()
    var titleString = ""
    var messageString = ""
    var isValidationFailed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setupTableView()
        checkForInitalization()
        NotificationCenter.default.addObserver(self, selector: #selector(loginDataUpdated), name: .agentLoginDataUpated, object: nil)
        
        #if swift(>=4.2)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self)
        if self.navigationController == nil {
            HippoConfig.shared.notifiyDeinit()
            dismiss(animated: true, completion: nil)
        } else if self.navigationController!.viewControllers.count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            HippoConfig.shared.notifiyDeinit()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    class func get() -> BroadCastViewController? {
        let storyboard = UIStoryboard(name: "HippoBroadCast", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "BroadCastViewController") as? BroadCastViewController
        return vc
    }
    class func getNavigation() -> UINavigationController? {
        
        let storyboard = UIStoryboard(name: "HippoBroadCast", bundle: FuguFlowManager.bundle)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "BroadCastNavigation") as? UINavigationController else {
            return nil
        }
        return navigationController
    }
}

extension BroadCastViewController {
    @objc func keyboardWillShow(sender: NSNotification) {
        #if swift(>=4.2)
        let key = UIResponder.keyboardFrameEndUserInfoKey
        #else
        let key = UIKeyboardFrameEndUserInfoKey
        #endif
        if let userInfo = sender.userInfo {
            if let keyboardSize = (userInfo[key] as? NSValue)?.cgRectValue {
                tableView.contentInset.bottom = keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        tableView.contentInset.bottom = 0
    }
    
    @objc func loginDataUpdated() {
        checkForInitalization()
    }
    
    fileprivate func checkForInitalization() {
        guard let token = HippoConfig.shared.agentDetail?.fuguToken, !token.isEmpty  else {
            startLoaderAnimation()
            return
        }
        getData()
    }
    
    fileprivate func getData() {
        startLoaderAnimation()
        broadcaster.getBroadcastTags {[weak self] (success, message) in
            self?.stopLoaderAnimation()
            guard success, self != nil else {
                if let errorMessage = message {
                    self?.setErrorView(hide: success, message: errorMessage)
                }
                return
            }
            self?.setErrorView(hide: true, message: "")
        }
    }
    
    fileprivate func setUpView() {
        self.navigationController?.setTheme()
        
        self.navigationItem.title = HippoConfig.shared.theme.broadcastHeader
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
            if HippoConfig.shared.theme.leftBarButtonFont != nil {
                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            }
            backButton.setTitleColor(HippoConfig.shared.theme.leftBarButtonTextColor, for: .normal)
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
                backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
    }
    
    func startLoaderAnimation() {
        setErrorView(hide: true, message: "")
        self.tableView.isHidden = true
        loadingImage.startRotationAnimation()
    }
    
    func stopLoaderAnimation() {
        self.tableView.isHidden = false
        loadingImage.stopRotationAnimation()
    }
    
    func setupTableView() {
        let bundle = FuguFlowManager.bundle
        tableView.register(UINib(nibName: "BroadCastTextViewCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTextViewCell")
        tableView.register(UINib(nibName: "BroadCastTextFieldCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTextFieldCell")
        tableView.register(UINib(nibName: "BoardCastSelectionCell", bundle: bundle), forCellReuseIdentifier: "BoardCastSelectionCell")
        tableView.register(UINib(nibName: "BroadCastTitleCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTitleCell")
        tableView.register(UINib(nibName: "BroadcastButtonCell", bundle: bundle), forCellReuseIdentifier: "BroadcastButtonCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func pushToSelection(type: BroadCastScreenRow) {
        let newBroadcastObject = broadcaster.copy()
        guard let vc = BroadcastSelectionViewController.get(manager: newBroadcastObject, type: type) else {
            return
        }
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushListContoller(store: BroadcastStore) {
        guard let vc = BroadcastListViewController.get(store: store) else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension BroadCastViewController: BroadcastListViewDelegate {
    func broadcasterUpdated(broadcaster: HippoBroadcaster) {
        self.broadcaster = broadcaster
        self.tableView.reloadData()
    }
}
extension BroadCastViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let index = BroadCastScreenRow(rawValue: indexPath.row), broadcaster.teams.count > 0 else {
            return
        }
        switch index {
        case .selectAgent:
            guard broadcaster.selectedTeam != nil, broadcaster.selectedTeam?.tagId != -100 else {
                return
            }
            pushToSelection(type: index)
        case .selectTeam:
            pushToSelection(type: index)
        case .showAgent:
            guard broadcaster.getSelectedAgentCount() > 0 else {
                return
            }
            pushToSelection(type: index)
        default:
            return
        }
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}

extension BroadCastViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BroadCastScreenRow.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let index = BroadCastScreenRow(rawValue: indexPath.row) else {
            return defaultCell()
        }
        switch index {
        case .header:
            return cellForHeader(indexPath: indexPath)
        case .selectTeam:
            return cellForSelection(indexPath: indexPath, type: index)
        case .selectAgent:
            return cellForSelection(indexPath: indexPath, type: index)
        case .showAgent:
            return cellForSelection(indexPath: indexPath, type: index)
        case .broadcastTitle:
            return cellForBroadcastTitle(indexPath: indexPath)
        case .broadcastMessage:
            return cellForBroadcastMessage(indexPath: indexPath)
        case .buttonCell:
            return cellForButtons(indexPath: indexPath)
        }
    }
    
    func defaultCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle  = .none
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//Return for tableViewCell
extension BroadCastViewController {
    
    func setErrorView(hide: Bool, message: String) {
        UIView.animate(withDuration: 0.2, animations: {
            self.errorConatinerView.alpha = hide ? 0 : 1
            self.errorLabel.alpha = hide ? 0 : 1
            self.errorLabel.text = hide ? "" : message
        }) { (_) in
            self.errorConatinerView.isHidden = hide
            self.errorLabel.isHidden = hide
        }
        
    }
    
    func cellForHeader(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTitleCell", for: indexPath) as? BroadCastTitleCell else {
            return defaultCell()
        }
        return cell
    }
    func cellForButtons(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastButtonCell", for: indexPath) as? BroadcastButtonCell else {
            return defaultCell()
        }
        cell.delegate = self
        //        cell.sendButton.isEnabled = validateData() == nil
        return cell
    }
    func cellForBroadcastTitle(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTextFieldCell", for: indexPath) as? BroadCastTextFieldCell else {
            return defaultCell()
        }
        //        let isErrorLabelHide = !isValidationFailed
        //        cell.setErrorLabelView(isHidden: isErrorLabelHide)
        cell.delegate = self
        return cell
    }
    func cellForSelection(indexPath: IndexPath, type: BroadCastScreenRow) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardCastSelectionCell", for: indexPath) as? BoardCastSelectionCell else {
            return defaultCell()
        }
        cell.setData(manager: broadcaster, type: type)
        return cell
    }
    
    func cellForBroadcastMessage(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTextViewCell", for: indexPath) as? BroadCastTextViewCell else {
            return defaultCell()
        }
        cell.delegate = self
        //        let isErrorLabelHide = !isValidationFailed
        //        cell.setErrorLabelView(isHidden: isErrorLabelHide)
        return cell
    }
    
    func validateData() -> String? {
        guard !titleString.isEmpty else {
            return "Please enter Title for broadcast."
        }
        guard !messageString.isEmpty else {
            return "Please enter Message for broadcast."
        }
        guard broadcaster.getSelectedAgentCount() > 0 else {
            return "Please select atleast one agent."
        }
        return nil
    }
}


extension BroadCastViewController: BroadCastTextViewCellDelegate, BroadCastTextFieldCellDelegate, BroadcastButtonCellDelegate {
    func previousMessageButtonClicked() {
        startLoaderAnimation()
        
    
        HippoBroadcaster.getPreviousBroadcastMessage {[weak self] (success, store) in
            self?.stopLoaderAnimation()
            guard self != nil, let parsedStore = store , success else {
                return
            }
            
            let channels = parsedStore.broadcasts
            if channels.isEmpty {
                self?.showAlert(title: "", message: HippoConfig.shared.strings.noBroadcastAvailable, buttonTitle: HippoStrings.ok, completion: nil)
                return
            }
            self?.pushListContoller(store: parsedStore)
        }
    }
    
    func sendButtonClicked() {
        if let errorMessage = validateData() {
            isValidationFailed = true
            showAlert(title: "", message: errorMessage, buttonTitle: HippoStrings.ok, completion: nil)
            tableView.reloadData()
            return
        }
        self.view.endEditing(true)
        guard FuguNetworkHandler.shared.isNetworkConnected else {
            showAlert(title: "", message: HippoStrings.noNetworkConnection, buttonTitle: HippoStrings.ok, completion: nil)
            return
        }
        
        let param: [String: Any] = ["user_first_message": messageString,
                                    "broadcast_title": titleString]
        startLoaderAnimation()
        broadcaster.sendBroadcastMessage(dict: param) {[weak self] (success, message) in
            self?.stopLoaderAnimation()
            guard success else {
                self?.showAlert(title: "", message: message, buttonTitle: HippoStrings.ok, completion: nil)
                return
            }
            self?.showAlert(title: "", message: message, buttonTitle: HippoStrings.ok, completion: {[weak self] (_) in
                self?.backButtonAction(UIButton())
            })
        }
    }
    
    func textViewTextChanged(newText: String) {
        messageString = newText
    }
    
    func textFieldTextChanged(newText: String) {
        
        titleString = newText
    }
    
}
