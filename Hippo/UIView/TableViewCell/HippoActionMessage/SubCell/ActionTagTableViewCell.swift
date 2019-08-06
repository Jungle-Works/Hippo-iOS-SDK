//
//  ActionTagTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 29/07/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol ActionTagProtocol: class {
    func tagClicked(_ title: String, tagView: TagView, sender: TagListView)
}

class ActionTagTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonTagView: TagListView!
    
    // MARK:
    var message: HippoActionMessage!
    weak var delegate: ActionTagProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUI() {
        buttonTagView.setTagListViewProperty()
        buttonTagView.delegate = self
    }
    
    func setupCell(message: HippoActionMessage)  {
        self.message = message
        let buttons: [HippoActionButton] = message.buttons ?? []
        buttonTagView.removeAllTags()
        buttonTagView.addTags(buttons)
        timeLabel.text = changeDateToParticularFormat(message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        self.layoutIfNeeded()
    }
}

extension ActionTagTableViewCell: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        guard let info = tagView.detail, let buttonInfo = info as? HippoActionButton else {
            return
        }
        delegate?.tagClicked(title, tagView: tagView, sender: sender)
        HippoConfig.shared.log.debug(buttonInfo.getJson(), level: .info)
    }
}
