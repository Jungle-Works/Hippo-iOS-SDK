//
//  SearchAddressController.swift
//  Hippo
//
//  Created by Arohi Magotra on 28/04/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

protocol SearchAddressControllerProtocol : class{
    func addressSelected(address: Address)
}

class SearchAddressController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private var tableView : UITableView!
    @IBOutlet private var textField : UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    //MARK:- Variables
    private var viewModel = SearchAdressVM()
    weak var delegate : SearchAddressControllerProtocol?
    private var informationView: InformationView?
    override func viewDidLoad() {
        super.viewDidLoad()
        noAddressFound(true)
        viewModel.responseRecieved = {[weak self]() in
            self?.noAddressFound()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    
    //MARK:- Function
    
    class func getNewInstance() -> SearchAddressController {
       let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
       let vc = storyboard.instantiateViewController(withIdentifier: "SearchAddressController") as! SearchAddressController
       return vc
    }
    
    @IBAction func actionBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension SearchAddressController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAddressCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.regular(ofSize: 14.0)
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = viewModel.getaddress(indexPath: indexPath.row).address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.addressSelected(address: viewModel.getaddress(indexPath: indexPath.row))
        self.actionBack()
    }
    
    @objc func callApi(){
        if textField.text != "", textField.text?.count ?? 0 > 2 {
            viewModel.searchText = textField.text
        }
    }
}

extension SearchAddressController {
    
    func noAddressFound(_ isCalledFromViewDidLoad : Bool = false){
        if viewModel.getAddressCount() == 0{
            if informationView == nil {
                informationView = InformationView.loadView(self.tableView.bounds)
            }
            self.informationView?.informationLabel.text = HippoStrings.noDataFound
            self.informationView?.informationLabel.isHidden = isCalledFromViewDidLoad
            self.informationView?.informationImageView.image = HippoConfig.shared.theme.emplyAddressImage
            self.informationView?.isButtonInfoHidden = true
            self.informationView?.isHidden = false
            DispatchQueue.main.async {
                self.tableView.addSubview(self.informationView!)
                self.tableView.layoutSubviews()
            }
        }else{
            for view in tableView.subviews{
                if view is InformationView{
                     view.removeFromSuperview()
                }
            }
            DispatchQueue.main.async {
                self.tableView.layoutSubviews()
            }
            self.informationView?.isHidden = true
        }
    }
    
}


extension SearchAddressController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? textField.text ?? ""
        if updatedString.isEmpty {
            viewModel.removeAllAddress()
            NSObject.cancelPreviousPerformRequests(
                  withTarget: self,
                  selector: #selector(callApi),
                  object: textField)
            return true
        }
        
        NSObject.cancelPreviousPerformRequests(
              withTarget: self,
              selector: #selector(callApi),
              object: textField)
        self.perform(
              #selector(callApi),
              with: textField,
              afterDelay: 0.2)
        return true
    }
}
