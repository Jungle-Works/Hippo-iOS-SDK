//
//  UploadCollectionViewCell.swift
//  Hippo
//
//  Created by Neha Vaish on 03/05/23.
//

import UIKit

class UploadCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dashedView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        dashedView.layer.cornerRadius = 8
        dashedView.layer.borderWidth = 1.5
        dashedView.layer.borderColor = UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1).cgColor
        dashedView.backgroundColor = .white
    }
}
