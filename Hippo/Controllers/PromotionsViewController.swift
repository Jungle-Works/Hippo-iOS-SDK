//
//  PromotionsViewController.swift
//  HippoChat
//
//  Created by Clicklabs on 12/23/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class PromotionsViewController: UIViewController {

    @IBOutlet weak var promotionsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PROMOTIONS"
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
        
        
        return UITableViewCell()
    }
    
    
}
