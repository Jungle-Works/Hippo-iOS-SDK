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
    
    
    override init?(dict: [String : Any]) {
        super.init(dict: dict)
        
        isActive = Bool.parse(key: "is_active", json: dict)
        selectedBtnId = dict["selected_btn_id"] as? String ?? ""
        
        
        
        if let content_value = dict["content_value"] as? [[String: Any]] {
            self.contentValues = content_value
            let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
            buttons = HippoActionButton.getArray(array: content_value, selectedId: selectedId)
        }
        setHeight()
        isUserInteractionEnbled = isActive
    }
    
    func setHeight() {
        cellDetail = HippoCellDetail()
        cellDetail?.senderNameHeight = 14
        cellDetail?.messageHeight = attributtedMessage.messageHeight
        cellDetail?.showSenderName = true
        cellDetail?.footerHeight = 18
        
        let buttonHeight = (buttons?.count ?? 0) * 50
        cellDetail?.additionalContentHeight = CGFloat(buttonHeight)
        cellDetail?.padding = 15
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
            buttons = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
        }
        setHeight()
    }
    
    func updateObject(with newObject: HippoActionMessage) {
        self.selectedBtnId = newObject.selectedBtnId
        self.isActive = newObject.isActive
        self.isUserInteractionEnbled = newObject.isUserInteractionEnbled
        
        let selectedId = selectedBtnId.isEmpty ? nil : selectedBtnId
        if !contentValues.isEmpty {
            buttons = HippoActionButton.getArray(array: contentValues, selectedId: selectedId)
        }
        setHeight()
        
        self.status = .sent
        
    }
}
