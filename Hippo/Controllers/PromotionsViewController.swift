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

    @IBOutlet weak var promotionsTableView: UITableView!
    @IBOutlet weak var loaderView: So_UIImageView!
    
    var data: [PromotionCellDataModel] = []
    weak var customCell: PromtionCutomCell?
    var refreshControl = UIRefreshControl()
    var count = 20
    var isMoreData = false
    var channelIdsArr = [Int]()
    var informationView: InformationView?

    var selectedRow = -1
    var states = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
        
        self.deleteAllAnnouncementsButton()
        
        setupRefreshController()
        promotionsTableView.backgroundColor = HippoConfig.shared.theme.multiselectUnselectedButtonColor
        
        promotionsTableView.register(UINib(nibName: "PromotionTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PromotionTableViewCell")
        promotionsTableView.rowHeight = UITableView.automaticDimension
        promotionsTableView.estimatedRowHeight = 50
        if let c = customCell {
          promotionsTableView.register(UINib(nibName: c.cellIdentifier, bundle: c.bundle), forCellReuseIdentifier: c.cellIdentifier)
        }
    }
    
    internal func setupRefreshController() {
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .themeColor
        promotionsTableView.backgroundView = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
    }
    @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
        isMoreData = false
        self.getAnnouncements(endOffset:19, startOffset: 0)
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.promotionsTableView.isHidden = false
        
        self.startLoaderAnimation()
        self.getAnnouncements(endOffset: 19, startOffset: 0)
        
        self.setUpTabBar()
        
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
    
    func deleteAllAnnouncementsButton() {
        let theme = HippoConfig.shared.theme
        let deleteAllAnnouncementsButton = UIBarButtonItem(image: UIImage(named: "ic_delete"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(deleteAllAnnouncementsButtonClicked))
        deleteAllAnnouncementsButton.tintColor = theme.logoutButtonTintColor ?? theme.headerTextColor
        
//        //let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
//        let btnleft : UIButton = UIButton(type: .custom)
//        btnleft.frame = CGRect(x:0, y:0, width:35, height:35)
//        btnleft.setTitleColor(UIColor.white, for: .normal)
//        btnleft.contentMode = .left
//        btnleft.setImage(UIImage(named :"iconBackTitleBar"), for: .normal)
//        btnleft.addTarget(self, action: #selector(backButtonClicked), for: .touchDown)
//        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)
//        backBarButon.tintColor = theme.logoutButtonTintColor ?? theme.headerTextColor
//        backBarButon.setBackgroundColor(color: #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1), forState: UIControl.State.highlighted)
//        self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        let btnleft = UIBarButtonItem(image: UIImage(named: "iconBackTitleBar"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(backButtonClicked))
        btnleft.tintColor = theme.logoutButtonTintColor ?? theme.headerTextColor
        self.navigationItem.leftBarButtonItem = btnleft
        self.navigationItem.leftBarButtonItems = [btnleft]
        
        self.navigationItem.rightBarButtonItem = deleteAllAnnouncementsButton
        self.navigationItem.rightBarButtonItems = [deleteAllAnnouncementsButton]
        
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
        showOptionAlert(title: "", message: "Are you sure, you want to clear all Notifications?", successButtonName: "YES", successComplete: { (_) in
            
            self.clearAnnouncements(indexPath: IndexPath(row: 0, section: 0), isDeleteAllStatus: 1)
            
        }, failureButtonName: "NO", failureComplete: nil)
    }
    
    func getAnnouncements(endOffset:Int,startOffset:Int) {
        
        let params = ["end_offset":"\(endOffset)","start_offset":"\(startOffset)","en_user_id":HippoUserDetail.fuguEnUserID,"app_secret_key":HippoConfig.shared.appSecretKey]
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getAnnouncements.rawValue) { (response, error, _, statusCode) in
            
            self.stopLoaderAnimation()
            
            if error == nil{
                self.refreshControl.endRefreshing()
                let r = response as? NSDictionary
                if let arr = r!["data"] as? NSArray{
                    if startOffset == 0 || arr.count >= 19{
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
                    }else{
                        self.isMoreData = true
                    }
                }
                self.noNotificationsFound()
                //self.promotionsTableView.reloadData()
            }
        }
    }
    
    func noNotificationsFound(){
        if self.data.count <= 0{
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            if informationView == nil {
                informationView = InformationView.loadView(self.view.bounds, delegate: self)
                informationView?.informationLabel.text = "No Notifications found"
            }
            self.promotionsTableView.isHidden = true
            self.informationView?.isHidden = false
            self.view.addSubview(informationView!)
        }else{
            self.promotionsTableView.isHidden = false
            self.informationView?.isHidden = true
            self.navigationItem.rightBarButtonItem?.tintColor = HippoConfig.shared.theme.logoutButtonTintColor ?? HippoConfig.shared.theme.headerTextColor
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
      
        cell.set(data: data[indexPath.row])
            
        cell.showReadMoreLessButton.tag = indexPath.row
        cell.showReadMoreLessButton.addTarget(self, action: #selector(expandCellSize(_:)), for: .touchUpInside)
        //cell.descriptionLabel.numberOfLines = 2
        let values = data[indexPath.row]
        cell.promotionTitle.text = values.title ?? ""
            
        cell.fullDescriptionLabel.text = values.description

            cell.descriptionLabel.text = values.description
            if (values.description?.count)! > 150{
                cell.showReadMoreLessButton.isHidden = false
                cell.showReadMoreLessButtonHeightConstraint.constant = 30
            }else{
                cell.showReadMoreLessButton.isHidden = true
                cell.showReadMoreLessButtonHeightConstraint.constant = 0
                
            }
            if states[indexPath.row] == true{
                cell.descriptionLabel.isHidden = false
                cell.fullDescriptionLabel.isHidden = true
                //cell.showReadMoreLessButton.setTitle("Read More", for: .normal)
                let attrs = NSAttributedString(string: "Read more",
                                               attributes:
                    [NSAttributedString.Key.foregroundColor: UIColor(red:109.0/255.0, green:212.0/255.0, blue:0.0/255.0, alpha:1.0),
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0),
                     NSAttributedString.Key.underlineColor: UIColor(red:109.0/255.0, green:212.0/255.0, blue:0.0, alpha:1.0),
                     NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                cell.showReadMoreLessButton.setAttributedTitle(attrs, for: .normal)
            }else if states[indexPath.row] == false{
                cell.descriptionLabel.isHidden = true
                cell.fullDescriptionLabel.isHidden = false
                //cell.showReadMoreLessButton.setTitle("Read Less", for: .normal)
                let attrs = NSAttributedString(string: "Read less",
                                               attributes:
                    [NSAttributedString.Key.foregroundColor: UIColor(red:109.0/255.0, green:212.0/255.0, blue:0.0, alpha:1.0),
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0),
                     NSAttributedString.Key.underlineColor: UIColor(red:109.0/255.0, green:212.0/255.0, blue:0.0, alpha:1.0),
                     NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                cell.showReadMoreLessButton.setAttributedTitle(attrs, for: .normal)
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
            self.promotionsTableView.reloadRows(at: [indexpath], with: .none)
            self.promotionsTableView.scrollToRow(at: indexpath, at: .top, animated: true)
        }else if states[row] == false{
            states[row] = true
            self.promotionsTableView.reloadRows(at: [indexpath], with: .none)
            self.promotionsTableView.scrollToRow(at: indexpath, at: .top, animated: true)
        }else{}
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //HippoConfig.shared.delegate?.promotionMessageRecievedWith(response:[:], viewController: self)
        let d = data[indexPath.row]
        if d.deepLink.isEmpty
        {
            
        }
        else
        {
            if d.skipBot.isEmpty
            {
                HippoConfig.shared.isSkipBot = false
            }
            else
            {
                HippoConfig.shared.isSkipBot = true
            }
            //HippoConfig.shared.openChatScreen(withLabelId: Int(data[indexPath.row].channelID) ?? 0)
            
            let labelID = d.channelID
            let conversationViewController = ConversationsViewController.getWith(labelId:"\(labelID)")
            self.navigationController?.pushViewController(conversationViewController, animated: true)
            
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.data.count {
            print("do something")
            if !isMoreData
            {
                let previousOffset = count
                count = 19 + count
                getAnnouncements(endOffset: count, startOffset: previousOffset)
            }
        }
    }
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Clear"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
           
            showOptionAlert(title: "", message: "Are you sure, you want to clear Notification?", successButtonName: "YES", successComplete: { (_) in
                
                self.clearAnnouncements(indexPath: indexPath, isDeleteAllStatus: 0)
                
            }, failureButtonName: "NO", failureComplete: nil)
        
        }
    }
    
}

extension PromotionsViewController: InformationViewDelegate {
    
}