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
            tryToSetResponseMessage(selectedButton: selectedButton)
            self.buttons = buttons
        }
        setHeight()
        isUserInteractionEnbled = isActive
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
    
    func setHeight() {
        cellDetail = HippoCellDetail()
        cellDetail?.headerHeight = attributtedMessage.messageHeight + attributtedMessage.nameHeight + attributtedMessage.timeHeight
        cellDetail?.showSenderName = false
        
        if let attributtedMessage = responseMessage?.attributtedMessage {
            let nameHeight: CGFloat = HippoConfig.shared.appUserType == .agent ? attributtedMessage.nameHeight : 0
            cellDetail?.responseHeight = attributtedMessage.messageHeight + attributtedMessage.timeHeight + nameHeight + 10
            cellDetail?.actionHeight = nil
        } else {
            let buttonHeight = buttonsHeight() //(buttons?.count ?? 0) * 50
            cellDetail?.actionHeight = CGFloat(buttonHeight) + 15 + 10 + 10 //Button Height + (timeLabelHeight + time gap from top) + padding
        }
        
        cellDetail?.padding = 1
        
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
        
        json["selected_btn_id"] = selectedBtnId
        json["is_active"] = isActive.intValue()
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
        if !contentValues.isEmpty {
            contentValues.append(contentsOf: customButtons)
            let list = contentValues
            let (buttons, selectedButton) = HippoActionButton.getArray(array: list, selectedId: selectedId)
            self.tryToSetResponseMessage(selectedButton: selectedButton)
            self.buttons = buttons
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
        if !contentValues.isEmpty {
            let (buttons, selectedButton) = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
            self.tryToSetResponseMessage(selectedButton: selectedButton)
            self.buttons = buttons
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

let customButtons: [[String: Any]] = [
  [
    "btn_id": "451",
    "btn_color": "#FFFFFF",
    "btn_title": "Agent List",
    "btn_title_color": "#000000",
    "btn_selected_color": "#1E7EFF",
    "action": "AGENTS",
    "btn_title_selected_color": "#FFFFFF"
  ],
  [
    "btn_id": "454",
    "btn_color": "#FFFFFF",
    "btn_title": "audio call",
    "btn_title_color": "#000000",
    "btn_selected_color": "#1E7EFF",
    "action": "AUDIO_CALL",
    "btn_title_selected_color": "#FFFFFF"
  ],
  [
    "btn_id": "455",
    "btn_color": "#FFFFFF",
    "btn_title": "video call",
    "btn_title_color": "#000000",
    "btn_selected_color": "#1E7EFF",
    "action": "VIDEO_CALL",
    "btn_title_selected_color": "#FFFFFF"
  ],
  [
    "btn_id": "455",
    "btn_color": "#FFFFFF",
    "btn_title": "Continue chat",
    "btn_title_color": "#000000",
    "btn_selected_color": "#1E7EFF",
    "action": "CONTINUE_CHAT",
    "btn_title_selected_color": "#FFFFFF"
  ]
]
