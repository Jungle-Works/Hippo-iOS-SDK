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
        return cell
    }
    
}
