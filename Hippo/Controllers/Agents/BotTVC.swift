//
//  BotTVC.swift
//  Hippo-Hippo
//
//  Created by soc-admin on 14/04/22.
//

import UIKit

class BotTVC: UITableViewCell {
    
    //MARK: - IB OUTLETS
    @IBOutlet weak var lblTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTxt.font = UIFont.regular(ofSize: 15.0)
        lblTxt.textColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
