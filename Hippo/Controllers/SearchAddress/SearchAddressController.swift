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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.responseRecieved = {[weak self]() in
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
