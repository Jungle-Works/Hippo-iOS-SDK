//
//  SelectAgentCell.swift
//  Hippo
//
//  Created by Arohi Sharma on 13/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

class SelectAgentCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet weak var label_Name : UILabel!
    @IBOutlet weak var label_Description : UILabel!
    @IBOutlet weak var label_Rating : UILabel!
    @IBOutlet weak var image_Agent : HippoImageView!
    @IBOutlet weak var constraint_Trailing : NSLayoutConstraint!
    @IBOutlet weak var imageView_Status : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    
}
