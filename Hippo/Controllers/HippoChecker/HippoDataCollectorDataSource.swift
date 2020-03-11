//
//  HippoDataCollectorDataSource.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import UIKit

class HippoDataCollectorDataSource: NSObject {
    
    //MARK: Variables
    var forms: [FormData]
    
    required init(forms: [FormData]) {
        self.forms = forms
    }
}
extension HippoDataCollectorDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let form = forms[indexPath.row]
        let type = form.type
        
        let cell: UITableViewCell
        switch type {
        case .textfield:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTextFieldCell", for: indexPath) as! BroadCastTextFieldCell
            customCell.setupCellFor(form: form)
            cell = customCell
        case .label:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "BroadCastTitleCell", for: indexPath) as! BroadCastTitleCell
            customCell.setupCellFor(form: form)
            cell = customCell
        case .button:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "BroadcastButtonCell", for: indexPath) as! BroadcastButtonCell
            customCell.setupCellFor(form: form)
            cell = customCell
        case .contactNumber:
            let customCell = tableView.dequeueReusableCell(withIdentifier: "ContactNumberTableCell", for: indexPath) as! ContactNumberTableCell
            customCell.setupCellFor(form: form)
            cell = customCell
        default:
            cell = UITableView.defaultCell()
        }
        return cell
    }
}
