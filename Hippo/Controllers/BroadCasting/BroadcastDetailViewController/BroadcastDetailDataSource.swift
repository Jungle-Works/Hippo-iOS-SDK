//
//  BroadcastDetailDataSourceAndDelegate.swift
//  Fugu
//
//  Created by Vishal on 11/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class BroadcastDetailDataSource: NSObject {
    
    enum BroadcastDetailSections: Int, CaseCountable {
        case header = 0
        case users
    }
    
    var broadcastDetail: BroadcastInfo?
    var userList: [CustomerInfo]
    
    init(broadcastDetail: BroadcastInfo, userList: [CustomerInfo]) {
        self.broadcastDetail = broadcastDetail
        self.userList = userList
    }
    
    func updateUserList(userList: [CustomerInfo]) {
        self.userList = userList
    }
    func appendUsers(newUsers: [CustomerInfo]) {
        self.userList.append(contentsOf: newUsers)
    }

}
extension BroadcastDetailDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return BroadcastDetailSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = BroadcastDetailSections(rawValue: section) else {
            return 0
        }
        switch tableSection {
        case .header:
            return broadcastDetail == nil ? 0 : 1
        case .users:
            return userList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = BroadcastDetailSections(rawValue: indexPath.section) else {
            return UITableView.defaultCell()
        }
        switch tableSection {
        case .header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastListTableViewCell", for: indexPath) as? BroadcastListTableViewCell, let broadcast = broadcastDetail else {
                return UITableView.defaultCell()
            }
            cell.setupCellWith(broadcast: broadcast)
            cell.setDetailUI()
            return cell
        case .users:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastUserStatusCell", for: indexPath) as? BroadcastUserStatusCell else {
                return UITableView.defaultCell()
            }
            cell.setCellData(user: userList[indexPath.row])
            return cell
        }
    }
}
extension BroadcastDetailDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
