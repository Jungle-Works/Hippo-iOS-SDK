//
//  SelectAgentController.swift
//  Hippo
//
//  Created by Arohi Sharma on 13/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

final class SelectAgentController: UIViewController, InformationViewDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet var tableView : UITableView!{
        didSet{
            tableView.register(UINib(nibName: "SelectAgentCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "SelectAgentCell")
        }
    }
    @IBOutlet var view_NavigationBar : NavigationBarChat!
    
    //MARK:- Variables
    var selectAgentVM = SelectAgentViewModel()
    var cardSelected : ((MessageCard)->())?
    private var informationView: InformationView?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func reloadData(){
        selectAgentVM.agentCard?.removeAll()
        tableView.reloadData()
        selectAgentVM.responseRecieved = {[weak self]() in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.noFieldsFound(errorMessage: HippoStrings.noDataFound)
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
    
    private func noFieldsFound(errorMessage : String){
        if (selectAgentVM.agentCard?.count == 0){
            if informationView == nil {
                informationView = InformationView.loadView(self.tableView.bounds, delegate: self)
            }
            self.informationView?.informationLabel.text = errorMessage
            self.informationView?.informationImageView.image = HippoConfig.shared.theme.noPrescription
            self.informationView?.isButtonInfoHidden = true
            self.informationView?.isHidden = false
            self.tableView.addSubview(informationView!)
            self.tableView.layoutSubviews()
        }else{
            for view in tableView.subviews{
                if view is InformationView{
                    view.removeFromSuperview()
                }
            }
            self.tableView.layoutSubviews()
            self.informationView?.isHidden = true
        }
    }
    
    //MARK:- IBAction
    
    @IBAction func action_BackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func openProfile(for channelId: Int, agentId: String?, profile: ProfileDetail?) {
        let presenter = AgentProfilePresenter(channelID: channelId, agentID: agentId, profile: profile)
        let vc = AgentProfileViewController.get(presenter: presenter)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension SelectAgentController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectAgentVM.agentCard?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAgentCell", for: indexPath) as? SelectAgentCell else{
            return SelectAgentCell()
        }
        if let card = selectAgentVM.agentCard?[indexPath.row]{
            cell.config(card: card)
        }
        cell.openProfile = {[weak self](profile) in
            self?.openProfile(for: -1, agentId: self?.selectAgentVM.agentCard?[indexPath.row].id, profile: profile)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let card = selectAgentVM.agentCard?[indexPath.row]{
            self.cardSelected?(card)
        }
        self.navigationController?.popViewController(animated: false)
    }
}
