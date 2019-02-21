//
//  ActionableMessageTableViewCell.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class ActionableMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var actionableMessageTableView: UITableView!
    let actionableMessageTableCellHandler = ActionableMessageCellHandler()
    
    var rootViewController: UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        self.timeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustShadow()
        actionableMessageTableView.estimatedRowHeight = 300
        actionableMessageTableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupBoxBackground(messageType: Int) {
        //bgView.backgroundColor = FuguConfig.shared.theme.incomingChatBoxColor
        
    }
    
    func adjustShadow() {
        shadowView.layoutIfNeeded()
        bgView.layoutIfNeeded()
        actionableMessageTableView.layoutIfNeeded()
        
        actionableMessageTableView.layer.cornerRadius = self.bgView.layer.cornerRadius
        actionableMessageTableView.clipsToBounds = true
        actionableMessageTableView.backgroundColor = HippoConfig.shared.theme.chatBoxBorderColor
        
        shadowView.layer.cornerRadius = self.bgView.layer.cornerRadius
        shadowView.clipsToBounds = true
        shadowView.backgroundColor = HippoConfig.shared.theme.chatBoxBorderColor
    }
    
    func resetPropertiesOfOutgoingCell() {
        backgroundColor = .clear
        selectionStyle = .none
        bgView.layer.cornerRadius = 5
        
       // retryButton.isHidden = true
        
    }
    
    
    func setUpData(messageObject: HippoMessage) {
        actionableMessageTableCellHandler.chatMessageObj = messageObject
        resetPropertiesOfOutgoingCell()
        let messageType = messageObject.type.rawValue
        setupBoxBackground(messageType: messageType)
        actionableMessageTableCellHandler.actionableMessage = messageObject.actionableMessage
        actionableMessageTableCellHandler.rootViewController = self.rootViewController
        actionableMessageTableView.delegate = actionableMessageTableCellHandler
        actionableMessageTableView.dataSource = actionableMessageTableCellHandler
        let timeOfMessage = changeDateToParticularFormat(messageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        timeLabel.text = "\t" + "\(timeOfMessage)"
        actionableMessageTableView.layoutIfNeeded()
        
    }
    
    func registerNib() {
        actionableMessageTableView.register(UINib(nibName: "ImageTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ImageTableViewCell")
        actionableMessageTableView.register(UINib(nibName: "HeaderTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "HeaderTableViewCell")
        actionableMessageTableView.register(UINib(nibName: "ItemTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ItemTableViewCell")
        actionableMessageTableView.register(UINib(nibName: "ButtonTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "ButtonTableViewCell")
        actionableMessageTableView.register(UINib(nibName: "SenderNameTableCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "SenderNameTableCell")
    }
    
 
    

}
