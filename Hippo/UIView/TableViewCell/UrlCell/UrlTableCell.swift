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
    @IBOutlet private var label_Url : UILabel!{
        didSet{
            label_Url.font = UIFont.regular(ofSize: 14.0)
        }
    }
    @IBOutlet private var button_Cross : UIButton!
    
    //MARK:- Clousers
    var crossBtnTapped: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Functions
    
    func config(url: TicketUrl){
        label_Url.text = url.name ?? ""
    }
    
    
    @IBAction private func action_crossbtn(){
        self.crossBtnTapped?()
    }
    
}
