//
//  AgentTagCellCollectionViewCell.swift
//  Hippo
//
//  Created by Arohi Magotra on 31/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

class AgentTagCell: UICollectionViewCell {

    //MARK:- IBOutlets
    @IBOutlet private var labelTitle : UILabel!{
        didSet{
            labelTitle.font = UIFont.regular(ofSize: 14.0)
        }
    }
    
    var crossBtnTapped : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.hippoBorderWidth = 1
        contentView.hippoBorderColor = .black
    }

    //MARK:- IBAction
    
    @IBAction func actionCancel(){
        crossBtnTapped?()
    }
    
    func config(_ tag : Tag){
        labelTitle.text = tag.tag_name
    }
}
