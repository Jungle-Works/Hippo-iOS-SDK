//
//  ActionTableDataSource.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class ActionTableDataSource: NSObject, UITableViewDataSource {
    typealias ActionTableProtocol = ActionTagProtocol
    
    enum ActionTableSections: Int, CaseCountable {
        case headerMessage = 0
        case buttons = 1
        /// Customer button messages: the answer bubble under the (kept) chips.
        case response = 2
    }
    weak var delegate: ActionTableProtocol?
    var message: HippoActionMessage?
    
    init(message: HippoActionMessage, delegate: ActionTableProtocol) {
        self.message = message
        self.delegate = delegate
    }
    
    func update(message: HippoActionMessage, delegate: ActionTableProtocol) {
        self.message = message
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard message != nil else {
            return 0
        }
        guard let message = message else { return 0 }
        let isAnswerType = message.type == .dateTime || message.type == .address || message.type == .botAttachment
        if isAnswerType {
            // Question only, then the answer once there is one.
            return message.responseMessage == nil ? 1 : 2
        }
        // Revamped customer chips stay visible after a pick, with the answer below them.
        if message.usesRevampedChips && message.responseMessage != nil {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionValue = ActionTableSections(rawValue: section) else {
            return 0
        }
        switch sectionValue {
        case .headerMessage:
            return 1
        case .buttons, .response:
            return 1 //message.buttons?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionValue = ActionTableSections(rawValue: indexPath.section), let message = self.message else {
            return UITableView.defaultCell()
        }
        let cell: UITableViewCell
        switch  sectionValue {
        case .headerMessage:
//            let cellForIndex = tableView.dequeueReusableCell(withIdentifier: "ActionLabelViewCell", for: indexPath) as! ActionLabelViewCell
//            cellForIndex.setUpCell(message: message.message)
//
//            cell = cellForIndex
            let isOutgoingMessage = HippoConfig.shared.appUserType == .agent
            cell = getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMessage, message: message, indexPath: indexPath)
        case .response:
            guard let responseMessage = message.responseMessage else { return UITableView.defaultCell() }
            cell = getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: HippoConfig.shared.appUserType != .agent, message: responseMessage, indexPath: indexPath)
        case .buttons:
            if let responseMessage = message.responseMessage, !message.usesRevampedChips {
                let isOutgoingMessage = HippoConfig.shared.appUserType != .agent
                if message.usesAddressAnswerBubble {
                    let addressCell = tableView.dequeueReusableCell(withIdentifier: BotAddressAnswerCell.identifier, for: indexPath) as! BotAddressAnswerCell
                    addressCell.set(message: message)
                    cell = addressCell
                } else if message.responseMessage?.type == .imageFile {
                    cell = getImageCell(tableView: tableView, isOutgoingMessage: isOutgoingMessage, message: responseMessage, indexPath: indexPath)
                }else if message.responseMessage?.type == .attachment {
                    cell = getAttachmentCell(tableView: tableView, isOutgoingMessage: isOutgoingMessage, message: responseMessage, indexPath: indexPath)
                }else {
                    cell = getNormalMessageTableViewCell(tableView: tableView, isOutgoingMessage: isOutgoingMessage, message: responseMessage, indexPath: indexPath)
                }
            } else {
                let cellForIndex = tableView.dequeueReusableCell(withIdentifier: "ActionTagTableViewCell", for: indexPath) as! ActionTagTableViewCell
                cellForIndex.setupCell(message: message)
                cellForIndex.delegate = delegate
                cell = cellForIndex
            }
        }
        return cell
    }
    
    func getNormalMessageTableViewCell(tableView: UITableView, isOutgoingMessage: Bool, message: HippoMessage, indexPath: IndexPath) -> UITableViewCell {
        let isCustomer = HippoConfig.shared.appUserType == .customer
        switch isOutgoingMessage {
        case false:
            let identifier = isCustomer ? "CustomerSupportMessageTableViewCell" : "SupportMessageTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SupportMessageTableViewCell
            let incomingAttributedString = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: message)
            return cell.configureCellOfSupportIncomingCell(resetProperties: true, attributedString: incomingAttributedString, channelId: -1, chatMessageObject: message)
        case true:
            let identifier = isCustomer ? "CustomerSelfMessageTableViewCell" : "SelfMessageTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SelfMessageTableViewCell
//            cell.delegate = self
//            return cell.configureIncomingMessageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath, comingFrom: "")
            if message.senderFullName != HippoConfig.shared.agentDetail?.fullName ?? ""{
                return cell.configureIncomingMessageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath, comingFrom: message.senderFullName)
            }else{
                return cell.configureIncomingMessageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath, comingFrom: "You")
            }
        }
    }
    
    func getImageCell(tableView: UITableView, isOutgoingMessage: Bool, message: HippoMessage, indexPath: IndexPath) -> UITableViewCell {
        
        if isOutgoingMessage == true {
            let isCustomer = HippoConfig.shared.appUserType == .customer
            // Same themed cell as an image the customer sends in the chat.
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: isCustomer ? "CustomerOutgoingImageCell" : "OutgoingImageCell", for: indexPath) as? OutgoingImageCell
            else {
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                return cell
            }
            if isCustomer {
                cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath)
                return cell
            }
            if message.senderFullName != HippoConfig.shared.agentDetail?.fullName ?? ""{
                cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath,comingFrom: message.senderFullName)
            }else{
                cell.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: message, indexPath: indexPath, comingFrom: "You")
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingImageCell", for: indexPath) as? IncomingImageCell
            else {
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                return cell
            }
            return cell.configureIncomingCell(resetProperties: true, channelId: -1, chatMessageObject: message, indexPath: indexPath)
        }
    }
    
    func getAttachmentCell(tableView: UITableView, isOutgoingMessage: Bool, message: HippoMessage, indexPath: IndexPath) -> UITableViewCell {
        if isOutgoingMessage {
            switch message.concreteFileType! {
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingVideoTableViewCell", for: indexPath) as! OutgoingVideoTableViewCell
               cell.messageLongPressed = { (message) in
                   
               }
                cell.setCellWith(message: message)
                cell.retryDelegate = getLastVisibleController() as? ConversationsViewController
                cell.delegate = getLastVisibleController() as? ConversationsViewController
                return cell
            case .audio:
                let audioIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingAudioTableViewCell" : "OutgoingAudioTableViewCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: audioIdentifier, for: indexPath) as! OutgoingAudioTableViewCell
                cell.setData(message: message)
                cell.delegate = getLastVisibleController() as? ConversationsViewController
                return cell
            default:
                // Same themed cell as a file the customer sends in the chat.
                let documentIdentifier = HippoConfig.shared.appUserType == .customer ? "CustomerOutgoingDocumentTableViewCell" : "OutgoingDocumentTableViewCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: documentIdentifier) as! OutgoingDocumentTableViewCell
               cell.messageLongPressed = { (message) in
                   
               }
                cell.setCellWith(message: message, comingFrom: message.senderFullName)
                cell.actionDelegate = getLastVisibleController() as? ConversationsViewController
                cell.delegate = getLastVisibleController() as? ConversationsViewController
                cell.nameLabel.isHidden = true
                return cell
            }
        } else {
            switch message.concreteFileType! {
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingVideoTableViewCell", for: indexPath) as! IncomingVideoTableViewCell
                cell.setCellWith(message: message)
                cell.delegate = getLastVisibleController() as? ConversationsViewController
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingAudioTableViewCell", for: indexPath) as! IncomingAudioTableViewCell
                cell.setData(message: message)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingDocumentTableViewCell") as! IncomingDocumentTableViewCell
                cell.setCellWith(message: message)
                cell.actionDelegate = getLastVisibleController() as? ConversationsViewController
                cell.nameLabel.isHidden = false
                return cell
            }
        }
    }
    
    
}
