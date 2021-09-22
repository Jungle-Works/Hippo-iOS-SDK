//
//  MultiSelectTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/16/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol submitButtonTableViewDelegate : class {
    
    func submitButtonPressed(hippoMessage:HippoMessage)
    
}



class MultiSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var multiselectTableView: UITableView!
    @IBOutlet weak var multiSelectHieightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bgViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var bgViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var multiSelectLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var multiSelectTrailingConstraint: NSLayoutConstraint!

    var isAgent: Bool = false
    var message: HippoMessage?
    weak var submitButtonDelegate: submitButtonTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgViewTrailingConstraint.constant = 60
        bgViewLeadingConstraint.constant = 35 + 10
        setTheme()
        setupTableView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setTheme() {
        backgroundColor = .clear
        
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        multiselectTableView.separatorStyle = .none
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        
        
        
    }
    
    private func setupTableView() {
        multiselectTableView.register(UINib(nibName: "MultipleSelectTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "MultipleSelectTableViewCell")
        
        
        multiselectTableView.register(UINib(nibName: "MultiSelectHeaderTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "MultiSelectHeaderTableViewCell")
        
        multiselectTableView.register(UINib(nibName: "ActionButtonViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ActionButtonViewCell")
       
        multiselectTableView.dataSource = self
        multiselectTableView.delegate = self
        multiselectTableView.tableFooterView = UIView()
    }
    
    func getTimeString() -> String {
        guard message != nil else {
            return ""
        }
        
        print(message!.creationDateTime)
        let timeOfMessage = changeDateToParticularFormat(message!.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
      
        return timeOfMessage
    }
    
    func setTime() {
        let timeOfMessage = getTimeString()
        timeLabel.text = timeOfMessage
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
    }
    
    func setName()
    {
        self.nameLabel.text = message?.senderFullName
        
        self.nameLabel.font = HippoConfig.shared.theme.senderNameFont
        self.nameLabel.textColor = HippoConfig.shared.theme.senderNameColor
    }
    
    
}

extension MultiSelectTableViewCell
{
    func set(message: HippoMessage, isAgent: Bool = false) {


        self.message = message
        
        if message.customAction?.maxSelection ?? 1 > 1
        {
            multiselectTableView.allowsMultipleSelection = true
        }
        else
        {
            multiselectTableView.allowsMultipleSelection = false
        }
        
//        if message.customAction?.isReplied == 1
//        {
//            multiselectTableView.allowsSelection = false
//        }
        
        setName()
        setTime()
        
        self.bgViewHeightConstraint.constant = message.calculatedHeight ?? 0
        self.layoutIfNeeded()
        
        self.multiselectTableView.reloadData()
    }
    
    
    @objc func submitButtonClicked()
    {
//        let arr = message?.customAction?.buttonsArray as! [MultiselectButtons]
//        var selectedButtonsArr = arr.filter { $0.status == true }
        var selectedButtonsArr = [MultiselectButtons]()
        if let arr = message?.customAction?.buttonsArray{
            selectedButtonsArr = arr.filter { $0.status == true }
        }
        
    if message?.customAction?.minSelection == 0 
    {
        showAlertWith(message: HippoStrings.noMinSelection, action: nil)
    }
    else
    {
        if selectedButtonsArr.count >= message?.customAction?.minSelection ?? 1
        {
            message?.customAction?.isReplied =  1
            submitButtonDelegate?.submitButtonPressed(hippoMessage: message!)
        }
        else
        {
            showAlertWith(message: HippoStrings.noMinSelection, action: nil)
        }
    }
        
    
      
}
    
    
}

extension MultiSelectTableViewCell: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if message?.customAction?.isReplied == 0
        {
            return 3
        }
        else
         {
            return 2
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1
        {
            return message?.customAction?.buttonsArray?.count ?? 0
        }
        else
        {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultiSelectHeaderTableViewCell", for: indexPath) as? MultiSelectHeaderTableViewCell else {
                return UITableView.defaultCell()
            }
            
            cell.selectionStyle = .none
            cell.descriptionLabel.text = message?.message
            cell.backgroundColor = .clear
            
            return cell
            
        }
        else if indexPath.section == 1
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleSelectTableViewCell", for: indexPath) as? MultipleSelectTableViewCell, let buttons = message?.customAction?.buttonsArray else {
                return UITableView.defaultCell()
            }
            let b = buttons[indexPath.row]
            cell.set(button: b)
            
            return cell
        }
        else if indexPath.section == 2
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonViewCell", for: indexPath) as? ActionButtonViewCell else {
                return UITableView.defaultCell()
            }
            
            cell.selectionStyle = .none
            cell.cellButton.setTitle(HippoStrings.submit, for: .normal)
            let theme = HippoConfig.shared.theme
            cell.cellButton.tintColor = .white
//            cell.cellButton.setTitleColor(.white, for: .normal)
            cell.cellButton.setTitleColor(HippoConfig.shared.theme.headerTextColor, for: .normal)
            cell.cellButton.setTitleColor(.paleGrey, for: .disabled)
            cell.cellButton.backgroundColor = theme.recievingBubbleColor
            cell.cellButton.layer.borderWidth = 0
            cell.cellButton.hippoCornerRadius = cell.cellButton.bounds.height / 2
            
            cell.cellButton .addTarget(self, action: #selector(submitButtonClicked), for: .touchUpInside)
            cell.buttonLeadingConstraint.constant = 20
            cell.buttonTrailingConstraint.constant = 20
            
//            let arr = message?.customAction?.buttonsArray as! [MultiselectButtons]
//            var selectedButtonsArr = arr.filter { $0.status == true }
            var selectedButtonsArr = [MultiselectButtons]()
            if let arr = message?.customAction?.buttonsArray as? [MultiselectButtons]{
                selectedButtonsArr = arr.filter { $0.status == true }
            }
            
            if selectedButtonsArr.count > 0
            {
                cell.cellButton.isEnabled = true
                
            }
            else
            {
                cell.cellButton.isEnabled = false
            }
            cell.cellButton.isHidden = self.isAgent
            
            return cell
        }
        else
        {
            return UITableView.defaultCell()
        }
        
    }
}

