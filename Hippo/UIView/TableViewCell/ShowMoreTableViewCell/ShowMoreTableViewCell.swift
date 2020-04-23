//
//  ShowMoreTableViewCell.swift
//  Fugu
//
//  Created by Vishal on 10/04/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import Kingfisher

protocol ShowMoreTableViewCellDelegate: class {
    func buttonClicked(with form: PaymentField)
}
class ShowMoreTableViewCell: UITableViewCell {

    //MARK:
    weak var delegate: ShowMoreTableViewCellDelegate?
    var form: PaymentField!
    var store: PaymentStore?
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func showMoreClicked(_ sender: Any) {
        delegate?.buttonClicked(with: form)
    }

    func setUI() {
        totalPriceLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        totalPriceLabel.font = UIFont.systemFont(ofSize: 15)
        
        showMoreButton.setTitleColor(Color.themeColor, for: .normal)
        showMoreButton.tintColor = Color.themeColor
    }
    func setupCell(form: PaymentField, store: PaymentStore) {
        self.form = form
        
        self.store?.totalPriceUpdated = nil
        self.store = store
        
        showMoreButton.setTitle(form.title, for: .normal)
        subscribeCallback()
        setTotalCostLabel()
    }
    
    
    func subscribeCallback() {
        store?.totalPriceUpdated = {
            DispatchQueue.main.async {
                self.setTotalCostLabel()
            }
        }
    }
    
    func setTotalCostLabel() {
        let price: Double = store?.totalCost ?? 0
        
        if price > 0 {
            let formattedValue = Helper.formatNumber(number: price)
            totalPriceLabel.text = "Total Price: \(formattedValue)"
        } else {
            totalPriceLabel.text = ""
        }
    }
}

