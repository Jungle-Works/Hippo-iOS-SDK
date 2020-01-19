//
//  PromotionsViewController.swift
//  HippoChat
//
//  Created by Clicklabs on 12/23/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PromotionCellDelegate : class
{
    //func getActionData(data:PromotionCellDataModel, viewController : UIViewController)
    func setData(data:PromotionCellDataModel)
    
    var cellIdentifier : String { get  }
    var bundle : Bundle? { get  }
    
}

typealias PromtionCutomCell = PromotionCellDelegate & UITableViewCell

class PromotionsViewController: UIViewController {

    @IBOutlet weak var promotionsTableView: UITableView!
    
    var data: [PromotionCellDataModel] = []
    weak var customCell: PromtionCutomCell?
    var refreshControl = UIRefreshControl()
    var count = 20
    var isMoreData = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ANNOUNCEMENTS"
       setupRefreshController()
        promotionsTableView.backgroundColor = HippoConfig.shared.theme.multiselectUnselectedButtonColor
        
        
    promotionsTableView.register(UINib(nibName: "PromotionTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PromotionTableViewCell")
        promotionsTableView.rowHeight = UITableView.automaticDimension
        promotionsTableView.estimatedRowHeight = 50
        if let c = customCell {
          promotionsTableView.register(UINib(nibName: c.cellIdentifier, bundle: c.bundle), forCellReuseIdentifier: c.cellIdentifier)
        }
        // Do any additional setup after loading the view.
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
        self.getAnnouncements(endOffset: 19, startOffset: 0)
    }
    
    func getAnnouncements(endOffset:Int,startOffset:Int) {
        
        let params = ["end_offset":"\(endOffset)","start_offset":"\(startOffset)","en_user_id":HippoUserDetail.fuguEnUserID,"app_secret_key":HippoConfig.shared.appSecretKey]
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getAnnouncements.rawValue) { (response, error, _, statusCode) in
            
            if error == nil
            {
                self.refreshControl.endRefreshing()
                let r = response as? NSDictionary
                if let arr = r!["data"] as? NSArray
                {
                    if startOffset == 0 || arr.count >= 19
                    {
                        for item in arr
                        {
                            let i = item as! [String:Any]
                            let dataNew = PromotionCellDataModel(dict:i)
                            self.data.append(dataNew!)
                        }
                    }
                    else
                    {
                        self.isMoreData = true
                    }
                    
                }
                self.promotionsTableView.reloadData()
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
        
        return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        let h = data[indexPath.row]
//        print(h.cellHeight)
//        return h.cellHeight

       // return 266
        
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //HippoConfig.shared.delegate?.promotionMessageRecievedWith(response:[:], viewController: self)
        let d = data[indexPath.row]
        if d.deepLink!.isEmpty
        {
            
        }
        else
        {
            HippoConfig.shared.openChatScreen(withLabelId: Int(data[indexPath.row].channelID) ?? 0)
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
   
}
