//
//  ChatInfoShowMoreTableViewCell.swift
//  Fugu
//
//  Created by Vishal on 10/04/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


protocol ChatInfoShowMoreDelegate: AnyObject {
    func buttonClicked()
}

class ChatInfoShowMoreTableViewCell: UITableViewCell {

    weak var delegate: ChatInfoShowMoreDelegate?
    
    @IBOutlet weak var showMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showMoreButton.setTitleColor(HippoTheme.defaultTheme().themeColor, for: .normal)
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func showMoreClicked(_ sender: Any) {
        delegate?.buttonClicked()
    }
}
