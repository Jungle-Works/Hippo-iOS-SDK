//
//  PaymentPlansDataSource.swift
//  HippoAgent
//
//  Created by Vishal on 05/12/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class PaymentPlansDataSource: NSObject {
    var plans: [PaymentPlan] = []
    var deletePlanClicked : ((PaymentPlan)->())?
    var editPlanClicked : ((PaymentPlan)->())?
    var sendPlanClicked : ((PaymentPlan)->())?
    var viewPlanClicked : ((PaymentPlan)->())?
}

extension PaymentPlansDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentPlanHomeCell", for: indexPath) as? PaymentPlanHomeCell else {
            return UITableView.defaultCell()
        }
        let plan = plans[indexPath.row]
        cell.set(plan: plan)
        cell.deletePlanClicked = {[weak self]() in
            DispatchQueue.main.async {
                if (self?.plans.count ?? 0) > indexPath.row, let plan = self?.plans[indexPath.row]{
                    self?.deletePlanClicked?(plan)
                }
            }
        }
        
        cell.editPlanClicked = {[weak self]() in
            DispatchQueue.main.async {
                if (self?.plans.count ?? 0) > indexPath.row, let plan = self?.plans[indexPath.row]{
                    if self?.plans[indexPath.row].type == .agentPlan{
                       self?.editPlanClicked?(plan)
                    }else{
                        self?.viewPlanClicked?(plan)
                    }
                }
            }
        }
        
        cell.sendPlanClicked = {[weak self]() in
            DispatchQueue.main.async {
                if (self?.plans.count ?? 0) > indexPath.row, let plan = self?.plans[indexPath.row]{
                    self?.sendPlanClicked?(plan)
                }
            }
        }
        
        return cell
    }
    
}
