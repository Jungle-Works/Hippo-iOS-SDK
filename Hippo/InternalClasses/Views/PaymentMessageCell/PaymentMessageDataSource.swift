//
//  PaymentMessageDataSource.swift
//  HippoChat
//
//  Created by Vishal on 04/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PaymentMessageListDelegate: class {
    func cellSelected(card: HippoCard)
}

typealias PaymentMessageDataSourceInteractor = PaymentMessageListDelegate & ActionButtonViewCellDelegate

class PaymentMessageDataSource: NSObject {
    var cards: [HippoCard] = []
    
    weak var delegate: PaymentMessageDataSourceInteractor?
    
    override init() {
        
    }
    
    func update(cards: [HippoCard]) {
        self.cards = cards
    }
}

extension PaymentMessageDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return cards.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = cards[indexPath.row]
        switch item {
        case let card as CustomerPayment:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerPaymentCardCell", for: indexPath) as? CustomerPaymentCardCell else {
                return UITableView.defaultCell()
            }
           // let paymentCard = cards.filter{$0 is CustomerPayment}
           // card.cardConfig.isMultiplePayment = paymentCard.count > 1 ? true : false
            cell.set(card: card)
            return cell
        case let card as PayementButton:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonViewCell", for: indexPath) as? ActionButtonViewCell else {
                 return UITableView.defaultCell()
            }
            cell.set(card: card)
            cell.delegate = delegate
            return cell
        case let card as PaymentHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignedAgentTableViewCell", for: indexPath) as? AssignedAgentTableViewCell else {
                return UITableView.defaultCell()
            }
            cell.set(card: card)
            return cell
        case let card as PaymentSecurely:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSecureView", for: indexPath) as? PaymentSecureView else {
                return UITableView.defaultCell()
            }
            cell.set(card: card)
            return cell
        default:
            return UITableView.defaultCell()
        }
    }
}

extension PaymentMessageDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let card = cards[indexPath.row]
        return card.cardHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = cards[indexPath.row]
        guard item as? CustomerPayment != nil else {
            return
        }
        for each in cards {
            switch each {
            case let parsed as CustomerPayment:
                parsed.isLocalySelected = false
            case let parsed as PayementButton:
                parsed.selectedCardDetail = item as? CustomerPayment
            default:
                break
            }
        }
        (item as? CustomerPayment)?.isLocalySelected = true
        delegate?.cellSelected(card: item)
    }
}
