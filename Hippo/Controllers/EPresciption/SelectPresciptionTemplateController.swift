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
    var tap: UITapGestureRecognizer!
    var swipe:UISwipeGestureRecognizer!
    var pdfUploadResult : ((UploadResult)->())?
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var table_SelectTemplate : UITableView!
    @IBOutlet var constraint_TableHeight : NSLayoutConstraint!
    @IBOutlet var view_Background : UIView!
    @IBOutlet var view_Container : UIView!
    @IBOutlet var label_PresciptionHeader : UILabel!{
        didSet{
            label_PresciptionHeader.font = UIFont.bold(ofSize: 18.0)
            label_PresciptionHeader.text = HippoConfig.shared.strings.selectPresciptionHeader
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        view_Background.addGestureRecognizer(tap)
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipe.direction = .down
        view_Background.addGestureRecognizer(swipe)
        view_Background.isHidden = true
        view_Container.isHidden = true
        constraint_TableHeight.constant = 0
        selectPresciptionVM.responseRecieved = {[weak self]() in
            DispatchQueue.main.async {
                self?.constraint_TableHeight.constant = CGFloat((self?.selectPresciptionVM.templateArr.count ?? 0) * 50) + 60
                self?.table_SelectTemplate.reloadData()
            }
        }
        selectPresciptionVM.getTemplates = true
        // Do any additional setup after loading the view.
    }

    
    
    class func getNewInstance(channelId : Int) -> SelectPresciptionTemplateController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectPresciptionTemplateController") as! SelectPresciptionTemplateController
        vc.selectPresciptionVM.channelID = channelId
        return vc
    }
    
    @IBAction func action_BackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectPresciptionTemplateController{
    func showViewAnimation() {
        view_Background.alpha = 0
        view_Background.isHidden = false
        view_Container.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view_Background.alpha = 1
            self.view.layoutIfNeeded()
        }) { (mark) in
            self.round()
        }
    }
    
    func round() {
        let path = UIBezierPath(roundedRect: view_Container.bounds, byRoundingCorners: [.topRight,.topLeft ], cornerRadii: CGSize(width: 8, height: 8))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view_Container.layer.mask = mask
        // Do any additional setup after loading the view.
    }
    
    @objc func tapOnView() {
        view_Background.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }
}

extension SelectPresciptionTemplateController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectPresciptionVM.templateArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.regular(ofSize: 16)
        cell.textLabel?.text = selectPresciptionVM.templateArr[indexPath.row].name ?? ""
        let bgColorView = UIView()
        bgColorView.backgroundColor = HippoConfig.shared.theme.themeColor
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FillPresciptionViewController.getNewInstance(template: selectPresciptionVM.templateArr[indexPath.row], channelId : selectPresciptionVM.channelID ?? -1)
        vc.pdfUploadResult = {[weak self](result) in
            DispatchQueue.main.async {
                if let result = result{
                    self?.pdfUploadResult?(result)
                }
                self?.tapOnView()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
}
