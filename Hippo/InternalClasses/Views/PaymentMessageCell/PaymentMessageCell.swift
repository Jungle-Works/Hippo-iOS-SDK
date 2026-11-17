//
//  PaymentMessageCell.swift
//  HippoChat
//
//  Created by Vishal on 04/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PaymentMessageCellDelegate: AnyObject {
    func cellButtonPressed(message: HippoMessage, card: HippoCard)
}

class PaymentMessageCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.layer.cornerRadius = 6
            // cornerRadius alone only draws the curve — it doesn't clip content to it. Without
            // this, the last row's flat rectangular corners (the "Proceed to Pay" button) sit
            // right where the table's own rounded corner should be and visibly overflow past it.
            tableView.clipsToBounds = true
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
        nameLbl.font = HippoConfig.shared.theme.broadcastTitleInfoFont
        backgroundColor = .clear
        // Panel reads the surface-background token on the customer screen — otherwise it and
        // the white plan cards inside it (CustomerPaymentCardCell) are both near-white with no
        // visible boundary between them. Agent keeps the legacy colour.
        tableView.backgroundColor = HippoConfig.shared.appUserType == .customer
            ? HippoConfig.shared.colorConfig.hippoReceiver
            : HippoConfig.shared.theme.outgoingChatBoxColor
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
        if message.senderFullName != HippoConfig.shared.agentDetail?.fullName ?? ""{
            nameLbl.text = message.senderFullName
        }else{
            nameLbl.text = "You"
        }
        // This cell has one layout for every payment message - there's no separate sent/
        // received variant to key off of, and isSentByMe() doesn't reliably match anyway
        // (these are bot/agent-originated even when the name above resolves to the
        // customer's own, via the agentDetail-is-nil quirk). Identity row is redundant in
        // the revamped customer thread regardless of whose name it would show - hide it
        // outright, matching every other cell's dropped avatar/name row.
        let hideName = HippoConfig.shared.appUserType == .customer
        nameView.isHidden = hideName
        nameLbl.isHidden = hideName
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
