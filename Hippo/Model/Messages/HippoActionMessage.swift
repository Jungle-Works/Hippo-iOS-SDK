//
//  HippoActionMessage.swift
//  Fugu
//
//  Created by Vishal on 04/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class HippoActionMessage: HippoMessage {
    
    var isActive: Bool = false
    var selectedBtnId: String = ""
    var isUserInteractionEnbled: Bool = false
    var buttons: [HippoActionButton]?
    var responseMessage: HippoMessage?
    
    
    override init?(dict: [String : Any]) {
        super.init(dict: dict)
        
        isActive = Bool.parse(key: "is_active", json: dict)
        selectedBtnId = dict["selected_btn_id"] as? String ?? ""
        
        
        
        if let content_value = dict["content_value"] as? [[String: Any]] {
            self.contentValues = content_value
            let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
            let (buttons, selectedButton) = HippoActionButton.getArray(array: content_value, selectedId: selectedId)
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
        responseMessage = HippoMessage(message: parsedSelectedButton.title, type: .normal)
        responseMessage?.userType = .customer
        responseMessage?.creationDateTime = self.creationDateTime
        responseMessage?.status = status
        cellDetail?.actionHeight = nil
    }
    func setHeight() {
        cellDetail = HippoCellDetail()
        cellDetail?.headerHeight = attributtedMessage.messageHeight + attributtedMessage.nameHeight + attributtedMessage.timeHeight
        cellDetail?.showSenderName = false
        
        
        let buttonHeight = buttonsHeight() //(buttons?.count ?? 0) * 50
        
        cellDetail?.actionHeight = CGFloat(buttonHeight) + attributtedMessage.timeHeight + 8
        
        if let attributtedMessage = responseMessage?.attributtedMessage {
            cellDetail?.responseHeight = attributtedMessage.messageHeight + attributtedMessage.timeHeight
            cellDetail?.actionHeight = nil
        }
        
        cellDetail?.padding = 12
    }
    
    
    func buttonsHeight() -> CGFloat {
        guard let buttons = buttons, !buttons.isEmpty else {
            return 0
        }
        
        let maxWidth = windowScreenWidth - 35
        var buttonCount: Int = 0
        var remaningWidth: CGFloat = maxWidth
        
        for each in buttons {
            let w: CGFloat = findButtonWidth(each.title) + 20
            let widthRemaningAfterInsertion = remaningWidth - w
            
            if remaningWidth == maxWidth {
                buttonCount += 1
                remaningWidth = widthRemaningAfterInsertion - 5
            } else if widthRemaningAfterInsertion < 0 {
                buttonCount += 1
                remaningWidth = maxWidth - w
            } else {
                remaningWidth = widthRemaningAfterInsertion - 5
            }
        }
        
        return CGFloat(buttonCount * 35)
    }
    private func findButtonWidth(_ text: String) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: text)
        attributedText.addAttribute(.font, value: HippoConfig.shared.theme.incomingMsgFont ?? UIFont.systemFont(ofSize: 16), range: range)
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
        
        return json
    }
    
    func selectBtnWith(btnId: String) {
        selectedBtnId = btnId
        isActive = false
        isUserInteractionEnbled = false
        
        let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
        if !contentValues.isEmpty {
            let (buttons, selectedButton) = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
            self.tryToSetResponseMessage(selectedButton: selectedButton)
            self.buttons = buttons
        }
        setHeight()
    }
    
    func updateObject(with newObject: HippoActionMessage) {
        self.selectedBtnId = newObject.selectedBtnId
        self.isActive = newObject.isActive
        self.isUserInteractionEnbled = newObject.isUserInteractionEnbled
        
        let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
        if !contentValues.isEmpty {
            let (buttons, selectedButton) = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
            self.tryToSetResponseMessage(selectedButton: selectedButton)
            self.buttons = buttons
        }
        setHeight()
        
        self.status = .sent
        
    }
}
