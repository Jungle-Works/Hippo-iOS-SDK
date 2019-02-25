//
//  ShowMoreTableViewCell.swift
//  Fugu
//
//  Created by Vishal on 10/04/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


protocol ShowMoreTableViewCellDelegate: class {
    func buttonClicked(with form: PaymentField)
}
class ShowMoreTableViewCell: UITableViewCell {

    //MARK:
    weak var delegate: ShowMoreTableViewCellDelegate?
    var form: PaymentField!
    
    @IBOutlet weak var showMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func showMoreClicked(_ sender: Any) {
        delegate?.buttonClicked(with: form)
    }

    func setupCell(form: PaymentField) {
        self.form = form
        
        showMoreButton.setTitle(form.title, for: .normal)
    }
}

