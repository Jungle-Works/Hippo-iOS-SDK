//
//  ActionTableDataSource.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class ActionTableDataSource: NSObject, UITableViewDataSource {
    
    
    enum ActionTableSections: Int, CaseCountable {
        case headerMessage = 0
        case buttons = 1
    }
    
    var message: HippoActionMessage?
    
    init(message: HippoActionMessage) {
        self.message = message
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ActionTableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionValue = ActionTableSections(rawValue: section), let message = self.message else {
            return 0
        }
        switch sectionValue {
        case .headerMessage:
            return 1
        case .buttons:
            return message.buttons?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionValue = ActionTableSections(rawValue: indexPath.section), let message = self.message else {
            return UITableView.defaultCell()
        }
        let cell: ActionViewCell
        switch  sectionValue {
        case .headerMessage:
            let cellForIndex = tableView.dequeueReusableCell(withIdentifier: "ActionLabelViewCell", for: indexPath) as! ActionLabelViewCell
            cellForIndex.setUpCell(message: message.message)
            
            cell = cellForIndex
        case .buttons:
            let cellForIndex = tableView.dequeueReusableCell(withIdentifier: "ActionButtonViewCell", for: indexPath) as! ActionButtonViewCell
            let buttons = message.buttons!
            
            cellForIndex.setupCell(buttonInfo: buttons[indexPath.row])
            cellForIndex.setButtonState(active: message.isUserInteractionEnbled)
            cell = cellForIndex
        }
        return cell
    }
}