extension MultiSelectTableViewCell : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1, let buttons = message?.customAction?.buttonsArray {
            let b = buttons[indexPath.row]
            return b.cardHeight
        }
        if indexPath.section == 0 {
            return message?.customAction?.messageHeight ?? 0.01
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && message?.customAction?.isReplied == 0
        {
            let cell = multiselectTableView.cellForRow(at: indexPath) as! MultipleSelectTableViewCell
            
            let button = message?.customAction?.buttonsArray![indexPath.row]
           
            if (message?.customAction!.maxSelection)! > 1
            {
//                let arr = message?.customAction?.buttonsArray as! [MultiselectButtons]
//                var selectedButtonsArr = arr.filter { $0.status == true }
//                print(selectedButtonsArr.count)
                var selectedButtonsArr = [MultiselectButtons]()
                if let arr = message?.customAction?.buttonsArray as? [MultiselectButtons]{
                    selectedButtonsArr = arr.filter { $0.status == true }
                }

                if selectedButtonsArr.count < (message?.customAction!.maxSelection)!
                {
                    button?.status = !button!.status!
                    message?.customAction?.buttonsArray![indexPath.row] = button!
                    cell.set(button: button!)
                }
                
                if selectedButtonsArr.contains(button!) && selectedButtonsArr.count >= (message?.customAction!.maxSelection)!
                {
                    button?.status = !button!.status!
                    message?.customAction?.buttonsArray![indexPath.row] = button!
                    cell.set(button: button!)
                }
            }
            else
            {
                button?.status = !button!.status!
                message?.customAction?.buttonsArray![indexPath.row] = button!
                
                for item in message?.customAction?.buttonsArray as! [MultiselectButtons]
               {
                    if item != button
                    {
                       item.status = false
                    }
                }
                 cell.set(button: button!)
            }
            
            tableView.reloadData()
        }
//        else if indexPath.section == 0
//        {
//            let cell = multiselectTableView.cellForRow(at: indexPath) as! MultiSelectHeaderTableViewCell
//            cell.backgroundColor = .clear
//        }
//        else
//        {
//            let cell = multiselectTableView.cellForRow(at: indexPath) as! ActionButtonViewCell
//            cell.backgroundColor = .clear
//        }
    }
    
}

