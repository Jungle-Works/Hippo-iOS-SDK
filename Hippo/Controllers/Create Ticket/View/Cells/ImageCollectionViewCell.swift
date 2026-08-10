//
//  ImageCollectionViewCell.swift
//  Hippo
//
//  Created by Neha Vaish on 26/04/23.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    var deleteCallBack: ((String?)->())?

    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var thumbnailmage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        dashedView.layer.cornerRadius = 12
        dashedView.layer.masksToBounds = true
        dashedView.layer.borderWidth = 1
        dashedView.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1).cgColor
    }

    @IBAction func deletePressed(_ sender: UIButton) {
        deleteCallBack?("")
    }
}
