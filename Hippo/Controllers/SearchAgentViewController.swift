//
//  SearchAgentViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 14/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SearchAgentViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet var textField_SelectCountry : UITextField!
    @IBOutlet var textField_SearchSkill : UITextField!
    @IBOutlet var table_SearchAgent : UITableView!
    @IBOutlet var view_SelectCountry : UIView!
    @IBOutlet var view_SearchSkill: UIView!
    @IBOutlet weak var image_Loader : So_UIImageView!
    @IBOutlet weak var view_Navigation : UIView!
    @IBOutlet weak var button_Skip : UIButton!
    
    //MARK:- Variables
    
    var countryList : [String] = ["All","India","USA","China","Japan"]
    var pickerView: UIPickerView?
    var searchAgentVM = SearchAgentViewModel()
    var cardSelected : ((MessageCard)->())?
    var informationView: InformationView?
    
    //MARK:- UIViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerView()
        searchAgentVM.responseRecieved = {[weak self]() in
            DispatchQueue.main.async {
                self?.noFieldsFound(errorMessage: HippoStrings.noDataFound)
                if self?.searchAgentVM.isCountrySearch ?? false{
                    if self?.searchAgentVM.countryTag == nil || self?.searchAgentVM.countryTag?.tag_id == nil{
                        return
                    }
                    self?.view_SearchSkill.isHidden = false
                    self?.view_SelectCountry.isHidden = true
                    self?.button_Skip.isHidden = true
                }else{
                    self?.view_SearchSkill.isHidden = false
                    self?.view_SelectCountry.isHidden = true
                }
                self?.table_SearchAgent.reloadData()
            }
        }
        
        searchAgentVM.startLoading = {[weak self](isLoading) in
            DispatchQueue.main.async {
                if isLoading{
                    self?.startLoaderAnimation()
                }else{
                    self?.stopLoaderAnimation()
                }
            }
        }
        view_SearchSkill.isHidden = true
        button_Skip.isHidden = false
        button_Skip.titleLabel?.font = UIFont.regular(ofSize: 15.0)
        button_Skip.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
        self.noFieldsFound(errorMessage: HippoStrings.noDataFound)
    }
    
    
    //MARK:- IBAction
    
    @IBAction func action_BackBtn(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action_SkipBtn(){
        DispatchQueue.main.async {
            self.view_SearchSkill.isHidden = false
            self.view_SelectCountry.isHidden = true
            self.button_Skip.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view_Navigation.setNeedsLayout()
        view_Navigation.layoutIfNeeded()
    }
    
    //MARK:- Function
    
    class func getNewInstance() -> SearchAgentViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchAgentViewController") as! SearchAgentViewController
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
        if (self.searchAgentVM.isCountrySearch == true && (self.searchAgentVM.countryTag == nil || self.searchAgentVM.countryTag?.tag_id == nil)) || (self.searchAgentVM.isCountrySearch == false && self.searchAgentVM.tagArr.count == 0){
            if informationView == nil {
                informationView = InformationView.loadView(self.table_SearchAgent.bounds, delegate: self)
            }
            self.informationView?.informationLabel.text = errorMessage
            self.informationView?.informationImageView.image = HippoConfig.shared.theme.noPrescription
            self.informationView?.isButtonInfoHidden = true
            self.informationView?.isHidden = false
            self.table_SearchAgent.addSubview(informationView!)
            self.table_SearchAgent.layoutSubviews()
        }else{
            for view in table_SearchAgent.subviews{
                if view is InformationView{
                    view.removeFromSuperview()
                }
            }
            self.table_SearchAgent.layoutSubviews()
            self.informationView?.isHidden = true
        }
    }

    private func setPickerView() {
        pickerView = UIPickerView()
        pickerView?.delegate = self
        pickerView?.dataSource = self
        pickerView?.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: HippoStrings.Done, style: UIBarButtonItem.Style.plain, target: self, action: #selector(prickerDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField_SelectCountry.inputView = pickerView
        textField_SelectCountry.inputAccessoryView = toolBar
        textField_SelectCountry.text = countryList.first ?? ""
    }
    
    @objc func prickerDoneButtonClicked() {
        if textField_SelectCountry.text == "All"{
            self.action_SkipBtn()
        }else{
            searchAgentVM.isCountrySearch = true
            searchAgentVM.searchKey = textField_SelectCountry.text
        }
        textField_SelectCountry.resignFirstResponder()
    }
}

extension SearchAgentViewController : InformationViewDelegate{

    
}

extension SearchAgentViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchAgentVM.tagArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = searchAgentVM.tagArr[indexPath.row].tag_name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SelectAgentController.getNewInstance()
        var idArr = [String]()
        if let id = searchAgentVM.countryTag?.tag_id{
            idArr.append(String(id))
        }
        idArr.append(String(searchAgentVM.tagArr[indexPath.row].tag_id ?? -1))
        vc.selectAgentVM.tagIds = idArr
        vc.cardSelected = {[weak self](card) in
            DispatchQueue.main.async {
                self?.cardSelected?(card)
                self?.dismiss(animated: false, completion: nil)
            }
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchAgentViewController : UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textField_SelectCountry{
            return false
        }
        
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? textField.text ?? ""
        if textField == textField_SearchSkill{
            if updatedString.count >= 3{
                searchAgentVM.isCountrySearch = false
                searchAgentVM.searchKey = updatedString
            }else if updatedString.count == 0 && searchAgentVM.tagArr.count != 0{
                searchAgentVM.tagArr.removeAll()
                table_SearchAgent.reloadData()
            }
        }
        return true
    }
    
}

extension SearchAgentViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = countryList[row]
        return value
    }
}

extension SearchAgentViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField_SelectCountry.text = countryList[row]
    }
}
