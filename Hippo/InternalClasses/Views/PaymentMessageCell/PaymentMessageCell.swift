//
//  PaymentMessageCell.swift
//  HippoChat
//
//  Created by Vishal on 04/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PaymentMessageCellDelegate: class {
    func cellButtonPressed(message: HippoMessage, card: HippoCard)
}

class PaymentMessageCell: UITableViewCell {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.layer.cornerRadius = 6
        }
    }
    
    let datasource: PaymentMessageDataSource = PaymentMessageDataSource()
    weak var delegate: PaymentMessageCellDelegate?
    var message: HippoMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
        setupTableView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    private func setTheme() {
        backgroundColor = .clear
        tableView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor//.clear
        tableView.separatorStyle = .none
        selectionStyle = .none
    }
    private func setupTableView() {
        tableView.register(UINib(nibName: "CustomerPaymentCardCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "CustomerPaymentCardCell")
        tableView.register(UINib(nibName: "ActionButtonViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ActionButtonViewCell")
        tableView.register(UINib(nibName: "AssignedAgentTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "AssignedAgentTableViewCell")
        tableView.register(UINib(nibName: "PaymentSecureView", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PaymentSecureView")
        
        
        
        
        tableView.dataSource = datasource
        tableView.delegate = datasource
        tableView.tableFooterView = UIView()
    }
}
extension PaymentMessageCell {
    func set(message: HippoMessage) {
        self.message = message
        let cards = (message.cards) ?? []
        self.datasource.update(cards: cards)
        self.datasource.delegate = self
        self.heightConstraint.constant = message.calculatedHeight ?? 0
        self.layoutIfNeeded()
        
        self.tableView.reloadData()
    }
    
}
extension PaymentMessageCell: PaymentMessageDataSourceInteractor {
    func buttonClick(buttonInfo: HippoCard) {
        guard let message = self.message else {
            return
        }
        delegate?.cellButtonPressed(message: message, card: buttonInfo)
    }
    
    func buttonClick(buttonInfo: HippoActionButton) {
        
    }
    
    func cellSelected(card: HippoCard) {
        tableView.reloadData()
    }
}
