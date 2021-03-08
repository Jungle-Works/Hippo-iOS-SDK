//
//  UrlTableCell.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

final
class UrlTableCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet private var label_Url : UILabel!
    @IBOutlet private var button_Cross : UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
