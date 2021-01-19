//
//  FillPresciptionViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 30/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class FillPresciptionViewController: UIViewController, InformationViewDelegate {

    //MARK:- Variables
    var template : Template?
    var channelId : Int?
    var pdfUploadResult : ((UploadResult?)->())?
    let datePickerView:UIDatePicker = UIDatePicker()
    var informationView: InformationView?
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var view_NavigationBar : NavigationBarChat!
    @IBOutlet weak var tableView_Template : UITableView!
    @IBOutlet weak var image_Loader : So_UIImageView!
    @IBOutlet weak var button_Send : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image_Loader.isHidden = true
        button_Send.isHidden = ((template?.body_keys?.count ?? 0) <= 0)
        
        tableView_Template.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView_Template.register(UINib(nibName: "PrescipionTextFieldCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PrescipionTextFieldCell")
        view_NavigationBar.setTitle(title: HippoConfig.shared.strings.sendPrescription)
        view_NavigationBar.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
        view_NavigationBar.call_button.isHidden = true
        view_NavigationBar.video_button.isHidden = true
        
        self.noFieldsFound(errorMessage: HippoConfig.shared.strings.noCustomField)
    }
    
}

extension FillPresciptionViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return template?.body_keys?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescipionTextFieldCell", for: indexPath) as? PrescipionTextFieldCell else { return PrescipionTextFieldCell() }
        cell.bodyKeys = template?.body_keys?[indexPath.row]
        cell.valueChanged = {[weak self]() in
            DispatchQueue.main.async {
                self?.template?.body_keys?[indexPath.row] = cell.bodyKeys ?? BodyKeys()
            }
        }
        cell.textViewEdited = {
            DispatchQueue.main.async {
                let size = cell.textView.bounds.size
                let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                            height: CGFloat.greatestFiniteMagnitude))
                if size.height != newSize.height {
                    UIView.setAnimationsEnabled(false)
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    if let thisIndexPath = tableView.indexPath(for: cell) {
                        tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
                    }
                }
            }
        }
        cell.setup()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension FillPresciptionViewController{
    //MARK:- IBAction
    
    @IBAction func action_BackBtn(){
        HippoKeyboardManager.shared.enable = false
        self.pdfUploadResult?(nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func action_CreatePrescription(){
        let selectPresciptionVM = SelectPresciptionViewModel()
        selectPresciptionVM.channelID = channelId
        let error = selectPresciptionVM.createParam(withTemplate: template ?? Template()).0
        let params = selectPresciptionVM.createParam(withTemplate: template ?? Template()).1
        if error != nil{
            self.showAlert(title: "Error", message: error ?? "", actionComplete: nil)
            return
        }
        selectPresciptionVM.pdfUploaded = {[weak self](error,result) in
            DispatchQueue.main.async {
                if let result = result{
                    self?.pdfUploadResult?(result)
                    self?.navigationController?.popViewController(animated: false)
                }else{
                    self?.showAlert(title: nil, message: error.debugDescription, actionComplete: nil)
                }
            }
        }
        selectPresciptionVM.startLoading = {[weak self](isLoading) in
            DispatchQueue.main.async {
                if isLoading{
                    self?.startLoaderAnimation()
                }else{
                    self?.stopLoaderAnimation()
                }
            }
        }
        selectPresciptionVM.createPresciptionParams = params
    }
    
}

extension FillPresciptionViewController{
    //MARK:- Functions
    
    class func getNewInstance(template : Template,channelId : Int) -> FillPresciptionViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "FillPresciptionViewController") as! FillPresciptionViewController
        vc.template = template
        vc.channelId = channelId
        return vc
    }
    
    private func startLoaderAnimation() {
        image_Loader.isHidden = false
        image_Loader.startRotationAnimation()
    }
    
    private func stopLoaderAnimation() {
        image_Loader.isHidden = true
        image_Loader.stopRotationAnimation()
    }
   
    private func noFieldsFound(errorMessage : String){
        if (self.template?.body_keys?.count ?? 0) <= 0{
            if informationView == nil {
                informationView = InformationView.loadView(self.tableView_Template.bounds, delegate: self)
            }
            self.informationView?.informationLabel.text = errorMessage
            self.informationView?.informationImageView.image = HippoConfig.shared.theme.noPrescription
            self.informationView?.isButtonInfoHidden = true
            self.informationView?.isHidden = false
            self.tableView_Template.addSubview(informationView!)
            self.tableView_Template.layoutSubviews()
        }else{
            for view in tableView_Template.subviews{
                if view is InformationView{
                     view.removeFromSuperview()
                }
            }
            self.tableView_Template.layoutSubviews()
            self.informationView?.isHidden = true
        }
    }
}
 
