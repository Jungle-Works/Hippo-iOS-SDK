//
//  ShowMoreTableViewCell.swift
//  Fugu
//
//  Created by Vishal on 10/04/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
//import Kingfisher

protocol ShowMoreTableViewCellDelegate: class {
    func buttonClicked(with form: PaymentField)
    func savePaymentPlanClicked(shouldSavePlan : Bool)
}
class ShowMoreTableViewCell: UITableViewCell {

    //MARK:
    weak var delegate: ShowMoreTableViewCellDelegate?
    var form: PaymentField!
    var store: PaymentStore?
    var savePaymentPlanClicked : ((Bool)->())?
    
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var button_CheckBox : UIButton!
    
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
    
    @IBAction func action_SavePlanCheckbox(){
        button_CheckBox.isSelected = !button_CheckBox.isSelected
        button_CheckBox.setImage(button_CheckBox.isSelected ? HippoConfig.shared.theme.checkBoxActive : HippoConfig.shared.theme.checkBoxInActive, for: .normal)
        delegate?.savePaymentPlanClicked(shouldSavePlan: button_CheckBox.isSelected)
    }
    

    func setUI() {
//        let theme = HippoTheme.theme
        totalPriceLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        totalPriceLabel.font = UIFont.regular(ofSize: 15)
        showMoreButton.setTitleColor(HippoConfig.shared.theme.broadcastTitleColor, for: .normal)
        showMoreButton.titleLabel?.font = UIFont.regular(ofSize: 15)
        showMoreButton.tintColor = HippoConfig.shared.theme.themeTextcolor
    }
    func setupCell(form: PaymentField, store: PaymentStore) {
        self.form = form
        
        self.store?.totalPriceUpdated = nil
        self.store = store
        
        showMoreButton.setTitle(form.title, for: .normal)
        if store.isCustomisedPayment ?? false{
            subscribeCallback()
            setTotalCostLabel()
        }
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
            totalPriceLabel.text = "\(HippoStrings.totalPrice): \(formattedValue)"
        } else {
            totalPriceLabel.text = ""
        }
        if HippoConfig.shared.appUserType == .agent{
            if store?.totalCostEnabled == false {
                totalPriceLabel.text = ""
            }
        }
    }
}

