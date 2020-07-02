//
//  PromotionTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/24/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class PromotionTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var promotionTitle: UILabel!
    @IBOutlet weak var promotionImage: UIImageView!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpUI()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI()
    {
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        //bgView.clipsToBounds = true
        bgView.backgroundColor = UIColor.white
        
        //promotionTitle.font = HippoConfig.shared.theme.titleFont
        //promotionTitle.textColor = HippoConfig.shared.theme.titleTextColor
        promotionTitle.textColor = .black//HippoConfig.shared.theme.conversationTitleColor.withAlphaComponent(1)
        
        descriptionLabel.font = HippoConfig.shared.theme.descriptionFont
        descriptionLabel.textColor = .darkText//HippoConfig.shared.theme.descriptionTextColor
        
        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textColor = .darkText//HippoConfig.shared.theme.descriptionTextColor//incomingMsgDateTextColor//
    }
    
    func set(data: PromotionCellDataModel)
    {
        if data.imageUrlString.isEmpty
        {
            self.promotionImage?.isHidden = true
            self.imageHeightConstraint.constant = 0
        }
        else
        {
            //self.imageHeightConstraint.constant = 160
            self.promotionImage?.isHidden = false
            let url = URL(string: data.imageUrlString)
//            self.promotionImage.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.placeHolderImage,  completionHandler:nil)
            
            //DispatchQueue.main.async {
                self.promotionImage.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.placeHolderImage, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                    if let img = image{
                        let ratio = img.size.width / img.size.height
                        let newHeight = self.promotionImage.frame.width / ratio
                        self.imageHeightConstraint.constant = newHeight
                        self.layoutIfNeeded()
                    }
                }
            //}
            
        }
        self.promotionTitle.text = data.title//"This is a new tittle"
       
       // self.promotionTitle.backgroundColor = UIColor.yellow
        self.descriptionLabel.text = data.description//"This is description of promotion in a new format"
        // print("text >>> \(self.descriptionLabel.text) height >> \(data.cellHeight)")
        
       // self.descriptionLabel.backgroundColor = UIColor.blue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: data.createdAt)
        
//        let dateFormatter2 = DateFormatter()
//        dateFormatter2.dateFormat = "dd MMM,yy h:mm a"
//        dateFormatter2.locale = Locale.current
//        dateFormatter2.timeZone = TimeZone.current
//        let timeOfMessage = dateFormatter2.string(from: date ?? Date())
        
        
        let timeOfMessage = changeDateToParticularFormat(date ?? Date(), dateFormat: "dd MMM,yy h:mm a", showInFormat: true)
        
      //  print("date>> \(timeOfMessage) dateCreatedAt?>>> \(data.createdAt)")
        
        self.dateTimeLabel.text = timeOfMessage
        
        self.layoutIfNeeded()
    }
}
