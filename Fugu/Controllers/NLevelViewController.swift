//
//  NLevelViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 29/03/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit
import NotificationCenter

class NLevelViewController: UIViewController {
    
    //MARK: Variables
    
    var listObject = [HippoSupportList]()
    let urlForFuguChat = "https://jungleworks.co/hippo/"
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
        let index = HippoSupportList.currentPathArray.index { (item) -> Bool in
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
        if HippoConnection.isNetworkConnected {
            handleErrorLabel(with: "", isForceShow: false)
        } else {
            handleErrorLabel(with: "No Internet Connection", isForceShow: true)
        }
    }
    
    func addObserver() {
        removeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetorkObserver), name: .HippoConnectionChanged, object: nil)
    }
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleNetorkObserver() {
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
        
        poweredByLabel.attributedText = attributedStringForLabelForTwoStrings("Powered by ", secondString: "Hippo", colorOfFirstString: HippoConfig.shared.powererdByColor, colorOfSecondString: HippoConfig.shared.HippoColor, fontOfFirstString: HippoConfig.shared.poweredByFont, fontOfSecondString: HippoConfig.shared.HippoStringFont, textAlighnment: .center, dateAlignment: .center)
        poweredByLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFuguChatWebLink(_:)))
        poweredByLabel.addGestureRecognizer(tap)
        updateBottomLabel()
    }
    @objc func openFuguChatWebLink(_ sender: UITapGestureRecognizer) {
        guard let fuguURL = URL(string: urlForFuguChat),
            UIApplication.shared.canOpenURL(fuguURL) else {
                return
        }
        UIApplication.shared.openURL(fuguURL)
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
            if success || HippoConfig.shared.userDetail?.fuguUserID != nil {
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
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: HippoFlowManager.bundle)
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
        return UITableViewAutomaticDimension
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
        
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: HippoFlowManager.bundle), forCellReuseIdentifier: "CategoryTableViewCell")
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