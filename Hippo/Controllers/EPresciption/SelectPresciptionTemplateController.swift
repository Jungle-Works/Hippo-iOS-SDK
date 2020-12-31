//
//  SelectPresciptionTemplateController.swift
//  Hippo
//
//  Created by Arohi Sharma on 29/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SelectPresciptionTemplateController: UIViewController {
    //MARK:- Variables
    var selectPresciptionVM = SelectPresciptionViewModel()
    
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var table_SelectTemplate : UITableView!{
        didSet{
            table_SelectTemplate.register(UINib(nibName: "SelectTemplateCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "SelectTemplateCell")
        }
    }
    @IBOutlet weak var view_NavigationBar : NavigationBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_NavigationBar.title = "Select Template"
        view_NavigationBar.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
        
        selectPresciptionVM.responseRecieved = {[weak self]() in
            DispatchQueue.main.async {
                self?.table_SelectTemplate.reloadData()
            }
        }
        selectPresciptionVM.getTemplates = true
        // Do any additional setup after loading the view.
    }

    
    
    class func getNewInstance() -> SelectPresciptionTemplateController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectPresciptionTemplateController") as! SelectPresciptionTemplateController
        return vc
    }
    
    @IBAction func action_BackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
}
extension SelectPresciptionTemplateController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectPresciptionVM.templateArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTemplateCell", for: indexPath) as? SelectTemplateCell else { return SelectTemplateCell() }
        cell.label_TemplateName.text = "Name: " + (selectPresciptionVM.templateArr[indexPath.row].name ?? "")
        cell.label_TemplateId.text = "Template Id: " + String(selectPresciptionVM.templateArr[indexPath.row].template_id ?? -1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FillPresciptionViewController.getNewInstance(template: selectPresciptionVM.templateArr[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
