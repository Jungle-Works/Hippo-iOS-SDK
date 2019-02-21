//
//  TypingViewTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 29/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

class TypingViewTableViewCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    @IBOutlet var gifImageView: UIImageView!
    
    override func awakeFromNib() { gifImageView.backgroundColor = .clear }
}
