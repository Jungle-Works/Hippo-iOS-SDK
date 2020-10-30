//
//  PromotionTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/24/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

//protocol PromotionTableViewCellDelegate: class {
//    func readmoreClicked(data: PromotionCellDataModel)
//}

class PromotionTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var fullDescriptionLabel: UITextView!
    //@IBOutlet weak var descriptionLabel: HippoLabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var promotionTitle: UILabel!
    @IBOutlet weak var promotionImage: UIImageView!{
        didSet{
            promotionImage.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var showReadMoreLessButton: UIButton!
    @IBOutlet weak var showReadMoreLessButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraint_timeLabelBottom : NSLayoutConstraint!
    
    var data: PromotionCellDataModel?
    var previewImage : (()->())?
//    weak var delegate: PromotionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpUI()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(){
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        //bgView.clipsToBounds = true
        bgView.backgroundColor = UIColor.white
        
         promotionTitle.font = HippoConfig.shared.theme.promotionTitle
        //promotionTitle.textColor = HippoConfig.shared.theme.titleTextColor
        promotionTitle.textColor = .black//HippoConfig.shared.theme.conversationTitleColor.withAlphaComponent(1)
          
        descriptionLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0) //.darkText//HippoConfig.shared.theme.descriptionTextColor
        descriptionLabel.font = HippoConfig.shared.theme.descriptionFont
//        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 11)
//        descriptionLabel.numberOfLines = 2
        
        fullDescriptionLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)//HippoConfig.shared.theme.descriptionTextColor
        fullDescriptionLabel.font = HippoConfig.shared.theme.descriptionFont
        
        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textColor = UIColor(red: 113/255, green: 113/255, blue: 113/255, alpha: 1.0) //HippoConfig.shared.theme.descriptionTextColor//incomingMsgDateTextColor//
    }
    
    func set(data: PromotionCellDataModel){
        
        self.data = data
        
        if data.imageUrlString.isEmpty{
            self.promotionImage?.isHidden = true
            self.imageHeightConstraint.constant = 0
            self.constraint_timeLabelBottom.constant = 0
        }else{
            self.imageHeightConstraint.constant = self.promotionImage.frame.size.width / 2.5
            self.promotionImage?.isHidden = false
            let url = URL(string: data.imageUrlString)
                self.promotionImage.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.placeHolderImage, options: nil, progressBlock: nil)
            self.constraint_timeLabelBottom.constant = 7
            //}
        }
//        self.promotionTitle.text = data.title//"This is a new tittle"
       
       // self.promotionTitle.backgroundColor = UIColor.yellow
//        self.descriptionLabel.text = data.description//"This is description of promotion in a new format"
   //        setDescriptionLabel()
        
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
        
        
        dateTimeLabel.text = date?.toString ?? ""
    

        self.layoutIfNeeded()
    }
    
    @IBAction func action_PreviewImage(){
        self.previewImage?()
    }
    
    
//    private func setDescriptionLabel() {
//        let desc = (data?.description ?? "")
//        descriptionLabel.text = desc
//        let readmoreFont = descriptionLabel.font //If font changes calculation is to be changed
//        let readmoreFontColor = UIColor.blue
//
//        let isTrailingAdded = self.descriptionLabel.addTrailing(with: "...", moreText: "Read More", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
//
//
//        if isTrailingAdded {
//            descriptionLabel.isUserInteractionEnabled = true
//            addGesture()
//        } else {
//            descriptionLabel.isUserInteractionEnabled = false
//            removeGesture()
//        }
//    }
//    private func addGesture() {
//        descriptionLabel.removeAllGesture()
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelClicked))
//        descriptionLabel.addGestureRecognizer(tapGesture)
//    }
//    private func removeGesture() {
//        descriptionLabel.removeAllGesture()
//    }
//    @objc private func labelClicked() {
//        if let data = self.data {
//            delegate?.readmoreClicked(data: data)
//        }
////        let message = (card?.description ?? "")
////        showAlertWith(message: message, action: nil)
//    }
}
