//
//  MultipleSelectTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/13/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class MultipleSelectTableViewCell: UITableViewCell {
    
    var message: HippoMessage?
    var selectedButtonsArr : [MultiselectButtons]?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewTrailingConstant: NSLayoutConstraint!
    @IBOutlet weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var selectionButtonView: UIImageView!
    
    
    @IBOutlet weak var innerCardView: UIView!
    @IBOutlet weak var innerCardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerCardViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerCardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerCardViewLeadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var buttonText: UILabel!
    @IBOutlet weak var buttonTextBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTextTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTextLeadingConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func setTheme() {
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        let theme = HippoConfig.shared.theme
        buttonText.textColor = theme.multiSelectTextColor
        buttonText.font = theme.multiSelectButtonFont
        buttonText.numberOfLines = 0
        
        bgView.backgroundColor = UIColor.clear
        innerCardView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = HippoConfig.shared.theme.multiselectUnselectedButtonColor //HippoConfig.shared.theme.chatBoxBorderColor
        
    }
    
}


extension MultipleSelectTableViewCell {
    func set(button: MultiselectButtons)
    {
        //setConstraint(config: card.cardConfig)
        setLabel(label:buttonText, text: button.btnTitle ?? "")
        
        var image:UIImage?
        if button.isMultiSelect
        {
            image = button.status! ? HippoConfig.shared.theme.checkBoxActive : HippoConfig.shared.theme.checkBoxInActive
        }
        else
        {
            image = button.status! ? HippoConfig.shared.theme.radioActive : HippoConfig.shared.theme.radioInActive
        }
        
        
        if button.status!
        {
            let renderedImage = image?.withRenderingMode(.alwaysTemplate)
            self.selectionButtonView?.image = renderedImage
            self.selectionButtonView.tintColor = HippoConfig.shared.theme.themeColor
            bgView.backgroundColor = HippoConfig.shared.theme.multiselectSelectedButtonColor
        }
        else
        {
            let renderedImage = image?.withRenderingMode(.alwaysOriginal)
            self.selectionButtonView?.image = renderedImage
            bgView.backgroundColor = HippoConfig.shared.theme.multiselectUnselectedButtonColor
           // self.selectionButtonView?.image = image
        }
        
        
    }
    
}


extension MultipleSelectTableViewCell {
    
    private func setLabel(label: UILabel, text: String?) {
        let parsedText = text?.trimWhiteSpacesAndNewLine() ?? ""
        label.text = parsedText
        label.isHidden = parsedText.isEmpty
    }
  
}


// MARK: - Revamped customer rows (design 04/05)

extension MultipleSelectTableViewCell {

    /// Option row: label on the left, radio / checkbox on the right; a picked row is tinted.
    /// Once the card is answered it is read-only: picked rows keep a filled check, others fade.
    func applyRevampedStyle(button: MultiselectButtons, answered: Bool) {
        let colors = HippoConfig.shared.colorConfig
        let on = button.status ?? false
        // Indicator to the right: flip leading/trailing for this row's own layout only.
        bgView.semanticContentAttribute = .forceRightToLeft
        innerCardView.semanticContentAttribute = .forceRightToLeft
        buttonText.textAlignment = .left
        buttonText.semanticContentAttribute = .forceLeftToRight

        bgView.layer.borderWidth = 0
        bgView.layer.cornerRadius = 12
        bgView.backgroundColor = on ? colors.hippoAccentSubtle : .clear
        bgView.alpha = answered && !on ? 0.45 : 1

        let baseSize = HippoConfig.shared.theme.multiSelectButtonFont.pointSize
        buttonText.font = UIFont.systemFont(ofSize: baseSize, weight: on ? .medium : .regular)
        buttonText.textColor = on ? colors.hippoAccent : colors.hippoTextPrimary

        selectionButtonView.tintColor = nil
        selectionButtonView.image = SelectIndicator.image(multi: button.isMultiSelect, on: on, answered: answered)
    }
}

/// Radio / checkbox drawn to the design: muted ring when off; on = thick accent ring (open single
/// select) or a filled accent mark with a white check (multi select, and any answered pick).
enum SelectIndicator {
    static func image(multi: Bool, on: Bool, answered: Bool) -> UIImage {
        let colors = HippoConfig.shared.colorConfig
        let size = CGSize(width: 20, height: 20)
        let filled = on && (multi || answered)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let rect = CGRect(origin: .zero, size: size)
            let shape: (CGRect) -> UIBezierPath = { r in
                multi ? UIBezierPath(roundedRect: r, cornerRadius: 6) : UIBezierPath(ovalIn: r)
            }
            if filled {
                colors.hippoAccent.setFill()
                shape(rect).fill()
                let check = UIBezierPath()
                check.move(to: CGPoint(x: 5.5, y: 10.4))
                check.addLine(to: CGPoint(x: 8.7, y: 13.6))
                check.addLine(to: CGPoint(x: 14.6, y: 6.8))
                check.lineWidth = 2.4
                check.lineCapStyle = .round
                check.lineJoinStyle = .round
                colors.hippoOnAccent.setStroke()
                check.stroke()
            } else if on {
                colors.hippoAccent.setFill()
                UIBezierPath(ovalIn: rect).fill()
                colors.hippoSurface.setFill()
                UIBezierPath(ovalIn: rect.insetBy(dx: 6, dy: 6)).fill()
            } else {
                colors.hippoSurface.setFill()
                let ring = shape(rect.insetBy(dx: 0.75, dy: 0.75))
                ring.fill()
                ring.lineWidth = 1.5
                colors.hippoTextMuted.withAlphaComponent(0.45).setStroke()
                ring.stroke()
            }
        }
    }
}
