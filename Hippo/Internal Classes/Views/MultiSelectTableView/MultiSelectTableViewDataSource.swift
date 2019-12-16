//
//  MultiSelectTableViewDataSource.swift
//  HippoChat
//
//  Created by Clicklabs on 12/16/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol MultiSelectTableViewDelegate: class {
    func cellSelected(card: HippoCard)
}

typealias MultiSelectTableViewDataSourceInteractor = MultiSelectTableViewCellDelegate & ActionButtonViewCellDelegate


class MultiSelectTableViewDataSource: NSObject {
    var cards: [HippoCard] = []
    weak var delegate: PaymentMessageDataSourceInteractor?
    
    override init() {
        
    }
    
    func update(cards: [HippoCard]) {
        self.cards = cards
    }
}

extension MultiSelectTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = cards[indexPath.row]
        switch item {
        case let card as MultiSelect:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleSelectTableViewCell", for: indexPath) as? MultipleSelectTableViewCell else {
                return UITableView.defaultCell()
            }
            cell.set(card: card)
            return cell
        case let card as SubmitButton:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonViewCell", for: indexPath) as? ActionButtonViewCell else {
                return UITableView.defaultCell()
            }
            cell.setMultiSelectSubmit(card: card)
            cell.delegate = delegate
            return cell
//        case let card as PaymentHeader:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignedAgentTableViewCell", for: indexPath) as? AssignedAgentTableViewCell else {
//                return UITableView.defaultCell()
//            }
//            cell.set(card: card)
//            return cell
//        case let card as PaymentSecurely:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSecureView", for: indexPath) as? PaymentSecureView else {
//                return UITableView.defaultCell()
//            }
//            cell.set(card: card)
//            return cell
        default:
            return UITableView.defaultCell()
        }
    }
}

extension MultiSelectTableViewDataSource: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let card = cards[indexPath.row]
        return card.cardHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
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
