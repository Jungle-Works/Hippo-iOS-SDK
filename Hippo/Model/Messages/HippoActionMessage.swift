//
//  HippoActionMessage.swift
//  Fugu
//
//  Created by Vishal on 04/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class HippoActionMessage: HippoMessage {

    var selectedBtnId: String = ""
    var isUserInteractionEnbled: Bool = false
    var buttons: [HippoActionButton]?
    var responseMessage: HippoMessage?
    var repliedBy: String?
    var repliedById: Int?
    
    
    override init?(dict: [String : Any]) {
        super.init(dict: dict)
        
        isActive = Bool.parse(key: "is_active", json: dict)
        selectedBtnId = dict["selected_btn_id"] as? String ?? ""
        repliedBy = dict["replied_by"] as? String
        repliedById = Int.parse(values: dict, key: "replied_by_id")
        
        
        if let content_value = dict["content_value"] as? [[String: Any]] {
            self.contentValues = content_value
            let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
            let (buttons, selectedButton) = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
            if type == .dateTime || type == .address {
                tryToSetResponseMessage()
            }else if type == .botAttachment {
                tryToSetResponseMessageForAttachment()
            }else {
                tryToSetResponseMessage(selectedButton: selectedButton)
            }
            self.buttons = buttons
        }
        setHeight()
        isUserInteractionEnbled = isActive
    }
    
    func tryToSetResponseMessageForAttachment() {
        if let dic = self.contentValues.first {
            responseMessage = HippoMessage(message: "", type: .normal, senderName: repliedBy, senderId: repliedById, chatType: chatType)
            if let rawFileType = dic["file_type"] as? String {
                responseMessage?.documentType = FileType(mimeType: rawFileType)
            }
            responseMessage?.thumbnailUrl = dic["thumbnail_url"] as? String
            responseMessage?.fileUrl = dic["url"] as? String ?? dic["attachment_url"] as? String
            responseMessage?.fileName = dic["file_name"] as? String
            responseMessage?.imageUrl = dic["attachment_url"] as? String
            if responseMessage?.documentType == .document || responseMessage?.documentType == .video {
                responseMessage?.type = .attachment
            }else {
                responseMessage?.type = .imageFile
            }
            responseMessage?.userType = .customer
            responseMessage?.creationDateTime = self.creationDateTime
            responseMessage?.status = status
            cellDetail?.actionHeight = nil
        }
    }
    
    
    func tryToSetResponseMessage(selectedButton: HippoActionButton?)  {
        guard let parsedSelectedButton = selectedButton else {
            return
        }
        responseMessage = HippoMessage(message: parsedSelectedButton.title, type: .normal, senderName: repliedBy, senderId: repliedById, chatType: chatType)
        responseMessage?.userType = .customer
        responseMessage?.creationDateTime = self.creationDateTime
        responseMessage?.status = status
        cellDetail?.actionHeight = nil
    }
    
    func tryToSetResponseMessage() {
        if let dic = self.contentValues.first {
            if type == .dateTime {
                responseMessage = HippoMessage(message: dic["date_time_message"] as? String ?? "", type: .normal, senderName: repliedBy, senderId: repliedById, chatType: chatType)
            }else {
                responseMessage = HippoMessage(message: dic["address"] as? String ?? "", type: .normal, senderName: repliedBy, senderId: repliedById, chatType: chatType)
            }
            responseMessage?.userType = .customer
            responseMessage?.creationDateTime = self.creationDateTime
            responseMessage?.status = status
            cellDetail?.actionHeight = nil
        }
    }
    
    func setHeight() {
        cellDetail = HippoCellDetail()
        cellDetail?.headerHeight = attributtedMessage.messageHeight + attributtedMessage.nameHeight + attributtedMessage.timeHeight
        cellDetail?.showSenderName = false
        
        if let attributtedMessage = responseMessage?.attributtedMessage {
            if responseMessage?.type == .imageFile {
                // Customer: CustomerOutgoingImageCell, same 288 as a sent image in the chat.
                cellDetail?.responseHeight = HippoConfig.shared.appUserType == .customer ? 288 : 250
            }else if responseMessage?.type == .attachment {
                switch responseMessage?.concreteFileType {
                case .video:
                    cellDetail?.responseHeight = 234
                default:
                    cellDetail?.responseHeight = 80
                }
            }else if usesAddressAnswerBubble {
                cellDetail?.responseHeight = BotAddressAnswerCell.height(for: self)
            }else {
                let nameHeight: CGFloat = HippoConfig.shared.appUserType == .agent ? attributtedMessage.nameHeight : 0
                cellDetail?.responseHeight = attributtedMessage.messageHeight + attributtedMessage.timeHeight + nameHeight + 10
            }
            if usesRevampedChips {
                // Chips stay on screen (picked one filled, the rest locked) above the answer.
                cellDetail?.actionHeight = customerChipsHeight() + 22
                cellDetail?.stacksResponseUnderActions = true
            } else {
                cellDetail?.actionHeight = nil
            }
        } else if usesRevampedChips {
            // Chip row: 5 top + chips + 12 time line + 5 bottom (ActionTagTableViewCell.xib).
            cellDetail?.actionHeight = customerChipsHeight() + 22
        } else {
            let buttonHeight = buttonsHeight() //(buttons?.count ?? 0) * 50
            cellDetail?.actionHeight = CGFloat(buttonHeight) + 15 + 10 + 10 //Button Height + (timeLabelHeight + time gap from top) + padding
        }
        
        cellDetail?.padding = 1
        
    }
    
    
    /// Customer answers to a bot address question use the address bubble (BotAddressAnswerCell).
    var usesAddressAnswerBubble: Bool {
        return type == .address && HippoConfig.shared.appUserType == .customer && responseMessage != nil
    }

    /// Customer quick-reply buttons (type 20) use the revamped chips (ActionTagTableViewCell).
    var usesRevampedChips: Bool {
        return type == .consent && HippoConfig.shared.appUserType == .customer && !(buttons ?? []).isEmpty
    }

    /// Chip metrics shared with ActionTagTableViewCell: 36pt tall, 15pt side padding, 8pt gaps.
    static let chipFont = UIFont.systemFont(ofSize: 14.5, weight: .medium)
    static let chipHeight: CGFloat = 36
    static let chipPaddingX: CGFloat = 15
    static let chipGap: CGFloat = 8

    /// Height of the wrapped chip rows, mirroring TagListView's layout (right-aligned rows).
    func customerChipsHeight() -> CGFloat {
        guard let buttons = buttons, !buttons.isEmpty else { return 0 }
        // Chat table + ActionTableView + ActionTagTableViewCell insets, rounded up: an over-estimate
        // only adds a little space, an under-estimate would clip a row of chips.
        let maxWidth = windowScreenWidth - 56
        var rows = 1
        var rowWidth: CGFloat = 0
        for each in buttons {
            let textWidth = (each.title as NSString).size(withAttributes: [.font: HippoActionMessage.chipFont]).width
            let w = min(maxWidth, ceil(textWidth) + HippoActionMessage.chipPaddingX * 2)
            if rowWidth == 0 {
                rowWidth = w
            } else if rowWidth + HippoActionMessage.chipGap + w > maxWidth {
                rows += 1
                rowWidth = w
            } else {
                rowWidth += HippoActionMessage.chipGap + w
            }
        }
        return CGFloat(rows) * HippoActionMessage.chipHeight + CGFloat(rows - 1) * HippoActionMessage.chipGap
    }

    func buttonsHeight() -> CGFloat {
        guard let buttons = buttons, !buttons.isEmpty else {
            return 0
        }
        
        let maxWidth = windowScreenWidth - 27
        var buttonCount: Int = 0
        var remaningWidth: CGFloat = maxWidth
        
        for each in buttons {
            let w: CGFloat = findButtonWidth(each.title) + 40
            let widthRemaningAfterInsertion = remaningWidth - w - 5
            
            if remaningWidth == maxWidth {
                buttonCount += 1
                remaningWidth = widthRemaningAfterInsertion
            } else if widthRemaningAfterInsertion <= -5 {
                buttonCount += 1
                remaningWidth = maxWidth - w - 5
            } else {
                remaningWidth = widthRemaningAfterInsertion
            }
//            let message = "===\(each.title)--w=\(w)--widthRemaningAfterInsertion=\(widthRemaningAfterInsertion)--b=\(buttonCount)--remaning=\(remaningWidth) \n"
//            HippoConfig.shared.log.debug(message, level: .custom)

        }
        
        return CGFloat(buttonCount * 35) + CGFloat(5 * (buttonCount - 1)) 
    }
    private func findButtonWidth(_ text: String) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: text)
        attributedText.addAttribute(.font, value: HippoConfig.shared.theme.incomingMsgFont, range: range)
        let boxSize: CGSize = CGSize(width: windowScreenWidth - 30, height: CGFloat.greatestFiniteMagnitude)
        return sizeOf(attributedString: attributedText, availableBoxSize: boxSize).width
    }
    
    private func sizeOf(attributedString: NSMutableAttributedString, availableBoxSize: CGSize) -> CGSize {
        return attributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size
    }
    
    override func getJsonToSendToFaye() -> [String : Any] {
        var json = super.getJsonToSendToFaye()
        if type != .dateTime && type != .address && type != .botAttachment{
            json["selected_btn_id"] = selectedBtnId
            json["is_active"] = isActive.intValue()
        }
        json["content_value"] = contentValues
        json["user_id"] = currentUserId()
        json["replied_by"] = currentUserName()
        json["replied_by_id"] = currentUserId()
        
        return json
    }
    
    func selectBtnWith(btnId: String) {
        selectedBtnId = btnId
        isActive = false
        isUserInteractionEnbled = false
        repliedById = currentUserId()
        repliedBy = currentUserName()
        
        let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
        if type == .dateTime || type == .address {
            tryToSetResponseMessage()
        } else if type == .botAttachment {
            tryToSetResponseMessageForAttachment()
        }else{
            if !contentValues.isEmpty {
                let list = contentValues
                let (buttons, selectedButton) = HippoActionButton.getArray(array: list, selectedId: selectedId)
                self.tryToSetResponseMessage(selectedButton: selectedButton)
                self.buttons = buttons
            }
        }
        setHeight()
    }
    
    func updateObject(with newObject: HippoActionMessage) {
        super.updateObject(with: newObject)
        self.selectedBtnId = newObject.selectedBtnId
        self.isActive = newObject.isActive
        self.isUserInteractionEnbled = newObject.isUserInteractionEnbled
        self.repliedById = newObject.repliedById
        self.repliedBy = newObject.repliedBy
        
        let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
        if type == .dateTime || type == .address {
            tryToSetResponseMessage()
        }else if type == .botAttachment {
            tryToSetResponseMessageForAttachment()
        }else {
            if !contentValues.isEmpty {
                let (buttons, selectedButton) = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
                self.tryToSetResponseMessage(selectedButton: selectedButton)
                self.buttons = buttons
            }
        }
        setHeight()
        
        self.status = .sent
        messageRefresed?()
        
    }
    
    func getButtonWithId(id: String) -> HippoActionButton? {
        guard let  buttons = self.buttons else {
            return nil
        }
        let button = buttons.first { (b) -> Bool in
            return b.id == id
        }
        return button
    }
}
