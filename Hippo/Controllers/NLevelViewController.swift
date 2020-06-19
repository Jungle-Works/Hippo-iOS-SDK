//
//  NLevelViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import NotificationCenter

class NLevelViewController: UIViewController {
    
    //MARK: Variables
    
    var listObject = [HippoSupportList]()
    let urlForHippoChat = "https://jungleworks.co/hippo/"
    var isFirstLevel = false
    
    
    @IBOutlet weak var errorContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorContainerView: UIView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var poweredByHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var poweredByLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUI()
        putUserDetail()
        addObserver()
        self.navigationController?.setTheme()
    }
    override func viewWillAppear(_ animated: Bool) {
        checkNetworkConnection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleInteractivePopGesture()
        isFirstLevel = false
        
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
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        guard let controllers = self.navigationController?.viewControllers, controllers.count > 1 else {
            HippoSupportList.currentPathArray.removeAll()
            self.dismiss(animated: true, completion: nil)
            return
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    func removeObjFromPath(with id: Int) {
        let index = HippoSupportList.currentPathArray.firstIndex { (item) -> Bool in
            return item.id == id
        }
        guard index != nil else {
            return
        }
        HippoSupportList.currentPathArray.remove(at: index!)
    }
    func handleInteractivePopGesture() {
        guard let controllers = self.navigationController?.viewControllers, controllers.count > 1 else {
            isFirstLevel = true
            return
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func handleErrorLabel(with errorMessage: String, isForceShow: Bool) {
        DispatchQueue.main.async {
            if isForceShow {
                self.errorContainerTopConstraint.constant = 0
                self.errorContainerView.backgroundColor = UIColor.red
                self.errorLabel.text = errorMessage
            } else {
                self.errorContainerTopConstraint.constant = -20
                self.errorContainerView.backgroundColor = UIColor.clear
                self.errorLabel.text = ""
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.errorContainerView.layoutIfNeeded()
            })
        }
    }
    
    func checkNetworkConnection() {
        if FuguNetworkHandler.shared.isNetworkConnected {
            handleErrorLabel(with: "", isForceShow: false)
        } else {
            handleErrorLabel(with: HippoStrings.noNetworkConnection, isForceShow: true)
        }
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
    func setUI() {
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.title = " " + HippoConfig.shared.theme.leftBarButtonText
            
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.image = HippoConfig.shared.theme.leftBarButtonImage
            }
        }
        
        poweredByLabel.attributedText = attributedStringForLabelForTwoStrings("Runs on ", secondString: "Hippo", colorOfFirstString: HippoConfig.shared.powererdByColor, colorOfSecondString: HippoConfig.shared.FuguColor, fontOfFirstString: HippoConfig.shared.poweredByFont, fontOfSecondString: HippoConfig.shared.FuguStringFont, textAlighnment: .center, dateAlignment: .center)
        poweredByLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openHippoChatWebLink(_:)))
        poweredByLabel.addGestureRecognizer(tap)
        updateBottomLabel()
    }
    @objc func openHippoChatWebLink(_ sender: UITapGestureRecognizer) {
        guard let hippoURL = URL(string: urlForHippoChat),
            UIApplication.shared.canOpenURL(hippoURL) else {
                return
        }
        UIApplication.shared.openURL(hippoURL)
    }
    func getData() {
        guard listObject.count == 0 else {
            return
        }
        HippoSupportList.getListForBusiness { (success, data) in
            guard success, data != nil else {
                return
            }
            self.title = HippoSupportList.FAQName
            self.listObject = data!
            self.tableView.reloadData()
        }
    }
    func putUserDetail() {
        
        guard listObject.count == 0, isFirstLevel else {
            return
        }
        setInitialData()
        guard HippoSupportList.FAQData.count <= 0 || userDetailData.count <= 0 else {
            return
        }
        HippoUserDetail.getUserDetailsAndConversation(completion: { [weak self] (success, error) in
            if success || HippoUserDetail.fuguUserID != nil {
                self?.setInitialData()
            }
        })
    }
    func setInitialData() {
        DispatchQueue.main.async {
            var cachedArray = [HippoSupportList]()
            cachedArray = HippoSupportList.getDataFromJson(dict: HippoSupportList.FAQData)
            
            self.title = HippoSupportList.FAQName
            self.listObject = cachedArray
            self.tableView.reloadData()
        }
        
    }
    
    func updateBottomLabel() {
        if let isWhiteLabel = userDetailData["is_whitelabel"] as? Bool, isWhiteLabel == true {
            poweredByHeightConstraint.constant = 0
        } else if !isFirstLevel {
            poweredByHeightConstraint.constant = 0
        } else {
            poweredByHeightConstraint.constant = 20
        }
        view.layoutIfNeeded()
    }
    
    class func get(with object: [HippoSupportList], title: String) -> NLevelViewController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NLevelViewController") as? NLevelViewController else {
            return nil
        }
        vc.listObject = object
        vc.title = title
        return vc
    }
    
}
extension NLevelViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension NLevelViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listObject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell") as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        cell.setData(object: self.listObject[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = self.listObject[indexPath.row].items
        let obj = self.listObject[indexPath.row]
        
        switch obj.action {
        case .LIST:
            HippoSupportList.currentPathArray.append(ListIdentifiers(id: obj.id, title: obj.title, parentId: obj.parent_id))
            pushToNextLevel(with: items, title: obj.title)
        case .DESCRIPTION:
            HippoSupportList.currentPathArray.append(ListIdentifiers(id: obj.id, title: obj.title, parentId: obj.parent_id))
            pushToDetailScreen(with: obj, title: obj.title)
        case .CHAT_SUPPORT:
            presentChatScreen(with: "", supportId: obj.id)
        case .SHOW_CONVERSATION:
            HippoConfig.shared.presentChatsViewController()
        case .CATEGORY:
            break
        }
        
    }
    func presentChatScreen(with message: String, supportId: Int) {
        guard let id = HippoConfig.shared.userDetail?.userUniqueKey else {
            return
        }
        
        var transctionId = HippoConfig.shared.ticketDetails.transactionId ?? ""
        
        if transctionId.isEmpty {
            transctionId = id + "_" + "\(supportId)"
        } else {
            transctionId += "_\(supportId)"
        }
        let channelName = HippoSupportList.FAQName + " #" + transctionId
        let tag = [HippoSupportList.FAQName]
        
        HippoConfig.shared.openChatScreen(withTransactionId: transctionId, tags: tag, channelName: channelName, message: message, userUniqueKey: id, isInAppMessage: true) { (success, error) in
            
        }
    }
    func setupTableView() {
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "CategoryTableViewCell")
    }
    func pushToDetailScreen(with obj: HippoSupportList, title: String) {
        let vc = ListDescriptionViewController.get(with: obj)
        vc?.title = title
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func pushToNextLevel(with obj: [HippoSupportList], title: String) {
        guard obj.count > 0 else {
            return
        }
        let vc = NLevelViewController.get(with: obj, title: title)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
