//
//  QuickReplyButtonCollectionViewCell.swift
//  Hippo
//
//  Created by ANKUSH BHATIA on 26/04/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class QuickReplyButtonCollectionViewCell: UICollectionViewCell {
    // MARK: Properties
    
    // MARK: IBOutlets
    @IBOutlet var buttonCell: UIButton! {
        didSet {
            buttonCell.isUserInteractionEnabled = false
        }
    }
}

