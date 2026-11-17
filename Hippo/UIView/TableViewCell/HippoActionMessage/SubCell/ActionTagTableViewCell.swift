//
//  ActionTagTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 29/07/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol ActionTagProtocol: AnyObject {
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
        let revamped = message.usesRevampedChips
        if revamped {
            // Size first: TagListView reads these when it creates each chip.
            buttonTagView.textFont = HippoActionMessage.chipFont
            buttonTagView.paddingX = HippoActionMessage.chipPaddingX
            buttonTagView.paddingY = (HippoActionMessage.chipHeight - HippoActionMessage.chipFont.pointSize) / 2
            buttonTagView.marginX = HippoActionMessage.chipGap
            buttonTagView.marginY = HippoActionMessage.chipGap
            buttonTagView.buttonBorderWidth = 0
        } else {
            setUI()
        }
        buttonTagView.removeAllTags()
        let tagViews = buttonTagView.addTags(buttons)
        if revamped {
            styleRevampedChips(tagViews, selectedId: message.selectedBtnId)
        }
        // Once answered, the time sits in the answer bubble below the chips.
        let answered = revamped && !message.selectedBtnId.isEmpty
        timeLabel.text = answered ? "" : changeDateToParticularFormat(message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        timeLabel.textColor = HippoConfig.shared.colorConfig.hippoTextMuted
        self.layoutIfNeeded()
    }

    /// Customer quick replies (design 03): accent-tinted chips; after a pick the chosen chip is filled
    /// with the accent and every chip is locked. Unchosen chips keep their normal look (no fade).
    private func styleRevampedChips(_ tagViews: [TagView], selectedId: String) {
        let colors = HippoConfig.shared.colorConfig
        let locked = !selectedId.isEmpty
        for tag in tagViews {
            let chosen = locked && (tag.detail as? HippoActionButton)?.id == selectedId
            tag.cornerRadiu = 12
            tag.hippoBorderWidth = 0
            tag.layer.borderWidth = 0
            tag.tagBackgroundColor = chosen ? colors.hippoAccent : colors.hippoAccentSubtle
            tag.textColor = chosen ? colors.hippoOnAccent : colors.hippoAccent
            tag.highlightedBackgroundColor = chosen ? colors.hippoAccent : colors.hippoAccentSubtle2
            tag.textFont = chosen ? UIFont.systemFont(ofSize: 14.5, weight: .semibold) : HippoActionMessage.chipFont
            tag.isUserInteractionEnabled = !locked
        }
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
