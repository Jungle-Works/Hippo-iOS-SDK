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
    
    var data: [PromotionCellDataModel]?
    weak var customCell: PromtionCutomCell?
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PROMOTIONS"
       
        
    promotionsTableView.register(UINib(nibName: "PromotionTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PromotionTableViewCell")
        if let c = customCell {
          promotionsTableView.register(UINib(nibName: c.cellIdentifier, bundle: c.bundle), forCellReuseIdentifier: c.cellIdentifier)
        }
        // Do any additional setup after loading the view.
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}



extension PromotionsViewController: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        //     cell.set(data: data![indexPath.row])
            
            return cell
        } else {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTableViewCell", for: indexPath) as? PromotionTableViewCell else {
            return UITableView.defaultCell()
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.promotionTitle.text = "This is a new tittle"
        cell.descriptionLabel.text = "This is description of promotion in a new format"
       // cell.set(data: data![indexPath.row])
        
        return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
      //  let h = data![indexPath.row]
       // return h.cellHeight + 160
        
        return 266
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //HippoConfig.shared.delegate?.promotionMessageRecievedWith(response:[:], viewController: self)
        
    }
   
}
