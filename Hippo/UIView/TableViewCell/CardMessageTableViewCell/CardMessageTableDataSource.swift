//
//  CardMessageTableDataSource.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class CardMessageTableDataSource: NSObject {
    var cards: [MessageCard] = []
}

extension CardMessageTableDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardListCell", for: indexPath) as? CardListCell else {
            return UICollectionViewCell()
        }
        cell.set(card: cards[indexPath.row])
        return cell
    }
    
    
}
