//
//  AgentProfileViewDatasource.swift
//  HippoChat
//
//  Created by Vishal on 26/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class AgentProfileViewDatasource: NSObject {
    
    enum AgentProfileViewSection: Int, CaseCountable {
        case name = 0
        case bio
        case customForm
    }
    var profileDetail: ProfileDetail?
}

extension AgentProfileViewDatasource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
       return AgentProfileViewSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let parsedSection = AgentProfileViewSection(rawValue: section) else {
            return 0
        }
        guard let profile = self.profileDetail else {
            return 0
        }
        switch parsedSection {
        case .name:
            return 1
        case .bio:
            let bioValue = (profile.descriptionField?.value ?? "").trimWhiteSpacesAndNewLine()
            return bioValue.isEmpty ? 0 : 1
        case .customForm:
            return profile.listToDisplay.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let parsedSection = AgentProfileViewSection(rawValue: indexPath.section) else {
            return UITableView.defaultCell()
        }
        guard let profile = self.profileDetail else {
            return UITableView.defaultCell()
        }
        
        switch parsedSection {
        case .name:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileNameCell", for: indexPath) as? ProfileNameCell else {
                break
            }
            cell.set(profile: profile)
            return cell
        case .bio:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailCell", for: indexPath) as? ProfileDetailCell, let desc = profile.descriptionField else {
                break
            }
            cell.set(field: desc)
            return cell
        case .customForm:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailCell", for: indexPath) as? ProfileDetailCell else {
                break
            }
            let field = profile.listToDisplay[indexPath.row]
            cell.set(field: field)
            return cell
        }
        return UITableView.defaultCell()
    }
    
    
}

extension AgentProfileViewDatasource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let parsedSection = AgentProfileViewSection(rawValue: section) else {
            return 0.01
        }
        guard let profile = self.profileDetail else {
            return 0.01
        }
        switch parsedSection {
        case .bio:
            let bioValue = (profile.descriptionField?.value ?? "").trimWhiteSpacesAndNewLine()
            return bioValue.isEmpty ? 0.01 : 20
        case .customForm:
            return profile.listToDisplay.isEmpty ? 0.01 : 20
        default:
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
}
