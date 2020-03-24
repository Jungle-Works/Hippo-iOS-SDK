//
//  CustomAction.swift
//  HippoChat
//
//  Created by Clicklabs on 12/17/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class CustomAction: NSObject {
    var minSelection: Int
    var maxSelection: Int
    var buttonsArray: [MultiselectButtons]?
    var message : String
    var messageHeight: CGFloat = 0
    var isReplied : Int
    var videoLink : String
    
    init?(dict: [String: Any])
    {
        guard let custom_actions = dict["custom_action"] as? [String: Any] else {
            return nil
        }
        self.minSelection = Int.parse(values: custom_actions, key: "min_selection") ?? 1
        self.maxSelection = Int.parse(values: custom_actions, key: "max_selection") ?? 1
        
        self.isReplied = Int.parse(values: custom_actions, key:"is_replied") ?? 0
        
        self.videoLink = String.parse(values: custom_actions, key:"video_link") ?? ""
        
        self.message = String.parse(values: dict, key: "message") ?? ""
        
        if let buttonsArr = custom_actions["multi_select_buttons"] as? [[String:Any]]
        {
            self.buttonsArray = MultiselectButtons.parse(list: buttonsArr, allowMultiSelect: maxSelection > 1)
        }
        super.init()
        self.calculateHeightForMessage(message: self.message)
    }
    
    
    
    

    
    @discardableResult
    func calculateHeightForMessage(message:String) -> CGFloat
    {
        let width:CGFloat = windowScreenWidth - 35 - 10 - 60 - 5 - 5 - 10 - 10
        let attributedString = NSMutableAttributedString(string: message)
        
        let range = NSRange.init(location: 0, length: attributedString.length)
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let font = HippoConfig.shared.theme.incomingMsgFont
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.incomingMsgColor, range: range)
     attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        
        let availableBoxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
          let size = attributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size
        
       // print(size.height)
        let h = size.height + 25 
        self.messageHeight = h
        return h
    }
    
    
    func setJsonValue() -> [String:Any]
    {
        var jsonDict:[String:Any] = [:]
        
        jsonDict["min_selection"] = self.minSelection
        jsonDict["max_selection"] = self.maxSelection
        jsonDict["is_replied"] = self.isReplied
        jsonDict["video_link"] = self.videoLink
        
        var arr = [[String:Any]]()
        
        if self.buttonsArray != nil{
            for item in (self.buttonsArray)!
            {
                let dict  = ["btn_id":item.btnId,"btn_title":item.btnTitle ?? "","status":item.status?.intValue() ?? 0] as [String:Any]
                
                arr.append(dict)
            }
        }
        
        jsonDict["multi_select_buttons"] = arr
        
        print(jsonDict)
        
        return jsonDict
    }
}



class MultiselectButtons: NSObject {
    var btnId: String
    var btnTitle : String?
    var status : Bool?
    var isMultiSelect: Bool = false
    var btnHeight : CGFloat = 50
    
    
    init?(dict: [String: Any]) {
        guard let id = String.parse(values: dict, key: "btn_id") else {
            return nil
        }
        self.btnId = id
        self.btnTitle = String.parse(values: dict, key: "btn_title")
        self.status = Bool.parse(key: "status", json: dict)
        
        super.init()
        self.calculateHeightForButtons(btnTitle:self.btnTitle ?? "")
        
    }
    
    static func parse(list: [[String: Any]], allowMultiSelect: Bool) -> [MultiselectButtons] {
        var items: [MultiselectButtons] = []
      
        for each in list {
            guard let item = MultiselectButtons(dict: each) else {
                continue
            }
            item.isMultiSelect = allowMultiSelect
            items.append(item)
           
        }
        return items
    }
    
    @discardableResult
    func calculateHeightForButtons(btnTitle:String) -> CGFloat
    {
        let width:CGFloat = windowScreenWidth - 35 - 10 - 60 - 10 - 10 - 22 - 5 - 10 - 5
        let attributedString = NSMutableAttributedString(string: btnTitle)
        
        let range = NSRange.init(location: 0, length: attributedString.length)
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let font = HippoConfig.shared.theme.multiSelectButtonFont
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
       
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.multiSelectTextColor, range: range)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        
        let availableBoxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let size = attributedString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size
        
       // print(size.height)
        self.btnHeight = size.height + 22 + 10 
        return btnHeight
    }
    

}

extension MultiselectButtons: HippoCard {
    var cardHeight: CGFloat {
        return btnHeight
    }
}
