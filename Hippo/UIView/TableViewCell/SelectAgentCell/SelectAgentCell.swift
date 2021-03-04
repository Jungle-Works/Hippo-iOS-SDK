//
//  SelectAgentCell.swift
//  Hippo
//
//  Created by Arohi Sharma on 13/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit


final class SelectAgentCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet weak private var label_Name : UILabel!
    @IBOutlet weak private var label_Description : UILabel!
    @IBOutlet weak private var label_Rating : UILabel!
    @IBOutlet weak private var image_Agent : HippoImageView!
    @IBOutlet weak private var constraint_Trailing : NSLayoutConstraint!
    @IBOutlet weak private var imageView_Status : UIImageView!
    
    //MARK:- clousers
    var openProfile : ((ProfileDetail)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        image_Agent.hippoBorderColor = .lightGray
        image_Agent.hippoCornerRadius = 8
        imageView_Status.hippoCornerRadius = imageView_Status.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Functions
    func config(card : MessageCard){
        label_Name.text = card.title
        label_Description.text = card.description
        label_Rating.text = "\(card.rating ?? 0.0)"
        let placeholder: UIImage? = UIImage(named: "placeholderImg", in: FuguFlowManager.bundle, compatibleWith: nil)
        image_Agent.setImage(resource: card.image, placeholder: placeholder)
        imageView_Status.setStatusImageView(status: card.onlineStatus?.rawValue ?? "")
    }
    
    @IBAction private func actionInfoTap(){
        let profile = ProfileDetail(json: [:])
        profile.image = image_Agent.imageURL?.absoluteString
        profile.fullName = label_Name.text
        profile.rating = label_Rating.text
        self.openProfile?(profile)
    }
    
}
