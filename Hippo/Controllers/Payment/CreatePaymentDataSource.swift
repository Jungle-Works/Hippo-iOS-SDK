//
//  CreatePaymentDataSource.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import UIKit

class CreatePaymentDataSource: NSObject {
    
    
    var store: PaymentStore
    var shouldSavePaymentPlan : Bool?
    
    init(store: PaymentStore) {
        self.store = store
    }
    
    enum DataSourceSection: Int, CaseCountable {
        case fields = 0
        case items
        case button
    }
}

extension CreatePaymentDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataSourceSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = DataSourceSection(rawValue: section) else {
            return 0
        }
        
        switch tableSection {
        case .fields:
            return store.fields.count
        case .items:
            return store.items.count
        case .button:
            return store.buttons.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = DataSourceSection(rawValue: indexPath.section) else {
            return UITableView.defaultCell()
        }
        switch tableSection {
        case .fields:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTextFieldCell", for: indexPath) as! BroadCastTextFieldCell
            let form = store.fields[indexPath.row]
            customCell.setupCell(form: form)
            customCell.isUserInteractionEnabled = store.isEditing
            return customCell
            
        case .button:
            let value = store.buttons[indexPath.row]
            
            switch value.action {
            case .addMore:
                let customCell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreTableViewCell", for: indexPath) as! ShowMoreTableViewCell
                customCell.button_CheckBox.isHidden = ((store.canEditPlan ?? false) || (store.isCustomisedPayment ?? false)) ? true : false
                customCell.button_CheckBox.imageView?.tintColor = .black
                customCell.button_CheckBox.isSelected = shouldSavePaymentPlan ?? false
                customCell.button_CheckBox.setImage((shouldSavePaymentPlan ?? false) ? HippoConfig.shared.theme.checkBoxActive : HippoConfig.shared.theme.checkBoxInActive, for: .normal)
                customCell.totalPriceLabel.text = ((store.canEditPlan ?? false) || (store.isCustomisedPayment ?? false)) ? " " : HippoStrings.savePlan
                customCell.setupCell(form: value, store: store)
               
                return customCell
            default:
                let customCell = tableView.dequeueReusableCell(withIdentifier: "BroadcastButtonCell", for: indexPath) as! BroadcastButtonCell
                customCell.setupCellFor(form: value)
                return customCell
            }
            
        case .items:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "PaymentItemDescriptionCell", for: indexPath) as! PaymentItemDescriptionCell
            customCell.isCustomPayment = store.isCustomisedPayment
            customCell.hideTitleTextField(store.isCustomisedPayment ?? false)
            let item = store.items[indexPath.row]
            let count = store.items.count
            customCell.setupCellFor(item: item)
            customCell.isUserInteractionEnabled = store.isEditing
            customCell.cancelIcon.isHidden = count == 1 || !store.isEditing
            return customCell
        }
    }
    
}
