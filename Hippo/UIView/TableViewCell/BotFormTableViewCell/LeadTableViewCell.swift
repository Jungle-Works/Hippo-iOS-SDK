//
//  BotFormTableViewCell.swift
//  Hippo
//
//  Created by ANKUSH BHATIA on 27/04/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol LeadTableViewCellDelegate: class {
    func cellUpdated(for cell: LeadTableViewCell, data: [FormData], isSkipAction: Bool)
    func sendReply(forCell cell: LeadTableViewCell, data: [FormData])
    func textfieldShouldBeginEditing(textfield: UITextField)
    func textfieldShouldEndEditing(textfield: UITextField)
    func leadSkipButtonClicked(message: HippoMessage, cell: LeadTableViewCell)
}

class LeadTableViewCell: MessageTableViewCell {
    // MARK: Properties
    lazy var leadCellIdentifier: String = String(describing: LeadDataTableViewCell.self)
    
    
    var filterFileArray = [FormData]()
    weak var delegate: LeadTableViewCellDelegate?
    var indexPath: IndexPath!
    var lastVisibleCellIndex: Int = 0
    static let skipButtonHeightConstant: CGFloat = 30
    
    // MARK: IBOutlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var skipButtonContainter: UIView!
    @IBOutlet weak var skipButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.isScrollEnabled = false
        }
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Actions
    @IBAction func skipButtonClicked(_ sender: Any) {
        guard let message = self.message else {
            return
        }
        delegate?.leadSkipButtonClicked(message: message, cell: self)
    }
    // MARK: Functions
    private func setup() {
        self.tableView.register(UINib(nibName: leadCellIdentifier, bundle: FuguFlowManager.bundle), forCellReuseIdentifier: leadCellIdentifier)
        tableView.layer.cornerRadius = 10
        
        tableView.backgroundColor = HippoConfig.shared.theme.gradientBackgroundColor //.clear
        
        tableView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        tableView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor//HippoConfig.shared.theme.gradientTopColor.cgColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor//HippoConfig.shared.theme.gradientBackgroundColor //
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        
        tableView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            tableView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            bgView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setData(indexPath: IndexPath, arr: [FormData], message: HippoMessage) {
        super.intalizeCell(with: message, isIncomingView: true)
        
        filterFileArray = arr
        self.indexPath = indexPath
        self.tableView.reloadData()
        skipButtonContainter.isHidden = !message.shouldShowSkipButton()
        skipButtonHeightConstraint.constant = LeadTableViewCell.skipButtonHeightConstant
       // delegate?.cellUpdated(for: indexPath)
    }
    
    func disableSkipButton() {
        skipButtonContainter.isHidden = true
        self.delegate?.cellUpdated(for: self, data: filterFileArray, isSkipAction: true)
    }
    func checkAndDisableSkipButton() {
        guard let message = message else {
            return
        }
        skipButtonContainter.isHidden = !message.shouldShowSkipButton()
    }
}

extension LeadTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterFileArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterFileArray[section].isShow {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: leadCellIdentifier, for: indexPath) as? LeadDataTableViewCell else {
            fatalError("No cell with identifier \(self.leadCellIdentifier) found.")
        }
        cell.setData(data: filterFileArray[indexPath.section])
        if indexPath.section == 0 {
            cell.labelNoOfQuestions.isHidden = false
            var count = 1
            for lead in filterFileArray {
                if lead.isShow {
                    cell.labelNoOfQuestions.text = "(\(count) of \(filterFileArray.count))"
                    count += 1
                }
            }
            cell.constraintViewTop.constant = 8
        } else {
            cell.labelNoOfQuestions.isHidden = true
            cell.constraintViewTop.constant = 0
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if filterFileArray[indexPath.section].isShow {
            if indexPath.section == 0 {
                if self.filterFileArray[indexPath.section].isCompleted {
                    return LeadDataTableViewCell.rowHeight - 10.0
                } else {
                    return LeadDataTableViewCell.rowHeight
                }
            } else {
                if self.filterFileArray[indexPath.section].isCompleted {
                    return LeadDataTableViewCell.rowHeight - 8.0 - 10.0
                } else {
                    return LeadDataTableViewCell.rowHeight - 8.0
                }
            }
        }
        return 0.001
    }
    
    
}
extension LeadTableViewCell: LeadDataCellDelegate {
    func enableError(isEnabled: Bool, cell: LeadDataTableViewCell, text: String?) {
        guard let indexPath: IndexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let section = indexPath.section
        filterFileArray[section].isErrorEnabled = isEnabled
        cell.labelValidationError.text = text
        self.tableView.reloadData()
        self.delegate?.cellUpdated(for: self, data: filterFileArray, isSkipAction: false)
    }
    
    func textfieldShouldBeginEditing(textfield: UITextField) {
        self.delegate?.textfieldShouldBeginEditing(textfield: textfield)
    }
    
    func textfieldShouldEndEditing(textfield: UITextField) {
        self.delegate?.textfieldShouldEndEditing(textfield: textfield)
    }
    
    func didTapSend(withReply reply: String, cell: LeadDataTableViewCell) {
        guard let indexPath: IndexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if (filterFileArray.count - 1) != indexPath.section {
            filterFileArray[indexPath.section + 1].isShow = true
        }
        filterFileArray[indexPath.section].isCompleted = true
        filterFileArray[indexPath.section].value = reply
        self.tableView.reloadData()
        self.delegate?.sendReply(forCell: self, data: filterFileArray)
    }
    
}

