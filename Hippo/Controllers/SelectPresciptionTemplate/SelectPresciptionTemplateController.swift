//
//  SelectPresciptionTemplateController.swift
//  Hippo
//
//  Created by Arohi Sharma on 28/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SelectPresciptionTemplateController: UIViewController {

    //MARK:- Variables
    
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var table_SelectTemplate : UITableView!{
        didSet{
            table_SelectTemplate.register(UINib(nibName: "PresciptionTemplateCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PresciptionTemplateCell")
        }
    }
    @IBOutlet weak var view_NavigationBar : NavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
extension SelectPresciptionTemplateController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
}
