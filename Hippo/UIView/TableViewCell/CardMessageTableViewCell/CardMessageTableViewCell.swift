//
//  CardMessageTableViewCell.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class CardMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var datasource: CardMessageTableDataSource?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupOneTimeSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func setupOneTimeSetup() {
        let nib = UINib(nibName: "CardListCell", bundle: FuguFlowManager.bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: "CardListCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        selectionStyle = .none
    }
    
    internal func setDataSource(with cards: [MessageCard]?) {
        if datasource == nil {
            datasource = CardMessageTableDataSource()
            collectionView.dataSource = datasource
        }
        datasource?.cards = cards ?? []
        collectionView.reloadData()
    }
}
extension CardMessageTableViewCell {
    func set(message: HippoMessage) {
        setDataSource(with: message.cards)
    }
}
extension CardMessageTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: collectionView.bounds.height - 10)
    }
}
