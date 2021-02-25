//
//  PromotionsViewController.swift
//  HippoChat
//
//  Created by Clicklabs on 12/23/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PromotionCellDelegate : class {
    //func getActionData(data:PromotionCellDataModel, viewController : UIViewController)
    func setData(data:PromotionCellDataModel)
    var cellIdentifier : String { get  }
    var bundle : Bundle? { get  }
}

typealias PromtionCutomCell = PromotionCellDelegate & UITableViewCell

class PromotionsViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var promotionsTableView: UITableView!{
        didSet{
            promotionsTableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var navigationBackgroundView: UIView!
    @IBOutlet weak var loaderView: So_UIImageView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var viewError_Height: NSLayoutConstraint!
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet weak var navigationBar : NavigationBar!
    
    //    @IBOutlet weak var top_Constraint : NSLayoutConstraint!
    //MARK:- Variables
    
    var data: [PromotionCellDataModel] = []
    weak var customCell: PromtionCutomCell?
    var refreshControl = UIRefreshControl()
    // var count = 20
    var isMoreData = false
    var channelIdsArr = [Int]()
    var informationView: InformationView?
    
    var selectedRow = -1
    var states = [Bool]()
    var shouldUseCache : Bool = true
    var page = 1
    var limit = 20
    var shouldFetchData = true
    var previousPage = 0
    var showMoreIndex : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        FuguNetworkHandler.shared.fuguConnectionChangesStartNotifier()
        
        if shouldUseCache {
            self.data = fetchAllAnnouncementCache()
            for _ in data{
                self.states.append(true)
            }
            noNotificationsFound()
        }
        
        self.setUpViewWithNav()
        
        setupRefreshController()
        promotionsTableView.backgroundColor = HippoConfig.shared.theme.promotionBackgroundColor
        
        promotionsTableView.register(UINib(nibName: "PromotionTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PromotionTableViewCell")
        promotionsTableView.rowHeight = UITableView.automaticDimension
        promotionsTableView.estimatedRowHeight = 50
        if let c = customCell {
            promotionsTableView.register(UINib(nibName: c.cellIdentifier, bundle: c.bundle), forCellReuseIdentifier: c.cellIdentifier)
        }
        if !(HippoConfig.shared.isOpenedFromPush ?? false){
            self.callGetAnnouncementsApi()
            HippoNotification.removeAllAnnouncementNotification()
        }else{
            refreshData()
            HippoConfig.shared.isOpenedFromPush = false
        }
    }
    
    internal func setupRefreshController() {
        //        refreshControl.backgroundColor = .clear
        //        refreshControl.tintColor = .themeColor
        promotionsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
    }
    
    @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
        isMoreData = false
        self.page = 1
        if FuguNetworkHandler.shared.isNetworkConnected {
            self.getAnnouncements(endOffset:limit, startOffset: 0)
        }else{
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshData(){
        getDataOrUpdateAnnouncement(HippoNotification.promotionPushDic.map{$0.value.channelID}, isforReadMore: false)
        HippoNotification.promotionPushDic.removeAll()
    }
    
    func getDataOrUpdateAnnouncement(_ channelIdArr : [Int], isforReadMore : Bool, indexRow : Int? = nil){
        let params = ["app_secret_key" : HippoConfig.shared.appSecretKey, "channel_ids" : channelIdArr, "user_id" : currentUserId()] as [String : Any]
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.getAndUpdateAnnouncement.rawValue) { (response, error, _, statusCode) in
            if let response = response as? [String : Any], let data = response["data"] as? [[String : Any]]{
                for value in data{
                    if let announcement = PromotionCellDataModel(dict: value){
                        self.data.insert(announcement, at: 0)
                        self.states.insert(true, at: 0)
                    }
                }
                let channelIdArr = self.data.map{String($0.channelID)}
                if let channelArr = UserDefaults.standard.value(forKey: DefaultName.announcementUnreadCount.rawValue) as? [String]{
                    let result = channelArr.filter { !channelIdArr.contains($0) }
                    UserDefaults.standard.set(result, forKey: DefaultName.announcementUnreadCount.rawValue)
                    HippoConfig.shared.announcementUnreadCount?(result.count)
                }
                self.noNotificationsFound()
            }
        }
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.promotionsTableView.isHidden = false
        self.checkNetworkConnection()
        self.setUpTabBar()
        self.setUpViewWithNav()
        //top_Constraint.constant = (self.navigationController?.navigationBar.frame.size.height ?? 0.0) + 20
        self.view.layoutSubviews()
    }
    
    func callGetAnnouncementsApi(){
        // self.startLoaderAnimation()
        self.page = 1
        self.getAnnouncements(endOffset: limit, startOffset: 0)
    }
    
    override func viewWillLayoutSubviews() {
        self.setUpTabBar()
    }
    
    func setUpTabBar(){
        //        self.tabBarController?.hidesBottomBarWhenPushed = true
        //        self.tabBarController?.tabBar.isHidden = false
        //        self.tabBarController?.tabBar.layer.zPosition = 0
        //        self.tabBarController?.tabBar.items?[1].title = "Notifications"
        
        //hide
        //self.tabBarController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        //self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    func setUpViewWithNav() {
   
        navigationBar.title = HippoConfig.shared.theme.promotionsAnnouncementsHeaderText
        navigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        navigationBar.rightButton.setTitle(HippoStrings.clearAll, for: .normal)
        navigationBar.rightButton.titleLabel?.font = UIFont.regular(ofSize: 14)
        navigationBar.rightButton.setTitleColor(UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0), for: .normal)
        navigationBar.rightButton.addTarget(self, action: #selector(deleteAllAnnouncementsButtonClicked), for: .touchUpInside)
        navigationBar.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        navigationBar.view.layer.shadowRadius = 2.0
        navigationBar.view.layer.shadowOpacity = 0.5
        navigationBar.view.layer.masksToBounds = false
        navigationBar.view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                                        y: navigationBar.bounds.maxY - navigationBar.layer.shadowRadius,
                                                                        width: navigationBar.bounds.width,
                                                                        height: navigationBar.layer.shadowRadius)).cgPath
        
    }
    
    @objc func backButtonClicked() {
        
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
            if let tabBarController = navigationController.viewControllers[0] as? UITabBarController{
                tabBarController.selectedIndex = 0
            }
        }
        
        //        if config.shouldPopVc {
        //            self.navigationController?.popViewController(animated: true)
        //        } else {
        _ = self.navigationController?.dismiss(animated: true, completion: nil)
        //        }
        
        let json = PromotionCellDataModel.getJsonFromAnnouncementArr(self.data)
        self.savePromotionsInCache(json)
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
    
    @objc func deleteAllAnnouncementsButtonClicked() {
        guard self.navigationItem.rightBarButtonItem?.tintColor != .clear else {
            return
        }
        UserDefaults.standard.set([], forKey: DefaultName.announcementUnreadCount.rawValue)
        HippoConfig.shared.announcementUnreadCount?(0)
        
        self.clearAnnouncements(indexPath: IndexPath(row: 0, section: 0), isDeleteAllStatus: 1)
        FuguDefaults.removeObject(forKey: DefaultName.appointmentData.rawValue)
        
        //   }, failureButtonName: "NO", failureComplete: nil)
    }
    
    func getAnnouncements(endOffset:Int,startOffset:Int) {
        
        let params = ["end_offset":"\(endOffset)","start_offset":"\(startOffset)","en_user_id":HippoUserDetail.fuguEnUserID,"app_secret_key":HippoConfig.shared.appSecretKey]
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getAnnouncements.rawValue) { (response, error, _, statusCode) in
            
            // self.stopLoaderAnimation()
            
            if error == nil{
                self.refreshControl.endRefreshing()
                let r = response as? NSDictionary
                if let arr = r!["data"] as? NSArray{
                    if arr.count == 0{
                        self.shouldFetchData = false
                    }
                    if startOffset == 0 && self.data.count > 0{
                        self.data.removeAll()
                        self.states.removeAll()
                    }
                    
                    for item in arr{
                        let i = item as! [String:Any]
                        let dataNew = PromotionCellDataModel(dict:i)
                        self.data.append(dataNew!)
                        self.states.append(true)
                    }
                    
                    if startOffset == 0{
                        self.savePromotionsInCache(arr as? [[String : Any]] ?? [[String : Any]]())
                    }
                    
                    let channelIdArr = self.data.map{String($0.channelID)}
                    if let channelArr = UserDefaults.standard.value(forKey: DefaultName.announcementUnreadCount.rawValue) as? [String]{
                        let result = channelArr.filter { !channelIdArr.contains($0) }
                        UserDefaults.standard.set(result, forKey: DefaultName.announcementUnreadCount.rawValue)
                        HippoConfig.shared.announcementUnreadCount?(result.count)
                    }
                    
                    
                }
                self.noNotificationsFound()
                //self.promotionsTableView.reloadData()
            }
        }
    }
    
    func noNotificationsFound(){
        guard let _ = promotionsTableView else {
            return
        }
        if self.data.count <= 0{
           // self.navigationItem.rightBarButtonItem?.tintColor = .clear
            if informationView == nil {
                informationView = InformationView.loadView(self.promotionsTableView.bounds, delegate: self)
                informationView?.informationLabel.text = HippoStrings.noNotificationFound
            }

            self.informationView?.isHidden = false
            self.promotionsTableView.addSubview(informationView!)
        }else{
            for view in promotionsTableView?.subviews ?? [UIView](){
                if view is InformationView{
                    view.removeFromSuperview()
                }
            }
            self.informationView?.isHidden = true
           // self.navigationItem.rightBarButtonItem?.tintColor = HippoConfig.shared.theme.logoutButtonTintColor ?? HippoConfig.shared.theme.headerTextColor
        }
        
        DispatchQueue.main.async {
            self.promotionsTableView.reloadData()
        }
        
    }
    
    func clearAnnouncements(indexPath: IndexPath, isDeleteAllStatus: Int){
        
        var params = [String : Any]()
        if isDeleteAllStatus == 0{
            //self.channelIdsArr.append(data[indexPath.row].channelID)
            //self.channelIdsArr[0] = data[indexPath.row].channelID
            self.channelIdsArr.insert(data[indexPath.row].channelID, at: 0)
            
            params = ["app_secret_key":HippoConfig.shared.appSecretKey,"en_user_id":HippoUserDetail.fuguEnUserID ?? "","channel_ids":self.channelIdsArr,"delete_all_announcements":isDeleteAllStatus] as [String : Any]
        }else{
            params = ["app_secret_key":HippoConfig.shared.appSecretKey,"en_user_id":HippoUserDetail.fuguEnUserID ?? "","delete_all_announcements":isDeleteAllStatus] as [String : Any]
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.clearAnnouncements.rawValue) { (response, error, _, statusCode) in
            
            self.channelIdsArr.removeAll()
            
            if error == nil
            {
                //let r = response as? NSDictionary
                if isDeleteAllStatus == 0{
                    self.promotionsTableView.beginUpdates()
                    self.data.remove(at: indexPath.row)
                    self.states.remove(at: indexPath.row)
                    self.promotionsTableView.deleteRows(at: [indexPath], with: .fade)
                    self.promotionsTableView.endUpdates()
                }else{
                    self.data.removeAll()
                    self.states.removeAll()
                    //self.promotionsTableView.reloadData()
                    //DispatchQueue.main.async {
                    //    self.promotionsTableView.reloadData()
                    //}
                }
              
                self.noNotificationsFound()
                
            }
        }
    }
    
}

