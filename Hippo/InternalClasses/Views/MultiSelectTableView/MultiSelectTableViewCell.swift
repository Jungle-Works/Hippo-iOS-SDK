//
//  MultiSelectTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/16/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol submitButtonTableViewDelegate : AnyObject {
    
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
        // Revamped customer thread shows no bot avatar, so the card lines up with the bot's text
        // bubbles instead of leaving the avatar's space empty - as on Android.
        bgViewLeadingConstraint.constant = CustomAction.cardLeading
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
        if CustomAction.usesRevampedCard {
            // Card: surface fill, hairline border, 16pt corners.
            let colors = HippoConfig.shared.colorConfig
            bgView.backgroundColor = colors.hippoSurface
            bgView.layer.cornerRadius = 16
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = colors.hippoBorder.cgColor
            multiselectTableView.separatorStyle = .none
            multiselectTableView.backgroundColor = .clear
            moveTimeToHeader()
            return
        }

        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        multiselectTableView.separatorStyle = .none
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        
        
        
    }
    
    /// Bottom gap under the footer (Submit / "Submitted"), read by the row height too.
    static func revampedBottomPadding(answered: Bool) -> CGFloat {
        return answered ? 6 : 2
    }

    private var tableBottomToCard: NSLayoutConstraint?

    /// As on Android: the time sits top right, on the "SELECT ONE" line, and the card ends just
    /// under Submit (12pt with the footer row's own 10pt) instead of carrying the time below it.
    private func moveTimeToHeader() {
        let timeConstraints = bgView.constraints.filter { $0.firstItem === timeLabel || $0.secondItem === timeLabel }
        NSLayoutConstraint.deactivate(timeConstraints)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        let bottom = multiselectTableView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -MultiSelectTableViewCell.revampedBottomPadding(answered: false))
        tableBottomToCard = bottom
        NSLayoutConstraint.activate([
            bottom,
            timeLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            // Header cell: 10pt inset, eyebrow line ~16pt tall.
            timeLabel.centerYAnchor.constraint(equalTo: multiselectTableView.topAnchor, constant: 20)
        ])
        bgView.bringSubviewToFront(timeLabel)
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
        guard let message = message else { return "" }
        return changeDateToParticularFormat(message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
    }
    
    func setTime() {
        let timeOfMessage = getTimeString()
        timeLabel.text = timeOfMessage
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textColor = CustomAction.usesRevampedCard ? HippoConfig.shared.colorConfig.hippoTextMuted
            : HippoConfig.shared.theme.incomingMsgDateTextColor
    }
    
    func setName()
    {
        // Revamped customer thread shows no sender identity on bot rows.
        if CustomAction.usesRevampedCard {
            self.nameLabel.text = ""
            return
        }
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
        if CustomAction.usesRevampedCard {
            timeLabel.font = UIFont.systemFont(ofSize: 11)
            tableBottomToCard?.constant = -MultiSelectTableViewCell.revampedBottomPadding(answered: message.customAction?.isReplied == 1)
        }
        
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
        
    if CustomAction.usesRevampedCard {
        // Submit is only enabled once max(1, min_selection) options are picked.
        if selectedButtonsArr.count >= max(1, message?.customAction?.minSelection ?? 1) {
            message?.customAction?.isReplied = 1
            submitButtonDelegate?.submitButtonPressed(hippoMessage: message!)
        }
        return
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
        // Revamped card always has a footer: Submit while open, "Submitted" once answered.
        if CustomAction.usesRevampedCard {
            return 3
        }
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
            if CustomAction.usesRevampedCard, let action = message?.customAction {
                cell.descriptionLabel.attributedText = action.revampedHeaderText(question: message?.message ?? "")
            } else {
                cell.descriptionLabel.text = message?.message
            }
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
            if CustomAction.usesRevampedCard {
                cell.applyRevampedStyle(button: b, answered: message?.customAction?.isReplied == 1)
            }
            
            return cell
        }
        else if indexPath.section == 2 && CustomAction.usesRevampedCard
        {
            return revampedFooterCell(tableView: tableView, indexPath: indexPath)
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
        if CustomAction.usesRevampedCard {
            return message?.customAction?.isReplied == 1 ? 34 : 61
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1,
              message?.customAction?.isReplied == 0,
              let customAction = message?.customAction,
              let buttonsArray = customAction.buttonsArray,
              indexPath.row < buttonsArray.count,
              let cell = multiselectTableView.cellForRow(at: indexPath) as? MultipleSelectTableViewCell else {
            return
        }

        let button = buttonsArray[indexPath.row]
        let maxSelection = customAction.maxSelection

        if maxSelection > 1 {
            let selectedButtonsArr = buttonsArray.filter { $0.status == true }

            if selectedButtonsArr.count < maxSelection {
                button.status = !(button.status ?? false)
                customAction.buttonsArray?[indexPath.row] = button
                cell.set(button: button)
            } else if selectedButtonsArr.contains(button) {
                button.status = !(button.status ?? false)
                customAction.buttonsArray?[indexPath.row] = button
                cell.set(button: button)
            }
        } else {
            button.status = !(button.status ?? false)
            customAction.buttonsArray?[indexPath.row] = button

            for item in buttonsArray where item != button {
                item.status = false
            }
            cell.set(button: button)
        }

        tableView.reloadData()
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


// MARK: - Revamped footer (design 04/05)

extension MultiSelectTableViewCell {

    private static let countLabelTag = 7301

    /// Open: Submit (full width for single select; count + compact Submit for multi select),
    /// enabled once min_selection is met. Answered: a read-only "Submitted" line with a lock.
    func revampedFooterCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let colors = HippoConfig.shared.colorConfig
        guard let action = message?.customAction else { return UITableView.defaultCell() }

        if action.isReplied == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let lock = NSTextAttachment()
            lock.image = UIImage(systemName: "lock")?.withTintColor(colors.hippoTextMuted, renderingMode: .alwaysOriginal)
            lock.bounds = CGRect(x: 0, y: -2, width: 12, height: 13)
            let text = NSMutableAttributedString(attachment: lock)
            text.append(NSAttributedString(string: "  " + HippoStrings.submitted, attributes: [
                .font: UIFont.systemFont(ofSize: 12.5, weight: .medium),
                .foregroundColor: colors.hippoTextMuted]))
            cell.textLabel?.attributedText = text
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonViewCell", for: indexPath) as? ActionButtonViewCell else {
            return UITableView.defaultCell()
        }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let selectedCount = (action.buttonsArray ?? []).filter { $0.status == true }.count
        let minNeeded = max(1, action.minSelection)
        let canSubmit = selectedCount >= minNeeded

        let button = cell.cellButton!
        button.setTitle(HippoStrings.submit, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 12
        button.backgroundColor = canSubmit ? colors.hippoAccent : colors.hippoAccentSubtle
        button.setTitleColor(colors.hippoOnAccent, for: .normal)
        button.setTitleColor(colors.hippoAccent.withAlphaComponent(0.5), for: .disabled)
        button.isEnabled = canSubmit
        button.alpha = 1
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        button.addTarget(self, action: #selector(submitButtonClicked), for: .touchUpInside)
        button.isHidden = self.isAgent

        var countLabel = cell.contentView.viewWithTag(MultiSelectTableViewCell.countLabelTag) as? UILabel
        if action.isMultiSelect {
            // Count on the left, compact Submit on the right.
            cell.buttonLeadingConstraint.constant = max(12, bgView.bounds.width > 0 ? bgView.bounds.width - 12 - 120 : 140)
            cell.buttonTrailingConstraint.constant = 12
            if countLabel == nil {
                let label = UILabel()
                label.tag = MultiSelectTableViewCell.countLabelTag
                label.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 18),
                    label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    label.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -8)
                ])
                countLabel = label
            }
            countLabel?.isHidden = false
            countLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            if selectedCount == 0 {
                countLabel?.text = minNeeded > 1 ? String(format: HippoStrings.selectAtLeastN, minNeeded) : HippoStrings.selectAtLeastOne
                countLabel?.textColor = colors.hippoTextMuted
            } else if action.maxSelection > 0 {
                countLabel?.text = String(format: HippoStrings.nOfMaxSelected, selectedCount, action.maxSelection)
                countLabel?.textColor = colors.hippoTextPrimary
            } else {
                countLabel?.text = String(format: HippoStrings.nSelected, selectedCount)
                countLabel?.textColor = colors.hippoTextPrimary
            }
        } else {
            // Single select: full-width Submit.
            cell.buttonLeadingConstraint.constant = 12
            cell.buttonTrailingConstraint.constant = 12
            countLabel?.isHidden = true
        }
        return cell
    }
}
