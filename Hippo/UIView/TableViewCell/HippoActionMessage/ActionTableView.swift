//
//  ActionTableView.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol ActionTableViewDelegate: class {
    func performActionFor(selectionId: String, message: HippoMessage)
}


class ActionTableView: MessageTableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    //MARK: Variables
    var dataSource: ActionTableDataSource?
    weak var delegate: ActionTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultConfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellData(message: HippoActionMessage) {
        self.message?.statusChanged = nil
        self.message = nil
        
        
        intalizeCell(with: message, isIncomingView: false)
        
        self.message?.statusChanged = {
            DispatchQueue.main.async {
                self.setUIData()
            }
        }
        setupTableView()
        dataSource?.update(message: message, delegate: self)
        setUIData()
    }
    
    private func setupTableView() {
        guard let actionMessage = message as? HippoActionMessage else {
            return
        }
        self.dataSource = ActionTableDataSource(message: actionMessage, delegate: self)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        selectionStyle = .none
        
        tableView.register(UINib(nibName: "ActionLabelViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ActionLabelViewCell")
        tableView.register(UINib(nibName: "ActionButtonViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ActionButtonViewCell")
        tableView.register(UINib(nibName: "ActionTagTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ActionTagTableViewCell")
        
        
        tableView.register(UINib(nibName: "SelfMessageTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "SelfMessageTableViewCell")
        tableView.register(UINib(nibName: "SupportMessageTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "SupportMessageTableViewCell")
        
    }
    private func setUIData() {
//        guard let actionMessage = message as? HippoActionMessage else {
//            return
//        }
        if tableView.dataSource == nil {
            setupTableView()
        }
        setName()
        setTime()
        setMessageStatus()
        
        tableView.isUserInteractionEnabled = HippoConfig.shared.appUserType == .customer
        
        tableView.reloadData()
    }
    private func setName() {
        self.nameLabel.attributedText = message?.attributtedMessage.senderNameAttributedString
    }
    private func setDefaultConfig() {
        setupBoxBackground()
//        adjustShadow()
        
//        bgView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
        
        selectionStyle = .none
        
        timeLabel.text = ""
        nameLabel.text = ""
        
        statusImageView.isHidden = true
        backgroundColor = UIColor.clear
        
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
    }
    private func setupBoxBackground() {
//        bgView.backgroundColor = UIColor.outGoingMessageBoxColor
    }
    
    
    private func adjustShadow() {
        self.shadowView.layer.masksToBounds = true
        self.shadowView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
        self.shadowView.backgroundColor = HippoConfig.shared.theme.chatBoxBorderColor
    }
    
    func setMessageStatus() {
        statusImageView.image = message?.status.getIcon()
    }
}

extension ActionTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionValue = ActionTableDataSource.ActionTableSections(rawValue: indexPath.section), let message = self.message else {
            return 0.01
        }
        switch sectionValue {
        case .headerMessage:
            return (message.cellDetail?.headerHeight ?? 0.01) + 6
        case .buttons:
            return message.cellDetail?.actionHeight ?? message.cellDetail?.responseHeight ?? 0.01
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch cell {
        case let customCell as ActionButtonViewCell:
            customCell.delegate = self
        default:
            return
        }
    }
}
extension ActionTableView: ActionButtonViewCellDelegate {
    func buttonClick(buttonInfo: HippoCard) {
        
    }
    
    func buttonClick(buttonInfo: HippoActionButton) {
        delegate?.performActionFor(selectionId: buttonInfo.id, message: message!)
    }
}
extension ActionTableView: ActionTagProtocol {
    func tagClicked(_ title: String, tagView: TagView, sender: TagListView) {
        guard let message = self.message, let buttonInfo = tagView.detail as? HippoActionButton else {
            return
        }
        delegate?.performActionFor(selectionId: buttonInfo.id, message: message)
    }
}