extension PromotionsViewController: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let c = customCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: c.cellIdentifier, for: indexPath) as? PromtionCutomCell else {
                return UITableView.defaultCell()
            }
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            //            cell.promotionTitle.text = "This is a new tittle"
            //            cell.descriptionLabel.text = "This is description of promotion in a new format"
            //   cell.set(data: data[indexPath.row])
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTableViewCell", for: indexPath) as? PromotionTableViewCell else {
                return UITableView.defaultCell()
            }
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.previewImage = {[weak self]() in
                DispatchQueue.main.async {
                    let showImageVC: ShowImageViewController = ShowImageViewController.getFor(imageUrlString: self?.data[indexPath.row].imageUrlString ?? "")
                    //showImageVC.shouldHidetopHeader = true
                    self?.modalPresentationStyle = .overCurrentContext
                    self?.present(showImageVC, animated: true, completion: nil)
                }
            }
            
            cell.set(data: data[indexPath.row])
            
            cell.showReadMoreLessButton.tag = indexPath.row
            cell.showReadMoreLessButton.addTarget(self, action: #selector(expandCellSize(_:)), for: .touchUpInside)
            //cell.descriptionLabel.numberOfLines = 2
            let values = data[indexPath.row]
            let croppedDescription = values.description?.count ?? 0 > 150 ? String(values.description?.prefix(150) ?? "") : values.description ?? ""
            cell.promotionTitle.attributedText = NSAttributedString(string:  values.title ?? "")
            cell.fullDescriptionLabel.attributedText = NSAttributedString(string:  values.description ?? "")
            cell.descriptionLabel.attributedText = NSAttributedString(string:  croppedDescription)
            cell.descriptionLabel.dataDetectorTypes = UIDataDetectorTypes.all
            cell.fullDescriptionLabel.dataDetectorTypes = UIDataDetectorTypes.all
            if (values.description?.count)! > 150{
            
                cell.showReadMoreLessButton.isHidden = false
                cell.showReadMoreLessButtonHeightConstraint.constant = 30
            }else{
                
                cell.showReadMoreLessButton.isHidden = true
                cell.showReadMoreLessButtonHeightConstraint.constant = 0
            }
            if indexPath.row < states.count, states[indexPath.row] == true{
                cell.descriptionLabel.isHidden = false
                cell.fullDescriptionLabel.isHidden = true
                cell.showReadMoreLessButton.setTitle(HippoStrings.readMore, for: .normal)
                cell.showReadMoreLessButton.titleLabel?.font = UIFont.regular(ofSize: 14.0)
                cell.showReadMoreLessButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
                
            }else if indexPath.row < states.count, states[indexPath.row] == false{
                cell.descriptionLabel.isHidden = true
                cell.fullDescriptionLabel.isHidden = false
                cell.showReadMoreLessButton.setTitle(HippoStrings.readLess, for: .normal)
                cell.showReadMoreLessButton.titleLabel?.font = UIFont.regular(ofSize: 14.0)
                cell.showReadMoreLessButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)

            }else{}
            
            return cell
        }
        
        
    }
    
    @objc func expandCellSize(_ sender:UIButton) {
        let row = sender.tag
        //let values = data[row]
        let indexpath = IndexPath(row: row, section: 0)
        
        guard let cell = self.promotionsTableView.cellForRow(at: indexpath) as? PromotionTableViewCell else { return }
        if states[row] == true{
            states[row] = false
            UIView.setAnimationsEnabled(false)
            self.promotionsTableView.beginUpdates()
            self.promotionsTableView.reloadRows(at: [indexpath], with: .none)
            self.promotionsTableView.layoutIfNeeded()
            self.promotionsTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
           // self.promotionsTableView.setContentOffset(currentOffset, animated: false)
            self.promotionsTableView.scrollToRow(at: indexpath, at: .top, animated: false)

        }else if states[row] == false{
            states[row] = true
            UIView.setAnimationsEnabled(false)
            self.promotionsTableView.beginUpdates()
            self.promotionsTableView.reloadRows(at: [indexpath], with: .none)

            self.promotionsTableView.layoutIfNeeded()
            self.promotionsTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
           // self.promotionsTableView.setContentOffset(currentOffset, animated: false)
            self.promotionsTableView.scrollToRow(at: indexpath, at: .middle, animated: false)
        }else{}
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let promotionData = data[indexPath.row] as? PromotionCellDataModel{
            if let deepLink = promotionData.deepLink as? String{
                if deepLink == "3x67AU1"{
                    HippoConfig.shared.getDeepLinkData(promotionData.customAttributeData ?? [String : Any]())
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return HippoStrings.clear
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            

                self.clearAnnouncements(indexPath: indexPath, isDeleteAllStatus: 0)
                
 //           }, failureButtonName: "NO", failureComplete: nil)
            
        }
    }
    
}

extension PromotionsViewController: InformationViewDelegate {
    
}

extension PromotionsViewController{
    
    //MARK:- Save Promotions data in cache
    
    func savePromotionsInCache(_ json: [[String: Any]]) {
        guard shouldUseCache else {
            return
        }
        FuguDefaults.set(value: json, forKey: DefaultName.appointmentData.rawValue)
        //FuguDefaults.set(value: self.conversationChatType, forKey: "conversationType")
    }
    
    func fetchAllAnnouncementCache() -> [PromotionCellDataModel] {
        guard let convCache = FuguDefaults.object(forKey: DefaultName.appointmentData.rawValue) as? [[String: Any]] else {
            return []
        }
        
        let arrayOfConversation = PromotionCellDataModel.getAnnouncementsArrayFrom(json: convCache)
        return arrayOfConversation
    }
    
}

extension PromotionsViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.reloadProducts(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.reloadProducts(scrollView)
        }
    }
    
    func reloadProducts(_ scrollView: UIScrollView) {
        if scrollView == promotionsTableView{
            if scrollView.frame.size.height + scrollView.contentOffset.y >= scrollView.contentSize.height, shouldFetchData{
                if page > previousPage{
                    self.previousPage = page
                    self.page += 1
                    let previousOffset = data.count
                    getAnnouncements(endOffset: limit, startOffset: previousOffset)
                }else{
                    return
                }
            }
        }
    }
}
extension PromotionsViewController{
    
    
    @objc func appMovedToBackground() {
        checkNetworkConnection()
    }
    
    @objc func appMovedToForground() {
        checkNetworkConnection()
    }
    
    
    func checkNetworkConnection() {
        errorLabel.backgroundColor = UIColor.red
        if FuguNetworkHandler.shared.isNetworkConnected {
            viewError_Height.constant = 0
            errorLabel.text = ""
        } else {
            viewError_Height.constant = 20
            errorContentView.backgroundColor = .red
            errorLabel.text = HippoStrings.noNetworkConnection
        }
    }
    
    
    // MARK: - HELPER
    func updateErrorLabelView(isHiding: Bool) {
        
        if isHiding {
            if self.viewError_Height.constant == 20 {
                fuguDelay(3, completion: {
                    // self.errorLabelTopConstraint.constant = -20
                    self.errorLabel.text = ""
                    self.viewError_Height.constant = 0
                    self.view.layoutIfNeeded()
                    self.errorLabel.backgroundColor = UIColor.red
                })
            }
            return
        }else{
            viewError_Height.constant = 20
            self.view.layoutIfNeeded()
        }
    }
}

