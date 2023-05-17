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
        // Initialization code
    }

    @IBAction func deletePressed(_ sender: UIButton) {
        deleteCallBack?("")
    }
    
}
