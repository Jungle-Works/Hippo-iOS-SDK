//
//  HippoActionButton.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

enum BotButtonAction: Int {
    case assignment = 1
    case audioCall = 2
    case videoCall = 3
    case chat = 4
    case openUrl = 5
}
enum BotButtonType: Int {
   case normal = 1
    case action = 2
}
class HippoActionButton {
    static let defaultButtonActionJson: [String: Any] = ["link_url": "https://fb.com"]
    
    var id: String
    var title: String = ""
    var isSelected: Bool = false
    var action: BotButtonAction?
    var buttonType: BotButtonType?
    var buttonActionJson: [String: Any] = HippoActionButton.defaultButtonActionJson
    
    private var selectedColorHex: String = ""
    private var colorHex: String = ""
    private var normalTitleHexColor: String  = "#000000"
    private var selectedTitleHexColor: String = "#000000"
    
    var color: UIColor
    var selectedColor: UIColor?
    var selectedTitleColor: UIColor?
    var normalTitleColor: UIColor?
    
    var isUserInteractionEnabled: Bool = true
    
    var json: [String: Any] = [:]
    
    init?(json: [String: Any], selectedId: String?) {
        guard let id = json["btn_id"] as? String else {
            return nil
        }
        self.json = json
        self.id = id
        self.title = json["btn_title"] as? String ?? ""
        self.colorHex = json["btn_color"] as? String ?? ""
        self.selectedColorHex = json["btn_selected_color"] as? String ?? ""
        
        self.normalTitleHexColor = json["btn_title_color"] as? String ?? ""
        self.selectedTitleHexColor = json["btn_title_selected_color"] as? String ?? ""
        
        if let action = Int.parse(values: json, key: "button_action_type") {
           self.action = BotButtonAction(rawValue: action)
        }
        if let action = Int.parse(values: json, key: "button_type") {
           self.buttonType = BotButtonType(rawValue: action)
        }
        self.buttonActionJson = json["button_action_json"] as? [String: Any] ??  HippoActionButton.defaultButtonActionJson
        self.color = UIColor.clear //HippoConfig.shared.theme.headerBackgroundColor
        
//        self.color = UIColor.hexStringToUIColor(hex: colorHex)
        self.selectedColor = UIColor.hexStringToUIColor(hex: selectedColorHex)
        self.selectedTitleColor = UIColor.hexStringToUIColor(hex: selectedTitleHexColor)
        self.normalTitleColor = UIColor.hexStringToUIColor(hex: normalTitleHexColor)
        
        let value = selectedId ?? ""
        isUserInteractionEnabled = value.isEmpty
        
        isSelected = selectedId == id
    }
    
    static func getArray(array: [[String: Any]], selectedId: String?) -> ([HippoActionButton]?, HippoActionButton?) {
        var list: [HippoActionButton] = []
        var selectedButton: HippoActionButton?
        
        for json in array {
            guard let action = HippoActionButton(json: json, selectedId: selectedId) else {
                continue
            }
            if action.isSelected {
                selectedButton = action
            }
             
            list.append(action)
        }
        let parsedList = list.isEmpty ? nil : list
        return (parsedList, selectedButton)
    }
    
    func getJson() -> [String : Any] {
        return self.json
    }
    func getUrlToOpen() -> URL? {
        guard let linkURL = buttonActionJson["link_url"] as? String, let url = URL(string: linkURL) else {
            return nil
        }
        return url
    }
}

extension HippoActionButton: TagViewCreation {
    var name: String {
        return title
    }
    var circlularCorner: Bool {
        return false
    }
    var tagViewId: Any? {
        return id
    }
    var tagViewTextColor: UIColor {
        return HippoConfig.shared.appUserType == .customer ? HippoConfig.shared.theme.botTextAndBorderColor : UIColor.lightGray
    }
}
