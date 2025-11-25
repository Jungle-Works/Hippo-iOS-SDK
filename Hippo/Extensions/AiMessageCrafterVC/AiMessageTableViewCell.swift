//
//  AiMessageTableViewCell.swift
//  HippoAgent
//
//  Created by Neha on 25/03/25.
//  Copyright © 2025 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


struct Language {
    let label: String
    let value: String
}


class AiMessageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sepratorLine: UIView!
    @IBOutlet weak var optionLblLeading: NSLayoutConstraint!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var languageBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    
    
    let languages: [Language] = [
        Language(label: "French", value: "French"),
        Language(label: "Spanish", value: "Spanish"),
        Language(label: "English", value: "English"),
        Language(label: "Portuguese", value: "Portuguese"),
        Language(label: "German", value: "German"),
        Language(label: "Swedish", value: "Swedish"),
        Language(label: "Danish", value: "Danish"),
        Language(label: "Turkish", value: "Turkish"),
        Language(label: "Hindi", value: "Hindi")
    ]
    var dropDown: DropDown?
    var callback: ((String)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpDropDown(with: languages)
        
        print("✅ AiMessageTableViewCell Loaded Successfully")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setData(value: Int) {
        guard icon != nil, titleLabel != nil, optionLabel != nil, languageButton != nil else {
            print("❌ One or more UI elements are nil in AiMessageTableViewCell")
            return
        }
        languageButton.setTitle("Select a language ▼", for: .normal)
        languageButton.layer.cornerRadius = 4
        languageButton.layer.borderWidth = 1
        languageButton.layer.borderColor = UIColor.systemGray4.cgColor
//        languageButton.titleLabel?.font = UIFont.regularProximaNova(withSize: 12)
//        languageButton.setTitleColor(HippoTheme.theme.label.primary, for: .normal)
//        self.titleLabel.font = UIFont.mediumMontserrat(withSize: 17)
//        self.optionLabel.font = UIFont.regularProximaNova(withSize: 14)
//        self.optionLabel.textColor = HippoTheme.theme.label.secondary
        icon.image = HippoConfig.shared.theme.sparkle
        if let tintColor = HippoConfig.shared.theme.sendBtnIconTintColor {
            icon.tintColor = tintColor
        }else{
            icon.tintColor = HippoConfig.shared.theme.customColorforIcons
        }
        if value == 7 {
            titleLabel.text = "AI Message Crafter"
            icon.isHidden = false
            iconWidth.constant = 35
            iconHeight.constant = 30
            titleLabel.isHidden = false
            languageButton.isHidden = false
            languageBtnWidth.constant = 130
            optionLblLeading.constant = 0
            sepratorLine.isHidden = false
            viewTopConstraint.constant = 20
           
           
        } else if value == 3 {
            titleLabel.text = "Select Tone"
            icon.isHidden = true
            iconWidth.constant = 0
            iconHeight.constant = 30
            titleLabel.isHidden = false
            languageButton.isHidden = true
            languageBtnWidth.constant = 0
            optionLblLeading.constant = 10
            sepratorLine.isHidden = true
            viewTopConstraint.constant = 20
           // self.titleLabel.textColor = HippoTheme.theme.label.primary
            bgView.layer.cornerRadius = 6
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            icon.isHidden = true
            iconWidth.constant = 0
            iconHeight.constant = 0
            titleLabel.isHidden = true
            languageButton.isHidden = true
            languageBtnWidth.constant = 0
            optionLblLeading.constant = 10
            sepratorLine.isHidden = true
            viewTopConstraint.constant = 0
            bgView.layer.cornerRadius = 6
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    
    func setUpDropDown(with dataSource: [Language]) {
        let languageLabels = dataSource.map { $0.label }
        dropDown = DropDown(anchorView: languageButton)
        dropDown?.dataSource = languageLabels
//        dropDown?.backgroundColor = HippoTheme.theme.systemBackgroundColor.tertiary
//        dropDown?.textColor = HippoTheme.theme.label.primary
        dropDown?.selectedTextColor = .themeColor
        dropDown?.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            languageButton.setTitle("\(item) ▼", for: .normal)
            callback?(item)
        }
        
        fuguDelay(0.0) {
            self.dropDown?.bottomOffset = CGPoint(x: 0, y: self.dropDown?.anchorView?.plainView.bounds.height ?? 0)
        }
    }
    
    
    private func filterBtnAction(_ sender: UIButton) {
        if let _ = DropDown.VisibleDropDown{
            dropDown?.hide()
        }else{
            dropDown?.show()
        }
    }
    
    @IBAction func lblBtn(_ sender: Any) {
        print("do nothing")
    }
    
    
    @IBAction func languagePressed(_ sender: UIButton) {
        filterBtnAction(sender)
    }
}
