//
//  MentionTableDataSourceDelegate.swift
//  HippoAgent
//
//  Created by Vishal on 04/06/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

protocol MentionTableDelegate: class {
    func mentionSelected(_ agent: Agent)
}

class MentionTableDataSourceDelegate: NSObject {
    var mentions: [Agent]
    weak var delegate: MentionTableDelegate?
    
    init(mentions: [Agent], delegate: MentionTableDelegate) {
        self.mentions = mentions
        self.delegate = delegate
    }
    func updateMentions(newMentions: [Agent]) {
        self.mentions = newMentions
    }
}

extension MentionTableDataSourceDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AgentListTableViewCell") as? AgentListTableViewCell else {
            return UITableViewCell()
        }
        let mention = mentions[indexPath.row]
        return cell.setupSuggestaionTableCell(agentObject: mention)
    }
}
extension MentionTableDataSourceDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mention = mentions[indexPath.row]
        delegate?.mentionSelected(mention)
    }
    
//    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? AgentListTableViewCell else { return }
//        cell.mainContentView.backgroundColor = UIColor.clear
//        cell.verticalSelectionLine.isHidden = false
//        cell.verticalSelectionLine.backgroundColor = UIColor.themeColor
//        cell.nameLabel.textColor = UIColor.themeColor
//        cell.layoutIfNeeded()
//    }
    
//    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? AgentListTableViewCell else { return }
//        cell.mainContentView.backgroundColor = UIColor.veryLightBlue
//        cell.verticalSelectionLine.isHidden = true
//        cell.nameLabel.textColor = UIColor.black
//        cell.layoutIfNeeded()
//    }
}
