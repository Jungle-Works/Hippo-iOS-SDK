//
//  CreateLabelViewController.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 19/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol CreateLabelDelegate: class {
    func createnewLabel(tagDetail: TagDetail, use: Bool)
    //    func useNewCreatedLabel(tagDetail: TagDetail, appendToExisting: Bool, updateSortedData: Bool)
}

class CreateLabelViewController: UIViewController {
    
    @IBOutlet weak var newLabelTF: UITextField!
    @IBOutlet weak var tagImage: So_UIImageView!
    @IBOutlet weak var chooseALabel: So_CustomLabel!
    @IBOutlet weak var labelsCollectionView: UICollectionView!
    
    @IBOutlet weak var addLabelButton: UIButton!
    @IBOutlet weak var useLabelButton: UIButton!
    @IBOutlet weak var leftBarItem: UIBarButtonItem!
    
    var colorCodeArray = ["#61BD4F", "#F2D600", "#FFAB4A", "#EB5A46", "#C377E0", "#0079BF", "#00C2E0", "#51E898", "#FF80CE", "#4d4d4d", "#B6BBBF", "#b04632"]
    var selectedColorLabel = -1
    weak var delegate: CreateLabelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpCreateLabelScreen()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fuguDelay(0) {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    // MARK:  IBActions
    @IBAction func cancelsAction(_ sender: UIButton) {
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func useLabelAction(_ sender: UIButton) {
        
        
        createTag {[weak self] (newTag) in
            guard let tag = newTag  else {
                return
            }
            self?.newLabelTF.resignFirstResponder()
            self?.delegate?.createnewLabel(tagDetail: tag, use: true)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func addLabelAction(_ sender: UIButton) {
        
        
        createTag {[weak self] (newTag) in
            guard  let tag = newTag else {
                return
            }
            self?.newLabelTF.resignFirstResponder()
            self?.delegate?.createnewLabel(tagDetail: tag, use: false)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    //Class methods
    class func get() -> CreateLabelViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateLabelViewController") as! CreateLabelViewController
        return vc
    }
}

extension CreateLabelViewController {
    func isValidData() -> Bool {
        
        guard self.selectedColorLabel >= 0 else {
            showAlert(self, title: "", message: "Please select a color.", actionComplete: nil)
            return false
        }
        
        guard let labelName = self.newLabelTF.text?.trimWhiteSpacesAndNewLine(), !labelName.isEmpty else {
            showAlert(self, title: "", message: "Please enter a label name", actionComplete: nil)
            return false
        }
        return true
    }
    
    
    func paramForCreatingTag() -> [String: Any] {
        var json: [String: Any] = [:]
        
        json["tag_name"] = (self.newLabelTF.text ?? "").trimWhiteSpacesAndNewLine()
        json["color_code"] = self.colorCodeArray[selectedColorLabel]
        
        return json
    }
    
    func createTag(completion: @escaping ((_ newTag: TagDetail?) ->())) {
        guard isValidData() else {
            completion(nil)
            return
        }
        let param = paramForCreatingTag()
        
        ChatInfoManager.sharedInstance.createNewTag(showLoader: true, param: param) { (result) in
            guard let newTag = result else {
                completion(nil)
                return
            }
            completion(newTag)
        }
    }
    
    func setTheme() {
        view.backgroundColor = HippoConfig.shared.theme.backgroundColor
    }
    
    func setUpCreateLabelScreen() {
        setupNavigationBar()
        self.newLabelTF.returnKeyType = .done
        
        useLabelButton.setBackgroundColor(color: .themeColor, forState: .normal)
        useLabelButton.titleLabel?.textColor = .white
        useLabelButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        
        addLabelButton.setBackgroundColor(color: .white, forState: .normal)
        addLabelButton.setTitleColor(.themeColor, for: .normal)
        addLabelButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        
        setTheme()
    }
    
    func setupNavigationBar() {
        leftBarItem.tintColor = HippoConfig.shared.theme.headerTextColor
        self.setNavBar(with: "Create Label")
    }
}

extension CreateLabelViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateLabelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorCodeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateLabelsCollectionViewCell", for: indexPath) as? CreateLabelsCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell.configureLabelsColorCell(resetProperties: false, bgColor: self.colorCodeArray[indexPath.row], selectedColorIndex: selectedColorLabel, row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedColorLabel = indexPath.row
        self.labelsCollectionView.reloadData()
    }
    
}

class CreateLabelsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelsColorView: So_UIView!
    @IBOutlet weak var selectedImage: So_UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureLabelsColorCell(resetProperties: Bool, bgColor: String, selectedColorIndex: Int, row: Int) -> CreateLabelsCollectionViewCell {
        if resetProperties {
            self.resetPropertiesofCreateLabels()
        }
        self.labelsColorView.backgroundColor = UIColor.hexStringToUIColor(hex: bgColor).withAlphaComponent(1.0)
        
        if selectedColorIndex == row {
            self.selectedImage.isHidden = false
        } else {
            self.selectedImage.isHidden = true
        }
        return self
    }
    
    func resetPropertiesofCreateLabels() {
        //        backgroundColor = .white
        //        labelsColorView.backgroundColor = .white
    }
}
