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
    
    
    
    

    
    /// Customer select cards (design 04/05) get the revamped card: eyebrow + question header,
    /// tinted option rows, Submit with a live count, "Submitted" once answered.
    static var usesRevampedCard: Bool {
        return HippoConfig.shared.appUserType == .customer
    }

    /// Card's left margin: lined up with the bot's text bubbles in the revamped customer thread
    /// (no avatar), avatar space otherwise. MultiSelectTableViewCell lays the card out with it.
    static var cardLeading: CGFloat {
        return usesRevampedCard ? 10 : 35 + 10
    }

    var isMultiSelect: Bool {
        return maxSelection > 1
    }

    /// "SELECT ONE" / "SELECT ALL THAT APPLY" above the question, as one attributed string so the
    /// header cell and the height calculation share it.
    func revampedHeaderText(question: String) -> NSAttributedString {
        let colors = HippoConfig.shared.colorConfig
        let eyebrow = (isMultiSelect ? HippoStrings.selectAllThatApply : HippoStrings.selectOne).uppercased()
        let eyebrowStyle = NSMutableParagraphStyle()
        eyebrowStyle.paragraphSpacing = 6
        let out = NSMutableAttributedString(string: eyebrow + "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 11.5, weight: .semibold),
            .foregroundColor: colors.hippoTextMuted,
            .kern: 0.4,
            .paragraphStyle: eyebrowStyle])
        let questionStyle = NSMutableParagraphStyle()
        questionStyle.lineSpacing = 2
        out.append(NSAttributedString(string: question, attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: colors.hippoTextPrimary,
            .paragraphStyle: questionStyle]))
        return out
    }

    @discardableResult
    func calculateHeightForMessage(message:String) -> CGFloat
    {
        if CustomAction.usesRevampedCard {
            let width: CGFloat = windowScreenWidth - CustomAction.cardLeading - 60 - 5 - 5 - 10 - 10
            let size = revampedHeaderText(question: message).boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
            let h = ceil(size.height) + 25
            self.messageHeight = h
            return h
        }
        let width:CGFloat = windowScreenWidth - CustomAction.cardLeading - 60 - 5 - 5 - 10 - 10
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
    
    
    func setJsonValue() -> [String:Any] {
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
        // Missing "status" = not selected (the option rows unwrap it).
        self.status = Bool.parse(key: "status", json: dict) ?? false
        
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
        let width:CGFloat = windowScreenWidth - CustomAction.cardLeading - 60 - 10 - 10 - 22 - 5 - 10 - 5
        let attributedString = NSMutableAttributedString(string: btnTitle)
        
        let range = NSRange.init(location: 0, length: attributedString.length)
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let font = HippoConfig.shared.theme.multiSelectButtonFont
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
       
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.multiSelectTextColor ?? UIColor(), range: range)
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
