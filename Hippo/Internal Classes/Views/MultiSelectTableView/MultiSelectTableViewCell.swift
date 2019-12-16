//
//  MultiSelectTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/16/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol MultiSelectTableViewCellDelegate: class {
    func cellButtonPressed(message: HippoMessage, card: HippoCard)
}


class MultiSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var multiselectTableView: UITableView!
    @IBOutlet weak var multiSelectHieightConstraint: NSLayoutConstraint!
    
    var message: HippoMessage?
    let datasource: MultiSelectTableViewDataSource = MultiSelectTableViewDataSource()
    weak var delegate: MultiSelectTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        multiselectTableView.backgroundColor = .clear
        multiselectTableView.separatorStyle = .none
        selectionStyle = .none
    }
    
    private func setupTableView() {
        multiselectTableView.register(UINib(nibName: "MultipleSelectTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "MultipleSelectTableViewCell")
       
        multiselectTableView.dataSource = datasource
        multiselectTableView.delegate = datasource
        multiselectTableView.tableFooterView = UIView()
    }
    
}

extension MultiSelectTableViewCell {
    func set(message: HippoMessage) {
        self.message = message
        let cards = (message.cards) ?? []
        self.datasource.update(cards: cards)
       // self.datasource.delegate = self
        self.multiSelectHieightConstraint.constant = message.calculatedHeight ?? 0
        self.layoutIfNeeded()
        
        self.multiselectTableView.reloadData()
    }
    
}

extension MultiSelectTableViewCell: MultiSelectTableViewDataSourceInteractor
{
    func cellButtonPressed(message: HippoMessage, card: HippoCard) {
        
    }
    
    func buttonClick(buttonInfo: HippoCard) {
        guard let message = self.message else {
            return
        }
        delegate?.cellButtonPressed(message: message, card: buttonInfo)
    }
    
    func buttonClick(buttonInfo: HippoActionButton) {
        
    }
    
    func cellSelected(card: HippoCard) {
        multiselectTableView.reloadData()
    }
}
