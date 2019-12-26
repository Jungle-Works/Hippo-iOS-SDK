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
    var image: UIImage?
    var title: String?
    var description: String?
    var date : String?
    var action:[String:Any]?
    var promotionID: Int
    var cellHeight:CGFloat = 0
    
    init?(dict: [String: Any])
    {
        guard let promotionID = dict["promotionID"] as? Int else {
            return nil
        }
          self.promotionID = promotionID
        
    }
    
    
    @discardableResult
    func calculateHeightForCell(title:String,description:String) -> CGFloat
    {
        let width:CGFloat = windowScreenWidth - 10 - 10 - 8 - 8
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
        
        // print(size.height)
        let h = size1.height + size2.height
        self.cellHeight = h
        return h
    }
   
}
