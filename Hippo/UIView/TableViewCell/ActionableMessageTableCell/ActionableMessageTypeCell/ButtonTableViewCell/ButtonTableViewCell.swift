//
//  ButtonTableViewCell.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var buttonCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerCell() {
        self.buttonCollectionView.register(UINib(nibName: "ButtonCollectionCell", bundle: FuguFlowManager.bundle), forCellWithReuseIdentifier: "ButtonCollectionCell")
    }
    
    func reloadButtonActionCollection() {
        buttonCollectionView.reloadData()
    }
    
}
