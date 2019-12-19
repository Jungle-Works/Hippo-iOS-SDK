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

    @IBOutlet weak var multiselectTableView: UITableView!
    @IBOutlet weak var multiSelectHieightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var multiSelectLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var multiSelectTrailingConstraint: NSLayoutConstraint!
    
    
    var message: HippoMessage?
    weak var submitButtonDelegate: submitButtonTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        multiSelectTrailingConstraint.constant = 60
        multiSelectLeadingConstraint.constant = 20
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
        
        multiselectTableView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        multiselectTableView.separatorStyle = .none
        multiselectTableView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
        multiselectTableView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        multiselectTableView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        
        setTime()
        
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
        let timeOfMessage = changeDateToParticularFormat(message!.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
      
        return timeOfMessage
    }
    
    func setTime() {
        let timeOfMessage = getTimeString()
        timeLabel.text = timeOfMessage
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
    }
    
    
}

extension MultiSelectTableViewCell {
    func set(message: HippoMessage) {
        self.message = message
        
        if message.customAction?.maxSelection ?? 1 > 1
        {
            multiselectTableView.allowsMultipleSelection = true
        }
        else
        {
            multiselectTableView.allowsMultipleSelection = false
        }
        
        //self.setSelectedButtonsArr()
        self.multiSelectHieightConstraint.constant = message.calculatedHeight ?? 0
        self.layoutIfNeeded()
        
        self.multiselectTableView.reloadData()
    }
    
    
    @objc func submitButtonClicked()
    {
       message?.customAction?.isReplied =  1
       submitButtonDelegate?.submitButtonPressed(hippoMessage: message!)
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
            
            cell.cellButton.setTitle("Submit", for: .normal)
            let theme = HippoConfig.shared.theme
            cell.cellButton.tintColor = .white
            cell.cellButton.setTitleColor(.white, for: .normal)
            cell.cellButton.backgroundColor = theme.themeColor
            cell.cellButton.layer.borderWidth = 0
            cell.cellButton.hippoCornerRadius = cell.cellButton.bounds.height / 2
            
            cell.cellButton .addTarget(self, action: #selector(submitButtonClicked), for: .touchUpInside)
            cell.buttonLeadingConstraint.constant = 20
            cell.buttonTrailingConstraint.constant = 20
            
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
        
        if indexPath.section == 1
        {
            let cell = multiselectTableView.cellForRow(at: indexPath) as! MultipleSelectTableViewCell
            
            let button = message?.customAction?.buttonsArray![indexPath.row]
           
            if (message?.customAction!.maxSelection)! > 1
            {
                let arr = message?.customAction?.buttonsArray as! [MultiselectButtons]

                var selectedButtonsArr = arr.filter { $0.status == true }
                print(selectedButtonsArr.count)

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
                
                for item in message?.customAction?.buttonsArray! as! [MultiselectButtons]
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
    }
    
}

