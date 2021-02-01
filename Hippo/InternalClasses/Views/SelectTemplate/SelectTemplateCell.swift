//
//  SelectTemplateCell.swift
//  Hippo
//
//  Created by Arohi Sharma on 29/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SelectTemplateCell: UITableViewCell {

    //MARK:- IBOutlets
    
    @IBOutlet var image_Preview : UIImageView!
    @IBOutlet var image_RadioBtn: UIImageView!
    @IBOutlet var label_TemplateName : UILabel!
    @IBOutlet var label_TemplateId : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
