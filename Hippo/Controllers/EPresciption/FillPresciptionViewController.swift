//
//  FillPresciptionViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 30/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class FillPresciptionViewController: UIViewController {

    //MARK:- Variables
    var template : Template?
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var view_NavigationBar : NavigationBar!
    @IBOutlet weak var tableView_Template : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView_Template.register(UINib(nibName: "BroadCastTextFieldCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "BroadCastTextFieldCell")
        view_NavigationBar.title = "Fill Presciption Template"
        view_NavigationBar.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
    }
    
}

extension FillPresciptionViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return template?.body_keys?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTextFieldCell", for: indexPath) as? BroadCastTextFieldCell else { return BroadCastTextFieldCell() }
        cell.titleLabel.text = template?.body_keys?[indexPath.row].key
        return cell
    }
}

extension FillPresciptionViewController{
    //MARK:- IBAction
    
    @IBAction func action_BackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension FillPresciptionViewController{
    //MARK:- Functions
    
    class func getNewInstance(template : Template) -> FillPresciptionViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "FillPresciptionViewController") as! FillPresciptionViewController
        vc.template = template
        return vc
    }
}
 
