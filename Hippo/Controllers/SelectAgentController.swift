//
//  SelectAgentController.swift
//  Hippo
//
//  Created by Arohi Sharma on 13/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

class SelectAgentController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet var tableView : UITableView!{
        didSet{
            tableView.register(UINib(nibName: "SearchAgentTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "SearchAgentTableViewCell")
        }
    }
    @IBOutlet var view_NavigationBar : NavigationBarChat!
    
    //MARK:- Variables
    var selectAgentVM = SelectAgentViewModel()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_NavigationBar.setTitle(title: "")
        view_NavigationBar.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
        view_NavigationBar.call_button.isHidden = true
        view_NavigationBar.video_button.isHidden = true
        
        selectAgentVM.responseRecieved = {[weak self]() in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        selectAgentVM.getList = true
    }
    
    //MARK:- Function
    class func getNewInstance() -> SelectAgentController {
         let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
         let vc = storyboard.instantiateViewController(withIdentifier: "SelectAgentController") as! SelectAgentController
         return vc
     }
    
    //MARK:- IBAction
    
    @IBAction func action_BackBtn(){
        self.navigationController?.popViewController(animated: false)
    }
}
extension SelectAgentController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectAgentVM.agentCard?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchAgentTableViewCell", for: indexPath) as? SearchAgentTableViewCell
        return cell ?? SearchAgentTableViewCell()
    }
}
