//
//  PromotionCellDataModel.swift
//  HippoChat
//
//  Created by Clicklabs on 12/24/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation


class PromotionCellDataModel
{
    var imageUrlString: String = ""
    var title: String?
    var description: String?
    var createdAt : String = ""
    var action:[String:Any]?
    var customAttributes: [String:Any]?
    var channelID:Int
    var userID:Int
    var disableReply:Bool?
    var deepLink:String = ""
    var cellHeight:CGFloat = 0.01
    var skipBot:String = ""
    
    
    
    init?(dict: [String: Any])
    {
        self.channelID = Int.parse(values: dict, key: "channel_id") ?? 1
        self.title = (dict["title"] as? String) ?? ""
        self.disableReply = Bool.parse(key: "disable_reply", json: dict) ?? true
        self.description = dict["description"] as? String ?? ""
        self.createdAt = dict["created_at"] as? String ?? ""
        self.userID = Int.parse(values: dict, key: "user_id") ?? 1
        
        if let tempDict = dict["custom_attributes"] as? [String:Any]
       {
            self.customAttributes = tempDict
           // print("customAttributes>>> \(customAttributes)")
        
        if let imageDict = self.customAttributes!["image"] as? [String:Any]
        {
            self.imageUrlString = imageDict["image_url"] as? String ?? ""
           // print("imageUrlString>>> \(imageUrlString)")
        }
        
        if let deepLink = self.customAttributes!["deeplink"] as? String
        {
            self.deepLink = deepLink as String ?? ""
            print("deep link>>> \(deepLink)")
        }
        
        if let data = self.customAttributes!["data"] as? [String:Any]
        {
            self.skipBot = data["skip_bot"] as? String ?? ""
            print("skipBot>>> \(skipBot)")
        }
    }
        
        self.cellHeight = calculateHeightForCell(title: self.title!, description: self.description!)
    }
    
    
    @discardableResult
    func calculateHeightForCell(title:String,description:String) -> CGFloat
    {
        let width:CGFloat = windowScreenWidth - 5 - 5
        let attributedTitleString = NSMutableAttributedString(string: title)
        let attributedDescriptionString = NSMutableAttributedString(string: description)
        
        let range = NSRange.init(location: 0, length: attributedTitleString.length)
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let descRange = NSRange.init(location: 0, length: attributedDescriptionString.length)
       
        let font = HippoConfig.shared.theme.titleFont
        attributedTitleString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributedTitleString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.titleTextColor, range: range)
        attributedTitleString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        
        let font2 = HippoConfig.shared.theme.descriptionFont
        attributedDescriptionString.addAttribute(NSAttributedString.Key.font, value: font2, range: descRange)
        attributedDescriptionString.addAttribute(NSAttributedString.Key.foregroundColor, value: HippoConfig.shared.theme.descriptionTextColor, range: descRange)
        attributedDescriptionString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: descRange)
        
        let availableBoxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let size1 = attributedTitleString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size
        
        let size2 = attributedDescriptionString.boundingRect(with: availableBoxSize, options: .usesLineFragmentOrigin, context: nil).size
        
        //let height2 = self.description?.height(withConstrainedWidth: width, font: font2)
        
      //  print("description >> \(height2)")
        let h = size1.height + size2.height
        
        var height:CGFloat = 0.01
        
        if self.imageUrlString.isEmpty
        {
            height = h + 20// time height
        }
        else
        {
            height = h + 20 + 160 // image height
        }
        // print("height ???? \(height)")
        return height
    }
   
       static func getAnnouncementsArrayFrom(json: [[String: Any]]) -> [PromotionCellDataModel] {
            var arrayOfConversation = [PromotionCellDataModel]()
            
            for rawConversation in json {
                if let conversation = PromotionCellDataModel(dict: rawConversation) {
                    arrayOfConversation.append(conversation)
                }
            }
            
            return arrayOfConversation
        }
    
}


