//
//  CreatePaymentDataSource.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import Foundation


class CreatePaymentDataSource: NSObject {
    
    
    var store: PaymentStore
    
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
            return customCell
            
        case .button:
            let value = store.buttons[indexPath.row]
            
            switch value.action {
            case .addMore:
                let customCell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreTableViewCell", for: indexPath) as! ShowMoreTableViewCell
                customCell.setupCell(form: value)
                return customCell
            default:
                let customCell = tableView.dequeueReusableCell(withIdentifier: "BroadcastButtonCell", for: indexPath) as! BroadcastButtonCell
                customCell.setupCellFor(form: value)
                return customCell
            }
           
        case .items:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "PaymentItemDescriptionCell", for: indexPath) as! PaymentItemDescriptionCell
            let item = store.items[indexPath.row]
            let count = store.items.count
            customCell.setupCellFor(item: item)
            customCell.cancelIcon.isHidden = count == 1
            
            return customCell
        }
    }
    
}
