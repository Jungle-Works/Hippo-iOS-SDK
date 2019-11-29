//
//  CardMessageTableViewCell.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol CardMessageDelegate: class {
    func cardSelected(cell: CardMessageTableViewCell, card: MessageCard, message: HippoMessage)
    func labelContainerClicked(cell: CardMessageTableViewCell, card: MessageCard, message: HippoMessage)
}

class CardMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var datasource: CardMessageTableDataSource?
    weak var delegate: CardMessageDelegate?
    var message: HippoMessage?
    
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
        collectionView.contentInset.left = 40
        self.backgroundColor = .clear
    }
    
    internal func setDataSource(with cards: [MessageCard]?) {
        if datasource == nil {
            datasource = CardMessageTableDataSource()
            collectionView.dataSource = datasource
        }
        datasource?.cards = cards ?? []
        collectionView.reloadData()
    }
    internal func getCards() -> [MessageCard]? {
           let selectedCard = message?.cards?.first(where: { (c) -> Bool in
               return (c as? MessageCard)?.id == message?.selectedCardId
           })
           let cards: [MessageCard]?
               
           if let parsedCard = selectedCard as? MessageCard {
               cards = [parsedCard]
           } else {
              cards = (message?.cards as? [MessageCard]) ?? []
           }
           return cards
       }
}
extension CardMessageTableViewCell {
    func set(message: HippoMessage) {
        self.message = message
        
        let selectedAgentId = (message.selectedCardId ?? "").trimWhiteSpacesAndNewLine()
        collectionView.allowsSelection = selectedAgentId.isEmpty
        setDataSource(with: getCards())
    }
}
extension CardMessageTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cell {
        case let customCell as CardListCell:
            customCell.delegate = self
        default:
            break
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: collectionView.bounds.height - 10)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let message = self.message else {
            HippoConfig.shared.log.error("can not find message", level: .error)
            return
        }
        guard  let cards = getCards(), !cards.isEmpty, cards.count > indexPath.row else {
            HippoConfig.shared.log.error("can not find cards or cards are empty", level: .error)
            return
        }
        let card = cards[indexPath.row]
        delegate?.cardSelected(cell: self, card: card, message: message)
    }
}
extension CardMessageTableViewCell: CardListCellDelegate {
    func labelContainerClicked(card: MessageCard) {
        if let message = self.message {
            delegate?.labelContainerClicked(cell: self, card: card, message: message)
        }
    }
    func readmoreClicked(card: MessageCard) {
        if let message = self.message {
            delegate?.labelContainerClicked(cell: self, card: card, message: message)
        }
    }
}
