//
//  CardListCell.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class CardListCell: UICollectionViewCell {

    @IBOutlet weak var imageView: HippoImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var labelContainterView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    func setTheme() {
        labelContainterView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        titleLabel.textColor = .white
        descriptionLabel.textColor = .darkText
        bgView.hippoCornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        bgView.backgroundColor = .white
        bottomContainer.backgroundColor = .white

    }
}
extension CardListCell {
    func set(card: MessageCard) {
        
//        descriptionLabel.isHidden = card.description.isEmpty
        descriptionLabel.text = "Unable to satisfy constraints.Probably at least one of the constraints in the following list is one you don't want"//card.description
        
        titleLabel.text = card.title
        let placeholder: UIImage? = UIImage(named: "placeholderImg", in: FuguFlowManager.bundle, compatibleWith: nil)
        imageView.setImage(resource: card.image, placeholder: placeholder)
    }
}
